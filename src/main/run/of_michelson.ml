module Michelson = Tezos_utils.Michelson
module Location = Simple_utils.Location
open Proto_alpha_utils
open Simple_utils.Trace
open Memory_proto_alpha.Protocol.Script_ir_translator
open Memory_proto_alpha.X
open Simple_utils.Runned_result
module Errors = Main_errors

let parse_constant ~raise code =
  let open Tezos_micheline in
  let open Tezos_micheline.Micheline in
  let code, errs = Micheline_parser.tokenize code in
  let code =
    match errs with
    | _ :: _ ->
      raise.error
        (Errors.unparsing_michelson_tracer
        @@ List.map ~f:(fun x -> `Tezos_alpha_error x) errs)
    | [] ->
      let code, errs = Micheline_parser.parse_expression ~check:false code in
      (match errs with
      | _ :: _ ->
        raise.error
          (Errors.unparsing_michelson_tracer
          @@ List.map ~f:(fun x -> `Tezos_alpha_error x) errs)
      | [] -> map_node (fun _ -> ()) (fun x -> x) code)
  in
  Trace.trace_alpha_tzresult ~raise Errors.unparsing_michelson_tracer
  @@ Memory_proto_alpha.node_to_canonical code


type options = Memory_proto_alpha.options

type dry_run_options =
  { parameter_ty : (Stacking.Program.meta, string) Tezos_micheline.Micheline.node option
        (* added to allow dry-running contract using `Tezos.self` *)
  ; amount : string
  ; balance : string
  ; now : string option
  ; sender : string option
  ; source : string option
  }

