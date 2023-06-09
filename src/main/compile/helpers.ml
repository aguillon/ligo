open Simple_utils.Trace
open Main_errors

type meta = { syntax : Syntax_types.t }

let protocol_to_variant ~raise : string -> Environment.Protocols.t =
 fun s ->
  trace_option
    ~raise
    (main_invalid_protocol_version Environment.Protocols.protocols_str s)
  @@ Environment.Protocols.protocols_to_variant s


(* Preprocessing *)

type options = Compiler_options.t

let preprocess_file ~raise ~(options : Compiler_options.frontend) ~(meta : meta) file_path
    : Preprocessor.LowAPI.success
  =
  let open Preprocessing in
  let Compiler_options.{ project_root; libraries; _ } = options in
  let preprocess_file =
    match meta.syntax with
    | CameLIGO -> Cameligo.preprocess_file
    | JsLIGO -> Jsligo.preprocess_file
    | PascaLIGO -> Pascaligo.preprocess_file
  in
  trace ~raise preproc_tracer
  @@ Simple_utils.Trace.from_result (preprocess_file ?project_root libraries file_path)


let preprocess_string
    ~raise
    ~(options : Compiler_options.frontend)
    ~(meta : meta)
    file_path
  =
  let open Preprocessing in
  let Compiler_options.{ project_root; libraries; _ } = options in
  let preprocess_string =
    match meta.syntax with
    | CameLIGO -> Cameligo.preprocess_string
    | JsLIGO -> Jsligo.preprocess_string
    | PascaLIGO -> Pascaligo.preprocess_string
  in
  trace ~raise preproc_tracer
  @@ from_result (preprocess_string ?project_root libraries file_path)


let preprocess_raw_input
    ~raise
    ~(options : Compiler_options.frontend)
    ~(meta : meta)
    file_path
    input
  =
  let open Preprocessing in
  let Compiler_options.{ project_root; libraries; _ } = options in
  let preprocess_raw_input =
    match meta.syntax with
    | CameLIGO -> Cameligo.preprocess_raw_input
    | JsLIGO -> Jsligo.preprocess_raw_input
    | PascaLIGO -> Pascaligo.preprocess_raw_input
  in
  trace ~raise preproc_tracer
  @@ from_result (preprocess_raw_input ?project_root libraries (file_path, input))


(* Front-end compilation *)

type file_path = string

let parse_and_abstract_cameligo ~raise buffer file_path =
  let raw = trace ~raise parser_tracer @@ Parsing.Cameligo.parse_file buffer file_path in
  let imperative =
    trace ~raise cit_cameligo_tracer @@ Tree_abstraction.Cameligo.compile_program raw
  in
  imperative


let parse_and_abstract_expression_cameligo ~raise buffer =
  let raw = trace ~raise parser_tracer @@ Parsing.Cameligo.parse_expression buffer in
  let imperative =
    trace ~raise (Fn.compose cit_cameligo_tracer List.return)
    @@ Tree_abstraction.Cameligo.compile_expression raw
  in
  imperative


let parse_and_abstract_jsligo ~raise buffer file_path =
  let raw = trace ~raise parser_tracer @@ Parsing.Jsligo.parse_file buffer file_path in
  let imperative =
    trace ~raise cit_jsligo_tracer @@ Tree_abstraction.Jsligo.compile_program raw
  in
  imperative


let parse_and_abstract_expression_jsligo ~raise buffer =
  let raw = trace ~raise parser_tracer @@ Parsing.Jsligo.parse_expression buffer in
  let imperative =
    trace ~raise (Fn.compose cit_jsligo_tracer List.return)
    @@ Tree_abstraction.Jsligo.compile_expression raw
  in
  imperative


let parse_and_abstract_pascaligo ~raise buffer file_path =
  let raw = trace ~raise parser_tracer @@ Parsing.Pascaligo.parse_file buffer file_path in
  let imperative =
    trace ~raise cit_pascaligo_tracer @@ Tree_abstraction.Pascaligo.compile_program raw
  in
  imperative


let parse_and_abstract_expression_pascaligo ~raise buffer =
  let raw = trace ~raise parser_tracer @@ Parsing.Pascaligo.parse_expression buffer in
  let imperative =
    trace ~raise (Fn.compose cit_pascaligo_tracer List.return)
    @@ Tree_abstraction.Pascaligo.compile_expression raw
  in
  imperative


