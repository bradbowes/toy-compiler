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


   PReturnNode = ^TReturnNode;
   TReturnNode = Object(TNode)
      Value: PNode;
      function Display: String; virtual;
   end;
   

function MakeCallNode(
      Call: PNode; Args: PList; Line, Col: LongInt): PCallNode;
function MakeReturnNode(Value: PNode; Line, Col: LongInt): PReturnNode;

   
implementation

function MakeCallNode(
      Call: PNode; Args: PList; Line, Col: LongInt): PCallNode;
var
   n: PCallNode;
begin;
   new(n, init(Line, Col));
   n^.Kind := CallNode;
   n^.Call := Call;
   n^.Args := Args;
   MakeCallNode := n;
end;


function TCallNode.Display: string;
begin
   Display := '[<funccall> ' + self.Call^.Display + ' [' + self.Args^.Display + ']]';
end;


function MakeReturnNode(Value: PNode; Line, Col: LongInt): PReturnNode;
var
   n: PReturnNode;
begin
   new(n, init(Line, Col));
   n^.Kind := ReturnNode;
   n^.Value := Value;
   MakeReturnNode := n;
end;


function TReturnNode.Display: string;
begin
   Display := '[<return> ' + self.Value^.Display + ']';
end;


end.
