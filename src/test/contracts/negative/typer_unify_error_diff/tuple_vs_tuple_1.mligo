
let main (_p : int) (s : int) : operation list * int =
  let y : string * int * int * string = "foo", 42, 24, "bar" in
  let x : tez    * nat * tez          = y in
  ([] : operation list), s