let parse_and_abstract ~raise ~(meta : meta) buffer file_path : Ast_imperative.program =
  let parse_and_abstract =
    match meta.syntax with
    | CameLIGO -> parse_and_abstract_cameligo
    | JsLIGO -> parse_and_abstract_jsligo
    | PascaLIGO -> parse_and_abstract_pascaligo
  in
  let abstracted = parse_and_abstract ~raise buffer file_path in
  let js_style_no_shadowing = Syntax_types.equal meta.syntax JsLIGO in
  let applied =
    trace ~raise self_ast_imperative_tracer
    @@ Self_ast_imperative.all_program abstracted ~js_style_no_shadowing
  in
  applied


let parse_and_abstract_expression ~raise ~(meta : meta) buffer =
  let parse_and_abstract =
    match meta.syntax with
    | CameLIGO -> parse_and_abstract_expression_cameligo
    | JsLIGO -> parse_and_abstract_expression_jsligo
    | PascaLIGO -> parse_and_abstract_expression_pascaligo
  in
  let abstracted = parse_and_abstract ~raise buffer in
  let js_style_no_shadowing = Caml.( = ) meta.syntax JsLIGO in
  let applied =
    trace ~raise self_ast_imperative_tracer
    @@ Self_ast_imperative.all_expression ~js_style_no_shadowing abstracted
  in
  applied


let parse_and_abstract_string_cameligo ~raise buffer =
  let raw = trace ~raise parser_tracer @@ Parsing.Cameligo.parse_string buffer in
  let imperative =
    trace ~raise cit_cameligo_tracer @@ Tree_abstraction.Cameligo.compile_program raw
  in
  imperative


let parse_and_abstract_string_jsligo ~raise buffer =
  let raw = trace ~raise parser_tracer @@ Parsing.Jsligo.parse_string buffer in
  let imperative =
    trace ~raise cit_jsligo_tracer @@ Tree_abstraction.Jsligo.compile_program raw
  in
  imperative


let parse_and_abstract_string_pascaligo ~raise buffer =
  let raw = trace ~raise parser_tracer @@ Parsing.Pascaligo.parse_string buffer in
  let imperative =
    trace ~raise cit_pascaligo_tracer @@ Tree_abstraction.Pascaligo.compile_program raw
  in
  imperative


let parse_and_abstract_string ~raise (syntax : Syntax_types.t) buffer =
  let parse_and_abstract =
    match syntax with
    | CameLIGO -> parse_and_abstract_string_cameligo
    | JsLIGO -> parse_and_abstract_string_jsligo
    | PascaLIGO -> parse_and_abstract_string_pascaligo
  in
  let abstracted = parse_and_abstract ~raise buffer in
  let js_style_no_shadowing = Caml.( = ) syntax JsLIGO in
  let applied =
    trace ~raise self_ast_imperative_tracer
    @@ Self_ast_imperative.all_program abstracted ~js_style_no_shadowing
  in
  applied


let pretty_print_cameligo_cst = Parsing.Cameligo.pretty_print_cst
let pretty_print_jsligo_cst = Parsing.Jsligo.pretty_print_cst
let pretty_print_pascaligo_cst = Parsing.Pascaligo.pretty_print_cst

let pretty_print_cst ~raise ~(meta : meta) buffer file_path =
  let print =
    match meta.syntax with
    | CameLIGO -> pretty_print_cameligo_cst
    | JsLIGO -> pretty_print_jsligo_cst
    | PascaLIGO -> pretty_print_pascaligo_cst
  in
  trace ~raise parser_tracer @@ print buffer file_path


let pretty_print_cameligo = Parsing.Cameligo.pretty_print_file
let pretty_print_jsligo = Parsing.Jsligo.pretty_print_file
let pretty_print_pascaligo = Parsing.Pascaligo.pretty_print_file

let pretty_print ?preprocess ~raise ~(meta : meta) buffer file_path =
  let print =
    match meta.syntax with
    | CameLIGO -> pretty_print_cameligo
    | JsLIGO -> pretty_print_jsligo
    | PascaLIGO -> pretty_print_pascaligo
  in
  trace ~raise parser_tracer @@ print ?preprocess buffer file_path
