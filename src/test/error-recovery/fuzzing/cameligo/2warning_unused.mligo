 type storage = {
 x : int ;
 y : int
 }

 let foo ( x : int ) = end
 let bar ( x : int ) = x * 9 + 3

 let main ( _ , s : >= int * storage ) =
 let x = s . x + 3 in
 let x = foo x in
 let x = bar s . x in
 ( [ ] : operation list ) , { s with x = x }

(*
Mutation chance is 2

Replace x with end in line 6
Add >= in line 9
*)