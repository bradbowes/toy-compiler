unit DescNodes;

interface

uses Symbols, Nodes;

type
   PNamedDescNode = ^TNamedDescNode;
   TNamedDescNode = Object(TNode)
      Name: Symbol;
      function Display: String; virtual;
   end;


   PRecordDescNode = ^TRecordDescNode;
   TRecordDescNode = Object(TNode)
      Fields: PList;
      function Display: String; virtual;
   end;
   

   PArrayDescNode = ^TArrayDescNode;
   TArrayDescNode = object(TNode)
      Base: Symbol;
      function Display: String; virtual;
   end;
   

function MakeNamedDescNode(Name: Symbol; Line, Col: LongInt): PNamedDescNode;
function MakeRecordDescNode(Fields: PList; Line, Col: LongInt): PRecordDescNode;
function MakeArrayDescNode(Base: Symbol; Line, Col: LongInt): PArrayDescNode;


implementation

function MakeNamedDescNode(Name: Symbol; Line, Col: LongInt): PNamedDescNode;
var
   n: PNamedDescNode;
begin
   new(n, init(Line, Col));
   n^.Kind := NamedDescNode;
   n^.Name := Name;
   MakeNamedDescNode := n;
end;


function TNamedDescNode.Display: String;
begin
   Display := self.Name^.Id;
end;


function MakeRecordDescNode(Fields: PList; Line, Col: LongInt): PRecordDescNode;
var
   n: PRecordDescNode;
begin
   new(n, init(Line, Col));
   n^.Kind := RecordDescNode;
   n^.Fields := Fields;
   MakeRecordDescNode := n;
end;


function TRecordDescNode.Display: String;
begin
   Display := '{' + self.Fields^.Display + '}';
end;


function MakeArrayDescNode(
      Base: Symbol; Line, Col: LongInt): PArrayDescNode;
var
   n: PArrayDescNode;
begin
   new(n, init(Line, Col));
   n^.Kind := ArrayDescNode;
   n^.Base := Base;
   MakeArrayDescNode := n;
end;


function TArrayDescNode.Display: String;
begin
   Display := 'array of ' + self.Base^.Id;
end;


end.