(* Shouldn't this be done by the cli parser ? *)
let make_dry_run_options ~raise ?tezos_context ?(constants = []) (opts : dry_run_options)
    : options
  =
  let open Proto_alpha_utils.Trace in
  let open Proto_alpha_utils.Memory_proto_alpha in
  let open Protocol.Alpha_context in
  let balance =
    match Tez.of_string opts.balance with
    | None -> raise.error @@ Errors.main_invalid_balance opts.balance
    | Some balance -> balance
  in
  let amount =
    match Tez.of_string opts.amount with
    | None -> raise.error @@ Errors.main_invalid_amount opts.amount
    | Some amount -> amount
  in
  let sender =
    match opts.sender with
    | None -> None
    | Some sender ->
      let sender =
        trace_alpha_tzresult
          ~raise
          (fun _ -> Errors.main_invalid_sender sender)
          (Contract.of_b58check sender)
      in
      Some sender
  in
  let source =
    match opts.source with
    | None -> None
    | Some source ->
      let source =
        trace_alpha_tzresult
          ~raise
          (fun _ -> Errors.main_invalid_source source)
          (Contract.of_b58check source)
      in
      Some source
  in
  let now =
    match opts.now with
    | None -> None
    | Some st ->
      (match Memory_proto_alpha.Protocol.Script_timestamp.of_string st with
      | Some t -> Some t
      | None -> raise.error @@ Errors.main_invalid_timestamp st)
  in
  let parameter_ty =
    match opts.parameter_ty with
    | Some x ->
      let x =
        Trace.trace_tzresult_lwt ~raise Errors.parsing_payload_tracer
        @@ Memory_proto_alpha.prims_of_strings x
      in
      let x = Tezos_micheline.Micheline.strip_locations x in
      Some x
    | None -> None
  in
  (* Parse constants *)
  let constants = List.map ~f:(parse_constant ~raise) constants in
  make_options
    ?tezos_context
    ~constants
    ?now
    ~amount
    ~balance
    ?sender
    ?source
    ?parameter_ty
    ()


let ex_value_ty_to_michelson ~raise (v : ex_typed_value) : _ Michelson.t * _ Michelson.t =
  let (Ex_typed_value (ty, value)) = v in
  let ty' =
    Trace.trace_tzresult_lwt ~raise Errors.unparsing_michelson_tracer
    @@ Memory_proto_alpha.unparse_michelson_ty ty
  in
  let value' =
    Trace.trace_tzresult_lwt ~raise Errors.unparsing_michelson_tracer
    @@ Memory_proto_alpha.unparse_michelson_data ty value
  in
  ty', value'


let pack_payload ~raise (payload : _ Michelson.t) ty =
  let ty =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_payload_tracer
    @@ Memory_proto_alpha.prims_of_strings ty
  in
  let (Ex_ty ty) =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_payload_tracer
    @@ Memory_proto_alpha.parse_michelson_ty ty
  in
  let payload =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_input_tracer
    @@ Memory_proto_alpha.prims_of_strings payload
  in
  let payload =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_payload_tracer
    @@ Memory_proto_alpha.parse_michelson_data payload ty
  in
  let data =
    Trace.trace_tzresult_lwt ~raise Errors.packing_payload_tracer
    @@ Memory_proto_alpha.pack ty payload
  in
  data


let fetch_lambda_types ~raise (contract_ty : _ Michelson.t) =
  match contract_ty with
  | Prim (_, "lambda", [ in_ty; out_ty ], _) -> in_ty, out_ty
  | _ -> raise.error Errors.main_unknown (*TODO*)


let run_contract
    ~raise
    ?options
    (exp : _ Michelson.t)
    (exp_type : _ Michelson.t)
    (input_michelson : _ Michelson.t)
  =
  let open! Memory_proto_alpha.Protocol in
  let input_ty, output_ty = fetch_lambda_types ~raise exp_type in
  let input_ty =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_input_tracer
    @@ Memory_proto_alpha.prims_of_strings input_ty
  in
  let param_type, storage_type =
    match input_ty with
    | Prim (_, T_pair, x :: y :: ys, _) ->
      let y =
        if List.is_empty ys
        then y
        else
          Tezos_micheline.Micheline.Prim (-1, Michelson_v1_primitives.T_pair, y :: ys, [])
      in
      x, y
    | _ -> failwith ("Internal error: input_ty was not a pair " ^ __LOC__)
  in
  let (Ex_ty input_ty) =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_input_tracer
    @@ Memory_proto_alpha.parse_michelson_ty input_ty
  in
  let (Ex_ty param_type) =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_input_tracer
    @@ Memory_proto_alpha.parse_michelson_ty param_type
  in
  let (Ex_ty storage_type) =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_input_tracer
    @@ Memory_proto_alpha.parse_michelson_ty storage_type
  in
  let output_ty =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_input_tracer
    @@ Memory_proto_alpha.prims_of_strings output_ty
  in
  let (Ex_ty output_ty) =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_input_tracer
    @@ Memory_proto_alpha.parse_michelson_ty output_ty
  in
  let input_michelson =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_input_tracer
    @@ Memory_proto_alpha.prims_of_strings input_michelson
  in
  let input =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_input_tracer
    @@ Memory_proto_alpha.parse_michelson_data input_michelson input_ty
  in
  let ty_stack_before = Script_typed_ir.Item_t (input_ty, Bot_t) in
  let ty_stack_after = Script_typed_ir.Item_t (output_ty, Bot_t) in
  let top_level =
    (* original_type_expr is probably wrong *)
    let entrypoints =
      Script_typed_ir.
        { root = Script_typed_ir.no_entrypoints; original_type_expr = Int (0, Z.zero) }
    in
    Script_tc_context.toplevel ~storage_type ~param_type ~entrypoints
  in
  let (descr : (_, _, _, _) descr) =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_code_tracer
    @@ Memory_proto_alpha.parse_michelson_fail
         ~top_level
         exp
         ty_stack_before
         ty_stack_after
  in
  let open! Memory_proto_alpha.Protocol.Script_interpreter in
  let res =
    Trace.trace_tzresult_lwt ~raise Errors.error_of_execution_tracer
    @@ Memory_proto_alpha.failure_interpret ?options descr input (EmptyCell, EmptyCell)
  in
  match res with
  | Memory_proto_alpha.Succeed output ->
    let ty, value =
      ex_value_ty_to_michelson ~raise (Ex_typed_value (output_ty, output))
    in
    Success (ty, value)
  | Memory_proto_alpha.Fail expr ->
    let expr =
      Tezos_micheline.Micheline.root
      @@ Memory_proto_alpha.Protocol.Michelson_v1_primitives.strings_of_prims expr
    in
    Fail expr


let run_function
    ~raise
    ?options
    (exp : _ Michelson.t)
    (exp_type : _ Michelson.t)
    (input_michelson : _ Michelson.t)
  =
  let open! Memory_proto_alpha.Protocol in
  let input_ty, output_ty = fetch_lambda_types ~raise exp_type in
  let input_ty =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_input_tracer
    @@ Memory_proto_alpha.prims_of_strings input_ty
  in
  let (Ex_ty input_ty) =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_input_tracer
    @@ Memory_proto_alpha.parse_michelson_ty input_ty
  in
  let output_ty =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_input_tracer
    @@ Memory_proto_alpha.prims_of_strings output_ty
  in
  let (Ex_ty output_ty) =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_input_tracer
    @@ Memory_proto_alpha.parse_michelson_ty output_ty
  in
  let input_michelson =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_input_tracer
    @@ Memory_proto_alpha.prims_of_strings input_michelson
  in
  let tezos_context =
    Option.map ~f:(fun ({ tezos_context; _ } : options) -> tezos_context) options
  in
  let input =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_input_tracer
    @@ Memory_proto_alpha.parse_michelson_data ?tezos_context input_michelson input_ty
  in
  let ty_stack_before = Script_typed_ir.Item_t (input_ty, Bot_t) in
  let ty_stack_after = Script_typed_ir.Item_t (output_ty, Bot_t) in
  let top_level = Script_tc_context.(add_lambda (init Data)) in
  let exp' =
    match exp with
    | Seq (_, [ Prim (_, "LAMBDA", [ _; _; v ], _) ]) -> v
    | _ -> failwith "not lambda"
  in
  let (descr : (_, _, _, _) descr) =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_code_tracer
    @@ Memory_proto_alpha.parse_michelson_fail
         ~top_level
         exp'
         ty_stack_before
         ty_stack_after
  in
  let open! Memory_proto_alpha.Protocol.Script_interpreter in
  let res =
    Trace.trace_tzresult_lwt ~raise Errors.error_of_execution_tracer
    @@ Memory_proto_alpha.failure_interpret ?options descr input (EmptyCell, EmptyCell)
  in
  match res with
  | Memory_proto_alpha.Succeed output ->
    let ty, value =
      ex_value_ty_to_michelson ~raise (Ex_typed_value (output_ty, output))
    in
    Success (ty, value)
  | Memory_proto_alpha.Fail expr ->
    let expr =
      Tezos_micheline.Micheline.root
      @@ Memory_proto_alpha.Protocol.Michelson_v1_primitives.strings_of_prims expr
    in
    Fail expr


let run_expression
    ~raise
    ?options
    ?legacy
    (exp : _ Michelson.t)
    (exp_type : _ Michelson.t)
  =
  let open! Memory_proto_alpha.Protocol in
  let exp_type =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_input_tracer
    @@ Memory_proto_alpha.prims_of_strings exp_type
  in
  let (Ex_ty exp_type') =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_input_tracer
    @@ Memory_proto_alpha.parse_michelson_ty exp_type
  in
  let top_level = Script_tc_context.(init Data)
  and ty_stack_before = Script_typed_ir.Bot_t
  and ty_stack_after = Script_typed_ir.Item_t (exp_type', Bot_t) in
  let tezos_context =
    match options with
    | None -> None
    | Some o -> Some o.Memory_proto_alpha.tezos_context
  in
  let descr =
    Trace.trace_tzresult_lwt ~raise Errors.parsing_code_tracer
    @@ Memory_proto_alpha.parse_michelson_fail
         ?legacy
         ?tezos_context
         ~top_level
         exp
         ty_stack_before
         ty_stack_after
  in
  let open! Memory_proto_alpha.Protocol.Script_interpreter in
  let res =
    Trace.trace_tzresult_lwt ~raise Errors.error_of_execution_tracer
    @@ Memory_proto_alpha.failure_interpret ?options descr EmptyCell EmptyCell
  in
  match res with
  | Memory_proto_alpha.Succeed output ->
    let ty, value =
      ex_value_ty_to_michelson ~raise (Ex_typed_value (exp_type', output))
    in
    Success (ty, value)
  | Memory_proto_alpha.Fail expr ->
    let expr =
      Tezos_micheline.Micheline.root
      @@ Memory_proto_alpha.Protocol.Michelson_v1_primitives.strings_of_prims expr
    in
    Fail expr


let run_failwith ~raise ?options (exp : _ Michelson.t) (exp_type : _ Michelson.t)
    : (int, string) Tezos_micheline.Micheline.node
  =
  let expr = run_expression ~raise ?options exp exp_type in
  match expr with
  | Success _ ->
    raise.error
      Errors.main_unknown (* TODO : simple_fail "an error of execution was expected" *)
  | Fail res -> res


let run_no_failwith ~raise ?options (exp : _ Michelson.t) (exp_type : _ Michelson.t) =
  let expr = run_expression ~raise ?options exp exp_type in
  match expr with
  | Success tval -> tval
  | Fail _ ->
    raise.error
      Errors.main_unknown (* TODO : simple_fail "unexpected error of execution" *)


let evaluate_expression ~raise ?options exp exp_type =
  let etv = run_expression ~raise ?options exp exp_type in
  match etv with
  | Success (_, value) -> value
  | Fail res -> raise.error @@ Errors.main_execution_failed res


let evaluate_constant ~raise ?options exp exp_type =
  let etv = run_expression ~raise ?options exp exp_type in
  match etv with
  | Success (_, value) ->
    let value_ =
      Trace.trace_alpha_tzresult ~raise Errors.unparsing_michelson_tracer
      @@ Memory_proto_alpha.node_to_canonical value
    in
    let _, hash, _ =
      Trace.trace_alpha_tzresult_lwt ~raise (fun _ -> Errors.main_unknown)
      @@ Memory_proto_alpha.(
           register_constant (dummy_environment ()).tezos_context value_)
    in
    hash, value
  | Fail res -> raise.error @@ Errors.main_execution_failed res


let clean_expression exp =
  let open Tezos_micheline.Micheline in
  inject_locations (fun v -> v) (strip_locations exp)


let clean_constant ~raise exp =
  let open Tezos_micheline.Micheline in
  let value = inject_locations (fun v -> v) (strip_locations exp) in
  let value_ =
    Trace.trace_alpha_tzresult ~raise Errors.unparsing_michelson_tracer
    @@ Memory_proto_alpha.node_to_canonical value
  in
  let _, hash, _ =
    Trace.trace_alpha_tzresult_lwt ~raise (fun _ -> Errors.main_unknown)
    @@ Memory_proto_alpha.(register_constant (dummy_environment ()).tezos_context value_)
  in
  hash, value
