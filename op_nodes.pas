unit op_nodes;
interface
uses nodes;

type
   op_type = (plus_op, minus_op, mul_op, div_op, mod_op,
              eq_op, ne_op, lt_op, le_op, gt_op, ge_op,
              and_op, or_op, not_op);


   unary_op_node = ^unary_op_node_t;
   unary_op_node_t = object(exp_node_t)
      op: op_type;
      exp: exp_node;
      function display: string; virtual;
   end;


   binary_op_node = ^binary_op_node_t;
   binary_op_node_t = object(exp_node_t)
      op: op_type;
      left: exp_node;
      right: exp_node;
      function display: string; virtual;
   end;

function make_unary_op_node(
      op: op_type; exp: exp_node; line, col: longint): unary_op_node;
function make_binary_op_node(
      op: op_type; left, right: exp_node; line, col: longint): binary_op_node;
   
implementation

function make_unary_op_node(
      op: op_type; exp: exp_node; line, col: longint): unary_op_node;
var
   n: unary_op_node;
begin
   new(n, init(line, col));
   n^.node_type := unary_op_nd;
   n^.op := op;
   n^.exp := exp;
   make_unary_op_node := n;
end;


function unary_op_node_t.display: string;
var
   s: string;
begin
   str(self.op, s);
   display := '[' + s + ' ' + self.exp^.display + ']';
end;


function make_binary_op_node(
      op: op_type; left, right: exp_node; line, col: longint): binary_op_node;
var
   n: binary_op_node;
begin
   new(n, init(line, col));
   n^.node_type := binary_op_nd;
   n^.op := op;
   n^.left := left;
   n^.right := right;
   make_binary_op_node := n;
end;


function binary_op_node_t.display: string;
var
   s: string;
begin
   str(self.op, s);
   display := '[' + s + ' ' + self.left^.display + ' ' + self.right^.display + ']';
end;

end.