unit ObjectNodes;
interface
uses Nodes, Symbols;

type
   PNewObjectNode = ^TNewObjectNode;
   TNewObjectNode = Object(TNode)
      Ty: Symbol;
      function Display: String; virtual;
   end;


   PNewArrayNode = ^TNewArrayNode;
   TNewArrayNode = Object(TNode)
      Ty: PNode;
      Size: PList;
      function Display: String; virtual;
   end;      


function MakeNewObjectNode(Ty: Symbol; Line, Col: LongInt): PNewObjectNode;
function MakeNewArrayNode(Ty: PNode; Size: PList; Line, Col: LongInt): PNewArrayNode;

implementation

function MakeNewObjectNode(Ty: Symbol; Line, Col: LongInt): PNewObjectNode;
var n: PNewObjectNode;
begin
   new(n, init(Line, Col));
   n^.Ty := Ty;
   n^.Tag := NewObjectNode;
   MakeNewObjectNode := n;
end;


function TNewObjectNode.Display: String;
begin
   Display := 'new ' + self.Ty^.Id
end;


function MakeNewArrayNode(Ty: PNode; Size: PList; Line, Col: LongInt): PNewArrayNode;
var
   n: PNewArrayNode;
begin
   new(n, init(Line, Col));
   n^.Ty := Ty;
   n^.Size := Size;
   n^.Tag := NewArrayNode;
   MakeNewArrayNode := n;
end;


function TNewArrayNode.Display: String;
begin
   Display := 'array ' + self.Size^.Display + ' of ' + self.Ty^.Display;
end;


end.