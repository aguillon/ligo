(* Driver for the CameLIGO lexer *)

(* Local dependencies *)

module Config        = Preprocessing_cameligo.Config
module PreprocParams = Preprocessor.CLI.Make (Config)
module Token         = Lexing_cameligo.Token
module UnitPasses    = Lx_ml_self_units.Self
module TokenPasses   = Lx_ml_self_tokens.Self

(* Vendors dependencies *)

module Std        = Simple_utils.Std
module Lexbuf     = Simple_utils.Lexbuf
module Parameters = LexerLib.CLI.Make (PreprocParams)
module PreprocAPI = Preprocessor.TopAPI.Make (PreprocParams)

module Warning =
  struct
    let add _ = () (* No warning registered *)
  end

module API =
  Lexing_shared.TopAPI.Make
    (PreprocAPI) (Parameters) (Token)
    (UnitPasses) (TokenPasses) (Warning)

let () =
  let open! API in
  let no_colour = Parameters.Options.no_colour in
  match check_cli () with
    Ok ->
      let std =
        match Parameters.Options.string with
          Some s ->
            let input = Lexbuf.String ("", s) in
            fst (scan_all_tokens ~no_colour input)
        | None ->
            let file = Option.value Parameters.Options.input ~default:"" in
            fst (scan_all_tokens ~no_colour (Lexbuf.File file))
      in
      let () = Std.(add_nl std.out) in
      let () = Std.(add_nl std.err) in
      Printf.printf  "%s%!" (Std.string_of std.out);
      Printf.eprintf "%s%!" (Std.string_of std.err)

  | Error msg -> Printf.eprintf "%s\n%!" msg
  | Info  msg -> Printf.printf "%s%!" msg (* Note the absence of "\n" *)
