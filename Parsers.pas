unit Parsers;
interface

uses
   Utils, Scanners, Symbols, Nodes, LiteralNodes, VarNodes,
   AssignNodes, OpNodes, IfNodes, LoopNodes, CallNodes,
   LetNodes, SequenceNodes, FieldNodes, DescNodes, DeclNodes, ObjectNodes, 
   Bindings;
   
procedure Parse(FileName: String);


implementation

procedure Parse(FileName: String);
var
   Scanner: PScanner;
   
   function GetExpression: PNode; forward;
   function GetTypeSpec: PNode; forward;

   
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


   function GetExpressionList(Sep : TokenTag) : PList;
   var
      List: PList;
   begin
      List := MakeList(Token.Line, Token.Col);
      if Sep = CommaToken then List^.Separator := CommaSeparator;
      Append(List, GetExpression);
      while Token.Tag = Sep do
      begin
         Next;
         Append(List, GetExpression);
      end;
      GetExpressionList := List;
   end;
   

   function GetField: PNode;
   var
      Name: Symbol;
      Line, Col: LongInt;
   begin
      Line := Token.Line;
      Col := Token.Col;
      Name := GetIdentifier;
      Advance(EqToken);
      GetField := MakeFieldNode(Name, GetExpression, Line, Col);
   end;

   
   function GetFieldList(): PList;
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
  

      
   function GetFactor: PNode;
   var
      Line, Col : LongInt;
      Value: String;
      List: PList;
      Factor: PNode = nil;
      Id: Symbol;
   begin
      Line := Token.Line;
      Col := Token.Col;
      Value := Token.Value;
      GetFactor := nil;
      case Token.Tag of
         NumberToken: 
            begin
               Next;
               Factor := MakeIntegerNode(atoi(Value, Line, Col), Line, Col);
            end;
         StringToken: 
            begin
               Next;
               Factor := MakeStringNode(Value, Line, Col);
            end;
         TrueToken: 
            begin
               Next;
               Factor := MakeBooleanNode(true, Line, Col);
            end;
         FalseToken: 
            begin
               Next;
               Factor := MakeBooleanNode(false, Line, Col);
            end;
         NilToken: 
            begin
               Next;
               Factor := MakeNilNode(Line, Col);
            end;
         MinusToken: 
            begin
               Next;
               Factor := MakeUnaryOpNode(MinusOp, GetFactor, Line, Col);
            end;
         IdToken: 
            begin
               Id := GetIdentifier;

               case Token.Tag of
                  LBraceToken: 
                     begin
                        Next;
                        GetFactor := MakeNewObjectNode(Id, GetFieldList, Line, Col);
                        Advance(RBraceToken);
                        Exit;
                     end;
                  LParenToken: 
                     begin
                        Next;
                        if Token.Tag = RParenToken then
                           List := MakeList(Token.Line, Token.Col)
                        else
                           List := GetExpressionList(CommaToken);
                        Advance(RParenToken);
                        Factor := MakeCallNode(Id, List, Line, Col);
                     end;
                  LBracketToken: 
                     begin
                        Next;
                        Factor := GetExpression;
                        Advance(RBracketToken);
                        if Token.Tag = OfToken then
                           begin
                              Next;
                              GetFactor := MakeNewArrayNode(Id, Factor, GetExpression, Line, Col);
                              Exit;                        
                           end                           
                        else
                           Factor :=  MakeIndexedVarNode(MakeSimpleVarNode(Id, Line, Col), Factor, Line, Col);
                     end;
                  
                  else
                     Factor := MakeSimpleVarNode(Id, Line, Col);
               end;

               while Token.Tag in [DotToken, LBracketToken] do
                  case Token.Tag of
                    DotToken: 
                       begin
                          Next;
                          Factor := MakeFieldVarNode(Factor, GetIdentifier, Line, Col);
                       end;
                    LBracketToken: 
                       begin
                          Next;
                          Factor := MakeIndexedVarNode(Factor, GetExpression, Line, Col);
                          Advance(RBracketToken);
                       end;
                  end;             
            end;
         LParenToken:
            begin
               Next;
               Factor := MakeSequenceNode(GetExpressionList(SemiColonToken), Line, Col);
               Advance(RParenToken);
            end;
         else
            begin
               Next;
               err('Expected value, got ''' + Value + '''', Line, Col);
            end;
      end;
      
      GetFactor := Factor;
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
   

   function GetConjunction: PNode;
   var
      Line, Col: LongInt;
      
      function Helper(left: PNode): PNode;
      begin
         if Token.Tag = AndToken then
            begin
               Next;
               Helper := Helper(MakeBinaryOpNode(
                     AndOp, left, GetBoolean, Line, Col));
            end
         else
            Helper := left;
      end;
      
   begin
      Line := Token.Line;
      Col := Token.Col;
      GetConjunction := Helper(GetBoolean);
   end;


   function GetDisjunction: PNode;
   var
      Line, Col: LongInt;
      
      function Helper(left: PNode): PNode;
      begin
         if Token.Tag = OrToken then
            begin
               Next;
               Helper := Helper(MakeBinaryOpNode(
                     OrOp, left, GetConjunction, Line, Col));
            end
         else
            Helper := left;
      end;
      
   begin
      Line := Token.Line;
      Col := Token.Col;
      GetDisjunction := Helper(GetConjunction);
   end;


   function GetAssignment: PNode;
   var
      Line, Col: LongInt;
      LeftSide: PNode;
      
   begin
      Line := Token.Line;
      Col := Token.Col;
      GetAssignment := nil;
      LeftSide := GetDisjunction;
      if Token.Tag = AssignToken then
         if IsVarNode(LeftSide) then
            begin
               Next;
               GetAssignment := MakeAssignNode(LeftSide, GetExpression, Line, Col);
            end
         else
            err('Assignment to non-variable object', Line, Col)
      else
         GetAssignment := LeftSide;
   end;


   function GetIfExpression: PNode;
   var
      Condition: PNode;
      Consequent: PNode;
      Line, Col: LongInt;
   begin
      GetIfExpression := nil;
      Line := Token.Line;
      Col := Token.Col;
      Next;
      Condition := GetExpression;
      Advance(ThenToken);
      Consequent := GetExpression;
      if Token.Tag = ElseToken then
         begin
            Next;
            GetIfExpression := MakeIfElseNode(
                  Condition, Consequent, GetExpression, Line, Col);
         end
      else
         GetIfExpression := MakeIfNode(Condition, Consequent, Line, Col);
   end;


   function GetWhileExpression: PNode;
   var
      Condition: PNode;
      Line, Col: LongInt;
   begin
      GetWhileExpression := nil;
      Line := Token.Line;
      Col := Token.Col;
      Next;
      Condition := GetExpression;
      Advance(DoToken);
      GetWhileExpression := MakeWhileNode(Condition, GetExpression, Line, Col);
   end;


   function GetForExpression: PNode;
   var
      Counter: symbol;
      Start, Finish: PNode;
      Line, Col: LongInt;
   begin
      GetForExpression := nil;
      Line := Token.Line;
      Col := Token.Col;
      Next;
      Counter := GetIdentifier;
      Advance(AssignToken);
      Start := GetExpression;
      Advance(ToToken);
      Finish := GetExpression;
      Advance(DoToken);
      GetForExpression := MakeForNode(
            Counter, Start, Finish, GetExpression, Line, Col);
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


   function getVarDeclaration: PNode;
   var
      Line, Col: LongInt;
      Name: Symbol;
      Ty: PNode = nil;
      Exp: PNode = nil;
   begin
      GetVarDeclaration := nil;
      Line := Token.Line;
      Col := Token.Col;
      Next;
      Name := GetIdentifier;
      if Token.Tag = ColonToken then
         begin
            Next;
            Ty := GetTypeSpec;
         end;
      if Token.Tag = AssignToken then
         begin
            Next;
            Exp := GetExpression;
         end
      else
         err('Expected '':'' or ''='', got ''' + Token.Value + '''',
             Token.Line, Token.Col);
      GetVarDeclaration := MakeVarDeclNode(Name, Ty, Exp, Line, Col);
   end;


   function GetFieldDesc: PNode;
   var
      Name: Symbol;
      Line, Col: LongInt;
   begin
      Line := Token.Line;
      Col := Token.Col;
      Name := GetIdentifier;
      Advance(ColonToken);
      GetFieldDesc := MakeFieldDescNode(Name, GetIdentifier, Line, Col);
   end;

   
   function GetFieldDescList: PList;
   var
      List: PList;
   begin
      List := MakeList(Token.Line, Token.Col);
      List^.Separator := CommaSeparator;
      if not (Token.Tag in [RParenToken, RBraceToken]) then
         begin
            Append(List, GetFieldDesc);
            while Token.Tag = CommaToken do
               begin
                  Next;
                  Append(List, GetFieldDesc);
               end;
         end;               
      GetFieldDescList := List;
   end;
  

   function GetTypeSpec: PNode;
   var
      Line, Col: LongInt;
      Desc: PNode = nil;
   begin
      Line := Token.Line;
      Col := Token.Col;
      case Token.Tag of
         LBraceToken: 
            begin
               Next;
               Desc := MakeRecordDescNode(GetFieldDescList, Line, Col);
               Advance(RBraceToken);
            end;
         ArrayToken:
            begin
               Next;
               Advance(OfToken);
               Desc := MakeArrayDescNode(GetIdentifier, Line, Col);
            end;
         IdToken:
            Desc := MakeNamedDescNode(GetIdentifier, Line, Col);
         else
            err('Expected type spec, got ''' +
               Token.Value, Token.Line, Token.Col);
      end;
      GetTypeSpec := Desc;
   end;


   function GetFunctionDeclaration: PNode;
   var
      Line, Col: LongInt;
      Name: Symbol;
      Ty: PNode = nil;
      Params: PList;
   begin
      Line := Token.Line;
      Col := Token.Col;
      GetFunctionDeclaration := nil;
      Next;
      Name := GetIdentifier;
      Advance(LParenToken);
      Params := GetFieldDescList;
      Advance(RParenToken);
      if Token.Tag = ColonToken then
         begin
            Next;
            Ty := GetTypeSpec;
         end;
      Advance(EqToken);
      GetFunctionDeclaration := MakeFunDeclNode(Name, Params, Ty, GetExpression, Line, Col);
   end;
  

   function GetTypeDeclaration: PNode;
   var
      Line, Col: LongInt;
      Name: Symbol;
   begin
      Line := Token.Line;
      Col := Token.Col;
      Next;
      Name := GetIdentifier;
      Advance(EqToken);
      GetTypeDeclaration := MakeTypeDeclNode(Name, GetTypeSpec, Line, Col);
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
   end;


   function GetDeclarationList: PList;
   var
      Decls: PList;
   begin
      Decls := MakeList(Token.Line, Token.Col);
      while Token.Tag in [VarToken, FunctionToken, TypeToken] do
         Append(Decls, GetDeclaration);
      GetDeclarationList := Decls
   end; { GetDeclarationList }


   function GetLetExpression: PNode;
   var
      Line, Col: LongInt;
      Decls: PList;
      Body: PNode;
   begin
      Line := Token.Line;
      Col := Token.Col;
      Next;
      Decls := GetDeclarationList;
      Advance(InToken);
      Body := GetExpression;
      GetLetExpression := MakeLetNode(Decls, Body, Line, Col);
   end;

   
   function GetExpression: PNode;
   begin
      case Token.Tag of
         IfToken: GetExpression := GetIfExpression;
         WhileToken: GetExpression := GetWhileExpression;
         ForToken: GetExpression := GetForExpression;
         LetToken: GetExpression := GetLetExpression;
         BreakToken: GetExpression := GetBreak;
         else GetExpression := GetAssignment;
      end;
   end;
   
   
var
   block: PNode;
begin
   Scanner := MakeScanner(FileName);
   Next;
   block := GetExpression;
   writeln(block^.display);
end; { Parse }


end.
