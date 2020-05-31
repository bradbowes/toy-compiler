unit DescNodes;

interface

uses Symbols, Nodes;

type
   PRecordDescNode = ^TRecordDescNode;
   TRecordDescNode = Object(TNode)
      Fields: PList;
      function Display: String; virtual;
   end;
  

   PArrayDescNode = ^TArrayDescNode;
   TArrayDescNode = Object(TNode)
      Base: Symbol;
      function Display: String; virtual;
   end;


   PNamedDescNode = ^TNamedDescNode;
   TNamedDescNode = Object(TNode)
      Named: Symbol;
      function Display: String; virtual;
   end;
   
   
   PFunDescNode = ^TFunDescNode;
   TFunDescNode = Object(TNode)
      Params: PList;
      Ty: PNode;
      function Display: String; virtual;
   end;


function MakeRecordDescNode(
      Fields: PList; Line, Col: LongInt): PRecordDescNode;
function MakeArrayDescNode(Base: Symbol; Line, Col: LongInt): PArrayDescNode;
function MakeNamedDescNode(Named: Symbol; Line, Col: LongInt): PNamedDescNode;
function MakeFunDescNode(Params: PList; Ty: PNode; Line, Col: LongInt): PFunDescNode;


implementation

function MakeRecordDescNode(
      Fields: PList; Line, Col: LongInt): PRecordDescNode;
var
   n: PRecordDescNode;
begin
   new(n, init(Line, Col));
   n^.Tag := RecordDescNode;
   n^.Fields := Fields;
   MakeRecordDescNode := n;
end;


function TRecordDescNode.Display: String;
begin
   Display := '{' + self.Fields^.Display + '}';
end;


function MakeArrayDescNode(Base: Symbol; Line, Col: LongInt): PArrayDescNode;
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
   Display := 'array of ' + self.Base^.Id;
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


function MakeFunDescNode(Params: PList; Ty: PNode; Line, Col: LongInt): PFunDescNode;
var
   n: PFunDescNode;
begin
   new(n, init(Line, Col));
   n^.Tag := FunDescNode;
   n^.Params := Params;
   n^.Ty := Ty;
   MakeFunDescNode := n;
end;


function TFunDescNode.Display: String;
var
   s: String;
begin
   s := 'function (' + self.Params^.Display + ')';
   if self.Ty <> nil then
      s := s + ': ' + self.Ty^.Display;
   Display := s;
end;


end.
