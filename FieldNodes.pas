unit FieldNodes;
interface

uses Symbols, Nodes;

type
   PFieldNode = ^TFieldNode;
   TFieldNode = Object(TNode)
      Name: Symbol;
      Ty: Symbol;
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


end.
