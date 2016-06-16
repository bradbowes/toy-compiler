unit Scanners;

interface

uses utils;

type 
   TokenKind = (AndToken,
                ArrayToken,
                AssignToken,
                BeginToken,
                BreakToken,
                ColonToken,
                CommaToken,
                CommentToken,
                DivToken,
                DoToken,
                DotToken,
                ElseIfToken,
                ElseToken,
                EndToken,
                EofToken,
                EqToken,
                FalseToken,
                ForToken,
                FunctionToken,
                GEqToken,
                GTToken,
                IfToken,
                IdToken,
                LBraceToken,
                LBracketToken,
                LEqToken,
                LParenToken,
                LTToken,
                MinusToken,
                ModToken,
                MulToken, 
                NEqToken,
                NewToken,
                NilToken,
                NotToken,
                NumberToken,
                OfToken,
                OrToken,  
                PlusToken,
                RBraceToken,
                RBracketToken,
                RecordToken,
                ReturnToken,
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
      Kind: TokenKind;
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


   procedure PushVal(c: char);
   begin
      Token.Value := Token.Value + c;
      Next;
   end;


   procedure Advance(TType: TokenKind);
   begin
      PushVal(s^.ch);
      Token.Kind := TType;
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
               chr(13):
                  begin
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
      Token.Kind := CommentToken;
   end;


   procedure GetString;
   begin
      Next;
      repeat
         if s^.ch = '''' then
            begin
               Next;
               if s^.ch = '''' then
                  PushVal('''')
               else
                  break;
            end
         else
            PushVal(s^.ch);
      until false;
      Token.Kind := StringToken;
   end;


   procedure GetNumber;
   begin
      while s^.ch in ['0'..'9'] do
         PushVal(s^.ch);
      Token.Kind := NumberToken;
   end;


   procedure GetId;
   begin
      while s^.ch in ['a'..'z', 'A'..'Z', '0'..'9', '_'] do
         PushVal(s^.ch);
      case Token.Value of 
         'and': Token.Kind := AndToken;
         'array': Token.Kind := ArrayToken;
         'begin': Token.Kind := BeginToken;
         'break': Token.Kind := BreakToken;
         'do': Token.Kind := DoToken;
         'else': Token.Kind := ElseToken;
         'elseif': Token.Kind := ElseIfToken;
         'end': Token.Kind := EndToken;
         'false': Token.Kind := FalseToken;
         'for': Token.Kind := ForToken;
         'function': Token.Kind := FunctionToken;
         'if': Token.Kind := IfToken;
         'mod': Token.Kind := ModToken;
         'new': Token.Kind := NewToken;
         'nil': Token.Kind := NilToken;
         'not': Token.Kind := NotToken;
         'of': Token.Kind := OfToken;
         'or': Token.Kind := OrToken;
         'record': Token.Kind := RecordToken;
         'return': Token.Kind := ReturnToken;
         'then': Token.Kind := ThenToken;
         'to': Token.Kind := ToToken;
         'true': Token.Kind := TrueToken;
         'type': Token.Kind := TypeToken;
         'var': Token.Kind := VarToken;
         'while': Token.Kind := WhileToken;
      else
         Token.Kind := IdToken;
      end;
   end;

begin
   SkipWhite;
   Token.Value := '';
   Token.Col := s^.x;
   Token.Line := s^.y;
   if not s^.open then
      begin
         Token.Kind := EofToken;
         Token.Value := '<EOF>';
      end
   else
      begin
         case s^.ch of 
            ',': Advance(CommaToken);
            ';': Advance(SemicolonToken);
            '.': Advance(DotToken);
            '(': Advance(LParenToken);
            ')': Advance(RParenToken);
            '[': Advance(LBracketToken);
            ']': Advance(RBracketToken);
            '{': Advance(LBraceToken);
            '}': Advance(RBraceToken);
            '+': Advance(PlusToken);
            '-': Advance(MinusToken);
            '*': Advance(MulToken);
            '/':
               begin
                  PushVal('/');
                  if s^.ch = '*' then SkipComment
                  else Token.Kind := DivToken;
               end;
            '=': Advance(EqToken);
            '<':
               begin
                  PushVal('<');
                  case s^.ch of 
                     '>': Advance(NEqToken);
                     '=': Advance(LEqToken);
                     else
                        Token.Kind := LTToken;
                  end;
               end;
            '>':
               begin
                  PushVal('>');
                  if s^.ch = '=' then Advance(GEqToken)
                  else Token.Kind := GTToken;
               end;
            ':':
               begin
                  PushVal(':');
                  if s^.ch = '=' then Advance(AssignToken)
                  else Token.Kind := ColonToken;
               end;
            '0'..'9': GetNumber;
            '''': GetString;
            'a'..'z', 'A'..'Z': GetId;
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

end.
