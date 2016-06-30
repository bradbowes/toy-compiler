unit FieldNodes;
interface

uses Symbols, Nodes;

type
   PFieldNode = ^TFieldNode;
   TFieldNode = Object(TNode)
      Name: Symbol;
      Ty: PNode;
      function Display: String; virtual;
   end;

function MakeFieldNode(Name: Symbol; Ty: PNode; Line, Col: LongInt): PFieldNode;
   

implementation

function MakeFieldNode(Name: Symbol; Ty: PNode; Line, Col: LongInt): PFieldNode;
var
   n: PFieldNode;
begin
   new(n, init(Line, Col));
   n^.Tag := FieldNode;
   n^.Name := Name;
   n^.Ty := Ty;
   MakeFieldNode := n;
end;


function TFieldNode.Display: String;
begin
   Display := self.Name^.Id + ': ' + self.Ty^.Display;
end;


end.
