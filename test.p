/* just testing loops */
while a <= 100 do
   a := read(b)
   increment(a)
   if eof(b) then
      for a := 1 to b + 1 do
         print(a)
      end
      break
   else
      exit()
   end;
end
