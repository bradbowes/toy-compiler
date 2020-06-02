unit SequenceNodes;
interface
uses Nodes;

type
   PSequenceNode = ^TSequenceNode;
   TSequenceNode = object(TNode)
      Body: PList;
      function Display: String; virtual;
   end;
         

function MakeSequenceNode(Body: PList; Line, Col: LongInt): PSequenceNode;
      

implementation

function MakeSequenceNode(Body: PList; Line, Col: LongInt): PSequenceNode;
var
   n: PSequenceNode;
begin
   new(n, init(Line, Col));
   n^.Tag := SequenceNode;
   n^.Body := Body;      
   MakeSequenceNode := n;
end;


function TSequenceNode.Display: String;
begin
   Display := '(' + chr(10) +
              Self.Body^.Display + chr(10) +
              ')';
end;


end.
