unit LiteralNodes;
interface
uses Nodes;

type
   PIntegerNode = ^TIntegerNode;
   TIntegerNode = Object(TNode)
      Value: Integer;
      function Display: String; virtual;
   end;


   PStringNode = ^TStringNode;
   TStringNode = Object(TNode)
      Value: String;
      function Display: String; virtual;
   end;
   

   PBooleanNode = ^TBooleanNode;
   TBooleanNode = Object(TNode)
      Value: Boolean;
      function Display: String; virtual;
   end;
   

   PNilNode = ^TNilNode;
   TNilNode = Object(TNode)
      function Display: String; virtual;
   end;


function MakeIntegerNode(Value, Line, Col: LongInt): PIntegerNode;
function MakeStringNode(Value: String; Line, Col: LongInt): PStringNode;
function MakeBooleanNode(Value: Boolean; Line, Col: LongInt): PBooleanNode;
function MakeNilNode(Line, Col: LongInt): PNilNode;

implementation

function MakeIntegerNode(Value, Line, Col: LongInt): PIntegerNode;
var
   n: PIntegerNode;
begin
   new(n, init(Line, Col));
   n^.Tag := IntegerNode;
   n^.Value := Value;
   MakeIntegerNode := n;
end;


function TIntegerNode.Display: String;
var
   s: String;
begin
   Str(self.Value, s);
   Display := s;
end;


function MakeStringNode(Value: String; Line, Col: LongInt): PStringNode;
var
   n: PStringNode;
begin
   new(n, init(Line, Col));
   n^.Tag := StringNode;
   n^.Value := Value;
   MakeStringNode := n;
end;


function TStringNode.Display: String;
begin
   Display := '"' + self.Value + '"';
end;


function MakeBooleanNode(Value: Boolean; Line, Col: LongInt): PBooleanNode;
var
   n: PBooleanNode;
begin
   new(n, init(Line, Col));
   n^.Tag := BooleanNode;
   n^.Value := Value;
   MakeBooleanNode := n;
end;


function TBooleanNode.Display: String;
var
   s: String;
begin
   Str(self.value, s);
   Display := LowerCase(s);
end;


function MakeNilNode(Line, Col: LongInt): PNilNode;
var
   n: PNilNode;
begin
   new(n, init(Line, Col));
   n^.Tag := NilNode;
   MakeNilNode := n;
end;


function TNilNode.Display: String;
begin
   Display := 'nil';
end;


end.
