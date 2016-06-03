unit assign_nodes;
interface
uses nodes, var_nodes;

type
   assign_node = ^assign_node_t;
   assign_node_t = object(stm_node_t)
      variable: var_node;
      exp: exp_node;
      function display: string; virtual;
   end;

function make_assign_node(
      variable: var_node; exp: exp_node; line, col: longint): assign_node;
   
implementation

function make_assign_node(
      variable: var_node; exp: exp_node; line, col: longint): assign_node;
var n: assign_node;
begin
   new(n, init(line, col));
   n^.node_type := assign_nd;
   n^.variable := variable;
   n^.exp := exp;
   make_assign_node := n;
end;


function assign_node_t.display: string;
begin
   display := '[<assign> ' + self.variable^.display + ' ' + self.exp^.display + ']';
end;


end.