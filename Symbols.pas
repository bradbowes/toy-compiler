unit Symbols;
interface

type
   Symbol = ^TSymbol;
   TSymbol = Record
      Id: String;
      Next: Symbol;
   end;

function Intern (s: String): Symbol;

implementation

const
   hash_size = 1021;
   

type
   hash_table = array [0 .. hash_size - 1] of Symbol; 


var
   tbl : hash_table;
   

function hash(s: String): Integer;
var
   h: LongInt;
   i: Integer;
begin
   h := 31;
   for i := 1 to length(s) do
      h := (ord(s[i]) + (h * 37)) mod 514229;
   hash := h mod hash_size;
end;


function MakeSymbol(s: String): Symbol;
var sym: Symbol;
begin
  new (sym);
  sym^.id := s;
  MakeSymbol := sym;
end;


function Intern(s: String): Symbol;
var
   h: integer;
   sym: Symbol;
begin
   h := hash (s);
   if tbl[h] = nil then
      begin
         tbl[h] := MakeSymbol(s);
         sym := tbl[h];
      end
   else
      begin
         sym := tbl[h];
         while sym^.id <> s do
            begin
               if sym^.next = nil then
                  sym^.next := MakeSymbol(s);
               sym := sym^.next;
            end;
      end;
   Intern := sym;
end;


end.
