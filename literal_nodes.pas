unit literal_nodes;
interface
uses nodes;

type
   integer_node = ^integer_node_t;
   integer_node_t = object(exp_node_t)
      value: integer;
      function display: string; virtual;
   end;


   string_node = ^string_node_t;
   string_node_t = object(exp_node_t)
      value: string;
      function display: string; virtual;
   end;
   

   boolean_node = ^boolean_node_t;
   boolean_node_t = object(exp_node_t)
      value: boolean;
      function display: string; virtual;
   end;
   

   nil_node = ^nil_node_t;
   nil_node_t = object(exp_node_t)
      function display: string; virtual;
   end;


function make_integer_node(value, line, col: longint): integer_node;
function make_string_node(value: string; line, col: longint): string_node;
function make_boolean_node(value: boolean; line, col: longint): boolean_node;
function make_nil_node(line, col: longint): nil_node;

implementation

function make_integer_node(value, line, col: longint): integer_node;
var
   n: integer_node;
begin
   new(n, init(line, col));
   n^.node_type := integer_nd;
   n^.value := value;
   make_integer_node := n;
end;


function integer_node_t.display: string;
var
   s: string;
begin
   str(self.value, s);
   display := s;
end;


function make_string_node(value: string; line, col: longint): string_node;
var
   n: string_node;
begin
   new(n, init(line, col));
   n^.node_type := string_nd;
   n^.value := value;
   make_string_node := n;
end;


function string_node_t.display: string;
begin
   display := '''' + self.value + '''';
end;


function make_boolean_node(
      value: boolean; line, col: longint): boolean_node;
var
   n: boolean_node;
begin
   new(n, init(line, col));
   n^.node_type := boolean_nd;
   n^.value := value;
   make_boolean_node := n;
end;


function boolean_node_t.display: string;
var
   s: string;
begin
   str(self.value, s);
   display := s;
end;


function make_nil_node(line, col: longint): nil_node;
var
   n: nil_node;
begin
   new(n, init(line, col));
   n^.node_type := nil_nd;
   make_nil_node := n;
end;


function nil_node_t.display: string;
begin
   display := 'nil';
end;


end.
