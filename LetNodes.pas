unit LetNodes;
interface
uses Nodes;

type
   PLetNode = ^TLetNode;
   TLetNode = object(TNode)
      Decls: PList;
      Body: PNode;
      function Display: String; virtual;
   end;
         

function MakeLetNode(Decls: PList; Body: PNode; Line, Col: LongInt): PLetNode;
      

implementation

function MakeLetNode(Decls: PList; Body: PNode; Line, Col: LongInt): PLetNode;
var
   n: PLetNode;
begin
   new(n, init(Line, Col));
   n^.Tag := LetNode;
   n^.Decls := Decls;
   n^.Body := Body;      
   MakeLetNode := n;
end;


function TLetNode.Display: String;
begin
   Display := 'let' + chr(10) +
              Self.Decls^.Display + chr(10) +
              'in' + chr(10) +
              Self.Body^.Display + chr(10);
end;


end.
