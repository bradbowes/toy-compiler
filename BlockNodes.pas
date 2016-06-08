unit BlockNodes;
interface
uses Symbols, Nodes;

type
   PBlockNode = ^TBlockNode;
   TBlockNode = object(TNode)
      Decls: PList;
      Body: PList;
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


end.
