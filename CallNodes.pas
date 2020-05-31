unit CallNodes;

interface

uses Nodes;

type
   PCallNode = ^TCallNode;
   TCallNode = Object(TNode)
      Call: PNode;
      Args: PList;
      function Display: String; virtual;
   end;


function MakeCallNode(
      Call: PNode; Args: PList; Line, Col: LongInt): PCallNode;

   
implementation

function MakeCallNode(
      Call: PNode; Args: PList; Line, Col: LongInt): PCallNode;
var
   n: PCallNode;
begin;
   new(n, init(Line, Col));
   n^.Tag := CallNode;
   n^.Call := Call;
   n^.Args := Args;
   MakeCallNode := n;
end;


function TCallNode.Display: string;
begin
   Display := self.Call^.Display + '(' + self.Args^.Display + ')';
end;


end.
