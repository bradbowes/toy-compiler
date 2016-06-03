unit scanners;

interface

uses utils;

type 
   token_tok = (tok_colon, tok_comma, tok_semicolon,
                tok_dot, tok_lparen, tok_rparen,
                tok_lbracket, tok_rbracket, tok_lbrace,
                tok_rbrace, tok_assign,
                tok_and, tok_or, tok_not, tok_eq, tok_ne,
                tok_lt, tok_gt, tok_le, tok_ge,
                tok_plus, tok_minus, tok_mul, tok_div,
                tok_mod, tok_var, tok_type, tok_array,
                tok_of, tok_function, tok_if, tok_then,
                tok_elseif, tok_else, tok_while, tok_do,
                tok_for, tok_break, tok_to, tok_begin, tok_new,
                tok_nil, tok_true, tok_false,
                tok_let, tok_in, tok_end, tok_return,
                tok_string, tok_number, tok_id, tok_eof,
                tok_comment);

   token_t = record
      tok: token_tok;
      val: string;
      line, col: longint;
   end;

   token =  ^token_t;

   scanner_t = record
      open: boolean;
      src: text;
      ch: char;
      x, y: longint;
   end;

   scanner = ^scanner_t;

function make_scanner(filename: string): scanner;
function scan(s: scanner): token;

implementation

function scan(s: scanner): token;

var t: token;

   procedure nextch;
   begin
      if s^.open then
         if eof(s^.src) then
            begin
               s^.ch := chr(4);
               close(s^.src);
               s^.open := false;
            end
         else
            begin
               read(s^.src, s^.ch);
               s^.x := s^.x + 1;
            end
      else
         err('Read past end of file', t^.line, t^.col);
   end;


   procedure push_val(c: char);
   begin
      t^.val := t^.val + c;
      nextch;
   end;


   procedure advance(tn: token_tok);
   begin
      push_val(s^.ch);
      t^.tok := tn;
   end;


   procedure skip_white;

      procedure newline;
      begin
         s^.y := s^.y + 1;
         s^.x := 0;
         nextch
      end;
   
   begin
      while s^.ch in [' ', chr(9), chr(13), chr(10)] do
         begin
            case s^.ch of 
               ' ', chr(9): nextch;
               chr(10): newline;
               chr(13):
                  begin
                     newline;
                     if s^.ch = chr(10) then nextch;
                  end;
            end;
      end;
   end;


   procedure skip_comment;
   begin
      t^.val := '/*';
      repeat
         repeat
            nextch;
            t^.val := t^.val + s^.ch;
         until s^.ch = '*';
         nextch;
      until s^.ch = '/';
      nextch;
      t^.val := t^.val + '/';
      t^.tok := tok_comment;
   end;


   procedure get_string;
   begin
      nextch;
      repeat
         if s^.ch = '''' then
            begin
               nextch;
               if s^.ch = '''' then
                  push_val('''')
               else
                  break;
            end
         else
            push_val(s^.ch);
      until false;
      t^.tok := tok_string;
   end;


   procedure get_number;
   begin
      while s^.ch in ['0'..'9'] do
         push_val(s^.ch);
      t^.tok := tok_number;
   end;


   procedure get_id;
   begin
      while s^.ch in ['a'..'z', 'A'..'Z', '0'..'9', '_'] do
         push_val(s^.ch);
      case t^.val of 
         'and': t^.tok := tok_and;
         'array': t^.tok := tok_array;
         'begin': t^.tok := tok_begin;
         'break': t^.tok := tok_break;
         'do': t^.tok := tok_do;
         'else': t^.tok := tok_else;
         'elseif': t^.tok := tok_elseif;
         'end': t^.tok := tok_end;
         'false': t^.tok := tok_false;
         'for': t^.tok := tok_for;
         'function': t^.tok := tok_function;
         'if': t^.tok := tok_if;
         'in': t^.tok := tok_in;
         'let': t^.tok := tok_let;
         'new': t^.tok := tok_new;
         'nil': t^.tok := tok_nil;
         'not': t^.tok := tok_not;
         'of': t^.tok := tok_of;
         'or': t^.tok := tok_or;
         'return': t^.tok := tok_return;
         'then': t^.tok := tok_then;
         'to': t^.tok := tok_to;
         'true': t^.tok := tok_true;
         'type': t^.tok := tok_type;
         'var': t^.tok := tok_var;
         'while': t^.tok := tok_while;
      else
         t^.tok := tok_id;
      end;
   end;

begin
   skip_white;
   new(t);
   t^.val := '';
   t^.col := s^.x;
   t^.line := s^.y;
   if not s^.open then
       t^.tok := tok_eof
   else
      begin
         case s^.ch of 
            ',': advance(tok_comma);
            ';': advance(tok_semicolon);
            '.': advance(tok_dot);
            '(': advance(tok_lparen);
            ')': advance(tok_rparen);
            '[': advance(tok_lbracket);
            ']': advance(tok_rbracket);
            '{': advance(tok_lbrace);
            '}': advance(tok_rbrace);
            '+': advance(tok_plus);
            '-': advance(tok_minus);
            '*': advance(tok_mul);
            '/':
               begin
                  push_val('/');
                  if s^.ch = '*' then skip_comment
                  else t^.tok := tok_div;
               end;
            '%': advance(tok_mod);
            '=': advance(tok_eq);
            '<':
               begin
                  push_val('<');
                  case s^.ch of 
                     '>': advance(tok_ne);
                     '=': advance(tok_le);
                     else
                        t^.tok := tok_lt;
                  end;
               end;
            '>':
               begin
                  push_val('>');
                  if s^.ch = '=' then advance(tok_ge)
                  else t^.tok := tok_gt;
               end;
            ':':
               begin
                  push_val(':');
                  if s^.ch = '=' then advance(tok_assign)
                  else t^.tok := tok_colon;
               end;
            '0'..'9': get_number;
            '''': get_string;
            'a'..'z', 'A'..'Z': get_id;
            else
               err('Illegal token ''' + s^.ch + '''', t^.line, t^.col);
         end;
      end;
   scan := t;
end;


function make_scanner(filename: string): scanner;
var s: scanner;
begin
   new(s);
   assign(s^.src, filename);
   reset(s^.src);
   s^.open := true;
   read(s^.src, s^.ch);
   s^.x := 1;
   s^.y := 1;
   make_scanner := s;
end;

end.
