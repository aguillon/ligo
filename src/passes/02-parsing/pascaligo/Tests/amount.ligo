function check_ (const _ : unit) : int is
  {
    var result : int := 0;
    if Tezos.get_amount() = 100tez then result := 42 else result := 0
  } with result
