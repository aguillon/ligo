type p = One | Two | Three | Four
type r = ((string * int) * (p * nat))

type t = { a : int ; b : r ; c : nat }

let s (x : t) = 
  match x with
    { a ; c ; b = ((x, y), (One, z)) } -> ()
  | { a ; b = ((x, y), (Two, z)) ; c } -> ()