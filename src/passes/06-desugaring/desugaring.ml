module Errors = Errors
module Compiler = Compiler
module Decompiler = Decompiler

let compile_program = Compiler.compile_program
let compile_expression = Compiler.compile_expression
let decompile_program = Decompiler.decompile_program
let decompile_expression = Decompiler.decompile_expression
