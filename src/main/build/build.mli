module Stdlib = Stdlib
module Source_input = BuildSystem.Source_input

val loc : Stdlib.Location.t

module type Params = sig
  val raise : (Main_errors.all, Main_warnings.all) Simple_utils.Trace.raise
  val options : Compiler_options.t
  val std_lib : Stdlib.t
  val top_level_syntax : Syntax_types.t
end

module M : functor (Params : Params) -> sig
  val raise : (Main_errors.all, Main_warnings.all) Simple_utils.Trace.raise
  val options : Compiler_options.t
  val std_lib : Stdlib.t
  val top_level_syntax : Syntax_types.t

  type file_name = Source_input.file_name
  type raw_input = Source_input.raw_input
  type code_input = Source_input.code_input
  type module_name = string
  type compilation_unit = Buffer.t
  type meta_data = Ligo_compile.Helpers.meta

  val preprocess
    :  code_input
    -> compilation_unit * meta_data * (module_name * module_name) list

  module AST : sig
    type declaration = Ast_typed.declaration
    type signature = Ast_typed.signature
    type t = Ast_typed.program
    type environment = Environment.t
    type sig_environment = Environment.signature

    val add_ast_to_env : t -> environment -> environment

    val add_module_to_env
      :  module_name
      -> environment
      -> sig_environment
      -> environment
      -> environment

    val init_env : environment
    val make_module_declaration : module_name -> t -> signature -> declaration
  end

  val lib_ast : unit -> AST.t
  val compile : AST.environment -> module_name -> meta_data -> compilation_unit -> AST.t
end

module Infer : functor (Params : Params) -> sig
  val raise : (Main_errors.all, Main_warnings.all) Simple_utils.Trace.raise
  val options : Compiler_options.t
  val std_lib : Stdlib.t
  val top_level_syntax : Syntax_types.t

  type file_name = Source_input.file_name
  type raw_input = Source_input.raw_input
  type code_input = Source_input.code_input
  type module_name = string
  type compilation_unit = Buffer.t
  type meta_data = Ligo_compile.Helpers.meta

  val preprocess
    :  code_input
    -> compilation_unit * meta_data * (module_name * module_name) list

  module AST : sig
    type declaration = Ast_core.declaration
    type t = Ast_core.program
    type environment = unit

    val add_ast_to_env : t -> environment -> environment
    val add_module_to_env : module_name -> environment -> environment -> environment
    val init_env : environment
    val make_module_declaration : module_name -> t -> declaration
  end

  val lib_ast : unit -> AST.t
  val compile : AST.environment -> module_name -> meta_data -> compilation_unit -> AST.t
end

type expression_mini_c =
  { expression : Mini_c.expression
  ; ast_type : Ast_aggregated.type_expression
  }

type expression_michelson =
  { expression : Stacking.compiled_expression
  ; ast_type : Ast_aggregated.type_expression
  }

type ('a, 'b) named =
  { name : 'a
  ; value : 'b
  }

type contract_michelson =
  { entrypoint : (Ligo_prim.Value_var.t, Stacking.compiled_expression) named
  ; views : (Ligo_prim.Value_var.t, Stacking.compiled_expression) named list
  }

val qualified_typed
  :  raise:(Main_errors.all, Main_warnings.all) Simple_utils.Trace.raise
  -> options:Compiler_options.t
  -> ?cform:Ligo_compile.Of_core.form
  -> Source_input.code_input
  -> Ast_typed.program

val qualified_typed_with_signature
  :  raise:(Main_errors.all, Main_warnings.all) Simple_utils.Trace.raise
  -> options:Compiler_options.t
  -> ?cform:Ligo_compile.Of_core.form
  -> Source_input.code_input
  -> Ast_typed.program * Ast_typed.signature

val build_contract_meta_ligo
  :  raise:(Main_errors.all, Main_warnings.all) Simple_utils.Trace.raise
  -> options:Compiler_options.t
  -> string list
  -> string list
  -> string
  -> Ligo_prim__Var.Value_var.t
     * Ast_aggregated.Types.expression
     * (Ligo_prim__Var.Value_var.t list * Ast_aggregated.Types.expression) option

val parse_module_path
  :  loc:Stdlib.Location.t
  -> string
  -> Ligo_prim__Var.Module_var.t list

val build_expression
  :  raise:(Main_errors.all, Main_warnings.all) Simple_utils.Trace.raise
  -> options:Compiler_options.t
  -> Syntax_types.t
  -> string
  -> string option
  -> expression_michelson

val dependency_graph
  :  raise:(Main_errors.all, Main_warnings.all) Simple_utils.Trace.raise
  -> options:Compiler_options.t
  -> ?cform:Ligo_compile.Of_core.form
  -> string
  -> Graph__Persistent.Digraph.Concrete(BuildSystem__Types.Node).t
     * (string * Ligo_compile.Helpers.meta * Buffer.t * (string * string) list)
       Stdlib__Map.Make(Stdlib__String).t

val build_contract
  :  raise:(Main_errors.all, Main_warnings.all) Simple_utils.Trace.raise
  -> options:Compiler_options.t
  -> string list
  -> string
  -> string list
  -> Source_input.code_input
  -> contract_michelson

val qualified_core
  :  raise:(Main_errors.all, Main_warnings.all) Simple_utils.Trace.raise
  -> options:Compiler_options.t
  -> Source_input.code_input
  -> Ast_core.program

val qualified_core_from_string
  :  raise:(Main_errors.all, Main_warnings.all) Simple_utils.Trace.raise
  -> options:Compiler_options.t
  -> Source_input.raw_input
  -> Ast_core.program

val qualified_core_from_raw_input
  :  raise:(Main_errors.all, Main_warnings.all) Simple_utils.Trace.raise
  -> options:Compiler_options.t
  -> string
  -> string
  -> Ast_core.program

val unqualified_core
  :  raise:(Main_errors.all, Main_warnings.all) Simple_utils.Trace.raise
  -> options:Compiler_options.t
  -> Source_input.file_name
  -> Ast_core.program

val qualified_typed_str
  :  raise:(Main_errors.all, Main_warnings.all) Simple_utils.Trace.raise
  -> options:Compiler_options.t
  -> string
  -> Ast_typed.program
