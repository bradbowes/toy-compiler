unit bindings;

interface
uses symbols;

type
   binding = ^binding_t;
   binding_t = record
      key : symbol;
      value : string;
      left, right : binding;
   end;			 

function bind (table : binding; key : symbol; value : string) : binding;
function lookup (table : binding; key : symbol) : string;

implementation

function make_binding (
      key : symbol; value : string; left, right : binding) : binding;
var b : binding;
begin
   new (b);
   b^.key := key;
   b^.value := value;
   b^.left := left;
   b^.right := right;
   make_binding := b;
end;

function height (table : binding) : integer;
var l, r : integer;
begin
   l := 0; r := 0;
   if not (table = nil) then begin
      if not (table^.left = nil) then l := 1 + height (table^.left);
      if not (table^.right = nil) then r := 1 + height (table^.right);
   end;
   if l > r then height := l else height := r
end;

function balance (table: binding) : integer;
begin
   if table = nil then balance := 0
   else balance := height (table^.left) - height (table^.right);
end;

function rotate_left (table : binding) : binding;
begin
   rotate_left := make_binding (table^.right^.key,
                                table^.right^.value,
                                make_binding (table^.key,
                                              table^.value,
                                              table^.left,
                                              table^.right^.left),
                                table^.right^.right);
   dispose (table);
end;

function rotate_right (table : binding) : binding;
begin
   rotate_right := make_binding (table^.left^.key,
                                 table^.left^.value,
                                 table^.left^.left,
                                 make_binding (table^.key,
                                               table^.value,
                                               table^.left^.right,
                                               table^.right));
   dispose (table);
end;

function bind (table : binding; key : symbol; value : string) : binding;
var
   item : binding;
   bal : integer;
begin
   if table = nil then
      item := make_binding (key, value, nil, nil)
   else if key < table^.key then
      item := make_binding (table^.key, table^.value,
                            bind (table^.left, key, value),
                            table^.right)
   else if key > table^.key then
      item := make_binding (table^.key, table^.value,
                            table^.left,
                            bind (table^.right, key, value))
   else
      item := make_binding (key, value, table^.left, table^.right);

   bal := balance (item);
   while (bal < -1) or (bal > 1) do begin
      if bal > 1 then item := rotate_right (item)
      else if bal < -1 then item := rotate_left (item);
      bal := balance (item);
   end;
   bind := item;
end;

function lookup (table : binding; key : symbol) : string;
begin
   if table = nil then
      lookup := 'not found'
   else if key < table^.key then
      lookup := lookup (table^.left, key)
   else if key > table^.key then
      lookup := lookup (table^.right, key)
   else
      lookup := table^.value;
end;

end.
