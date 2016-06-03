unit if_nodes;
interface
uses nodes;

type
   if_else_node = ^if_else_node_t;
   if_else_node_t = object(stm_node_t)
      condition: exp_node;
      consequent: stm_node;
      alternative: stm_node;
      function display: string; virtual;
   end;


   if_node = ^if_node_t;
   if_node_t = object(stm_node_t)
      condition: exp_node;
      consequent: stm_node;
      function display: string; virtual;
   end;


function make_if_else_node(
      condition: exp_node; consequent, alternative: stm_node;
      line, col: longint): if_else_node;
function make_if_node(
      condition: exp_node; consequent: stm_node; line, col: longint): if_node;

implementation

function make_if_else_node(
      condition: exp_node; consequent, alternative: stm_node;
      line, col: longint): if_else_node;
var
   n: if_else_node;
begin
   new(n, init(line, col));
   n^.node_type := if_else_nd;
   n^.condition := condition;
   n^.consequent := consequent;
   n^.alternative := alternative;
   make_if_else_node := n;
end;


function if_else_node_t.display: string;
begin
   display := '<if-else>' + chr(10) +
         '<condition>' + self.condition^.display + '</condition>' + chr(10) +
         '<consequent>' + self.consequent^.display + '</consequent>' + chr(10) +
         '<alternative>' + self.alternative^.display + '</alternative>' + chr(10) +
         '</if-else>' + chr(10);
end;
   

function make_if_node(
      condition: exp_node; consequent: stm_node; line, col: longint): if_node;
var
   n: if_node;
begin
   new(n, init(line, col));
   n^.node_type := if_nd;
   n^.condition := condition;
   n^.consequent := consequent;
   make_if_node := n;
end;


function if_node_t.display: string;
begin
   display := '<if>' + chr(10) +
         '<condition>' + self.condition^.display + '</condition>' + chr(10) +
         '<consequent>' + self.consequent^.display + '</consequent>' + chr(10) +
         '</if>' + chr(10);
end;

end.