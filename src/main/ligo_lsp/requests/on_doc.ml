(* TODO: use String, Option, Set, List & Hashtbl from Core *)
open Linol_lwt
module Hashtbl = Caml.Hashtbl
module List = Caml.List
open Handler
module Diagnostics = Diagnostics

(* We define here a helper that will:
       - process a document
       - store the state resulting from the processing
       - return the diagnostics from the new state
    *)
let on_doc : DocumentUri.t -> string -> unit Handler.t =
 fun uri contents ->
  let open Ligo_interface in
  let@ () = send_debug_msg @@ "Updating DOC :" ^ DocumentUri.to_string uri in
  let@ get_scope_buffers = ask_docs_cache in
  let@ syntax =
    match Utils.get_syntax uri with
    | None ->
      lift_IO
      @@ failwith
      @@ "Expected file with LIGO code, got: "
      ^ DocumentUri.to_path uri
    | Some s -> return s
  in
  let new_state = Ligo_interface.get_scope uri contents in
  Hashtbl.replace
    get_scope_buffers
    uri
    { get_scope_info = new_state; syntax; code = contents };
  let@ { max_number_of_problems; _ } = ask_config in
  let deprecation_warnings =
    match syntax with
    | PascaLIGO ->
      [ Diagnostics.
          { range = None
          ; message = "PascaLIGO is not officially supported in this LIGO version"
          ; severity = DiagnosticSeverity.Warning
          }
      ]
    | CameLIGO | JsLIGO -> []
  in
  let simple_diags = Diagnostics.get_diagnostics new_state in
  let diags =
    List.map
      Diagnostics.from_simple_diagnostic
      (Utils.take max_number_of_problems @@ simple_diags @ deprecation_warnings)
  in
  send_diagnostic diags
