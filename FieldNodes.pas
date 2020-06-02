unit FieldNodes;
interface

uses Symbols, Nodes;

type
   PFieldDescNode = ^TFieldDescNode;
   TFieldDescNode = Object(TNode)
      Name: Symbol;
      Ty: Symbol;
      function Display: String; virtual;
   end;


   PFieldNode = ^TFieldNode;
   TFieldNode = Object(TNode)
      Name: Symbol;
      Value: PNode;
      function Display: String; virtual;
   end;


function MakeFieldDescNode(Name, Ty: Symbol; Line, Col: LongInt): PFieldDescNode;
function MakeFieldNode(Name : Symbol; Value: PNode; Line, Col: LongInt): PFieldNode;


implementation

function MakeFieldDescNode(Name, Ty: Symbol; Line, Col: LongInt): PFieldDescNode;
var
   n: PFieldDescNode;
begin
   new(n, init(Line, Col));
   n^.Tag := FieldDescNode;
   n^.Name := Name;
   n^.Ty := Ty;
   MakeFieldDescNode := n;
end;


function TFieldDescNode.Display: String;
begin
   Display := self.Name^.Id + ': ' + self.Ty^.Id;
end;


function MakeFieldNode(Name : Symbol; Value: PNode; Line, Col: LongInt): PFieldNode;
var
   n: PFieldNode;
begin
   new(n, init(Line, Col));
   n^.Tag := FieldNode;
   n^.Name := Name;
   n^.Value := Value;
   MakeFieldNode := n;
end;

function TFieldNode.Display: String;
begin
   Display := self.Name^.Id + ' = ' + self.Value^.Display;
end;

end.
