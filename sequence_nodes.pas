unit sequence_nodes;
interface
uses symbols, nodes, decl_nodes;

type
   sequence_node = ^sequence_node_t;
   sequence_node_t = object(stm_node_t)
      list: stm_list;
      function display: string; virtual;
   end;


   let_node = ^let_node_t;
   let_node_t = object(stm_node_t)
      decls: decl_list;
      body: stm_list;
   end;
         

function make_sequence_node(list: stm_list; line, col: longint): sequence_node;
function make_let_node(
      decls: decl_list; body: stm_list; line, col: longint): let_node;
      

implementation

function make_sequence_node(
      list: stm_list; line, col: longint): sequence_node;
var
   n: sequence_node;
begin
   new(n, init(line, col));
   n^.node_type := sequence_nd;
   n^.list := list;
   make_sequence_node := n;
end;


function sequence_node_t.display: string;
var
   s: string;
   ls : stm_list;
begin
   ls := self.list;
   s := '<stm>' + ls^.stm^.display + '</stm>' + chr(10);
   while ls^.next <> nil do
      begin
         ls := ls^.next;
         s := s + '<stm>' + ls^.stm^.display + '</stm>' + chr(10);
      end;
   display := s;
end;   
   

function make_let_node(
      decls: decl_list; body: stm_list; line, col: longint): let_node;
var n: let_node;
begin
   new(n, init(line, col));
   n^.node_type := let_nd;
   n^.decls := decls;
   n^.body := body;      
   make_let_node := n;
end;


end.
