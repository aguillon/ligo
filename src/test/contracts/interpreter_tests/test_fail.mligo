#include "./contract_under_test/fail_contract.mligo"

let test =
  let (typed_addr,_code,_) = Test.originate main () 0tez in
  let contr = Test.to_contract typed_addr in
  let addr = Tezos.address contr in

  match Test.transfer_to_contract contr () 10tez with
  | Success _ -> (failwith "Should fail !" : michelson_program )
  | Fail e -> (
    match e with
    | Rejected x ->
      let (x, addr_fail) = x in
      let () = assert (addr_fail = addr) in
      x
    | _ -> (failwith "Failed, but wrong reason" : michelson_program )
  )
