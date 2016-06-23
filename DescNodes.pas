unit DescNodes;

interface

uses Symbols, Nodes;

type
   PRecordDescNode = ^TRecordDescNode;
   TRecordDescNode = Object(TNode)
      Parent: Symbol;
      Fields: PList;
      function Display: String; virtual;
   end;
  

function MakeRecordDescNode(Parent: Symbol; Fields: PList; Line, Col: LongInt): PRecordDescNode;


implementation

function MakeRecordDescNode(Parent: Symbol; Fields: PList; Line, Col: LongInt): PRecordDescNode;
var
   n: PRecordDescNode;
begin
   new(n, init(Line, Col));
   n^.Tag := RecordDescNode;
   n^.Parent := Parent;
   n^.Fields := Fields;
   MakeRecordDescNode := n;
end;


function TRecordDescNode.Display: String;
var
   s: String;
begin
   if self.Parent = nil then
      s := 'object'
   else
      s := self.Parent^.Id;

   Display := 'record (' + s + ') ' + chr(10) + self.Fields^.Display + chr(10) + 'end';
end;


end.
