type storage = (int,"foo",string,"bar") michelson_or 

type return = operation list * storage

let main (action : unit) (store : storage) : return =
  let foo = M_right ("one") in
  (([] : operation list), (foo: storage))
