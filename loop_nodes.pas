unit loop_nodes;
interface
uses symbols, nodes;

type
   while_node = ^while_node_t;
   while_node_t = object(stm_node_t)
      condition: exp_node;
      body: stm_node;
      function display: string; virtual;
   end;


   for_node = ^for_node_t;
   for_node_t = object(stm_node_t)
      counter: symbol;
      start: exp_node;
      finish: exp_node;
      body: stm_node;
      function display: string; virtual;
   end;


   break_node = ^break_node_t;
   break_node_t = object(stm_node_t)
      function display: string; virtual;
   end;


function make_while_node(
      condition: exp_node; body: stm_node; line, col: longint): while_node;
function make_for_node(
      counter: symbol; start, finish: exp_node; body: stm_node;
      line, col: longint): for_node;
function make_break_node(line, col: longint): break_node;


implementation

function make_while_node(
      condition: exp_node; body: stm_node; line, col: longint): while_node;
var
   n: while_node;
begin
   new(n, init(line, col));
   n^.node_type := while_nd;
   n^.condition := condition;
   n^.body := body;
   make_while_node := n;
end;


function while_node_t.display: string;
begin
   display := '<while> ' + chr(10) +
              '<condition>' + self.condition^.display + '</condition>' + chr(10) +
              '<body>' + self.body^.display + '</body>' + chr(10) +
              '</while>' + chr(10);
end;


function make_for_node(
      counter: symbol; start, finish: exp_node; body: stm_node;
      line, col: longint): for_node;
var
   n: for_node;
begin
   new(n, init(line, col));
   n^.node_type := for_nd;
   n^.counter := counter;
   n^.start := start;
   n^.finish := finish;
   n^.body := body;
   make_for_node := n;
end;


function for_node_t.display: string;
begin
   display := '<for>' + chr(10) +
         '<counter>' + self.counter^.id + '</counter>' + chr(10) +
         '<start>' + self.start^.display + '</start>' + chr(10) +
         '<finish>' + self.finish^.display + '</finish>' + chr(10) +
         '<body>' + self.body^.display + '</body>' + chr(10) +
         '</for>' + chr(10);
end;


function make_break_node(line, col: longint): break_node;
var n: break_node;
begin
   new(n, init(line, col));
   n^.node_type := break_nd;
   make_break_node := n;
end;


function break_node_t.display: string;
begin
   display := '<break />'
end;


end.