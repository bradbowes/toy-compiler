unit CallNodes;

interface

uses Symbols, Nodes;

type
   PCallNode = ^TCallNode;
   TCallNode = Object(TNode)
      Call: Symbol;
      Args: PList;
      function Display: String; virtual;
   end;


function MakeCallNode(
      Call: Symbol; Args: PList; Line, Col: LongInt): PCallNode;

   
implementation

function MakeCallNode(
      Call: Symbol; Args: PList; Line, Col: LongInt): PCallNode;
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
   Display := self.Call^.Id + '(' + self.Args^.Display + ')';
end;


end.
