unit IfNodes;
interface
uses Nodes;

type
   PIfElseNode = ^TIfElseNode;
   TIfElseNode = Object(TNode)
      Condition: PNode;
      Consequent: PNode;
      Alternative: PNode;
      function Display: String; virtual;
   end;


   PIfNode = ^TIfNode;
   TIfNode = Object(TNode)
      condition: PNode;
      consequent: PNode;
      function Display: String; virtual;
   end;


function MakeIfElseNode(Condition, Consequent, Alternative: PNode;
      Line, Col: LongInt): PIfElseNode;
function MakeIfNode(Condition, Consequent: PNode; Line, Col: LongInt): PIfNode;


implementation

function MakeIfElseNode(Condition, Consequent, Alternative: PNode;
      Line, Col: LongInt): PIfElseNode;
var
   n: PIfElseNode;
begin
   New(n, init(Line, Col));
   n^.Tag := IfElseNode;
   n^.Condition := Condition;
   n^.Consequent := Consequent;
   n^.Alternative := Alternative;
   MakeIfElseNode := n;
end;


function TIfElseNode.Display: String;
begin
   Display := 'if ' + Self.Condition^.Display + ' then' + Chr(10) +
              Self.Consequent^.Display +
              'else' + chr(10) +
              Self.Alternative^.Display +
              'end';
end;
   

function MakeIfNode(Condition, Consequent: PNode; Line, Col: LongInt): PIfNode;
var
   n: PIfNode;
begin
   New(n, init(Line, Col));
   n^.Tag := IfNode;
   n^.Condition := Condition;
   n^.Consequent := Consequent;
   MakeIfNode := n;
end;


function TIfNode.Display: String;
begin
   Display := 'if ' + Self.Condition^.Display + ' then' + Chr(10) +
              Self.Consequent^.Display + '</consequent>' +
              'end';
end;


end.
