(* Generic parser for LIGO *)

(* Main functor *)

module Make (Lexer: Lexer.S with module Token := LexToken)
            (Parser: module type of Parser)
            (ParErr: sig val message : int -> string end) =
  struct
    module I = Parser.MenhirInterpreter
    module S = MenhirLib.General (* Streams *)

    (* The call [stack checkpoint] extracts the parser's stack out of
       a checkpoint. *)

    let stack = function
      I.HandlingError env -> I.stack env
    |                   _ -> assert false

    (* The call [state checkpoint] extracts the number of the current
       state out of a parser checkpoint. *)

    let state checkpoint : int =
      match Lazy.force (stack checkpoint) with
        S.Nil -> 0 (* WARNING: Hack. The first state should be 0. *)
      | S.Cons (I.Element (s,_,_,_),_) -> I.number s

    (* The parser has successfully produced a semantic value. *)

    let success v = v

    (* The parser has suspended itself because of a syntax error. Stop. *)

    type message = string
    type valid   = Lexer.token
    type invalid = Lexer.token
    type error = message * valid option * invalid

    exception Point of error

    let failure get_win checkpoint =
      let message = ParErr.message (state checkpoint) in
      match get_win () with
        Lexer.Nil -> assert false
      | Lexer.One invalid ->
          raise (Point (message, None, invalid))
      | Lexer.Two (invalid, valid) ->
          raise (Point (message, Some valid, invalid))

    (* The two Menhir APIs are called from the following two functions. *)

    let incr_contract Lexer.{read; buffer; get_win; close; _} : AST.t =
      let supplier = I.lexer_lexbuf_to_supplier read buffer
      and failure  = failure get_win in
      let parser   = Parser.Incremental.contract buffer.Lexing.lex_curr_p in
      let ast      = I.loop_handle success failure supplier parser
      in close (); ast

    let mono_contract = Parser.contract

    (* Errors *)

    let format_error ?(offsets=true) mode (msg, valid_opt, invalid) =
      let invalid_region = LexToken.to_region invalid in
      let header =
        "Parse error " ^ invalid_region#to_string ~offsets mode in
      let trailer =
        match valid_opt with
          None ->
            if LexToken.is_eof invalid then ""
            else let invalid_lexeme = LexToken.to_lexeme invalid in
                 Printf.sprintf ", before \"%s\"" invalid_lexeme
        | Some valid ->
            let valid_lexeme = LexToken.to_lexeme valid in
            let s = Printf.sprintf ", after \"%s\"" valid_lexeme in
            if LexToken.is_eof invalid then s
            else
              let invalid_lexeme = LexToken.to_lexeme invalid in
              Printf.sprintf "%s and before \"%s\"" s invalid_lexeme in
      let header = header ^ trailer in
      header ^ (if msg = "" then ".\n" else ":\n" ^ msg)

  end
