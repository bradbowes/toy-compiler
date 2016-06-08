unit DescNodes;

interface

uses Symbols, Nodes;

type
   PNamedDescNode = ^TNamedDescNode;
   TNamedDescNode = Object(TNode)
      Name: Symbol;
   end;


   PRecordDescNode = ^TRecordDescNode;
   TRecordDescNode = Object(TNode)
      Fields: PList;
   end;
   

   PArrayDescNode = ^TArrayDescNode;
   TArrayDescNode = object(TNode)
      Base: Symbol;
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


function MakeRecordDescNode(Fields: PList; Line, Col: LongInt): PRecordDescNode;
var
   n: PRecordDescNode;
begin
   new(n, init(Line, Col));
   n^.Kind := RecordDescNode;
   n^.Fields := Fields;
   MakeRecordDescNode := n;
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


end.