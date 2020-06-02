unit DeclNodes;

interface

uses Symbols, Nodes;

type
   PTypeDeclNode = ^TTypeDeclNode;
   TTypeDeclNode = Object(TNode)
      Name: Symbol;
      Ty: PNode;
      function Display: String; virtual;
   end;


   PVarDeclNode = ^TVarDeclNode;
   TVarDeclNode = Object(TNode)
      Name: Symbol;
      Ty: PNode;
      Initializer: PNode;
      function Display: String; virtual;
   end;


   PFunDeclNode = ^TFunDeclNode;
   TFunDeclNode = Object(TNode)
      Name: Symbol;
      Params: PList;
      Ty: PNode;
      Body: PNode;
      function Display: String; virtual;
   end;
   

function MakeTypeDeclNode(
      Name: symbol; Ty: PNode; Line, Col: LongInt): PTypeDeclNode;
function MakeVarDeclNode(
      Name: Symbol; Ty, Initializer: PNode; Line, Col: LongInt): PVarDeclNode;
function MakeFunDeclNode(
      Name: Symbol; Params: PList; Ty, Body: PNode; Line, Col: LongInt): PFunDeclNode;


implementation

function MakeTypeDeclNode(
      Name: Symbol; Ty: PNode; Line, Col: LongInt): PTypeDeclNode;
var
   n: PTypeDeclNode;
begin
   new(n, init(Line, Col));
   n^.Tag := TypeDeclNode;
   n^.Name := Name;
   n^.Ty := Ty;
   MakeTypeDeclNode := n;
end;


function TTypeDeclNode.Display: String;
begin
   Display := 'type ' + self.Name^.Id + ' = ' + self.Ty^.Display;
end;


function MakeVarDeclNode(
      Name: Symbol; Ty, Initializer: PNode; Line, Col: LongInt): PVarDeclNode;
var
   n: PVarDeclNode;
begin
   new(n, init(Line, Col));
   n^.Tag := VarDeclNode;
   n^.Name := Name;
   n^.Ty := Ty;
   n^.Initializer := Initializer;
   MakeVarDeclNode := n;
end;
   

function TVarDeclNode.Display: String;
var
   s: String;
begin
   s := 'var ' + self.Name^.Id;
   if self.Ty <> nil then
      s := s + ': ' + self.Ty^.Display;
   if self.Initializer <> nil then
      s := s + ' := ' + self.Initializer^.Display;
   Display := s;
end;


function MakeFunDeclNode(
      Name: Symbol; Params: PList; Ty, Body: PNode; Line, Col: LongInt): PFunDeclNode;
var
   n: PFunDeclNode;
begin
   new(n, init(Line, Col));
   n^.Tag := FunDeclNode;
   n^.Name := Name;
   n^.Params := Params;
   n^.Ty := Ty;
   n^.Body := Body;
   MakeFunDeclNode := n;
end;
      

function TFunDeclNode.Display: String;
var
   s: String;
begin
   s := 'function ' + self.Name^.Id + '(' + self.Params^.Display + ')';
   if self.Ty <> nil then
      s := s + ': ' + self.Ty^.Display;
   Display := s + ' =' + chr(10) + self.Body^.Display;
end;


end.
