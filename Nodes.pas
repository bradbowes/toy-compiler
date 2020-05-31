unit Nodes;
interface

type
   NodeTag = (AssignNode, CallNode, ReturnNode,
              SimpleVarNode, FieldVarNode, IndexedVarNode,
              IntegerNode, StringNode, BooleanNode, NilNode, 
              TypeDeclNode, VarDeclNode, FunDeclNode,
              NamedDescNode, RecordDescNode, ArrayDescNode,
              FunDescNode, UnaryOpNode, BinaryOpNode,
              FieldNode, IfElseNode, IfNode,
              WhileNode, ForNode, BreakNode, LetNode, SequenceNode,
              ListNode, NewObjectNode, NewArrayNode);

   
   SeparatorType = (SemicolonSeparator, CommaSeparator);


   PNode = ^TNode;
   TNode = Object
      Line, Col: LongInt;
      Tag: NodeTag;
      constructor init(l, c: LongInt);
      function Display: String; virtual;
   end;


   PListItem = ^TListItem;
   TListItem = Object
      Node: PNode;
      Next: PListItem;
   end;
   
   
   PList = ^TList;
   TList = Object(TNode)
      First: PListItem;
      Last: PListItem;
      Separator: SeparatorType;
      function Display: String; virtual;
   end;


function MakeList(Line, Col: LongInt): PList;
procedure Append(List: PList; Node: PNode);


implementation

constructor TNode.init(l, c: LongInt);
begin
   self.Line := l;
   self.Col := c;
end;


function TNode.Display: String;
var
   s: String;
begin
   str(self.Tag, s);
   Display := '<' + s + '>';
end;


function MakeList(Line, Col: LongInt): PList;
var
   list: PList;
begin
   new(list, init(Line, Col));
   list^.Tag := ListNode;
   list^.First := nil;
   list^.Last := nil;
   list^.Separator := SemicolonSeparator;
   MakeList := list;
end;


function MakeListItem(Node: PNode): PListItem;
var
   item: PListItem;
begin
   new(item);
   item^.Node := Node;
   item^.Next := nil;
   MakeListItem := item;
end;


procedure Append(List: PList; Node: PNode);
var
   newItem: PListItem;
begin
   newItem := MakeListItem(Node);
   if List^.First = nil then
      begin
         List^.First := newItem;
         List^.Last := List^.First;
      end
   else
      begin
         List^.Last^.Next := newItem;
         List^.Last := newItem;
      end;
end;


function TList.Display: String;
var
   it: PListItem;
   s: String;
begin
   s := '';
   it := self.First;
   while it <> nil do
      begin
         s := s + it^.Node^.Display;
         if it^.Next <> nil then
            case self.Separator of
              SemiColonSeparator : s := s + ';' + chr(10);
              CommaSeparator     : s := s + ', ';
            end;                 
         it := it^.Next;
      end;
   Display := s;
end;
      
      
end.
