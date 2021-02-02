unit Scanners;

interface

uses Utils;

type 
   TokenTag = (AndToken,
               ArrayToken,
               AssignToken,
               BreakToken,
               ColonToken,
               CommaToken,
               CommentToken,
               DivToken,
               DoToken,
               DotToken,
               ElseToken,
               EofToken,
               EqToken,
               FalseToken,
               ForToken,
               FunctionToken,
               GEqToken,
               GTToken,
               IdToken,
               IfToken,
	       ImportToken,
               InToken,
               LBraceToken,
               LBracketToken,
               LEqToken,
               LetToken,
               LParenToken,
               LTToken,
               MinusToken,
	       ModuleToken,
               MulToken, 
               NEqToken,
               NilToken,
               NumberToken,
               OfToken,
               OrToken,  
               PlusToken,
               RBraceToken,
               RBracketToken,
               RParenToken,
               SemicolonToken,
               StringToken,   
               ThenToken,
               ToToken, 
               TrueToken,
               TypeToken,
               VarToken, 
               WhileToken);


   TToken = record
            Tag: TokenTag;
            Value: string;
            Line, Col: longint;
         end;


   PScanner = ^TScanner;
   TScanner = record
              open: boolean;
              src: text;
              ch: char;
              x, y: longint;
           end;


function MakeScanner(FileName: String): PScanner;
procedure Scan(s: PScanner);


var
   Token: TToken;
   TokenDisplay: array[AndToken..WhileToken] of String;


implementation

procedure Scan(s: PScanner);

   procedure Next;
   begin
      if s^.open then
         if eof(s^.src) then
         begin
            s^.ch := chr(4);
            close(s^.src);
            s^.open := false;
         end
         else
         begin
            read(s^.src, s^.ch);
            s^.x := s^.x + 1;
         end
         else
            err('Read past end of file', Token.Line, Token.Col);
   end;


   procedure PushChar();
   begin
      Token.Value := Token.Value + s^.ch;
      Next;
   end;


   procedure Recognize(TType: TokenTag);
   begin
      PushChar;
      Token.Tag := TType;
   end;


   procedure SkipWhite;

      procedure NewLine;
      begin
         s^.y := s^.y + 1;
         s^.x := 0;
         Next
      end;

   begin
      while s^.ch in [' ', chr(9), chr(13), chr(10)] do
      begin
         case s^.ch of 
           ' ', chr(9): Next;
           chr(10): NewLine;
           chr(13): begin
              NewLine;
              if s^.ch = chr(10) then Next;
           end;
         end;
      end;
   end;


   procedure SkipComment;
   begin
      Token.Value := '/*';
      repeat
         repeat
            Next;
            Token.Value := Token.Value + s^.ch;
         until s^.ch = '*';
         Next;
      until s^.ch = '/';
      Next;
      Token.Value := Token.Value + '/';
      Token.Tag := CommentToken;
   end;


   procedure GetString;
   begin
      Next;
      repeat
         if s^.ch = '"' then
         begin
            Next;
            if s^.ch = '"' then
               PushChar
            else
               break;
         end
         else
            PushChar;
      until false;
      Token.Tag := StringToken;
   end;


   procedure GetNumber;
   begin
      while s^.ch in ['0'..'9'] do
         PushChar;
      Token.Tag := NumberToken;
   end;


   procedure GetId;
   begin
      while s^.ch in ['a'..'z', 'A'..'Z', '0'..'9', '_'] do
         PushChar;
      case Token.Value of 
         'array': Token.Tag := ArrayToken;
         'break': Token.Tag := BreakToken;
         'do': Token.Tag := DoToken;
         'else': Token.Tag := ElseToken;
         'false': Token.Tag := FalseToken;
         'for': Token.Tag := ForToken;
         'function': Token.Tag := FunctionToken;
         'if': Token.Tag := IfToken;
         'import': Token.Tag := ImportToken;
         'in': Token.Tag := InToken;
         'let': Token.Tag := LetToken;
         'module': Token.Tag := ModuleToken;
         'nil': Token.Tag := NilToken;
         'of': Token.Tag := OfToken;
         'then': Token.Tag := ThenToken;
         'to': Token.Tag := ToToken;
         'true': Token.Tag := TrueToken;
         'type': Token.Tag := TypeToken;
         'var': Token.Tag := VarToken;
         'while': Token.Tag := WhileToken;
      else         
         Token.Tag := IdToken;
      end;
   end;

