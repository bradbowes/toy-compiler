unit decl_nodes;

interface

uses symbols, nodes, field_nodes, desc_nodes;

type
   decl_node = ^decl_node_t;
   decl_node_t = object(node_t)
   end;


   type_decl_node = ^type_decl_node_t;
   type_decl_node_t = object(decl_node_t)
      name: symbol;
      ty: type_desc_node;
   end;


   var_decl_node = ^var_decl_node_t;
   var_decl_node_t = object(decl_node_t)
      name: symbol;
      ty: symbol;
      initializer: exp_node;
   end;


   fun_decl_node = ^fun_decl_node_t;
   fun_decl_node_t = object(decl_node_t)
      name: symbol;
      params: field_list;
      ty: symbol;
      body: exp_node;
   end;
   

   decl_list = ^decl_list_t;
   decl_list_t = object(node_t)
      decl: decl_node;
      next: decl_list;
   end;


function make_type_decl_node(
      name: symbol; ty: type_desc_node; line, col: longint): type_decl_node;
function make_var_decl_node(
      name, ty: symbol; initializer: exp_node; line, col: longint): var_decl_node;
function make_fun_decl_node(
      name: symbol; params: field_list; ty: symbol; body: exp_node;
      line, col: longint): fun_decl_node;
function make_decl_list(decl: decl_node): decl_list;
function append_decl_list(list: decl_list; decl: decl_node): decl_list;


implementation

function make_type_decl_node(
      name: symbol; ty: type_desc_node; line, col: longint): type_decl_node;
var
   n: type_decl_node;
begin
   new(n, init(line, col));
   n^.node_type := type_decl_nd;
   n^.name := name;
   n^.ty := ty;
   make_type_decl_node := n;
end;
   

function make_var_decl_node(
      name, ty: symbol; initializer: exp_node; line, col: longint): var_decl_node;
var
   n: var_decl_node;
begin
   new(n, init(line, col));
   n^.node_type := var_decl_nd;
   n^.name := name;
   n^.ty := ty;
   n^.initializer := initializer;
   make_var_decl_node := n;
end;
   

function make_fun_decl_node(
      name: symbol; params: field_list; ty: symbol; body: exp_node;
      line, col: longint): fun_decl_node;
var
   n: fun_decl_node;
begin
   new(n, init(line, col));
   n^.node_type := fun_decl_nd;
   n^.name := name;
   n^.params := params;
   n^.ty := ty;
   n^.body := body;
   make_fun_decl_node := n;
end;
      

function make_decl_list(decl: decl_node): decl_list;
var
   l: decl_list;
begin
   new(l, init(decl^.line, decl^.col));
   l^.node_type := decl_ls;
   l^.decl := decl;
   make_decl_list := l;
end;


function append_decl_list(list: decl_list; decl: decl_node): decl_list;
var
   l, e: decl_list;
begin
   l := make_decl_list(decl);
   e := list;
   while e^.next <> nil do
      e := e^.next;
   e^.next := l;
   append_decl_list := list;
end;


end.
