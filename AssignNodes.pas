unit AssignNodes;

interface
uses Nodes;

type 
   PAssignNode = ^TAssignNode;
   TAssignNode = object(TNode)
      Variable: PNode;
      Expression: PNode;
      function Display: string; virtual;
   end;


function MakeAssignNode(
      Variable: PNode; Expression: PNode; Line, Col: LongInt): PAssignNode;


implementation

function MakeAssignNode(
      Variable: PNode; Expression: PNode; line, col: longint): PAssignNode;
var n: PAssignNode;
begin
   new(n, init(Line, Col));
   n^.Tag := AssignNode;
   n^.Variable := Variable;
   n^.Expression := Expression;
   MakeAssignNode := n;
end;


function TAssignNode.Display: string;
begin
   Display := self.Variable^.Display + ' := ' + self.Expression^.Display;
end;


end.
