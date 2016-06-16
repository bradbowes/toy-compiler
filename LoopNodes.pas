unit LoopNodes;
interface
uses Symbols, Nodes;

type
   PWhileNode = ^TWhileNode;
   TWhileNode = Object(TNode)
      Condition: PNode;
      Body: PList;
      function Display: String; virtual;
   end;


   PForNode = ^TForNode;
   TForNode = Object(TNode)
      Counter: Symbol;
      Start: PNode;
      Finish: PNode;
      Body: PList;
      function Display: String; virtual;
   end;


   PBreakNode = ^TBreakNode;
   TBreakNode = Object(TNode)
      function Display: String; virtual;
   end;


function MakeWhileNode(Condition: PNode; Body: PList; Line, Col: LongInt): PWhileNode;
function MakeForNode(
      Counter: Symbol; Start, Finish: PNode; body: PList;
      Line, Col: LongInt): PForNode;
function MakeBreakNode(Line, Col: LongInt): PBreakNode;


implementation

function MakeWhileNode(Condition: PNode; Body: PList; Line, Col: LongInt): PWhileNode;
var
   n: PWhileNode;
begin
   new(n, init(Line, Col));
   n^.Kind := WhileNode;
   n^.Condition := Condition;
   n^.Body := Body;
   MakeWhileNode := n;
end;


function TWhileNode.Display: string;
begin
   Display := 'while ' + Self.Condition^.Display + ' do' + Chr(10) +
              Self.Body^.Display +
              'end';
end;


function MakeForNode(
      Counter: Symbol; Start, Finish: PNode; Body: PList;
      Line, Col: LongInt): PForNode;
var
   n: PForNode;
begin
   new(n, init(Line, Col));
   n^.Kind := ForNode;
   n^.Counter := Counter;
   n^.Start := Start;
   n^.Finish := Finish;
   n^.Body := Body;
   MakeForNode := n;
end;


function TForNode.Display: String;
begin
   Display := 'for ' + Self.Counter^.Id + ' := ' +
              Self.Start^.Display + ' to ' +
              Self.Finish^.Display + ' do' + Chr(10) +
              Self.Body^.Display +
              'end'
end;


function MakeBreakNode(Line, Col: LongInt): PBreakNode;
var n: PBreakNode;
begin
   new(n, init(Line, Col));
   n^.Kind := BreakNode;
   MakeBreakNode := n;
end;


function TBreakNode.Display: String;
begin
   Display := '<break />'
end;


end.