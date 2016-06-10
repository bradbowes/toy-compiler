unit BlockNodes;
interface
uses Symbols, Nodes;

type
   PBlockNode = ^TBlockNode;
   TBlockNode = object(TNode)
      Decls: PList;
      Body: PList;
      function Display: String; virtual;
   end;
         

function MakeBlockNode(Decls, Body: PList; Line, Col: LongInt): PBlockNode;
      

implementation

function MakeBlockNode(Decls, Body: PList; Line, Col: LongInt): PBlockNode;
var
   n: PBlockNode;
begin
   new(n, init(Line, Col));
   n^.Kind := BlockNode;
   n^.Decls := Decls;
   n^.Body := Body;      
   MakeBlockNode := n;
end;


function TBlockNode.Display: String;
begin
   Display := '<declartions>' + chr(10) +
              Self.Decls^.Display +
              '</declarations>' + chr(10) +
              '<body>' + chr(10) +
              Self.Body^.Display +
              '</body>' + chr(10);
end;


end.
