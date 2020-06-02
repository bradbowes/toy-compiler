let

   type node = { value: int,  next: node }

   type nodearray = array of node

   type intarray = array of int
               
   var a: boolean := false
   var b := (1 + 3) * 4
   var c := 2

   function doSomething(a: int, b: int, c: int): xi =
   let
     var x := false
   in
     if x then
        a + b + c
   end

in

   node := node { value = 0, next = nil };

   /* nodes := nodearray[50] of node { value = 0, next = nil }; */

   for i := 0 to 1 do
      node := nodes[i];
      while node <> nil do (
         thething(node.value);
         node := node.next
      );
         
   if a = 1 then
      print("hello")
   else
      print(node.next.value);


   hello := "goodbye"

   
end


