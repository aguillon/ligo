open Cli_expect

let%expect_test _ =
  run_ligo_good
    [ "compile"; "contract"; test "timelock.mligo"; "--protocol"; "kathmandu" ];
  [%expect
    {|
    { parameter (pair chest_key chest) ;
      storage bytes ;
      code { CAR ;
             UNPAIR ;
             PUSH nat 1000 ;
             DUG 2 ;
             OPEN_CHEST ;
             IF_LEFT
               { RIGHT (or unit unit) }
               { IF { UNIT ; LEFT unit } { UNIT ; RIGHT unit } ; LEFT bytes } ;
             IF_LEFT
               { IF_LEFT { DROP ; PUSH bytes 0x01 } { DROP ; PUSH bytes 0x00 } }
               {} ;
             NIL operation ;
             PAIR } } |}]

let%expect_test _ =
  run_ligo_good
    [ "compile"; "contract"; test "open_chest_result.mligo"; "--protocol"; "kathmandu" ];
  [%expect
    {|
    { parameter (or (or (unit %fail_d) (unit %fail_t)) (bytes %ok_o)) ;
      storage (or (or (unit %fail_decrypt) (unit %fail_timelock)) (bytes %ok_opening)) ;
      code { CAR ;
             IF_LEFT
               { IF_LEFT { DROP ; UNIT ; LEFT unit } { DROP ; UNIT ; RIGHT unit } ;
                 LEFT bytes }
               { RIGHT (or unit unit) } ;
             NIL operation ;
             PAIR } } |}]
