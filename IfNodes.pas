unit IfNodes;
interface
uses Nodes;

type
   PIfElseNode = ^TIfElseNode;
   TIfElseNode = Object(TNode)
      Condition: PNode;
      Consequent: PList;
      Alternative: PList;
      function Display: String; virtual;
   end;


   PIfNode = ^TIfNode;
   TIfNode = Object(TNode)
      condition: PNode;
      consequent: PList;
      function Display: String; virtual;
   end;


function MakeIfElseNode(Condition: PNode; Consequent, Alternative: PList;
      Line, Col: LongInt): PIfElseNode;
function MakeIfNode(Condition: PNode; Consequent: PList; Line, Col: LongInt): PIfNode;


implementation

function MakeIfElseNode(Condition: PNode; Consequent, Alternative: PList;
      Line, Col: LongInt): PIfElseNode;
var
   n: PIfElseNode;
begin
   New(n, init(Line, Col));
   n^.Kind := IfElseNode;
   n^.Condition := Condition;
   n^.Consequent := Consequent;
   n^.Alternative := Alternative;
   MakeIfElseNode := n;
end;


function TIfElseNode.Display: String;
begin
   Display := '<if-else>' + Chr(10) +
         '<condition>' + Self.Condition^.Display + '</condition>' + Chr(10) +
         '<consequent>' + Self.Consequent^.Display + '</consequent>' + Chr(10) +
         '<alternative>' + Self.Alternative^.Display + '</alternative>' + Chr(10) +
         '</if-else>' + Chr(10);
end;
   

function MakeIfNode(Condition: PNode; Consequent: PList; Line, Col: LongInt): PIfNode;
var
   n: PIfNode;
begin
   New(n, init(Line, Col));
   n^.Kind := IfNode;
   n^.Condition := Condition;
   n^.Consequent := Consequent;
   MakeIfNode := n;
end;


function TIfNode.Display: String;
begin
   Display := '<if>' + Chr(10) +
         '<condition>' + Self.Condition^.Display + '</condition>' + Chr(10) +
         '<consequent>' + Self.Consequent^.Display + '</consequent>' + Chr(10) +
         '</if>' + Chr(10);
end;

end.