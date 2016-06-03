unit call_nodes;

interface

uses symbols, nodes, var_nodes;

type
   funcall_node = ^funcall_node_t;
   funcall_node_t = object(exp_node_t)
      fn: var_node;
      args: exp_list;
      function display: string; virtual;
   end;


   proccall_node = ^proccall_node_t;
   proccall_node_t = object(stm_node_t)
      proc: var_node;
      args: exp_list;
      function display: string; virtual;
   end;
   
   
   return_node = ^return_node_t;
   return_node_t = object(stm_node_t)
      value: exp_node;
      function display: string; virtual;
   end;
   

function make_funcall_node(
      fn: var_node; args: exp_list; line, col: longint): funcall_node;
function make_proccall_node(
      proc: var_node; args: exp_list; line, col: longint): proccall_node;
function make_proccall_node(fc: funcall_node): proccall_node;
function make_return_node(value: exp_node; line, col: longint): return_node;

   
implementation

function make_funcall_node(
      fn: var_node; args: exp_list; line, col: longint): funcall_node;
var
   n: funcall_node;
begin;
   new(n, init(line, col));
   n^.node_type := funcall_nd;
   n^.fn := fn;
   n^.args := args;
   make_funcall_node := n;
end;


function funcall_node_t.display: string;
var
   args_display: string;
begin
   if self.args = nil then
      args_display := ''
   else
      args_display := self.args^.display;
      
   display := '[<funccall> ' + self.fn^.display + ' [' + args_display + ']]';
end;


function make_proccall_node(
      proc: var_node; args: exp_list; line, col: longint): proccall_node;
var
   n: proccall_node;
begin;
   new(n, init(line, col));
   n^.node_type := proccall_nd;
   n^.proc := proc;
   n^.args := args;
   make_proccall_node := n;
end;


function make_proccall_node(fc: funcall_node): proccall_node;
begin
   make_proccall_node := make_proccall_node(fc^.fn, fc^.args, fc^.line, fc^.col);
end;


function proccall_node_t.display: string;
var
   args_display: string;
begin
   if self.args = nil then
      args_display := ''
   else
      args_display := self.args^.display;
      
   display := '[<proccall> ' + self.proc^.display + ' [' + args_display + ']]';
end;


function make_return_node(value: exp_node; line, col: longint): return_node;
var
   n: return_node;
begin
   new(n, init(line, col));
   n^.node_type := return_nd;
   n^.value := value;
   make_return_node := n;
end;


function return_node_t.display: string;
begin
   display := '[<return> ' + self.value^.display + ']';
end;


end.
