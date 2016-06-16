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
   HashSize = 1021;
   

type
   HashTable = Array [0 .. HashSize - 1] of Symbol; 


var
   Tbl : HashTable;


function Hash(S: String): Integer;
var
   H: LongInt;
   i: Integer;
begin
   H := 31;
   for i := 1 to Length(S) do
      H := (Ord(S[i]) + (H * 37)) mod 514229;
   Hash := H mod HashSize;
end;


function MakeSymbol(S: String): Symbol;
var Sym: Symbol;
begin
  New(Sym);
  Sym^.Id := S;
  MakeSymbol := Sym;
end;


function Intern(S: String): Symbol;
var
   H: Integer;
   Sym: Symbol;
begin
   H := Hash (S);
   if Tbl[H] = nil then
      begin
         Tbl[H] := MakeSymbol(S);
         Sym := Tbl[H];
      end
   else
      begin
         Sym := Tbl[H];
         while Sym^.Id <> S do
            begin
               if Sym^.Next = nil then
                  Sym^.Next := MakeSymbol(S);
               Sym := Sym^.Next;
            end;
      end;
   Intern := Sym;
end;


end.
