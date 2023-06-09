open Cli_expect

let gs s = "../../test/contracts/get_scope_tests/" ^ s

let%expect_test _ =
  run_ligo_good
    [ "info"
    ; "get-scope"
    ; gs "bad_field_record.mligo"
    ; "--format"
    ; "dev"
    ; "--with-types"
    ; "--no-stdlib"
    ];
  [%expect
    {|
    Scopes:
    [  ] File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 1, characters 18-43
    [ foo_record#1:5-15  ] File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 4, characters 8-9
    [ foo_record#1:5-15  ] File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 5, characters 8-9
    [ c#3:4-5 foo_record#1:5-15  ] File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 9, characters 10-11
    [ c#3:4-5 foo_record#1:5-15 i#9:6-7  ] File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 10, characters 2-3
    [ a#8:4-5 c#3:4-5 foo_record#1:5-15  ] File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 13, characters 10-11
    [ a#8:4-5 c#3:4-5 foo_record#1:5-15 j#13:6-7  ] File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 14, characters 2-3

    Variable definitions:
    (a#8:4-5 -> a)
    Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 8, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 9, character 2 to line 10, character 3
    Content: |resolved: int|
    references: []
    (b#12:4-5 -> b)
    Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 12, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 13, character 2 to line 14, character 3
    Content: |unresolved|
    references: []
    (c#3:4-5 -> c)
    Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 3, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 3, character 8 to line 6, character 1
    Content: |resolved: foo_record|
    references:
      File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 9, characters 10-11 ,
      File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 13, characters 10-11
    (i#9:6-7 -> i)
    Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 9, characters 6-7
    Body Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 9, characters 10-15
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 10, characters 2-3
    (j#13:6-7 -> j)
    Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 13, characters 6-7
    Body Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 13, characters 10-15
    Content: |unresolved|
    references:
      File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 14, characters 2-3
    Type definitions:
    (foo_record#1:5-15 -> foo_record)
    Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 1, characters 5-15
    Body Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 1, characters 18-43
    Content: : |record[bar -> int , foo -> int]|
    references: []
    Module definitions:
    Errors:
    File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 13, characters 10-15:
     12 | let b =
     13 |   let j = c.boo in
     14 |   j

    Invalid record field "boo" in record.

|}];
  run_ligo_good
    [ "info"
    ; "get-scope"
    ; gs "local_type.mligo"
    ; "--format"
    ; "dev"
    ; "--with-types"
    ; "--no-stdlib"
    ];
  [%expect
    {|
    Scopes:
    [ u#1:16-17  ] File "../../test/contracts/get_scope_tests/local_type.mligo", line 2, characters 10-12
    [ b#4:11-12 toto#3:7-11 u#1:16-17 y#2:6-7  ] File "../../test/contracts/get_scope_tests/local_type.mligo", line 4, characters 30-31
    [ foo#4:6-9 toto#3:7-11 u#1:16-17 y#2:6-7  ] File "../../test/contracts/get_scope_tests/local_type.mligo", line 5, characters 2-6
    [ local_type#1:4-14  ] File "../../test/contracts/get_scope_tests/local_type.mligo", line 7, characters 8-10

    Variable definitions:
    (b#4:11-12 -> b)
    Range: File "../../test/contracts/get_scope_tests/local_type.mligo", line 4, characters 11-12
    Body Range: File "../../test/contracts/get_scope_tests/local_type.mligo", line 4, characters 30-31
    Content: |core: toto|
    references:
      File "../../test/contracts/get_scope_tests/local_type.mligo", line 4, characters 30-31
    (foo#4:6-9 -> foo)
    Range: File "../../test/contracts/get_scope_tests/local_type.mligo", line 4, characters 6-9
    Body Range: File "../../test/contracts/get_scope_tests/local_type.mligo", line 4, characters 11-12
    Content: |core: toto -> toto|
    references: []
    (local_type#1:4-14 -> local_type)
    Range: File "../../test/contracts/get_scope_tests/local_type.mligo", line 1, characters 4-14
    Body Range: File "../../test/contracts/get_scope_tests/local_type.mligo", line 1, characters 16-17
    Content: |core: unit -> int|
    references: []
    (u#1:16-17 -> u)
    Range: File "../../test/contracts/get_scope_tests/local_type.mligo", line 1, characters 16-17
    Body Range: File "../../test/contracts/get_scope_tests/local_type.mligo", line 2, character 2 to line 5, character 6
    Content: |core: unit|
    references: []
    (x#7:4-5 -> x)
    Range: File "../../test/contracts/get_scope_tests/local_type.mligo", line 7, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/local_type.mligo", line 7, characters 8-10
    Content: |resolved: int|
    references: []
    (y#2:6-7 -> y)
    Range: File "../../test/contracts/get_scope_tests/local_type.mligo", line 2, characters 6-7
    Body Range: File "../../test/contracts/get_scope_tests/local_type.mligo", line 2, characters 10-12
    Content: |unresolved|
    references: []
    Type definitions:
    (toto#3:7-11 -> toto)
    Range: File "../../test/contracts/get_scope_tests/local_type.mligo", line 3, characters 7-11
    Body Range: File "../../test/contracts/get_scope_tests/local_type.mligo", line 3, characters 14-17
    Content: : |int|
    references:
      File "../../test/contracts/get_scope_tests/local_type.mligo", line 4, characters 15-19 ,
      File "../../test/contracts/get_scope_tests/local_type.mligo", line 4, characters 23-27
    Module definitions:
    Errors:
    File "../../test/contracts/get_scope_tests/local_type.mligo", line 5, characters 2-6:
      4 |   let foo (b : toto) : toto = b in
      5 |   titi
      6 |

    Variable "titi" not found.
 |}];
  run_ligo_good
    [ "info"
    ; "get-scope"
    ; gs "errors/syntax_error.mligo"
    ; "--format"
    ; "dev"
    ; "--with-types"
    ; "--no-stdlib"
    ];
  [%expect
    {|
    Scopes:

    Variable definitions:
    Type definitions:
    Module definitions:
    Errors:
    File "../../test/contracts/get_scope_tests/errors/syntax_error.mligo", line 1, characters 0-4:
      1 | letx : int = 0
    Ill-formed contract.
    At this point, if the declaration is complete, one of the following is
    expected:
      * another declaration;
      * the end of the file. |}];
  run_ligo_good
    [ "info"
    ; "get-scope"
    ; gs "errors/type_error.mligo"
    ; "--format"
    ; "dev"
    ; "--with-types"
    ; "--no-stdlib"
    ];
  [%expect
    {|
    Scopes:
    [  ] File "../../test/contracts/get_scope_tests/errors/type_error.mligo", line 1, characters 8-11
    [  ] File "../../test/contracts/get_scope_tests/errors/type_error.mligo", line 1, characters 14-21

    Variable definitions:
    (x#1:4-5 -> x)
    Range: File "../../test/contracts/get_scope_tests/errors/type_error.mligo", line 1, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/errors/type_error.mligo", line 1, characters 14-21
    Content: |core: int|
    references: []
    Type definitions:
    Module definitions:
    Errors:
    File "../../test/contracts/get_scope_tests/errors/type_error.mligo", line 1, characters 14-21:
      1 | let x : int = "Hello"

    Invalid type(s).
    Expected "int", but got: "string". |}];
  run_ligo_good
    [ "info"
    ; "get-scope"
    ; test "warning_unused.mligo"
    ; "--format"
    ; "dev"
    ; "--with-types"
    ; "--no-stdlib"
    ];
  [%expect
    {|
    Scopes:
    [  ] File "../../test/contracts/warning_unused.mligo", line 1, character 15 to line 4, character 1
    [ storage#1:5-12 x#6:9-10  ] File "../../test/contracts/warning_unused.mligo", line 6, characters 20-21
    [ foo#6:4-7 storage#1:5-12 x#7:9-10  ] File "../../test/contracts/warning_unused.mligo", line 7, characters 20-29
    [ bar#7:4-7 foo#6:4-7 storage#1:5-12  ] File "../../test/contracts/warning_unused.mligo", line 9, characters 10-13
    [ bar#7:4-7 foo#6:4-7 s#9:12-13 storage#1:5-12  ] File "../../test/contracts/warning_unused.mligo", line 10, characters 10-17
    [ bar#7:4-7 foo#6:4-7 s#9:12-13 storage#1:5-12 x#10:6-7  ] File "../../test/contracts/warning_unused.mligo", line 11, characters 10-15
    [ bar#7:4-7 foo#6:4-7 s#9:12-13 storage#1:5-12 x#11:6-7  ] File "../../test/contracts/warning_unused.mligo", line 12, characters 10-17
    [ bar#7:4-7 foo#6:4-7 s#9:12-13 storage#1:5-12 x#12:6-7  ] File "../../test/contracts/warning_unused.mligo", line 13, characters 3-5
    [ bar#7:4-7 foo#6:4-7 s#9:12-13 storage#1:5-12 x#12:6-7  ] File "../../test/contracts/warning_unused.mligo", line 13, characters 8-22
    [ bar#7:4-7 foo#6:4-7 s#9:12-13 storage#1:5-12 x#12:6-7  ] File "../../test/contracts/warning_unused.mligo", line 13, characters 26-27
    [ bar#7:4-7 foo#6:4-7 s#9:12-13 storage#1:5-12 x#12:6-7  ] File "../../test/contracts/warning_unused.mligo", line 13, characters 37-38

    Variable definitions:
    (bar#7:4-7 -> bar)
    Range: File "../../test/contracts/warning_unused.mligo", line 7, characters 4-7
    Body Range: File "../../test/contracts/warning_unused.mligo", line 7, characters 9-10
    Content: |resolved: int -> int|
    references:
      File "../../test/contracts/warning_unused.mligo", line 12, characters 10-13
    (foo#6:4-7 -> foo)
    Range: File "../../test/contracts/warning_unused.mligo", line 6, characters 4-7
    Body Range: File "../../test/contracts/warning_unused.mligo", line 6, characters 9-10
    Content: |resolved: int -> int|
    references:
      File "../../test/contracts/warning_unused.mligo", line 11, characters 10-13
    (main#9:4-8 -> main)
    Range: File "../../test/contracts/warning_unused.mligo", line 9, characters 4-8
    Body Range: File "../../test/contracts/warning_unused.mligo", line 9, characters 10-13
    Content: |resolved: ( int *
                          record[x -> int , y -> int({ name: x }, { name: y })] ) ->
    ( list (operation) *
      record[x -> int , y -> int({ name: x }, { name: y })] )|
    references: []
    (s#9:12-13 -> s)
    Range: File "../../test/contracts/warning_unused.mligo", line 9, characters 12-13
    Body Range: File "../../test/contracts/warning_unused.mligo", line 10, character 2 to line 13, character 39
    Content: |resolved: storage|
    references:
      File "../../test/contracts/warning_unused.mligo", line 10, characters 10-11 ,
      File "../../test/contracts/warning_unused.mligo", line 12, characters 14-15 ,
      File "../../test/contracts/warning_unused.mligo", line 13, characters 26-27
    (x#10:6-7 -> x)
    Range: File "../../test/contracts/warning_unused.mligo", line 10, characters 6-7
    Body Range: File "../../test/contracts/warning_unused.mligo", line 10, characters 10-17
    Content: |resolved: int|
    references:
      File "../../test/contracts/warning_unused.mligo", line 11, characters 14-15
    (x#11:6-7 -> x)
    Range: File "../../test/contracts/warning_unused.mligo", line 11, characters 6-7
    Body Range: File "../../test/contracts/warning_unused.mligo", line 11, characters 10-15
    Content: |resolved: int|
    references: []
    (x#12:6-7 -> x)
    Range: File "../../test/contracts/warning_unused.mligo", line 12, characters 6-7
    Body Range: File "../../test/contracts/warning_unused.mligo", line 12, characters 10-17
    Content: |resolved: int|
    references:
      File "../../test/contracts/warning_unused.mligo", line 13, characters 37-38
    (x#6:9-10 -> x)
    Range: File "../../test/contracts/warning_unused.mligo", line 6, characters 9-10
    Body Range: File "../../test/contracts/warning_unused.mligo", line 6, characters 20-21
    Content: |core: int|
    references:
      File "../../test/contracts/warning_unused.mligo", line 6, characters 20-21
    (x#7:9-10 -> x)
    Range: File "../../test/contracts/warning_unused.mligo", line 7, characters 9-10
    Body Range: File "../../test/contracts/warning_unused.mligo", line 7, characters 20-29
    Content: |core: int|
    references:
      File "../../test/contracts/warning_unused.mligo", line 7, characters 20-21
    Type definitions:
    (storage#1:5-12 -> storage)
    Range: File "../../test/contracts/warning_unused.mligo", line 1, characters 5-12
    Body Range: File "../../test/contracts/warning_unused.mligo", line 1, character 15 to line 4, character 1
    Content: : |record[x -> int , y -> int]|
    references:
      File "../../test/contracts/warning_unused.mligo", line 9, characters 22-29
    Module definitions:
    Warnings:
    File "../../test/contracts/warning_unused.mligo", line 11, characters 6-7:
     10 |   let x = s.x + 3 in
     11 |   let x = foo x in
     12 |   let x = bar s.x in
    :
    Warning: unused variable "x".
    Hint: replace it by "_x" to prevent this warning. |}];
  run_ligo_good
    [ "info"
    ; "get-scope"
    ; test "warning_duplicate2.mligo"
    ; "--format"
    ; "dev"
    ; "--with-types"
    ; "--no-stdlib"
    ];
  [%expect
    {|
    Scopes:
    [  ] File "../../test/contracts/warning_duplicate2.mligo", line 1, characters 8-35
    [ x#1:4-5  ] File "../../test/contracts/warning_duplicate2.mligo", line 2, characters 9-10
    [ x#1:4-5  ] File "../../test/contracts/warning_duplicate2.mligo", line 2, characters 12-13

    Variable definitions:
    (x#1:4-5 -> x)
    Range: File "../../test/contracts/warning_duplicate2.mligo", line 1, characters 4-5
    Body Range: File "../../test/contracts/warning_duplicate2.mligo", line 1, characters 8-35
    Content: |resolved: option (ticket (nat))|
    references:
      File "../../test/contracts/warning_duplicate2.mligo", line 2, characters 9-10 ,
      File "../../test/contracts/warning_duplicate2.mligo", line 2, characters 12-13
    (x#2:4-5 -> x)
    Range: File "../../test/contracts/warning_duplicate2.mligo", line 2, characters 4-5
    Body Range: File "../../test/contracts/warning_duplicate2.mligo", line 2, characters 9-13
    Content: |resolved: ( option (ticket (nat)) * option (ticket (nat)) )|
    references: []
    Type definitions:
    Module definitions:
    Warnings:
    File "../../test/contracts/warning_duplicate2.mligo", line 1, characters 4-5:
      1 | let x = Tezos.create_ticket 42n 42n
      2 | let x = (x, x)
    :
    Warning: variable "x" cannot be used more than once. |}];
  run_ligo_good
    [ "info"
    ; "get-scope"
    ; test "warning_duplicate.mligo"
    ; "--format"
    ; "dev"
    ; "--with-types"
    ; "--no-stdlib"
    ];
  [%expect
    {|
    Scopes:
    [  ] File "../../test/contracts/warning_duplicate.mligo", line 2, characters 10-20
    [  ] File "../../test/contracts/warning_duplicate.mligo", line 2, characters 23-65
    [ Foo#1:7-10 x#2:6-7  ] File "../../test/contracts/warning_duplicate.mligo", line 5, characters 9-14
    [ Foo#1:7-10 x#2:6-7  ] File "../../test/contracts/warning_duplicate.mligo", line 5, characters 16-21

    Variable definitions:
    (x#5:4-5 -> x)
    Range: File "../../test/contracts/warning_duplicate.mligo", line 5, characters 4-5
    Body Range: File "../../test/contracts/warning_duplicate.mligo", line 5, characters 9-21
    Content: |resolved: ( ticket (nat) * ticket (nat) )|
    references: []
    Type definitions:
    Module definitions:
    (Foo#1:7-10 -> Foo)
    Range: File "../../test/contracts/warning_duplicate.mligo", line 1, characters 7-10
    Body Range: File "../../test/contracts/warning_duplicate.mligo", line 1, character 0 to line 3, character 3
    Content: Members: Variable definitions:
                      (x#2:6-7 -> x)
                      Range: File "../../test/contracts/warning_duplicate.mligo", line 2, characters 6-7
                      Body Range: File "../../test/contracts/warning_duplicate.mligo", line 2, characters 23-65
                      Content: |core: ticket (nat)|
                      references:
                        File "../../test/contracts/warning_duplicate.mligo", line 5, characters 13-14 ,
                        File "../../test/contracts/warning_duplicate.mligo", line 5, characters 20-21
                      Type definitions:
                      Module definitions:

    references:
      File "../../test/contracts/warning_duplicate.mligo", line 5, characters 9-12 ,
      File "../../test/contracts/warning_duplicate.mligo", line 5, characters 16-19

    Warnings:
    File "../../test/contracts/warning_duplicate.mligo", line 2, characters 2-65:
      1 | module Foo = struct
      2 |   let x : nat ticket = Option.unopt (Tezos.create_ticket 42n 42n)
      3 | end
    :
    Warning: variable "Foo.x" cannot be used more than once. |}]
