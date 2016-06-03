unit field_nodes;

interface

uses symbols, nodes;

type
   field_node = ^field_node_t;
   field_node_t = object(node_t)
      name: symbol;
      ty: symbol;
   end;

   field_list = ^field_list_t;
   field_list_t = object(node_t)
      field: field_node;
      next: field_list;
   end;
   

function make_field_node(name, ty: symbol; line, col: longint): field_node;
function make_field_list(field: field_node): field_list;
function append_field_list(list: field_list; field: field_node): field_list;
   

implementation

function make_field_node(name, ty: symbol; line, col: longint): field_node;
var
   n: field_node;
begin
   new(n, init(line, col));
   n^.node_type := field_nd;
   n^.name := name;
   n^.ty := ty;
   make_field_node := n;
end;


function make_field_list(field: field_node): field_list;
var
   l: field_list;
begin
   new(l, init(field^.line, field^.col));
   l^.node_type := field_ls;
   l^.field := field;
   make_field_list := l;
end;


function append_field_list(list: field_list; field: field_node): field_list;
var
   l, e: field_list;
begin
   l := make_field_list(field);
   e := list;
   while e^.next <> nil do
      e := e^.next;
   e^.next := l;
   append_field_list := list;
end;


end.
