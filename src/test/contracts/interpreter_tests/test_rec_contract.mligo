let rec main (p : unit) (s : unit) : operation list * unit =
  main p s

let test =
  let (taddr, _, _) = Test.originate main () 0tez in
  let _contr = Test.to_contract taddr in
  ()
