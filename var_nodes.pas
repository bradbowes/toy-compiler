unit var_nodes;
interface
uses symbols, nodes;
   
type
   var_node = ^var_node_t;
   var_node_t = object(exp_node_t)
   end;


   simple_var_node = ^simple_var_node_t;
   simple_var_node_t = object(var_node_t)
      sym: symbol;
      function display: string; virtual;
   end;   


   field_var_node = ^field_var_node_t;
   field_var_node_t = object(var_node_t)
      variable: var_node;
      field: symbol;
      function display: string; virtual;
   end;


   indexed_var_node = ^indexed_var_node_t;
   indexed_var_node_t = object(var_node_t)
      variable: var_node;
      index: exp_node;
      function display: string; virtual;
   end;

function make_simple_var_node(sym: symbol; line, col: longint): simple_var_node;
function make_field_var_node(
      variable: var_node; field: symbol; line, col: longint): field_var_node;
function make_indexed_var_node(    
      variable: var_node; index: exp_node; line, col: longint): indexed_var_node;
function is_var_node(n: node): boolean;


implementation

function make_simple_var_node(sym: symbol; line, col: longint): simple_var_node;
var
   n: simple_var_node;
begin
   new(n, init(line, col));
   n^.node_type := simple_var_nd;
   n^.sym := sym;
   make_simple_var_node := n;
end;


function simple_var_node_t.display: string;
begin
   display := self.sym^.id;
end;


function make_field_var_node(    
      variable: var_node; field: symbol; line, col: longint): field_var_node;
var
   n: field_var_node;
begin
   new(n, init(line, col));
   n^.node_type := field_var_nd;
   n^.variable := variable;
   n^.field := field;
   make_field_var_node := n;
end;


function field_var_node_t.display: string;
begin
   display := '[<field> ' + self.variable^.display + ' ' + field^.id + ']';
end;


function make_indexed_var_node(    
      variable: var_node; index: exp_node; line, col: longint): indexed_var_node;
var
   n: indexed_var_node;
begin
   new(n, init(line, col));
   n^.node_type := indexed_var_nd;
   n^.variable := variable;
   n^.index := index;
   make_indexed_var_node := n;
end;


function indexed_var_node_t.display: string;
begin
   display := '[<index> ' + self.variable^.display + ' ' + self.index^.display + ']';
end;
 

function is_var_node(n: node): boolean;
begin
   is_var_node := n^.node_type in [simple_var_nd, field_var_nd, indexed_var_nd];
end;


end.
