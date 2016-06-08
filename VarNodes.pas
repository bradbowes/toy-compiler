unit VarNodes;
interface
uses Symbols, Nodes;
   
type
   PSimpleVarNode = ^TSimpleVarNode;
   TSimpleVarNode = object(TNode)
      Sym: Symbol;
      function Display: String; virtual;
   end;   


   PFieldVarNode = ^TFieldVarNode;
   TFieldVarNode = object(TNode)
      Variable: PNode;
      Field: Symbol;
      function Display: String; virtual;
   end;


   PIndexedVarNode = ^TIndexedVarNode;
   TIndexedVarNode = object(TNode)
      variable: PNode;
      index: PNode;
      function Display: String; virtual;
   end;

function MakeSimpleVarNode(Sym: Symbol; Line, Col: LongInt): PSimpleVarNode;
function MakeFieldVarNode(
      Variable: PNode; Field: Symbol; Line, Col: LongInt): PFieldVarNode;
function MakeIndexedVarNode(    
      Variable: PNode; Index: PNode; Line, Col: LongInt): PIndexedVarNode;
function IsVarNode(Node: PNode): Boolean;


implementation

function MakeSimpleVarNode(Sym: Symbol; Line, Col: LongInt): PSimpleVarNode;
var
   n: PSimpleVarNode;
begin
   new(n, init(Line, Col));
   n^.Kind := SimpleVarNode;
   n^.Sym := Sym;
   MakeSimpleVarNode := n;
end;


function TSimpleVarNode.Display: String;
begin
   Display := self.Sym^.Id;
end;


function MakeFieldVarNode(    
      Variable: PNode; Field: Symbol; Line, Col: LongInt): PFieldVarNode;
var
   n: PFieldVarNode;
begin
   new(n, init(Line, Col));
   n^.Kind := FieldVarNode;
   n^.Variable := Variable;
   n^.Field := Field;
   MakeFieldVarNode := n;
end;


function TFieldVarNode.Display: String;
begin
   Display := self.variable^.display + '.' + field^.id;
end;


function MakeIndexedVarNode(    
      Variable: PNode; Index: PNode; Line, Col: LongInt): PIndexedVarNode;
var
   n: PIndexedVarNode;
begin
   new(n, init(Line, Col));
   n^.Kind := IndexedVarNode;
   n^.Variable := Variable;
   n^.Index := Index;
   MakeIndexedVarNode := n;
end;


function TIndexedVarNode.Display: String;
begin
   Display := self.variable^.display + '[' + self.index^.display + ']';
end;
 

function IsVarNode(Node: PNode): Boolean;
begin
   IsVarNode := Node^.Kind in [SimpleVarNode, FieldVarNode, IndexedVarNode];
end;


end.
