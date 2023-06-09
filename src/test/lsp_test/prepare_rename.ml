open Lsp.Types
module Requests = Ligo_lsp.Server.Requests
open Requests.Handler
open Common
open Handlers

type prepare_rename_test =
  { test_name : string
  ; file_path : string
  ; reference : Position.t
  ; can_rename : bool
  }

let get_prepare_rename_test
    ({ test_name; file_path; reference; can_rename } : prepare_rename_test)
    : unit Alcotest.test_case
  =
  Alcotest.test_case test_name `Quick
  @@ fun () ->
  let result, _diagnostics =
    test_run_session
    @@ let@ uri = open_file (to_absolute file_path) in
       Requests.on_req_prepare_rename reference uri
  in
  let error_prefix = Format.asprintf "In %s, %a: " file_path pp_position reference in
  match result with
  | None ->
    if can_rename
    then Alcotest.fail @@ error_prefix ^ "Cannot prepare rename for this reference."
    else ()
  | Some actual_range ->
    if can_rename
    then
      if Utils.is_position_in_range reference actual_range
      then ()
      else Alcotest.fail @@ error_prefix ^ "Reference is not contained within the range."
    else
      Alcotest.fail
      @@ error_prefix
      ^ "Should not be able to rename this identifier, but we can."


let test_cases =
  [ { test_name = "Identifier (definition)"
    ; file_path = "contracts/lsp/simple.mligo"
    ; reference = Position.create ~line:0 ~character:4
    ; can_rename = true
    }
  ; { test_name = "Identifier (reference)"
    ; file_path = "contracts/lsp/simple.mligo"
    ; reference = Position.create ~line:1 ~character:8
    ; can_rename = true
    }
    (* FIXME #1694 should not allow to rename assert
  ; { test_name = "Identifier from stdlib"
    ; file_path = "contracts/lsp/simple.mligo"
    ; reference = Position.create ~line:5 ~character:8
    ; can_rename = false
    } *)
  ; { test_name = "Number"
    ; file_path = "contracts/lsp/simple.mligo"
    ; reference = Position.create ~line:0 ~character:8
    ; can_rename = false
    }
  ; { test_name = "Type"
    ; file_path = "contracts/lsp/local_module.mligo"
    ; reference = Position.create ~line:2 ~character:8
    ; can_rename = true
    }
  ; { test_name = "Module"
    ; file_path = "contracts/lsp/local_module.mligo"
    ; reference = Position.create ~line:6 ~character:16
    ; can_rename = true
    }
  ; { test_name = "Built-in type"
    ; file_path = "contracts/lsp/local_module.mligo"
    ; reference = Position.create ~line:1 ~character:11
    ; can_rename = false
    }
    (* FIXME #1694 should not allow to rename bool
  ; { test_name = "Type from stdlib"
    ; file_path = "contracts/lsp/local_module.mligo"
    ; reference = Position.create ~line:5 ~character:28
    ; can_rename = false
    } *)
  ; { test_name = "Keyword"
    ; file_path = "contracts/lsp/simple.mligo"
    ; reference = Position.create ~line:0 ~character:0
    ; can_rename = false
    }
  ]


let tests = "prepare_rename", List.map ~f:get_prepare_rename_test test_cases
