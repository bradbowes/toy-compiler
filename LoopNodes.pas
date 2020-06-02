unit LoopNodes;
interface
uses Symbols, Nodes;

type
   PWhileNode = ^TWhileNode;
   TWhileNode = Object(TNode)
      Condition: PNode;
      Body: PNode;
      function Display: String; virtual;
   end;


   PForNode = ^TForNode;
   TForNode = Object(TNode)
      Counter: Symbol;
      Start: PNode;
      Finish: PNode;
      Body: PNode;
      function Display: String; virtual;
   end;


   PBreakNode = ^TBreakNode;
   TBreakNode = Object(TNode)
      function Display: String; virtual;
   end;


function MakeWhileNode(Condition, Body: PNode; Line, Col: LongInt): PWhileNode;
function MakeForNode(
      Counter: Symbol; Start, Finish, body: PNode;
      Line, Col: LongInt): PForNode;
function MakeBreakNode(Line, Col: LongInt): PBreakNode;


implementation

function MakeWhileNode(Condition, Body: PNode; Line, Col: LongInt): PWhileNode;
var
   n: PWhileNode;
begin
   new(n, init(Line, Col));
   n^.Tag := WhileNode;
   n^.Condition := Condition;
   n^.Body := Body;
   MakeWhileNode := n;
end;


function TWhileNode.Display: string;
begin
   Display := 'while ' + Self.Condition^.Display + ' do' + Chr(10) +
              Self.Body^.Display;
end;


function MakeForNode(
      Counter: Symbol; Start, Finish, Body: PNode;
      Line, Col: LongInt): PForNode;
var
   n: PForNode;
begin
   new(n, init(Line, Col));
   n^.Tag := ForNode;
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
              Self.Body^.Display;
end;


function MakeBreakNode(Line, Col: LongInt): PBreakNode;
var n: PBreakNode;
begin
   new(n, init(Line, Col));
   n^.Tag := BreakNode;
   MakeBreakNode := n;
end;


function TBreakNode.Display: String;
begin
   Display := 'break'
end;


end.
