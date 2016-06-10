unit Scanners;

interface

uses utils;

type 
   TokenType = (ColonToken, CommaToken, SemicolonToken,
                DotToken, LParenToken, RParenToken,
                LBracketToken, RBracketToken, LBraceToken,
                RBraceToken, AssignToken,
                AndToken, OrToken, NotToken, EqToken, NEqToken,
                LTToken, GTToken, LEqToken, GEqToken,
                PlusToken, MinusToken, MulToken, DivToken,
                ModToken, VarToken, TypeToken, ArrayToken,
                OfToken, FunctionToken, IfToken, ThenToken,
                ElseIfToken, ElseToken, WhileToken, DoToken,
                ForToken, BreakToken, ToToken, BeginToken, NewToken,
                NilToken, TrueToken, FalseToken,
                EndToken, ReturnToken,
                StringToken, NumberToken, IdToken, EofToken,
                CommentToken);


   PToken =  ^TToken;
   TToken = record
      Token: TokenType;
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
function Scan(s: PScanner): PToken;

implementation

function Scan(s: PScanner): PToken;
var
   t: PToken;

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
         err('Read past end of file', t^.line, t^.col);
   end;


   procedure PushVal(c: char);
   begin
      t^.Value := t^.Value + c;
      Next;
   end;


   procedure Advance(TType: TokenType);
   begin
      PushVal(s^.ch);
      t^.Token := TType;
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
      t^.Value := '/*';
      repeat
         repeat
            Next;
            t^.Value := t^.Value + s^.ch;
         until s^.ch = '*';
         Next;
      until s^.ch = '/';
      Next;
      t^.Value := t^.Value + '/';
      t^.Token := CommentToken;
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
      t^.Token := StringToken;
   end;


   procedure GetNumber;
   begin
      while s^.ch in ['0'..'9'] do
         PushVal(s^.ch);
      t^.Token := NumberToken;
   end;


   procedure GetId;
   begin
      while s^.ch in ['a'..'z', 'A'..'Z', '0'..'9', '_'] do
         PushVal(s^.ch);
      case t^.Value of 
         'and': t^.Token := AndToken;
         'array': t^.Token := ArrayToken;
         'begin': t^.Token := BeginToken;
         'break': t^.Token := BreakToken;
         'do': t^.Token := DoToken;
         'else': t^.Token := ElseToken;
         'elseif': t^.Token := ElseIfToken;
         'end': t^.Token := EndToken;
         'false': t^.Token := FalseToken;
         'for': t^.Token := ForToken;
         'function': t^.Token := FunctionToken;
         'if': t^.Token := IfToken;
         'new': t^.Token := NewToken;
         'nil': t^.Token := NilToken;
         'not': t^.Token := NotToken;
         'of': t^.Token := OfToken;
         'or': t^.Token := OrToken;
         'return': t^.Token := ReturnToken;
         'then': t^.Token := ThenToken;
         'to': t^.Token := ToToken;
         'true': t^.Token := TrueToken;
         'type': t^.Token := TypeToken;
         'var': t^.Token := VarToken;
         'while': t^.Token := WhileToken;
      else
         t^.Token := IdToken;
      end;
   end;

begin
   SkipWhite;
   new(t);
   t^.Value := '';
   t^.col := s^.x;
   t^.line := s^.y;
   if not s^.open then
      begin
         t^.Token := EofToken;
         t^.Value := '<EOF>';
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
                  else t^.Token := DivToken;
               end;
            '%': Advance(ModToken);
            '=': Advance(EqToken);
            '<':
               begin
                  PushVal('<');
                  case s^.ch of 
                     '>': Advance(NEqToken);
                     '=': Advance(LEqToken);
                     else
                        t^.Token := LTToken;
                  end;
               end;
            '>':
               begin
                  PushVal('>');
                  if s^.ch = '=' then Advance(GEqToken)
                  else t^.Token := GTToken;
               end;
            ':':
               begin
                  PushVal(':');
                  if s^.ch = '=' then Advance(AssignToken)
                  else t^.Token := ColonToken;
               end;
            '0'..'9': GetNumber;
            '''': GetString;
            'a'..'z', 'A'..'Z': GetId;
            else
               err('Illegal token ''' + s^.ch + '''', t^.line, t^.col);
         end;
      end;
   Scan := t;
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
