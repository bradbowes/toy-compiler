unit parsers;
interface

uses
   utils, scanners, symbols, nodes, literal_nodes, var_nodes,
   assign_nodes, op_nodes, if_nodes, loop_nodes, call_nodes,
   field_nodes, decl_nodes, sequence_nodes, bindings;

function parse(file_name: string): stm_node;


implementation

function parse(file_name: string): stm_node;
var
   s: scanner;
   t: token;
   
   procedure next;
   begin
      t := scan(s);
      while t^.tok = tok_comment do
         t := scan(s);
   end;

   function get_exp: exp_node; forward;
   function get_sequence: stm_node; forward;
   
   function get_exp_list: exp_list;
   var
      exp: exp_node;
      ls: exp_list;
   begin
      ls := nil;
      if t^.tok <> tok_rparen then
         begin
            exp := get_exp;
            ls := make_exp_list(exp);
            while t^.tok = tok_comma do
               begin
                  next;
                  exp := get_exp;
                  ls := append_exp_list(ls, exp);
               end;
         end;               
      get_exp_list := ls;
   end;

   function get_var(variable: var_node): exp_node;
   var
      val: string;
      n: node;
      line, col: longint;
   begin
      get_var := nil;
      case t^.tok of
         tok_dot:
            begin
               next;
               if t^.tok = tok_id then
                  begin
                     val := t^.val;
                     line := t^.line;
                     col := t^.col;
                     next;
                     get_var := get_var(
                           make_field_var_node(
                                  variable,
                                  intern(val),
                                  line,
                                  col));
                  end
               else
                  err('Expected field identifier', t^.line, t^.col);
            end;
         tok_lbracket:
            begin
               next;
               line := t^.line;
               col := t^.col;
               n := get_exp();
               if t^.tok = tok_rbracket then
                  begin
                     next;
                     get_var := get_var(
                           make_indexed_var_node(
                                 variable,
                                 exp_node(n),
                                 line,
                                 col));
                  end
               else
                  err('Expected '']''', t^.line, t^.col);
            end;
         tok_lparen:
            begin
               next;
               line := t^.line;
               col := t^.col;
               n := get_exp_list;
               if t^.tok = tok_rparen then
                  begin
                     next;
                     get_var := make_funcall_node(variable, exp_list(n), line, col);
                  end
               else
                  err('Expected '')''', t^.line, t^.col);
               
            end;
         else
            get_var := variable;
      end
   end;
                     
   
   function get_factor: exp_node;
   var
      line, col: longint;
      val: string;
   begin
      line := t^.line;
      col := t^.col;
      val := t^.val;
      get_factor := nil;
      case t^.tok of
         tok_number:
            begin
               next;
               get_factor := make_integer_node(atoi(val, line, col), line, col);
            end;
         tok_string:
            begin
               next;
               get_factor := make_string_node(val, line, col);
            end;
         tok_true:
            begin
               next;
               get_factor := make_boolean_node(true, line, col);
            end;
         tok_false:
            begin
               next;
               get_factor := make_boolean_node(false, line, col);
            end;
         tok_nil:
            begin
               next;
               get_factor := make_nil_node(line, col);
            end;
         tok_minus:
            begin
               next;
               get_factor := make_unary_op_node(minus_op, get_exp(), line, col);
            end;
         tok_id:
            begin
               next;
               get_factor := get_var(make_simple_var_node(intern(val), line, col));
            end;
         else
            begin
               next;
               err('Expected value, got ''' + val + '''', line, col);
            end;
      end;
   end; { get_factor }


   function get_product: exp_node;
   var
      line, col: longint;
      
      function helper(left: exp_node): exp_node;
      
         function make_mul_node(op: op_type): binary_op_node;
         begin
            next;
            make_mul_node := make_binary_op_node(op, left, get_factor, line, col);
         end;
      
      var tok: token;
      begin
         tok := t;
         case tok^.tok of
            tok_mul: helper := helper(make_mul_node(mul_op));
            tok_div: helper := helper(make_mul_node(div_op));
            tok_mod: helper := helper(make_mul_node(mod_op));
            else helper := left;
         end;
      end;
      
   begin
      line := t^.line;
      col := t^.col;
      get_product := helper(get_factor);
   end; { get_product }


   function get_sum: exp_node;
   var
      line, col: longint;
      
      function helper(left: exp_node): exp_node;
      
         function make_add_node(op: op_type): binary_op_node;
         begin
            next;
            make_add_node := make_binary_op_node(op, left, get_product, line, col);
         end;
      
      var tok: token;
      begin
         tok := t;
         case tok^.tok of
            tok_plus: helper := helper(make_add_node(plus_op));
            tok_minus: helper := helper(make_add_node(minus_op));
            else helper := left;
         end;
      end;
      
   begin
      line := t^.line;
      col := t^.col;
      get_sum := helper(get_product);
   end; { get_sum }


   function get_bool: exp_node;
   var
      line, col: longint;
      left: exp_node;
      tok: token;
      
      function make_compare_node(op: op_type): binary_op_node;
      begin
         next;
         make_compare_node := make_binary_op_node(op, left, get_sum, line, col);
      end;
      
   begin
      line := t^.line;
      col := t^.col;
      left := get_sum;
      tok := t;
      case tok^.tok of
         tok_eq: get_bool := make_compare_node(eq_op);
         tok_ne: get_bool := make_compare_node(ne_op);
         tok_lt: get_bool := make_compare_node(lt_op);
         tok_le: get_bool := make_compare_node(le_op);
         tok_gt: get_bool := make_compare_node(gt_op);
         tok_ge: get_bool := make_compare_node(ge_op);
         else get_bool := left;
      end;
   end;
   
   
   function get_negation: exp_node;
   var
      line, col: longint;
   begin
      line := t^.line;
      col := t^.col;
      if t^.tok = tok_not then
         begin
            next;
            get_negation := make_unary_op_node(not_op, get_bool, line, col);
         end
      else
         get_negation := get_bool
   end;
   

   function get_conjunction: exp_node;
   var
      line, col: longint;
      
      function helper(left: exp_node): exp_node;
      var tok: token;
      begin
         tok := t;

         if tok^.tok = tok_and then
            begin
               next;
               helper := helper(make_binary_op_node(
                     and_op, left, get_negation, line, col));
            end
         else
            helper := left;
      end;
      
   begin
      line := t^.line;
      col := t^.col;
      get_conjunction := helper(get_negation);
   end; { get_conjunction }


   function get_exp: exp_node;
   var
      line, col: longint;
      
      function helper(left: exp_node): exp_node;
      var tok: token;
      begin
         tok := t;

         if tok^.tok = tok_or then
            begin
               next;
               helper := helper(
                     make_binary_op_node(or_op, left, get_conjunction, line, col));
            end
         else
            helper := left;
      end;
      
   begin
      line := t^.line;
      col := t^.col;
      get_exp := helper(get_conjunction);
   end; { get_exp }


   function get_if: stm_node;
   var
      condition: exp_node;
      consequent, alternative: stm_node;
      line, col: longint;
   begin
      get_if := nil;
      line := t^.line;
      col := t^.col;
      next;
      condition := get_exp;
      if t^.tok = tok_then then
         begin
            next;
            consequent := get_sequence;
            if t^.tok = tok_else then
               begin
                  next;
                  alternative := get_sequence;
                  get_if := make_if_else_node(
                        condition, consequent, alternative, line, col);
               end
            else
               get_if := make_if_node(condition, consequent, line, col);
            if t^.tok = tok_end then
               next
            else
               err('Expected ''end'', got ''' + t^.val + '''', t^.line, t^.col);
         end
      else
         err('Expected ''then'', got ''' + t^.val + '''', t^.line, t^.col);
   end; { get_if }


   function get_while: stm_node;
   var
      condition: exp_node;
      line, col: longint;
   begin
      get_while := nil;
      line := t^.line;
      col := t^.col;
      next;
      condition := get_exp;
      if t^.tok = tok_do then
         begin
            next;
            get_while := make_while_node(condition, get_sequence, line, col);
            if t^.tok = tok_end then
               next
            else
               err('Expected ''end'', got ''' + t^.val + '''', t^.line, t^.col);
         end
      else
         err('Expected ''do'', got ''' + t^.val + '''', t^.line, t^.col);
   end;


   function get_for: stm_node;
   var
      counter: symbol;
      start, finish: exp_node;
      line, col: longint;
   begin
      get_for := nil;
      line := t^.line;
      col := t^.col;
      next;
      if t^.tok = tok_id then
         begin
            counter := intern(t^.val);
            next;
            if t^.tok = tok_assign then
               begin
                  next;
                  start := get_exp;
                  if t^.tok = tok_to then
                     begin
                        next;
                        finish := get_exp;
                        if t^.tok = tok_do then
                           begin
                              next;
                              get_for := make_for_node(
                                    counter, start, finish, get_sequence, line, col);
                              if t^.tok = tok_end then
                                 next
                              else
                                 err('Expected ''end'', got ''' + t^.val + '''',
                                     t^.line, t^.col); 
                           end
                        else
                           err('Expected ''do'', got ''' + t^.val + '''',
                                 t^.line, t^.col);
                     end
                  else
                     err('Expected ''to'', got ''' + t^.val + '''', t^.line, t^.col);
               end
            else
               err('Expected '':='', got ''' + t^.val + '''', t^.line, t^.col);
         end
      else
         err('Expected variable, got ''' + t^.val + '''', t^.line, t^.col);
   end;


   function get_break: stm_node;
   var
      line, col: longint;
   begin
      line := t^.line;
      col := t^.col;
      next;
      get_break := make_break_node(line, col);
   end;
   
   
   function get_return: stm_node;
   var
      line, col: longint;
   begin
      line := t^.line;
      col := t^.col;
      next;
      get_return := make_return_node(get_exp, line, col);
   end;


   function get_assignment(left: var_node): stm_node;
   begin
      get_assignment := nil;
      if t^.tok = tok_assign then
         begin
            next;
            get_assignment := make_assign_node(
                  left, get_exp, left^.line, left ^.col);
         end
      else
        err('Expected assignment or procedure call', left^.line, left^.col)
   end;
   
   
   function get_stm: stm_node;
   var
      exp: exp_node;
   begin
      get_stm := nil;
      case t^.tok of
         tok_if: get_stm := get_if;
         tok_while: get_stm := get_while;
         tok_for: get_stm := get_for;
         tok_break: get_stm := get_break;
         tok_return: get_stm := get_return;
         tok_id:
            begin
               exp := get_exp;
               if is_var_node(exp) then
                  get_stm := get_assignment(var_node(exp))
               else if exp^.node_type = funcall_nd then
                  get_stm := make_proccall_node(funcall_node(exp))
               else
                  err('Illegal expression', exp^.line, exp^.col);
            end;
         else
            err('Expected statement, got ''' + t^.val + '''', t^.line, t^.col);
      end;
      if t^.tok = tok_semicolon then
         next;
   end; { get_exp }


   function get_sequence: stm_node;
   var
      list: stm_list;
   begin
      list := make_stm_list(get_stm);
      while t^.tok in [tok_if, tok_while, tok_for, tok_break,
                       tok_return, tok_id, tok_let] do
         list := append_stm_list(list, get_stm);
      get_sequence := make_sequence_node(list, list^.line, list^.col);
   end;
            

var stm: stm_node;
begin
   s := make_scanner(file_name);
   next;
   stm := get_stm;
   writeln(stm^.display);
   parse := stm;
end; { parse }


end.