begin
   SkipWhite;
   Token.Value := '';
   Token.Col := s^.x;
   Token.Line := s^.y;
   if not s^.open then
   begin
      Token.Tag := EofToken;
      Token.Value := '<EOF>';
   end
   else
   begin
      case s^.ch of 
         ',': Recognize(CommaToken);
         ';': Recognize(SemicolonToken);
         '.': Recognize(DotToken);
         '(': Recognize(LParenToken);
         ')': Recognize(RParenToken);
         '[': Recognize(LBracketToken);
         ']': Recognize(RBracketToken);
         '{': Recognize(LBraceToken);
         '}': Recognize(RBraceToken);
         '+': Recognize(PlusToken);
         '-': Recognize(MinusToken);
         '*': Recognize(MulToken);
         '&': Recognize(AndToken);
         '|': Recognize(OrToken);
         '/': begin
            PushChar;
            if s^.ch = '*' then SkipComment
            else Token.Tag := DivToken;
         end;
         '=': Recognize(EqToken);
         '<': begin
            PushChar;
            case s^.ch of 
               '>': Recognize(NEqToken);
               '=': Recognize(LEqToken);
            else  
               Token.Tag:= LTToken;
            end;
         end;            
         '>': begin
            PushChar;
            if s^.ch = '=' then Recognize(GEqToken)
            else Token.Tag := GTToken;
         end;
         ':': begin
            PushChar;
            if s^.ch = '=' then Recognize(AssignToken)
            else Token.Tag := ColonToken;
         end;
         '0'..'9': GetNumber;
         '"': GetString;
         'a'..'z', 'A'..'Z', '_': GetId;
      else
         err('Illegal token ''' + s^.ch + '''', Token.Line, Token.Col);
      end;
   end;
end;


function MakeScanner(FileName: String): PScanner;
var s: PScanner;
begin
   new(s);
   assign(s^.src, FileName);
   reset(s^.src);
   s^.open := true;
   read(s^.src, s^.ch);
   s^.x := 1;
   s^.y := 1;
   MakeScanner := s;
end;


begin
   TokenDisplay[AndToken] := '&';
   TokenDisplay[ArrayToken] := 'array';
   TokenDisplay[AssignToken] := ':=';
   TokenDisplay[BreakToken] := 'break';
   TokenDisplay[ColonToken] := ':';
   TokenDisplay[CommaToken] := ',';
   TokenDisplay[CommentToken] := '';
   TokenDisplay[DivToken] := '/';   
   TokenDisplay[DoToken] := 'do';
   TokenDisplay[DotToken] := '.';
   TokenDisplay[ElseToken] := 'else';
   TokenDisplay[EofToken] := '';
   TokenDisplay[EqToken] := '=';
   TokenDisplay[FalseToken] := 'false';
   TokenDisplay[ForToken] := 'for';
   TokenDisplay[FunctionToken] := 'function';
   TokenDisplay[GEqToken] := '>=';
   TokenDisplay[GTToken] := '>';
   TokenDisplay[IdToken] := '';
   TokenDisplay[IfToken] := 'if';
   TokenDisplay[ImportToken] := 'import';
   TokenDisplay[LBraceToken] := '{';
   TokenDisplay[LBracketToken] := '[';
   TokenDisplay[LEqToken] := '<=';
   TokenDisplay[LParenToken] := '(';
   TokenDisplay[LTToken] := '<';
   TokenDisplay[MinusToken] := '-';
   TokenDisplay[ModuleToken] := 'module';
   TokenDisplay[MulToken] := '*';
   TokenDisplay[NEqToken] := '<>';
   TokenDisplay[NilToken] := 'nil';
   TokenDisplay[NumberToken] := '';
   TokenDisplay[OfToken] := 'of';
   TokenDisplay[OrToken] := '|';
   TokenDisplay[PlusToken] := '+';
   TokenDisplay[RBraceToken] := '}';
   TokenDisplay[RBracketToken] := ']';
   TokenDisplay[RParenToken] := ')';
   TokenDisplay[SemicolonToken] := ';';
   TokenDisplay[StringToken] := '';
   TokenDisplay[ThenToken] := 'then';
   TokenDisplay[ToToken] := 'to';
   TokenDisplay[TrueToken] := 'true';
   TokenDisplay[TypeToken] := 'type';
   TokenDisplay[VarToken] := 'var';
   TokenDisplay[WhileToken] := 'while';
end.
