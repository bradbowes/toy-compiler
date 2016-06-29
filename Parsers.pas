unit Parsers;
interface

uses
   utils, Scanners, Symbols, Nodes, LiteralNodes, VarNodes,
   AssignNodes, OpNodes, IfNodes, LoopNodes, CallNodes,
   BlockNodes, FieldNodes, DescNodes, DeclNodes, bindings;
   
procedure Parse(FileName: String);


implementation

procedure Parse(FileName: String);
var
   Scanner: PScanner;
   
   function GetExpression: PNode; forward;
   function GetSequence: PList; forward;
   function GetBlock: PNode; forward;
   
   procedure Next;
   begin
      Scan(Scanner);
      while Token.Tag = CommentToken do
         Scan(Scanner);
   end;
   
   function GetIdentifier: Symbol;
   var
      Value: String;
   begin
      Value := Token.Value;
      GetIdentifier := nil;
      if Token.Tag = IdToken then
         begin
            GetIdentifier := Intern(Value);
            Next;
         end
      else
         err('Expected identifier, got ''' + Value + '''', Token.Line, Token.Col);
   end;


   procedure Advance(T: TokenTag);
   begin
      if Token.Tag = T then
         Next
      else
         err('Expected ''' + TokenDisplay[T] + ''', got ''' +
             Token.Value + '''', Token.Line, Token.Col);
   end;


   function GetExpressionList: PList;
   var
      List: PList;
   begin
      List := MakeList(Token.Line, Token.Col);
      List^.Separator := CommaSeparator;
      if Token.Tag <> RParenToken then
         begin
            Append(List, GetExpression);
            while Token.Tag = CommaToken do
               begin
                  Next;
                  Append(List, GetExpression);
               end;
         end;               
      GetExpressionList := List;
   end;
   

   function GetVariable(Variable: PNode): PNode;
   var
      Id: Symbol;
      Node: PNode;
      Line, Col: LongInt;
      
      procedure GetNext;
      begin
         Next;
         Line := Token.Line;
         Col := Token.Col;
      end;
      
   begin
      GetVariable := nil;
      Line := Variable^.Line;
      Col := Variable^.Col;
      case Token.Tag of
         DotToken:
            begin
               GetNext;
               Id := GetIdentifier;
               GetVariable := GetVariable(MakeFieldVarNode(Variable, Id, Line, Col));
            end;
         LBracketToken:
            begin
               GetNext;
               Node := GetExpression;
               Advance(RBracketToken);
               GetVariable := GetVariable(MakeIndexedVarNode(Variable, Node, Line, Col));
            end;
         LParenToken:
            begin
               GetNext;
               Node := GetExpressionList;
               Advance(RParenToken);
               GetVariable := MakeCallNode(Variable, PList(Node), Line, Col);
            end;
         else
            GetVariable := Variable;
      end;
   end;
                     
   
   function GetFactor: PNode;
   var
      Line, Col: LongInt;
      Value: String;
   begin
      Line := Token.Line;
      Col := Token.Col;
      Value := Token.Value;
      GetFactor := nil;
      case Token.Tag of
         NumberToken:
            begin
               Next;
               GetFactor := MakeIntegerNode(atoi(Value, Line, Col), Line, Col);
            end;
         StringToken:
            begin
               Next;
               GetFactor := MakeStringNode(Value, Line, Col);
            end;
         TrueToken:
            begin
               Next;
               GetFactor := MakeBooleanNode(true, Line, Col);
            end;
         FalseToken:
            begin
               Next;
               GetFactor := MakeBooleanNode(false, Line, Col);
            end;
         NilToken:
            begin
               Next;
               GetFactor := MakeNilNode(Line, Col);
            end;
         MinusToken:
            begin
               Next;
               GetFactor := MakeUnaryOpNode(MinusOp, GetExpression, Line, Col);
            end;
         IdToken:
            begin
               Next;
               GetFactor := GetVariable(MakeSimpleVarNode(Intern(Value), Line, Col));
            end;
         else
            begin
               Next;
               err('Expected value, got ''' + Value + '''', Line, Col);
            end;
      end;
   end;


   function GetProduct: PNode;
   var
      Line, Col: LongInt;
      
      function Helper(left: PNode): PNode;
      
         function MakeMulNode(op: OpType): PBinaryOpNode;
         begin
            Next;
            MakeMulNode := MakeBinaryOpNOde(op, left, GetFactor, Line, Col);
         end;
      
      begin
         case Token.Tag of
            MulToken: Helper := Helper(MakeMulNode(MulOp));
            DivToken: Helper := Helper(MakeMulNode(DivOp));
            ModToken: Helper := Helper(MakeMulNode(ModOp));
            else Helper := left;
         end;
      end;
      
   begin
      Line := Token.Line;
      Col := Token.Col;
      GetProduct := Helper(GetFactor);
   end; { GetProduct }


   function GetSum: PNode;
   var
      Line, Col: LongInt;
      
      function Helper(left: PNode): PNode;
      
         function MakeAddNode(op: OpType): PBinaryOpNode;
         begin
            Next;
            MakeAddNode := MakeBinaryOpNode(op, left, GetProduct, Line, Col);
         end;
      
      begin
         case Token.Tag of
            PlusToken: Helper := Helper(MakeAddNode(PlusOp));
            MinusToken: Helper := Helper(MakeAddNode(MinusOp));
            else Helper := left;
         end;
      end;
      
   begin
      Line := Token.Line;
      Col := Token.Col;
      GetSum := Helper(GetProduct);
   end; { GetSum }


   function GetBoolean: PNode;
   var
      Line, Col: LongInt;
      left: PNode;

      function MakeCompareNode(op: OpType): PBinaryOpNode;
      begin
         Next;
         MakeCompareNode := MakeBinaryOpNode(op, left, GetSum, Line, Col);
      end;
      
   begin
      Line := Token.Line;
      Col := Token.Col;
      left := GetSum;
      case Token.Tag of
         EqToken: GetBoolean := MakeCompareNode(EqOp);
         NEqToken: GetBoolean := MakeCompareNode(NEqOp);
         LTToken: GetBoolean := MakeCompareNode(LTOp);
         LEqToken: GetBoolean := MakeCompareNode(LEqOp);
         GTToken: GetBoolean := MakeCompareNode(GTOp);
         GEqToken: GetBoolean := MakeCompareNode(GEqOp);
         else GetBoolean := left;
      end;
   end;
   
   
   function GetComplement: PNode;
   var
      Line, Col: LongInt;
   begin
      Line := Token.Line;
      Col := Token.Col;
      if Token.Tag = NotToken then
         begin
            Next;
            GetComplement := MakeUnaryOpNode(NotOp, GetBoolean, Line, Col);
         end
      else
         GetComplement := GetBoolean
   end;
   

   function GetConjunction: PNode;
   var
      Line, Col: LongInt;
      
      function Helper(left: PNode): PNode;
      begin
         if Token.Tag = AndToken then
            begin
               Next;
               Helper := Helper(MakeBinaryOpNode(
                     AndOp, left, GetComplement, Line, Col));
            end
         else
            Helper := left;
      end;
      
   begin
      Line := Token.Line;
      Col := Token.Col;
      GetConjunction := Helper(GetComplement);
   end;


   function GetExpression: PNode;
   var
      Line, Col: LongInt;
      
      function Helper(left: PNode): PNode;
      begin
         if Token.Tag = OrToken then
            begin
               Next;
               Helper := Helper(
                     MakeBinaryOpNode(OrOp, left, GetConjunction, Line, Col));
            end
         else
            Helper := left;
      end;
      
   begin
      Line := Token.Line;
      Col := Token.Col;
      GetExpression := Helper(GetConjunction);
   end;


   function GetIfStatement: PNode;
   var
      Condition: PNode;
      Consequent: PList;
      Line, Col: LongInt;
   begin
      GetIfStatement := nil;
      Line := Token.Line;
      Col := Token.Col;
      Next;
      Condition := GetExpression;
      Advance(ThenToken);
      Consequent := GetSequence;
      if Token.Tag = ElseToken then
         begin
            Next;
            GetIfStatement := MakeIfElseNode(
                  Condition, Consequent, GetSequence, Line, Col);
         end
      else
         GetIfStatement := MakeIfNode(Condition, Consequent, Line, Col);
      Advance(EndToken);
   end;


   function GetWhileStatement: PNode;
   var
      Condition: PNode;
      Line, Col: LongInt;
   begin
      GetWhileStatement := nil;
      Line := Token.Line;
      Col := Token.Col;
      Next;
      Condition := GetExpression;
      Advance(DoToken);
      GetWhileStatement := MakeWhileNode(Condition, GetSequence, Line, Col);
      Advance(EndToken);
   end;


   function GetForStatement: PNode;
   var
      Counter: symbol;
      Start, Finish: PNode;
      Line, Col: LongInt;
   begin
      GetForStatement := nil;
      Line := Token.Line;
      Col := Token.Col;
      Next;
      Counter := GetIdentifier;
      Advance(AssignToken);
      Start := GetExpression;
      Advance(ToToken);
      Finish := GetExpression;
      Advance(DoToken);
      GetForStatement := MakeForNode(
            Counter, Start, Finish, GetSequence, Line, Col);
      Advance(EndToken);
   end;


   function GetBreak: PNode;
   var
      Line, Col: LongInt;
   begin
      Line := Token.Line;
      Col := Token.Col;
      Next;
      GetBreak := MakeBreakNode(Line, Col);
   end;


   function GetReturnStatement: PNode;
   var
      Line, Col: LongInt;
   begin
      Line := Token.Line;
      Col := Token.Col;
      Next;
      GetReturnStatement := MakeReturnNode(GetExpression, Line, Col);
   end;


   function GetAssignment(left: PNode): PNode;
   begin
      GetAssignment := nil;
      Advance(AssignToken);
      GetAssignment := MakeAssignNode(left, GetExpression, left^.Line, left ^.Col);
   end;


   function GetStatement: PNode;
   var
      exp: PNode;
   begin
      GetStatement := nil;
      case Token.Tag of
         IfToken: GetStatement := GetIfStatement;
         WhileToken: GetStatement := GetWhileStatement;
         ForToken: GetStatement := GetForStatement;
         BreakToken: GetStatement := GetBreak;
         ReturnToken: GetStatement := GetReturnStatement;
         IdToken:
            begin
               exp := GetExpression;
               if IsVarNode(exp) then
                  GetStatement := GetAssignment(exp)
               else if exp^.Tag = CallNode then
                  GetStatement := exp
               else
                  err('Illegal expression', exp^.Line, exp^.Col);
            end;
         else
            err('Expected statement, got ''' + Token.Value + '''',
                Token.Line, Token.Col);
      end;
      if Token.Tag = SemicolonToken then
         Next;
   end; { GetStatement }


   function GetSequence: PList;
   var
      Seq: PList;
   begin
      Seq := MakeList(Token.Line, Token.Col);
      while Token.Tag in [IfToken, WhileToken, ForToken, BreakToken,
                             ReturnToken, IdToken] do
         Append(Seq, GetStatement);
      GetSequence := Seq;
   end;
   
   
   function GetVarDeclaration: PNode;
   var
      Line, Col: LongInt;
      Name: Symbol;
      Ty: Symbol = nil;
      Exp: PNode = nil;
   begin
      GetVarDeclaration := nil;
      Line := Token.Line;
      Col := Token.Col;
      Next;
      Name := GetIdentifier;
      case Token.Tag of
         ColonToken:
            begin
               Next;
               Ty := GetIdentifier;
               if Token.Tag = EqToken then
                  begin
                     Next;
                     Exp := GetExpression;
                  end;
            end;
         EqToken:
            begin
               Next;
               Exp := GetExpression;
            end
         else
            err('Expected '':'' or ''='', got ''' + Token.Value + '''',
                Token.Line, Token.Col);
      end;
      GetVarDeclaration := MakeVarDeclNode(Name, Ty, Exp, Line, Col);
   end;


   function GetField: PNode;
   var
      Name: Symbol;
      Line, Col: LongInt;
   begin
      Line := Token.Line;
      Col := Token.Col;
      Name := GetIdentifier;
      Advance(ColonToken);
      GetField := MakeFieldNode(Name, GetIdentifier, Line, Col);
   end;

   
   function GetFieldList: PList;
   var
      List: PList;
   begin
      List := MakeList(Token.Line, Token.Col);
      List^.Separator := CommaSeparator;
      if not (Token.Tag in [RParenToken, RBraceToken]) then
         begin
            Append(List, GetField);
            while Token.Tag = CommaToken do
               begin
                  Next;
                  Append(List, GetField);
               end;
         end;               
      GetFieldList := List;
   end;
  

   function GetFunctionDeclaration: PNode;
   var
      Line, Col: LongInt;
      Name: Symbol;
      Ty: Symbol = nil;
      Params: PList;
   begin
      Line := Token.Line;
      Col := Token.Col;
      GetFunctionDeclaration := nil;
      Next;
      Name := GetIdentifier;
      Advance(LParenToken);
      Params := GetFieldList;
      Advance(RParenToken);
      if Token.Tag = ColonToken then
         begin
            Next;
            Ty := GetIdentifier;
         end;
      if Token.Tag = SemiColonToken then
         Next;
      GetFunctionDeclaration := MakeFunDeclNode(Name, Params, Ty, GetBlock, Line, Col);
   end;
  

   function GetTypeDeclaration: PNode;
   var
      Line, Col: LongInt;
      Name, Parent: Symbol;
      Desc: PNode = nil;
   begin
      Line := Token.Line;
      Col := Token.Col;
      Parent := nil;
      Next;
      Name := GetIdentifier;
      Advance(EqToken);
      if Token.Tag = RecordToken then
         begin
            Next;
            if Token.Tag = LParenToken then
               begin
                  Next;
                  Parent := GetIdentifier;
                  Advance(RParenToken);
               end;
               Desc := MakeRecordDescNode(Parent, GetFieldList, Line, Col);
               Advance(EndToken);
            end
      else
         err('Expected ''record'', got ''' +
             Token.Value, Token.Line, Token.Col);
      GetTypeDeclaration := MakeTypeDeclNode(Name, Desc, Line, Col);
   end;
               

   function GetDeclaration: PNode;
   begin
      GetDeclaration := nil;
      case Token.Tag of
         VarToken: GetDeclaration := GetVarDeclaration;
         FunctionToken: GetDeclaration := GetFunctionDeclaration;
         TypeToken: GetDeclaration := GetTypeDeclaration;
      else
         err('Expected declaration, got ''' + Token.Value + '''',
             Token.Line, Token.Col);
      end;
      if Token.Tag = SemicolonToken then
         Next;
   end;


   function GetDeclarationList: PList;
   var
      Decls: PList;
   begin
      Decls := MakeList(Token.Line, Token.Col);
      while Token.Tag in [VarToken, FunctionToken, TypeToken] do
         Append(Decls, GetDeclaration);
      GetDeclarationList := Decls
   end;
   
   
   function GetBlock: PNode;
   var
      Line, Col: LongInt;
      Decls: PList;
      Body: PList;
   begin
      Line := Token.Line;
      Col := Token.Col;
      Decls := GetDeclarationList;
      
      if Token.Tag = BeginToken then
         begin
            Next;
            Body := GetSequence;
         end
      else
         Body := MakeList(Token.Line, Token.Col);
      Advance(EndToken);
      GetBlock := MakeBlockNode(Decls, Body, Line, Col);
   end;
      

var
   block: PNode;
begin
   Scanner := MakeScanner(FileName);
   Next;
   block := GetBlock;
   writeln(block^.display);
end; { Parse }


end.
