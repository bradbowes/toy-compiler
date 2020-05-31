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
      Ty: Symbol;
      Size: PNode;
      Initializer: PNode;
      function Display: String; virtual;
   end;      


function MakeNewObjectNode(Ty: Symbol; Line, Col: LongInt): PNewObjectNode;
function MakeNewArrayNode(Ty: Symbol; Size, Initializer: PNode; Line, Col: LongInt): PNewArrayNode;

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


function MakeNewArrayNode(Ty: Symbol; Size, Initializer: PNode; Line, Col: LongInt): PNewArrayNode;
var
   n: PNewArrayNode;
begin
   new(n, init(Line, Col));
   n^.Ty := Ty;
   n^.Size := Size;
   n^.Initializer := Initializer;
   n^.Tag := NewArrayNode;
   MakeNewArrayNode := n;
end;


function TNewArrayNode.Display: String;
begin
   Display := self.Ty^.Id + '[' + self.Size^.Display + '] of ' + self.Initializer^.Display;
end;


end.