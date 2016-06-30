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
  

   PArrayDescNode = ^TArrayDescNode;
   TArrayDescNode = Object(TNode)
      Base: PNode;
      function Display: String; virtual;
   end;


   PNamedDescNode = ^TNamedDescNode;
   TNamedDescNode = Object(TNode)
      Named: Symbol;
      function Display: String; virtual;
   end;


function MakeRecordDescNode(Parent: Symbol; Fields: PList; Line, Col: LongInt): PRecordDescNode;
function MakeArrayDescNode(Base: PNode; Line, Col: LongInt): PArrayDescNode;
function MakeNamedDescNode(Named: Symbol; Line, Col: LongInt): PNamedDescNode;


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


function MakeArrayDescNode(Base: PNode; Line, Col: LongInt): PArrayDescNode;
var
   n: PArrayDescNode;
begin
   new(n, init(Line, Col));
   n^.Tag := ArrayDescNode;
   n^.Base := Base;
   MakeArrayDescNode := n;
end;


function TArrayDescNode.Display: String;
begin
   Display := 'array of ' + self.Base^.Display;
end;


function MakeNamedDescNode(Named: Symbol; Line, Col: LongInt): PNamedDescNode;
var
   n: PNamedDescNode;
begin
   new(n, init(Line, Col));
   n^.Tag := NamedDescNode;
   n^.Named := Named;
   MakeNamedDescNode := n;
end;


function TNamedDescNode.Display: String;
begin
   Display := Named^.Id;
end;


end.
