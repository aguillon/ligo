open Test_helpers

let () =
  Printexc.record_backtrace true;
  run_test
  @@ test_suite
       "Contract test"
       [ (*Coase_tests.main *)
         Vote_tests.main
       ; Id_tests.main (* ; Id_tests_p.main *)
       ; Basic_multisig_tests.main
       ; Multisig_tests.main
         (* ; Multisig_v2_tests.main *)
         (* ; Replaceable_id_tests.main *)
         (* ; Time_lock_tests.main *)
         (* ; Hash_lock_tests.main *)
         (* ; Hash_lock_tests_p.main *)
       ; Time_lock_repeat_tests.main
       ; Pledge_tests.main
       ; Tzip5_tests.main
       ; Tzip7_tests.main
       ; Positive_contract_tests.main
       ];
  ()
