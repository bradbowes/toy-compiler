unit OpNodes;
interface
uses Nodes;

type
   OpType = (PlusOp, MinusOp, MulOp, DivOp,
             EqOp, NEqOp, LtOp, LEqOp, GTOp, GEqOp,
             AndOp, OrOp);


   PUnaryOpNode = ^TUnaryOpNode;
   TUnaryOpNode = object(TNode)
      Op: OpType;
      Expression: PNode;
      function Display: String; virtual;
   end;


   PBinaryOpNode = ^TBinaryOpNode;
   TBinaryOpNode = object(TNode)
      Op: OpType;
      Left: PNode;
      Right: PNode;
      function Display: String; virtual;
   end;

function MakeUnaryOpNode(
      Op: OpType; Expression: PNode; Line, Col: LongInt): PUnaryOpNode;
function MakeBinaryOpNode(
      Op: OpType; Left, Right: PNode; Line, Col: LongInt): PBinaryOpNode;

implementation

function MakeUnaryOpNode(
      Op: OpType; Expression: PNode; Line, Col: LongInt): PUnaryOpNode;
var
   n: PUnaryOpNode;
begin
   new(n, init(Line, Col));
   n^.Tag := UnaryOpNode;
   n^.Op := Op;
   n^.Expression := Expression;
   MakeUnaryOpNode := n;
end;


function TUnaryOpNode.Display: String;
var
   s: String;
begin
   Str(self.Op, s);
   SetLength(s, Length(s) - 2);
   Display := Lowercase(s) + '(' + self.Expression^.Display + ')';
end;


function MakeBinaryOpNode(
      Op: OpType; Left, Right: PNode; Line, Col: LongInt): PBinaryOpNode;
var
   n: PBinaryOpNode;
begin
   new(n, init(Line, Col));
   n^.Tag := BinaryOpNode;
   n^.Op := Op;
   n^.Left := Left;
   n^.Right := Right;
   MakeBinaryOpNode := n;
end;


function TBinaryOpNode.Display: String;
var
   s: String;
begin
   Str(self.Op, s);
   SetLength(s, Length(s) - 2);
   Display := Lowercase(s) + '(' + self.Left^.Display + ', ' + self.Right^.Display + ')';
end;


end.
