unit Parsers;
interface

uses
   utils, Scanners, Symbols, Nodes, LiteralNodes, VarNodes,
   AssignNodes, OpNodes, IfNodes, LoopNodes, CallNodes,
   BlockNodes, FieldNodes, DeclNodes, bindings;
   
procedure Parse(FileName: String);


implementation

procedure Parse(FileName: String);
var
   Scanner: PScanner;
   Token: PToken;
   
   function GetExpression: PNode; forward;
   function GetSequence: PList; forward;
   function GetBlock: PNode; forward;
   
   procedure Next;
   begin
      Token := Scan(Scanner);
      while Token^.Token = CommentToken do
         Token := Scan(Scanner);
   end;
   
   function GetIdentifier: Symbol;
   var
      Value: String;
   begin
      Value := Token^.Value;
      GetIdentifier := nil;
      if Token^.Token = IdToken then
         begin
            GetIdentifier := Intern(Value);
            Next;
         end
      else
         err('Expected identifier, got ''' + Value + '''', Token^.Line, Token^.Col);
   end;


   procedure Advance(T: TokenType; ErrDesc: String);
   begin
      if Token^.Token = T then
         Next
      else
         err('Expected ''' + ErrDesc + ''', got ''' +
             Token^.Value, Token^.Line, Token^.Col);
   end;


   function GetExpressionList: PList;
   var
      List: PList;
   begin
      List := MakeList(Token^.Line, Token^.Col);
      List^.Separator := CommaSeparator;
      if Token^.Token <> RParenToken then
         begin
            Append(List, GetExpression);
            while Token^.Token = CommaToken do
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
         Line := Token^.Line;
         Col := Token^.Col;
      end;
      
   begin
      GetVariable := nil;
      case Token^.Token of
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
               Advance(RBracketToken, ']');
               GetVariable := GetVariable(MakeIndexedVarNode(Variable, Node, Line, Col));
            end;
         LParenToken:
            begin
               GetNext;
               Node := GetExpressionList;
               Advance(RParenToken, ')');
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
      Line := Token^.Line;
      Col := Token^.Col;
      Value := Token^.Value;
      GetFactor := nil;
      case Token^.Token of
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
         case Token^.Token of
            MulToken: Helper := Helper(MakeMulNode(MulOp));
            DivToken: Helper := Helper(MakeMulNode(DivOp));
            ModToken: Helper := Helper(MakeMulNode(ModOp));
            else Helper := left;
         end;
      end;
      
   begin
      Line := Token^.Line;
      Col := Token^.Col;
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
         case Token^.Token of
            PlusToken: Helper := Helper(MakeAddNode(PlusOp));
            MinusToken: Helper := Helper(MakeAddNode(MinusOp));
            else Helper := left;
         end;
      end;
      
   begin
      Line := Token^.Line;
      Col := Token^.Col;
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
      Line := Token^.Line;
      Col := Token^.Col;
      left := GetSum;
      case Token^.Token of
         EqToken: GetBoolean := MakeCompareNode(EqOp);
         NEqToken: GetBoolean := MakeCompareNode(NEqOp);
         LTToken: GetBoolean := MakeCompareNode(LTOp);
         LEqToken: GetBoolean := MakeCompareNode(LEqOp);
         GTToken: GetBoolean := MakeCompareNode(GTOp);
         GEqToken: GetBoolean := MakeCompareNode(GEqOp);
         else GetBoolean := left;
      end;
   end;
   
   
   function GetNegation: PNode;
   var
      Line, Col: LongInt;
   begin
      Line := Token^.Line;
      Col := Token^.Col;
      if Token^.Token = NotToken then
         begin
            Next;
            GetNegation := MakeUnaryOpNode(NotOp, GetBoolean, Line, Col);
         end
      else
         GetNegation := GetBoolean
   end;
   

   function GetConjunction: PNode;
   var
      Line, Col: LongInt;
      
      function Helper(left: PNode): PNode;
      begin
         if Token^.Token = AndToken then
            begin
               Next;
               Helper := Helper(MakeBinaryOpNode(
                     AndOp, left, GetNegation, Line, Col));
            end
         else
            Helper := left;
      end;
      
   begin
      Line := Token^.Line;
      Col := Token^.Col;
      GetConjunction := Helper(GetNegation);
   end;


   function GetExpression: PNode;
   var
      Line, Col: LongInt;
      
      function Helper(left: PNode): PNode;
      begin
         if Token^.Token = OrToken then
            begin
               Next;
               Helper := Helper(
                     MakeBinaryOpNode(OrOp, left, GetConjunction, Line, Col));
            end
         else
            Helper := left;
      end;
      
   begin
      Line := Token^.Line;
      Col := Token^.Col;
      GetExpression := Helper(GetConjunction);
   end;


   function GetIfStatement: PNode;
   var
      Condition: PNode;
      Consequent: PList;
      Line, Col: LongInt;
   begin
      GetIfStatement := nil;
      Line := Token^.Line;
      Col := Token^.Col;
      Next;
      Condition := GetExpression;
      Advance(ThenToken, 'then');
      Consequent := GetSequence;
      if Token^.Token = ElseToken then
         begin
            Next;
            GetIfStatement := MakeIfElseNode(
                  Condition, Consequent, GetSequence, Line, Col);
         end
      else
         GetIfStatement := MakeIfNode(Condition, Consequent, Line, Col);
      Advance(EndToken, 'end');
   end;


   function GetWhileStatement: PNode;
   var
      Condition: PNode;
      Line, Col: LongInt;
   begin
      GetWhileStatement := nil;
      Line := Token^.Line;
      Col := Token^.Col;
      Next;
      Condition := GetExpression;
      if Token^.Token = DoToken then
         begin
            Next;
            GetWhileStatement := MakeWhileNode(Condition, GetSequence, Line, Col);
            if Token^.Token = EndToken then
               Next
            else
               err('Expected ''end'', got ''' + Token^.Value + '''',
                   Token^.Line, Token^.Col);
         end
      else
         err('Expected ''do'', got ''' + Token^.Value + '''',
             Token^.Line, Token^.Col);
   end;


   function GetForStatement: PNode;
   var
      Counter: symbol;
      Start, Finish: PNode;
      Line, Col: LongInt;
   begin
      GetForStatement := nil;
      Line := Token^.Line;
      Col := Token^.Col;
      Next;
      Counter := GetIdentifier;
      Advance(AssignToken, ':=');
      Start := GetExpression;
      Advance(ToToken, 'to');
      Finish := GetExpression;
      Advance(DoToken, 'do');
      GetForStatement := MakeForNode(
            Counter, Start, Finish, GetSequence, Line, Col);
      Advance(EndToken, 'end');
   end;


   function GetBreak: PNode;
   var
      Line, Col: LongInt;
   begin
      Line := Token^.Line;
      Col := Token^.Col;
      Next;
      GetBreak := MakeBreakNode(Line, Col);
   end;


   function GetReturnStatement: PNode;
   var
      Line, Col: LongInt;
   begin
      Line := Token^.Line;
      Col := Token^.Col;
      Next;
      GetReturnStatement := MakeReturnNode(GetExpression, Line, Col);
   end;


   function GetAssignment(left: PNode): PNode;
   begin
      GetAssignment := nil;
      if Token^.Token = AssignToken then
         begin
            Next;
            GetAssignment := MakeAssignNode(
                  left, GetExpression, left^.Line, left ^.Col);
         end
      else
         err('Expected assignment or procedure call', left^.Line, left^.Col)
   end;


   function GetStatement: PNode;
   var
      exp: PNode;
   begin
      GetStatement := nil;
      case Token^.Token of
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
               else if exp^.Kind = CallNode then
                  GetStatement := exp
               else
                  err('Illegal expression', exp^.Line, exp^.Col);
            end;
         else
            err('Expected statement, got ''' + Token^.Value + '''',
                Token^.Line, Token^.Col);
      end;
      if Token^.Token = SemicolonToken then
         Next;
   end; { GetStatement }


   function GetSequence: PList;
   var
      Seq: PList;
   begin
      Seq := MakeList(Token^.Line, Token^.Col);
      while Token^.Token in [IfToken, WhileToken, ForToken, BreakToken,
                             ReturnToken, IdToken] do
         Append(Seq, GetStatement);
      GetSequence := Seq;
   end;
   
   
   function GetVarDeclaration: PNode;
   var
      Line, Col: LongInt;
      Name, Ty: Symbol;
      Exp: PNode;
   begin
      GetVarDeclaration := nil;
      Name := nil;
      Ty := nil;
      Exp := nil;
      Line := Token^.Line;
      Col := Token^.Col;
      Next;
      Name := GetIdentifier;
      case Token^.Token of
         ColonToken:
            begin
               Next;
               Ty := GetIdentifier;
               if Token^.Token = AssignToken then
                  begin
                     Next;
                     Exp := GetExpression;
                  end;
            end;
         AssignToken:
            begin
               Next;
               Exp := GetExpression;
            end
         else
            err('Expected '':'' or '':='', got ''' + Token^.Value + '''',
                Token^.Line, Token^.Col);
      end;
      GetVarDeclaration := MakeVarDeclNode(Name, Ty, Exp, Line, Col);
   end;


   function GetField: PNode;
   var
      Name: Symbol;
      Line, Col: LongInt;
   begin
      Line := Token^.Line;
      Col := Token^.Col;
      Name := GetIdentifier;
      Advance(ColonToken, ':');
      GetField := MakeFieldNode(Name, GetIdentifier, Line, Col);
   end;

   
   function GetFieldList: PList;
   var
      List: PList;
   begin
      List := MakeList(Token^.Line, Token^.Col);
      List^.Separator := CommaSeparator;
      if not (Token^.Token in [RParenToken, RBraceToken]) then
         begin
            Append(List, GetField);
            while Token^.Token = CommaToken do
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
      Name, Ty: Symbol;
      Params: PList;
   begin
      Line := Token^.Line;
      Col := Token^.Col;
      GetFunctionDeclaration := nil;
      Next;
      Name := GetIdentifier;
      Advance(LParenToken, '(');
      Params := GetFieldList;
      Advance(RParenToken, ')');
      if Token^.Token = ColonToken then
         begin
            Next;
            Ty := GetIdentifier;
         end
      else
         Ty := nil;
      GetFunctionDeclaration := MakeFunDeclNode(Name, Params, Ty, GetBlock, Line, Col);
      
   end;
  

   function GetDeclaration: PNode;
   begin
      GetDeclaration := nil;
      case Token^.Token of
         VarToken: GetDeclaration := GetVarDeclaration;
         FunctionToken: GetDeclaration := GetFunctionDeclaration;
      else
         err('Expected declaration, got ''' + Token^.Value + '''',
             Token^.Line, Token^.Col);
      end;
      if Token^.Token = SemicolonToken then
         Next;
   end;


   function GetDeclarations: PList;
   var
      Decls: PList;
   begin
      Decls := MakeList(Token^.Line, Token^.Col);
      while Token^.Token in [VarToken, FunctionToken, TypeToken] do
         Append(Decls, GetDeclaration);
      GetDeclarations := Decls
   end;
   
   
   function GetBlock: PNode;
   var
      Line, Col: LongInt;
      Decls: PList;
      Body: PList;
   begin
      Line := Token^.Line;
      Col := Token^.Col;
      Decls := GetDeclarations;
      
      if Token^.Token = BeginToken then
         begin
            Next;
            Body := GetSequence;
         end
      else
         Body := MakeList(Token^.Line, Token^.Col);
      Advance(EndToken, 'end');
      GetBlock := MakeBlockNode(Decls, Body, Line, Col);
   end;
      

var
   block: PNode;
begin
   Token := nil;
   Scanner := MakeScanner(FileName);
   Next;
   block := GetBlock;
   writeln(block^.display);
end; { Parse }


end.
