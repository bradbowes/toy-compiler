unit FieldNodes;
interface

uses Symbols, Nodes;

type
   PFieldNode = ^TFieldNode;
   TFieldNode = Object(TNode)
      Name: Symbol;
      Ty: Symbol;
      function Display: String; virtual;
   end;

function MakeFieldNode(Name, Ty: Symbol; Line, Col: LongInt): PFieldNode;
   

implementation

function MakeFieldNode(Name, Ty: Symbol; Line, Col: LongInt): PFieldNode;
var
   n: PFieldNode;
begin
   new(n, init(Line, Col));
   n^.Kind := FieldNode;
   n^.Name := Name;
   n^.Ty := Ty;
   MakeFieldNode := n;
end;


function TFieldNode.Display: String;
begin
   Display := self.Name^.Id + ': ' + self.Ty^.Id;
end;


end.
