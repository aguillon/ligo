open Cli_expect

let%expect_test _ =
  run_ligo_good [ "compile" ; "contract" ; (test "sub_mutez_new.mligo") ; "--protocol" ; "ithaca" ] ;
  [%expect{|
    { parameter unit ;
      storage mutez ;
      code { CDR ;
             PUSH mutez 1000000 ;
             SWAP ;
             SUB_MUTEZ ;
             IF_NONE { PUSH string "option is None" ; FAILWITH } {} ;
             NIL operation ;
             PAIR } } |}]

let%expect_test _ =
  run_ligo_good [ "compile" ; "contract" ; (test "sub_mutez_new.ligo") ; "--protocol" ; "ithaca" ] ;
  [%expect{|
    { parameter unit ;
      storage mutez ;
      code { CDR ;
             PUSH mutez 1000000 ;
             SWAP ;
             SUB_MUTEZ ;
             IF_NONE { PUSH string "option is None" ; FAILWITH } {} ;
             NIL operation ;
             PAIR } } |}]

let%expect_test _ =
  run_ligo_good [ "compile" ; "contract" ; (test "sub_mutez_new.religo") ; "--protocol" ; "ithaca" ] ;
  [%expect{|
    { parameter unit ;
      storage mutez ;
      code { CDR ;
             PUSH mutez 1000000 ;
             SWAP ;
             SUB_MUTEZ ;
             IF_NONE { PUSH string "option is None" ; FAILWITH } {} ;
             NIL operation ;
             PAIR } } |}]

let%expect_test _ =
  run_ligo_good [ "compile" ; "contract" ; (test "sub_mutez_new.jsligo") ; "--protocol" ; "ithaca" ] ;
  [%expect{|
    { parameter unit ;
      storage mutez ;
      code { PUSH mutez 1000000 ;
             SWAP ;
             CDR ;
             SUB_MUTEZ ;
             IF_NONE { PUSH string "option is None" ; FAILWITH } {} ;
             NIL operation ;
             PAIR } } |}]

let%expect_test _ =
  run_ligo_good [ "print" ; "ast-typed" ; (test "sub_mutez_new.mligo") ; "--protocol" ; "ithaca" ] ;
  [%expect{xxx|
    const sub =
      lambda (gen#2) return  match gen#2 with
                              | ( store , delta ) ->
                              SUB_MUTEZ(store , delta)
    const main =
      lambda (gen#3) return  match gen#3 with
                              | ( _#4 , store ) ->
                              ( LIST_EMPTY() , (Option.unopt@{tez})@((sub)@(( store , 1000000mutez ))) ) |xxx}]

let%expect_test _ =
  run_ligo_good [ "print" ; "ast-typed" ; (test "sub_mutez_new.ligo") ; "--protocol" ; "ithaca" ] ;
  [%expect{xxx|
    const sub =
      lambda (parameters#62) return  match parameters#62 with
                                      | ( store , delta ) ->
                                      SUB_MUTEZ(store , delta)
    const main =
      lambda (parameters#64) return  match parameters#64 with
                                      | ( _#63 , store ) ->
                                      ( LIST_EMPTY() , (Option.unopt@{tez})@((sub)@(( store , 1000000mutez ))) ) |xxx}]

let%expect_test _ =
  run_ligo_good [ "print" ; "ast-typed" ; (test "sub_mutez_new.religo") ; "--protocol" ; "ithaca" ] ;
  [%expect{xxx|
    const sub =
      lambda (gen#62) return  match gen#62 with
                               | ( store , delta ) ->
                               SUB_MUTEZ(store , delta)
    const main =
      lambda (gen#63) return  match gen#63 with
                               | ( _#64 , store ) ->
                               ( LIST_EMPTY() , (Option.unopt@{tez})@((sub)@(( store , 1000000mutez ))) ) |xxx}]

let%expect_test _ =
  run_ligo_good [ "print" ; "ast-typed" ; (test "sub_mutez_new.jsligo") ; "--protocol" ; "ithaca" ] ;
  [%expect{xxx|
    const sub =
      lambda (gen#62) return let store = gen#62.0 in let delta = gen#62.1 in SUB_MUTEZ(store ,
      delta)[@private]
    const main =
      lambda (gen#64) return let _#63 = gen#64.0 in let store = gen#64.1 in
      ( LIST_EMPTY() , (Option.unopt@{tez})@((sub)@(( store , 1000000mutez ))) )[@private] |xxx}]

let%expect_test _ =
  run_ligo_good [ "print" ; "ast-core" ; (test "sub_mutez_new.mligo") ] ;
  [%expect{|
    const sub : ( tez * tez ) -> option (tez) =
      lambda (gen#2 : ( tez * tez )) : option (tez) return  match gen#2 with
                                                             | (store,delta) ->
                                                             C_POLYMORPHIC_SUB
                                                             (store ,
                                                              delta)
    const main : ( unit * tez ) -> ( list (operation) * tez ) =
      lambda (gen#3 : ( unit * tez )) : ( list (operation) * tez ) return
       match gen#3 with
        | (_#4,store) -> ( LIST_EMPTY() : list (operation) ,
                           (Option.unopt)@((sub)@(( store , 1000000mutez ))) ) |}]

let%expect_test _ =
  run_ligo_good [ "print" ; "ast-core" ; (test "sub_mutez_new.ligo") ] ;
  [%expect{|
    const sub : ( tez * tez ) -> option (tez) =
      lambda (parameters#2 : ( tez * tez )) : option (tez) return  match
                                                                    parameters#2 with
                                                                    | (store : tez,delta : tez) ->
                                                                    C_POLYMORPHIC_SUB
                                                                    (store ,
                                                                     delta)
    const main : ( unit * tez ) -> ( list (operation) * tez ) =
      lambda (parameters#4 : ( unit * tez )) : ( list (operation) * tez ) return
       match parameters#4 with
        | (_#3 : unit,store : tez) -> ( LIST_EMPTY() : list (operation) ,
                                        (Option.unopt)@((sub)@(( store ,
                                                                 1000000mutez ))) ) |}]

let%expect_test _ =
  run_ligo_good [ "print" ; "ast-core" ; (test "sub_mutez_new.religo") ] ;
  [%expect{|
    const sub =
      lambda (gen#2 : ( tez * tez )) : option (tez) return  match gen#2 with
                                                             | (store,delta) ->
                                                             C_POLYMORPHIC_SUB
                                                             (store ,
                                                              delta)
    const main =
      lambda (gen#3 : ( unit * tez )) : ( list (operation) * tez ) return
       match gen#3 with
        | (_#4,store) -> ( LIST_EMPTY() : list (operation) ,
                           (Option.unopt)@((sub)@(( store , 1000000mutez ))) ) |}]

let%expect_test _ =
  run_ligo_good [ "print" ; "ast-core" ; (test "sub_mutez_new.jsligo") ] ;
  [%expect{|
    const sub[@var] =
      rec (sub:( tez * tez ) -> option (tez) => lambda (gen#2 : ( tez * tez )) : option (tez) return
      let store = gen#2.0 in
      let delta = gen#2.1 in C_POLYMORPHIC_SUB(store , delta) )[@private]
    const main[@var] =
      rec (main:( unit * tez ) -> ( list (operation) * tez ) => lambda (gen#4 :
      ( unit * tez )) : ( list (operation) * tez ) return let _#3 = gen#4.0 in
                                                          let store = gen#4.1 in
                                                          ( LIST_EMPTY() : list (operation) ,
                                                            (Option.unopt)@(
                                                            (sub)@(( store ,
                                                                     1000000mutez ))) ) )[@private] |}]
