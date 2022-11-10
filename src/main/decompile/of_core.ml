open Ast_core
open Desugaring

let decompile (m : program) : Ast_imperative.program = decompile_program m

let decompile_expression (e : expression) : Ast_imperative.expression =
  decompile_expression e
