Unit Bindings;

Interface
Uses Symbols, Nodes;

type
   PBinding = ^TBinding;
   TBinding = record
      Key : Symbol;
      Value : PNode;
      Left, Right : PBinding;
   end;


function Bind(Table : PBinding; Key : Symbol; Value : PNode): PBinding;
function Lookup(Table : PBinding; Key : Symbol): PNode;


Implementation


function MakeBinding(
      Key : Symbol; Value : PNode; Left, Right : PBinding): PBinding;
var
   b : PBinding;
begin
   new (b);
   b^.Key := Key;
   b^.Value := Value;
   b^.Left := Left;
   b^.Right := Right;
   MakeBinding := b;
end;


function Height(Table : PBinding): Integer;
var
   l, r: integer;
begin
   l := 0; r := 0;
   if not (Table = nil) then begin
      if not (Table^.Left = nil) then l := 1 + Height(Table^.Left);
      if not (Table^.Right = nil) then r := 1 + Height(Table^.Right);
   end;
   if l > r then Height := l else Height := r
end;


function Balance(Table: PBinding): Integer;
begin
   if Table = nil then Balance := 0
   else Balance := Height (Table^.Left) - Height (Table^.Right);
end;


function RotateLeft(Table : PBinding): PBinding;
begin
   RotateLeft := MaKeBinding(Table^.Right^.Key,
                             Table^.Right^.Value,
                             MakeBinding(Table^.Key,
                                         Table^.Value,
                                         Table^.Left,
                                         Table^.Right^.Left),
                             Table^.Right^.Right);
   dispose(Table);
end;


function RotateRight(Table : PBinding): PBinding;
begin
   RotateRight := MakeBinding(Table^.Left^.Key,
                              Table^.Left^.Value,
                              Table^.Left^.Left,
                              MakeBinding(Table^.Key,
                                          Table^.Value,
                                          Table^.Left^.Right,
                                          Table^.Right));
   dispose(Table);
end;


function Bind(Table : PBinding; Key : Symbol; Value : PNode) : PBinding;
var
   Item : PBinding;
   Bal : Integer;
begin
   if Table = nil then
      Item := MakeBinding(Key, Value, nil, nil)
   else if Key < Table^.Key then
      Item := MakeBinding(Table^.Key, Table^.Value,
                          Bind(Table^.Left, Key, Value),
                          Table^.Right)
   else if Key > Table^.Key then
      Item := MakeBinding(Table^.Key, Table^.Value,
                          Table^.Left,
                          Bind(Table^.Right, Key, Value))
   else
      Item := MakeBinding(Key, Value, Table^.Left, Table^.Right);

   Bal := Balance(Item);
   while (Bal < -1) or (Bal > 1) do begin
      if Bal > 1 then Item := RotateRight(Item)
      else if Bal < -1 then Item := RotateLeft(Item);
      Bal := Balance(Item);
   end;
   Bind := Item;
end;


function Lookup(Table : PBinding; Key : Symbol): PNode;
begin
   if Table = nil then
      Lookup := nil
   else if Key < Table^.Key then
      Lookup := Lookup(Table^.Left, Key)
   else if Key > Table^.Key then
      Lookup := Lookup (Table^.Right, Key)
   else
      Lookup := Table^.Value;
end;


end.
