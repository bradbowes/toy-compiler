unit desc_nodes;

interface

uses symbols, nodes, field_nodes;

type
   type_desc_node = ^type_desc_node_t;
   type_desc_node_t = object(node_t)
   end;


   named_desc_node = ^named_desc_node_t;
   named_desc_node_t = object(type_desc_node_t)
      name: symbol;
   end;


   record_desc_node = ^record_desc_node_t;
   record_desc_node_t = object(type_desc_node_t)
      fields: field_list;
   end;
   

   array_desc_node = ^array_desc_node_t;
   array_desc_node_t = object(type_desc_node_t)
      base: symbol;
   end;
   

function make_named_desc_node(name: symbol; line, col: longint): named_desc_node;
function make_record_desc_node(fields: field_list; line, col: longint): record_desc_node;
function make_array_desc_node(base: symbol; line, col: longint): array_desc_node;

implementation

function make_named_desc_node(
      name: symbol; line, col: longint): named_desc_node;
var
   n: named_desc_node;
begin
   new(n, init(line, col));
   n^.node_type := named_desc_nd;
   n^.name := name;
   make_named_desc_node := n;
end;   


function make_record_desc_node(
      fields: field_list; line, col: longint): record_desc_node;
var
   n: record_desc_node;
begin
   new(n, init(line, col));
   n^.node_type := record_desc_nd;
   n^.fields := fields;
   make_record_desc_node := n;
end;


function make_array_desc_node(
      base: symbol; line, col: longint): array_desc_node;
var
   n: array_desc_node;
begin
   new(n, init(line, col));
   n^.node_type := array_desc_nd;
   n^.base := base;
   make_array_desc_node := n;
end;


end.