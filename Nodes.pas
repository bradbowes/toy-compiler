unit Nodes;
interface

type
   NodeType = (AssignNode, CallNode, ReturnNode,
               SimpleVarNode, FieldVarNode, IndexedVarNode,
               IntegerNode, StringNode, BooleanNode, NilNode, 
               TypeDeclNode, VarDeclNode, FunDeclNode,
               NamedDescNode, RecordDescNode, ArrayDescNode,
               UnaryOpNode, BinaryOpNode,
               FieldNode, IfElseNode, IfNode,
               WhileNode, ForNode, BreakNode, BlockNode,
               ListNode);

   PNode = ^TNode;
   TNode = Object
      Line, Col: LongInt;
      Kind: NodeType;
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
   str(self.Kind, s);
   Display := '<' + s + '>';
end;


function MakeList(Line, Col: LongInt): PList;
var
   list: PList;
begin
   new(list, init(Line, Col));
   list^.Kind := ListNode;
   list^.First := nil;
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
   item, newItem: PListItem;
begin
   newItem := MakeListItem(Node);
   if List^.First = nil then
      List^.First := newItem
   else
      begin
         item := List^.First;
         while item^.Next <> nil do
            item := item^.Next;
         item^.Next := newItem;
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
         s := s + '<item>' + it^.Node^.Display + '</item>' + chr(10);
         it := it^.Next;
      end;
   Display := s;
end;
      
      
end.
