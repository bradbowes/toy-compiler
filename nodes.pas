unit nodes;
interface

type
   node_type = (assign_nd, funcall_nd, proccall_nd, return_nd,
                simple_var_nd, field_var_nd, indexed_var_nd,
                integer_nd, string_nd, boolean_nd, nil_nd, 
                type_decl_nd, var_decl_nd, fun_decl_nd, decl_ls,
                named_desc_nd, record_desc_nd, array_desc_nd,
                unary_op_nd, binary_op_nd,
                field_nd, field_ls, if_else_nd, if_nd,
                while_nd, for_nd, break_nd, sequence_nd, let_nd,
                exp_ls, stm_ls);

   node = ^node_t;
   node_t = object
      line, col: longint;
      node_type: node_type;
      constructor init (l, c: longint);
      function display: string; virtual;
   end;


   exp_node = ^exp_node_t;
	exp_node_t = object(node_t)
   end;


   exp_list = ^exp_list_t;
   exp_list_t = object(node_t)
      exp: exp_node;
      next: exp_list;
      function display: string; virtual;
   end;


   stm_node = ^stm_node_t;
   stm_node_t = object(node_t)
   end;
   

   stm_list = ^stm_list_t;
   stm_list_t = object(node_t)
      stm: stm_node;
      next: stm_list;
      function display: string; virtual;
   end;


function make_exp_list(exp: exp_node): exp_list;
function append_exp_list(list: exp_list; exp: exp_node): exp_list;
function make_stm_list(stm: stm_node): stm_list;
function append_stm_list(list: stm_list; stm: stm_node): stm_list;


implementation

constructor node_t.init(l, c: longint);
begin
   self.line := l;
   self.col := c;
end;


function node_t.display: string;
var
   s: string;
begin
   str(self.node_type, s);
   display := '<' + s + '>';
end;


function make_exp_list(exp: exp_node): exp_list;
var
   l: exp_list;
begin
   new(l, init(exp^.line, exp^.col));
   l^.node_type := exp_ls;
   l^.exp := exp;
   make_exp_list := l;
end;


function append_exp_list(list: exp_list; exp: exp_node): exp_list;
var
   l, e: exp_list;
begin
   l := make_exp_list(exp);
   e := list;
   while e^.next <> nil do
      e := e^.next;
   e^.next := l;
   append_exp_list := list;
end;


function exp_list_t.display: string;
var
   output: string;
begin
   output := self.exp^.display;
   if self.next <> nil then
      output := output + ', ' + self.next^.display;
   display := output;
end;
        

function make_stm_list(stm: stm_node): stm_list;
var
   l: stm_list;
begin
   new(l, init(stm^.line, stm^.col));
   l^.node_type := stm_ls;
   l^.stm := stm;
   make_stm_list := l;
end;


function append_stm_list(list: stm_list; stm: stm_node): stm_list;
var
   l, e: stm_list;
begin
   l := make_stm_list(stm);
   e := list;
   if e^.next <> nil then
      e := e^.next;
   e^.next := l;
   append_stm_list := list;
end;


function stm_list_t.display: string;
var
   output: string;
begin
   output := self.stm^.display;
   while self.next <> nil do
      output := output + ', ' + self.next^.display;
   display := output;
end;
        

end.
