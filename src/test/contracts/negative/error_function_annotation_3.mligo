type op =
  | Add of int
  | Sub of int


let main (p : int) (s : op) : (operation list) * op =
  match s with
  | Add si -> Add si
  | Sub si -> Sub si
