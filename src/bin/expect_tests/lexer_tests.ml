open Cli_expect

let%expect_test _ =
  begin
    (* 1. Errors generated by Core.mll in vendors/LexerLib *)

    (* Invalid UTF-8 sequence *)

    (* TODO *)

    (* Unterminated comment *)

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/unterminated_comment.ligo"];
    [%expect {test|
File "../../test/lexer/LexerLib/unterminated_comment.ligo", line 1, characters 0-2:
  1 | (* not closed
File "../../test/lexer/LexerLib/unterminated_comment.ligo", line 1, characters 0-2:
Unterminated comment.
Hint: Close with "*)".
|test}];

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/unterminated_comment.mligo"];
    [%expect {test|
File "../../test/lexer/LexerLib/unterminated_comment.mligo", line 1, characters 0-2:
  1 | (* not closed
File "../../test/lexer/LexerLib/unterminated_comment.mligo", line 1, characters 0-2:
Unterminated comment.
Hint: Close with "*)".
|test}];

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/unterminated_comment.religo"];
    [%expect {test|
Reasonligo is depreacted, support will be dropped in a few versions.

Reasonligo is depreacted, support will be dropped in a few versions.

File "../../test/lexer/LexerLib/unterminated_comment.religo", line 1, characters 0-2:
  1 | /* not closed
File "../../test/lexer/LexerLib/unterminated_comment.religo", line 1, characters 0-2:
Unterminated comment.
Hint: Close with "*/".
|test}];

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/unterminated_comment.jsligo"];
    [%expect {test|
File "../../test/lexer/LexerLib/unterminated_comment.jsligo", line 1, characters 0-2:
  1 | /* not closed
File "../../test/lexer/LexerLib/unterminated_comment.jsligo", line 1, characters 0-2:
Unterminated comment.
Hint: Close with "*/".
|test}];

    (* Unterminated string *)

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/unterminated_string.ligo"];
    [%expect {test|
File "../../test/lexer/LexerLib/unterminated_string.ligo", line 1, characters 0-1:
  1 | "open
The string starting here is interrupted by a line break.
Hint: Remove the break, close the string before or insert a backslash.
|test}];

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/unterminated_string.mligo"];
    [%expect {test|
File "../../test/lexer/LexerLib/unterminated_string.mligo", line 1, characters 0-1:
  1 | "open
The string starting here is interrupted by a line break.
Hint: Remove the break, close the string before or insert a backslash.
|test}];

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/unterminated_string.religo"];
    [%expect {test|
Reasonligo is depreacted, support will be dropped in a few versions.

Reasonligo is depreacted, support will be dropped in a few versions.

File "../../test/lexer/LexerLib/unterminated_string.religo", line 1, characters 0-1:
  1 | "open
The string starting here is interrupted by a line break.
Hint: Remove the break, close the string before or insert a backslash.
|test}];

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/unterminated_string.jsligo"];
    [%expect {test|
File "../../test/lexer/LexerLib/unterminated_string.jsligo", line 1, characters 0-1:
  1 | "open
The string starting here is interrupted by a line break.
Hint: Remove the break, close the string before or insert a backslash.
|test}];

    (* Broken string *)

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/broken_string.ligo"];
    [%expect {test|
File "../../test/lexer/LexerLib/broken_string.ligo", line 1, characters 19-20:
  1 | const a : string = "broken
  2 | over
The string starting here is interrupted by a line break.
Hint: Remove the break, close the string before or insert a backslash.
|test}];

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/broken_string.mligo"];
    [%expect {test|
File "../../test/lexer/LexerLib/broken_string.mligo", line 1, characters 8-9:
  1 | let a = "broken
  2 | over
The string starting here is interrupted by a line break.
Hint: Remove the break, close the string before or insert a backslash.
|test}];

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/broken_string.religo"];
    [%expect {test|
Reasonligo is depreacted, support will be dropped in a few versions.

Reasonligo is depreacted, support will be dropped in a few versions.

File "../../test/lexer/LexerLib/broken_string.religo", line 1, characters 8-9:
  1 | let a = "broken
  2 | over
The string starting here is interrupted by a line break.
Hint: Remove the break, close the string before or insert a backslash.
|test}];

    run_ligo_bad [ "compile"; "contract";
                   "../../test/lexer/LexerLib/broken_string.jsligo"];
    [%expect {test|
File "../../test/lexer/LexerLib/broken_string.jsligo", line 1, characters 19-20:
  1 | const a : string = "broken
  2 | over
The string starting here is interrupted by a line break.
Hint: Remove the break, close the string before or insert a backslash.
|test}];

    (* Invalid character in string *)

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/invalid_character_in_string.ligo"];
    [%expect {test|
File "../../test/lexer/LexerLib/invalid_character_in_string.ligo", line 1, characters 20-21:
  1 | const z : string = "	";
Invalid character in string.
Hint: Remove or replace the character.
|test}];

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/invalid_character_in_string.mligo"];
    [%expect {test|
File "../../test/lexer/LexerLib/invalid_character_in_string.mligo", line 1, characters 9-10:
  1 | let z = "	";
Invalid character in string.
Hint: Remove or replace the character.
|test}];

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/invalid_character_in_string.religo"];
    [%expect {test|
Reasonligo is depreacted, support will be dropped in a few versions.

Reasonligo is depreacted, support will be dropped in a few versions.

File "../../test/lexer/LexerLib/invalid_character_in_string.religo", line 1, characters 9-10:
  1 | let z = "	";
Invalid character in string.
Hint: Remove or replace the character.
|test}];

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/invalid_character_in_string.jsligo"];
    [%expect {test|
File "../../test/lexer/LexerLib/invalid_character_in_string.jsligo", line 1, characters 11-12:
  1 | const z = "	";
Invalid character in string.
Hint: Remove or replace the character.
|test}];

    (* Undefined escape sequence *)

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/undefined_escape_sequence.ligo"];
    [%expect {test|
File "../../test/lexer/LexerLib/undefined_escape_sequence.ligo", line 1, characters 1-3:
  1 | "\z"
Undefined escape sequence.
Hint: Remove or replace the sequence.
|test}];

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/undefined_escape_sequence.mligo"];
    [%expect {test|
File "../../test/lexer/LexerLib/undefined_escape_sequence.mligo", line 1, characters 1-3:
  1 | "\z"
Undefined escape sequence.
Hint: Remove or replace the sequence.
|test}];

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/undefined_escape_sequence.religo"];
    [%expect {test|
Reasonligo is depreacted, support will be dropped in a few versions.

Reasonligo is depreacted, support will be dropped in a few versions.

File "../../test/lexer/LexerLib/undefined_escape_sequence.religo", line 1, characters 1-3:
  1 | "\z"
Undefined escape sequence.
Hint: Remove or replace the sequence.
|test}];

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/undefined_escape_sequence.jsligo"];
    [%expect {test|
File "../../test/lexer/LexerLib/undefined_escape_sequence.jsligo", line 1, characters 1-3:
  1 | "\z"
Undefined escape sequence.
Hint: Remove or replace the sequence.
|test}];

    (* Invalid linemarker argument *)

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/undefined_linemarker_argument.ligo"];
    [%expect {test|
File "../../test/lexer/LexerLib/undefined_linemarker_argument.ligo", line 1, characters 41-42:
  1 | # 1 "undefined_linemarker_argument.ligo" WRONG
Unexpected or invalid linemarker argument.
Hint: The optional argument is either 1 or 2.
|test}];

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/undefined_linemarker_argument.mligo"];
    [%expect {test|
File "../../test/lexer/LexerLib/undefined_linemarker_argument.mligo", line 1, characters 41-42:
  1 | # 1 "undefined_linemarker_argument.ligo" WRONG
Unexpected or invalid linemarker argument.
Hint: The optional argument is either 1 or 2.
|test}];

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/undefined_linemarker_argument.religo"];
    [%expect {test|
Reasonligo is depreacted, support will be dropped in a few versions.

Reasonligo is depreacted, support will be dropped in a few versions.

File "../../test/lexer/LexerLib/undefined_linemarker_argument.religo", line 1, characters 41-42:
  1 | # 1 "undefined_linemarker_argument.ligo" WRONG
Unexpected or invalid linemarker argument.
Hint: The optional argument is either 1 or 2.
|test}];

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/LexerLib/undefined_linemarker_argument.jsligo"];
    [%expect {test|
File "../../test/lexer/LexerLib/undefined_linemarker_argument.jsligo", line 1, characters 41-42:
  1 | # 1 "undefined_linemarker_argument.ligo" WRONG
Unexpected or invalid linemarker argument.
Hint: The optional argument is either 1 or 2.
|test}];

    (* 2. Errors from passes/01-lexing/shared/Lexer.mll:

       A test in _one_ syntax may be enough, except when the error
       depends on the lexical conventions of the concrete
       syntaxes. See each Token.ml files and the examples below. *)

    (* Unexpected character *)

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/Lexing/unexpected_character.ligo"];
    [%expect {test|
File "../../test/lexer/Lexing/unexpected_character.ligo", line 1, characters 19-20:
  1 | const x : string = ���;
Unexpected character '\239'.
|test}];

    (* Non-canonical zero *)

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/Lexing/non_canonical_zero.ligo"];
    [%expect {test|
File "../../test/lexer/Lexing/non_canonical_zero.ligo", line 1, characters 16-19:
  1 | const n : nat = 000
Non-canonical zero.
Hint: Use 0.
|test}];

    (* Invalid symbol *)

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/Lexing/invalid_symbol.ligo"];
    [%expect {test|
File "../../test/lexer/Lexing/invalid_symbol.ligo", line 1, characters 18-21:
  1 | const b : int = 1 ... 10;
Invalid symbol: "...".
Hint: Check the LIGO syntax you use.
|test}];

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/Lexing/invalid_symbol.mligo"];
    [%expect {test|
File "../../test/lexer/Lexing/invalid_symbol.mligo", line 1, characters 10-13:
  1 | let b = 1 ... 10;
  2 |
Invalid symbol: "...".
Hint: Check the LIGO syntax you use.
|test}];

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/Lexing/invalid_symbol.religo"];
    [%expect {test|
Reasonligo is depreacted, support will be dropped in a few versions.

Reasonligo is depreacted, support will be dropped in a few versions.

File "../../test/lexer/Lexing/invalid_symbol.religo", line 1, characters 10-11:
  1 | let b = 1 # 10;
Invalid symbol: "#".
Hint: Check the LIGO syntax you use.
|test}];

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/Lexing/invalid_symbol.jsligo"];
    [%expect {test|
File "../../test/lexer/Lexing/invalid_symbol.jsligo", line 1, characters 12-13:
  1 | const b = 1 # 10;
Invalid symbol: "#".
Hint: Check the LIGO syntax you use.
|test}];

    (* Wrong nat syntax *)

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/Lexing/wrong_nat_syntax.jsligo"];
    [%expect {test|
File "../../test/lexer/Lexing/wrong_nat_syntax.jsligo", line 1, characters 14-16:
  1 | let x : nat = 0n;
Wrong nat syntax.
Example: "12334 as nat".
|test}];

    (* Wrong mutez syntax *)

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/Lexing/wrong_mutez_syntax.jsligo"];
    [%expect {test|
File "../../test/lexer/Lexing/wrong_mutez_syntax.jsligo", line 1, characters 14-20:
  1 | let x : tez = 5mutez;
Wrong mutez syntax.
Example: "1234 as mutez".
|test}];

    (* Wrong lang syntax *)

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/Lexing/wrong_lang_syntax.jsligo"];
    [%expect {test|
File "../../test/lexer/Lexing/wrong_lang_syntax.jsligo", line 2, characters 2-13:
  1 | let michelson_add = (n : (nat, nat)) : nat =>
  2 |   [%Michelson ({| { UNPAIR ; ADD } |} : ((nat, nat) => nat)) ](n);
Wrong code injection syntax.
Example: "(Michelson `{UNPAIR; ADD}` as ((n: [nat, nat]) => nat))".
|test}];

     (* Unterminated verbatim *)

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/Lexing/unterminated_verbatim.ligo"];
    [%expect {test|
File "../../test/lexer/Lexing/unterminated_verbatim.ligo", line 1, characters 19-21:
  1 | const s : string = {|
Unterminated verbatim.
Hint: Close with "|}".
|test}];

    (* Invalid linemarker argument: This error should not happen if
       we assume the preprocessor is correct. Since there is currently
       no way to disable the preprocessor when calling the compiler,
       it is not possible to generate a test for this case (the preprocessor
       would fail on a linemarker). *)

    (* Overflow mutez *)

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/Lexing/overflow_mutez.ligo"];
    [%expect {test|
File "../../test/lexer/Lexing/overflow_mutez.ligo", line 1, characters 16-40:
  1 | const m : tez = 9223372036854775808mutez (* 2^63 *)
Mutez amount too large.
Note: From 0 to 2^63-1=9_223_372_036_854_775_807.
|test}];

    (* Underflow mutez *)

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/Lexing/underflow_mutez.ligo"];
    [%expect {test|
File "../../test/lexer/Lexing/underflow_mutez.ligo", line 1, characters 16-34:
  1 | const x : tez = 0.000_000_000_1tez
Mutez amount not an integer.
|test}];

    (* 3. Errors from Style.ml: They can be specific to a given
       concrete syntax or not. *)

    (* Odd-lengthed bytes *)

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/Style/odd_lengthed_bytes.ligo"];
    [%expect {test|
File "../../test/lexer/Style/odd_lengthed_bytes.ligo", line 1, character 22:
  1 | const x : bytes = 0xABC
The length of the byte sequence is an odd number.
Hint: Add or remove a digit.
|test}];

    (* Missing break *)

    run_ligo_bad ["compile"; "contract";
                  "../../test/lexer/Style/missing_break.ligo"];
    [%expect {test|
File "../../test/lexer/Style/missing_break.ligo", line 1, character 19:
  1 | const a : int = 300zennies;
Missing break.
Hint: Insert some space.
|test}];

    (* Add semi-colon *)

    run_ligo_good [ "print" ; "ast-typed" ; "../../test/lexer/add_semi.jsligo" ] ;
    [%expect {xxx|
    const x[@var] : int = 1[@private]
    module Foo =
      struct
      const y[@var] : int = x[@private]
      const z[@var] : int = 2
      module Bar = struct
                   const w[@var] : int = 1[@private]
                   end[@private]
      module Do = struct
                  const r[@var] : int = 1
                  end[@private]
      end |xxx}]
  end
