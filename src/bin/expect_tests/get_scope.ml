open Cli_expect

let gs = fun s -> ("../../test/contracts/get_scope_tests/"^s)

let%expect_test _ =
  run_ligo_good [ "info" ; "get-scope" ; gs "lambda_letin.mligo" ; "--format" ; "dev" ; "--with-types" ] ;
  [%expect {|
Scopes:
[ a#0 f#5 ] File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 9, characters 2-7
[ a#0 g#3 i#1 j#2 k#4 ] File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 7, characters 4-21
[ a#0 g#3 i#1 j#2 ] File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 6, characters 12-25
[ a#0 i#1 j#2 ] File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 5, characters 12-21
[ ] File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 1, characters 0-9

Variable definitions:
(a#0 -> a)
Range: File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 1, characters 4-5
Body Range: File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 1, characters 8-9
Content: |resolved: int|
references:
  File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 5, characters 20-21 ,
  File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 6, characters 20-21 ,
  File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 7, characters 12-13 ,
  File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 9, characters 6-7
(b#6 -> b)
Range: File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 3, characters 4-5
Body Range: File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 4, character 2 to line 9, character 7
Content: |resolved: int|
references: []
(f#5 -> f)
Range: File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 4, characters 6-7
Body Range: File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 4, character 32 to line 7, character 21
Content: |core: int -> int -> int|
references:
  File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 9, characters 2-3
(g#3 -> g)
Range: File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 5, characters 8-9
Body Range: File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 5, characters 12-21
Content: |resolved: int|
references:
  File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 6, characters 24-25 ,
  File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 7, characters 16-17
(i#1 -> i)
Range: File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 4, characters 37-38
Body Range: File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 4, character 32 to line 7, character 21
Content: |core: int|
references:
  File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 5, characters 16-17 ,
  File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 6, characters 16-17 ,
  File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 7, characters 8-9
(j#2 -> j)
Range: File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 4, characters 47-48
Body Range: File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 5, character 4 to line 7, character 21
Content: |core: int|
references:
  File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 5, characters 12-13 ,
  File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 6, characters 12-13 ,
  File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 7, characters 4-5
(k#4 -> k)
Range: File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 6, characters 8-9
Body Range: File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 6, characters 12-25
Content: |resolved: int|
references:
  File "../../test/contracts/get_scope_tests/lambda_letin.mligo", line 7, characters 20-21
Type definitions:
Module definitions: |} ]

let%expect_test _ =
  run_ligo_good [ "info" ; "get-scope" ; gs "letin.mligo" ; "--format" ; "dev" ; "--with-types" ] ;
  [%expect {|
Scopes:
[ a#0 c#1 d#4 ] File "../../test/contracts/get_scope_tests/letin.mligo", line 10, characters 2-11
[ a#0 c#1 e#2 f#3 ] File "../../test/contracts/get_scope_tests/letin.mligo", line 8, characters 4-17
[ a#0 c#1 e#2 ] File "../../test/contracts/get_scope_tests/letin.mligo", line 7, characters 12-21
[ a#0 c#1 ] File "../../test/contracts/get_scope_tests/letin.mligo", line 6, characters 12-17
[ a#0 ] File "../../test/contracts/get_scope_tests/letin.mligo", line 4, characters 10-15
[ ] File "../../test/contracts/get_scope_tests/letin.mligo", line 1, characters 0-9

Variable definitions:
(a#0 -> a)
Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 1, characters 4-5
Body Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 1, characters 8-9
Content: |resolved: int|
references:
  File "../../test/contracts/get_scope_tests/letin.mligo", line 4, characters 14-15 ,
  File "../../test/contracts/get_scope_tests/letin.mligo", line 6, characters 12-13 ,
  File "../../test/contracts/get_scope_tests/letin.mligo", line 7, characters 12-13 ,
  File "../../test/contracts/get_scope_tests/letin.mligo", line 8, characters 4-5 ,
  File "../../test/contracts/get_scope_tests/letin.mligo", line 10, characters 2-3
(b#5 -> b)
Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 3, characters 4-5
Body Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 4, character 2 to line 10, character 11
Content: |resolved: int|
references: []
(c#1 -> c)
Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 4, characters 6-7
Body Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 4, characters 10-15
Content: |resolved: int|
references:
  File "../../test/contracts/get_scope_tests/letin.mligo", line 6, characters 16-17 ,
  File "../../test/contracts/get_scope_tests/letin.mligo", line 7, characters 16-17 ,
  File "../../test/contracts/get_scope_tests/letin.mligo", line 8, characters 8-9 ,
  File "../../test/contracts/get_scope_tests/letin.mligo", line 10, characters 6-7
(d#4 -> d)
Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 5, characters 6-7
Body Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 6, character 4 to line 8, character 17
Content: |resolved: int|
references:
  File "../../test/contracts/get_scope_tests/letin.mligo", line 10, characters 10-11
(e#2 -> e)
Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 6, characters 8-9
Body Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 6, characters 12-17
Content: |resolved: int|
references:
  File "../../test/contracts/get_scope_tests/letin.mligo", line 7, characters 20-21 ,
  File "../../test/contracts/get_scope_tests/letin.mligo", line 8, characters 12-13
(f#3 -> f)
Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 7, characters 8-9
Body Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 7, characters 12-21
Content: |resolved: int|
references:
  File "../../test/contracts/get_scope_tests/letin.mligo", line 8, characters 16-17
Type definitions:
Module definitions: |} ]

let%expect_test _ =
  run_ligo_good [ "info" ; "get-scope" ; gs "lambda.mligo" ; "--format" ; "dev" ; "--with-types" ] ;
  [%expect {|
Scopes:
[ a#0 f#3 ] File "../../test/contracts/get_scope_tests/lambda.mligo", line 5, characters 2-7
[ a#0 i#1 j#2 ] File "../../test/contracts/get_scope_tests/lambda.mligo", line 4, characters 58-63
[ ] File "../../test/contracts/get_scope_tests/lambda.mligo", line 1, characters 0-9

Variable definitions:
(a#0 -> a)
Range: File "../../test/contracts/get_scope_tests/lambda.mligo", line 1, characters 4-5
Body Range: File "../../test/contracts/get_scope_tests/lambda.mligo", line 1, characters 8-9
Content: |resolved: int|
references: []
(b#4 -> b)
Range: File "../../test/contracts/get_scope_tests/lambda.mligo", line 3, characters 4-5
Body Range: File "../../test/contracts/get_scope_tests/lambda.mligo", line 4, character 2 to line 5, character 7
Content: |resolved: int|
references: []
(f#3 -> f)
Range: File "../../test/contracts/get_scope_tests/lambda.mligo", line 4, characters 6-7
Body Range: File "../../test/contracts/get_scope_tests/lambda.mligo", line 4, characters 31-63
Content: |core: int -> int -> int|
references:
  File "../../test/contracts/get_scope_tests/lambda.mligo", line 5, characters 2-3
(i#1 -> i)
Range: File "../../test/contracts/get_scope_tests/lambda.mligo", line 4, characters 36-37
Body Range: File "../../test/contracts/get_scope_tests/lambda.mligo", line 4, characters 31-63
Content: |core: int|
references:
  File "../../test/contracts/get_scope_tests/lambda.mligo", line 4, characters 62-63
(j#2 -> j)
Range: File "../../test/contracts/get_scope_tests/lambda.mligo", line 4, characters 46-47
Body Range: File "../../test/contracts/get_scope_tests/lambda.mligo", line 4, characters 58-63
Content: |core: int|
references:
  File "../../test/contracts/get_scope_tests/lambda.mligo", line 4, characters 58-59
Type definitions:
Module definitions: |} ]

let%expect_test _ =
  run_ligo_good [ "info" ; "get-scope" ; gs "match.mligo" ; "--format" ; "dev" ; "--with-types" ] ;
  [%expect{|
    Scopes:
    [ a#1 b#5 c#9 mytype#0 s#11 ] File "../../test/contracts/get_scope_tests/match.mligo", line 19, characters 16-21
    [ a#1 b#5 c#9 d#10 mytype#0 ] File "../../test/contracts/get_scope_tests/match.mligo", line 18, characters 28-31
    [ a#1 b#5 c#9 mytype#0 ] File "../../test/contracts/get_scope_tests/match.mligo", line 18, character 9 to line 20, character 13
    [ a#1 b#5 hd#8 mytype#0 tl#7 ] File "../../test/contracts/get_scope_tests/match.mligo", line 15, characters 14-15
    [ a#1 b#5 c#6 mytype#0 ] File "../../test/contracts/get_scope_tests/match.mligo", line 14, characters 4-5
    [ a#1 b#5 mytype#0 ] File "../../test/contracts/get_scope_tests/match.mligo", line 11, character 11 to line 14, character 5
    [ a#1 mytype#0 y#4 ] File "../../test/contracts/get_scope_tests/match.mligo", line 8, characters 13-18
    [ a#1 mytype#0 x#3 ] File "../../test/contracts/get_scope_tests/match.mligo", line 7, characters 13-18
    [ a#1 c#2 mytype#0 ] File "../../test/contracts/get_scope_tests/match.mligo", line 6, characters 26-27
    [ a#1 mytype#0 ] File "../../test/contracts/get_scope_tests/match.mligo", line 6, characters 9-27
    [ mytype#0 ] File "../../test/contracts/get_scope_tests/match.mligo", line 3, characters 0-9

    Variable definitions:
    (a#1 -> a)
    Range: File "../../test/contracts/get_scope_tests/match.mligo", line 3, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/match.mligo", line 3, characters 8-9
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/match.mligo", line 6, characters 17-18 ,
      File "../../test/contracts/get_scope_tests/match.mligo", line 7, characters 17-18 ,
      File "../../test/contracts/get_scope_tests/match.mligo", line 8, characters 17-18 ,
      File "../../test/contracts/get_scope_tests/match.mligo", line 14, characters 4-5 ,
      File "../../test/contracts/get_scope_tests/match.mligo", line 18, characters 28-29 ,
      File "../../test/contracts/get_scope_tests/match.mligo", line 19, characters 20-21 ,
      File "../../test/contracts/get_scope_tests/match.mligo", line 20, characters 12-13
    (b#5 -> b)
    Range: File "../../test/contracts/get_scope_tests/match.mligo", line 5, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/match.mligo", line 6, character 2 to line 8, character 18
    Content: |resolved: int|
    references: []
    (c#2 -> c)
    Range: File "../../test/contracts/get_scope_tests/match.mligo", line 6, characters 13-14
    Body Range: File "../../test/contracts/get_scope_tests/match.mligo", line 6, characters 17-18
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/match.mligo", line 6, characters 26-27
    (c#6 -> c)
    Range: File "../../test/contracts/get_scope_tests/match.mligo", line 13, characters 8-9
    Body Range: File "../../test/contracts/get_scope_tests/match.mligo", line 13, characters 12-13
    Content: |resolved: int|
    references: []
    (c#9 -> c)
    Range: File "../../test/contracts/get_scope_tests/match.mligo", line 10, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/match.mligo", line 11, character 2 to line 15, character 15
    Content: |resolved: int|
    references: []
    (d#10 -> d)
    Range: File "../../test/contracts/get_scope_tests/match.mligo", line 18, characters 13-14
    Body Range: File "../../test/contracts/get_scope_tests/match.mligo", line 18, characters 17-18
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/match.mligo", line 18, characters 30-31
    (d#12 -> d)
    Range: File "../../test/contracts/get_scope_tests/match.mligo", line 17, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/match.mligo", line 18, character 2 to line 20, character 13
    Content: |resolved: int|
    references: []
    (hd#8 -> hd)
    Range: File "../../test/contracts/get_scope_tests/match.mligo", line 15, characters 4-6
    Body Range: File "../../test/contracts/get_scope_tests/match.mligo", line 15, characters 4-6
    Content: |resolved: int|
    references: []
    (s#11 -> s)
    Range: File "../../test/contracts/get_scope_tests/match.mligo", line 19, characters 10-11
    Body Range: File "../../test/contracts/get_scope_tests/match.mligo", line 19, characters 10-11
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/match.mligo", line 19, characters 16-17
    (tl#7 -> tl)
    Range: File "../../test/contracts/get_scope_tests/match.mligo", line 15, characters 8-10
    Body Range: File "../../test/contracts/get_scope_tests/match.mligo", line 15, characters 8-10
    Content: |resolved: list (int)|
    references: []
    (x#3 -> x)
    Range: File "../../test/contracts/get_scope_tests/match.mligo", line 7, characters 8-9
    Body Range: File "../../test/contracts/get_scope_tests/match.mligo", line 7, characters 8-9
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/match.mligo", line 7, characters 13-14
    (y#4 -> y)
    Range: File "../../test/contracts/get_scope_tests/match.mligo", line 8, characters 8-9
    Body Range: File "../../test/contracts/get_scope_tests/match.mligo", line 8, characters 8-9
    Content: |resolved: string|
    references: []
    Type definitions:
    (mytype#0 -> mytype)
    Range: File "../../test/contracts/get_scope_tests/match.mligo", line 1, characters 0-40
    Body Range: File "../../test/contracts/get_scope_tests/match.mligo", line 1, characters 14-40
    Content: : sum[Bar -> string , Foo -> int]
    Module definitions: |} ]

let%expect_test _ =
  run_ligo_good [ "info" ; "get-scope" ; gs "rec.mligo" ; "--format" ; "dev" ; "--with-types" ] ;
  [%expect{|
    Scopes:
    [ a#0 b#6 c#5 ] File "../../test/contracts/get_scope_tests/rec.mligo", line 9, characters 2-9
    [ a#0 c#5 ] File "../../test/contracts/get_scope_tests/rec.mligo", line 8, character 2 to line 9, character 10
    [ a#0 c#1 i#2 j#3 k#4 ] File "../../test/contracts/get_scope_tests/rec.mligo", line 6, characters 4-10
    [ a#0 c#1 i#2 j#3 ] File "../../test/contracts/get_scope_tests/rec.mligo", line 5, characters 12-21
    [ a#0 c#1 ] File "../../test/contracts/get_scope_tests/rec.mligo", line 4, characters 37-40
    [ ] File "../../test/contracts/get_scope_tests/rec.mligo", line 1, characters 0-9

    Variable definitions:
    (a#0 -> a)
    Range: File "../../test/contracts/get_scope_tests/rec.mligo", line 1, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/rec.mligo", line 1, characters 8-9
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/rec.mligo", line 5, characters 20-21 ,
      File "../../test/contracts/get_scope_tests/rec.mligo", line 9, characters 5-6
    (b#6 -> b)
    Range: File "../../test/contracts/get_scope_tests/rec.mligo", line 8, characters 6-7
    Body Range: File "../../test/contracts/get_scope_tests/rec.mligo", line 8, characters 10-11
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/rec.mligo", line 9, characters 8-9
    (b#7 -> b)
    Range: File "../../test/contracts/get_scope_tests/rec.mligo", line 3, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/rec.mligo", line 4, character 2 to line 9, character 10
    Content: |resolved: int|
    references: []
    (c#1 -> c)
    Range: File "../../test/contracts/get_scope_tests/rec.mligo", line 4, characters 10-11
    Body Range: File "../../test/contracts/get_scope_tests/rec.mligo", line 4, characters 37-40
    Content: |core: ( int * int ) -> int|
    references:
      File "../../test/contracts/get_scope_tests/rec.mligo", line 6, characters 4-5
    (c#5 -> c)
    Range: File "../../test/contracts/get_scope_tests/rec.mligo", line 4, characters 10-11
    Body Range: File "../../test/contracts/get_scope_tests/rec.mligo", line 4, characters 6-9
    Content: |core: ( int * int ) -> int|
    references:
      File "../../test/contracts/get_scope_tests/rec.mligo", line 9, characters 2-3
    (i#2 -> i)
    Range: File "../../test/contracts/get_scope_tests/rec.mligo", line 4, characters 37-38
    Body Range: File "../../test/contracts/get_scope_tests/rec.mligo", line 4, characters 37-38
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/rec.mligo", line 5, characters 12-13
    (j#3 -> j)
    Range: File "../../test/contracts/get_scope_tests/rec.mligo", line 4, characters 39-40
    Body Range: File "../../test/contracts/get_scope_tests/rec.mligo", line 4, characters 39-40
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/rec.mligo", line 5, characters 16-17
    (k#4 -> k)
    Range: File "../../test/contracts/get_scope_tests/rec.mligo", line 5, characters 8-9
    Body Range: File "../../test/contracts/get_scope_tests/rec.mligo", line 5, characters 12-21
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/rec.mligo", line 6, characters 7-8
    Type definitions:
    Module definitions: |} ]

let%expect_test _ =
  run_ligo_good [ "info" ; "get-scope" ; gs "shadowing.mligo" ; "--format" ; "dev" ; "--with-types" ] ;
  [%expect{|
    Scopes:
    [ a#0 c#1 d#4 ] File "../../test/contracts/get_scope_tests/shadowing.mligo", line 10, characters 2-11
    [ a#3 c#1 e#2 ] File "../../test/contracts/get_scope_tests/shadowing.mligo", line 8, characters 4-13
    [ a#0 c#1 e#2 ] File "../../test/contracts/get_scope_tests/shadowing.mligo", line 7, characters 12-21
    [ a#0 c#1 ] File "../../test/contracts/get_scope_tests/shadowing.mligo", line 6, characters 12-17
    [ a#0 ] File "../../test/contracts/get_scope_tests/shadowing.mligo", line 4, characters 10-15
    [ ] File "../../test/contracts/get_scope_tests/shadowing.mligo", line 1, characters 0-9

    Variable definitions:
    (a#0 -> a)
    Range: File "../../test/contracts/get_scope_tests/shadowing.mligo", line 1, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/shadowing.mligo", line 1, characters 8-9
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/shadowing.mligo", line 4, characters 14-15 ,
      File "../../test/contracts/get_scope_tests/shadowing.mligo", line 6, characters 12-13 ,
      File "../../test/contracts/get_scope_tests/shadowing.mligo", line 7, characters 12-13 ,
      File "../../test/contracts/get_scope_tests/shadowing.mligo", line 10, characters 2-3
    (a#3 -> a)
    Range: File "../../test/contracts/get_scope_tests/shadowing.mligo", line 7, characters 8-9
    Body Range: File "../../test/contracts/get_scope_tests/shadowing.mligo", line 7, characters 12-21
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/shadowing.mligo", line 8, characters 4-5
    (b#5 -> b)
    Range: File "../../test/contracts/get_scope_tests/shadowing.mligo", line 3, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/shadowing.mligo", line 4, character 2 to line 10, character 11
    Content: |resolved: int|
    references: []
    (c#1 -> c)
    Range: File "../../test/contracts/get_scope_tests/shadowing.mligo", line 4, characters 6-7
    Body Range: File "../../test/contracts/get_scope_tests/shadowing.mligo", line 4, characters 10-15
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/shadowing.mligo", line 6, characters 16-17 ,
      File "../../test/contracts/get_scope_tests/shadowing.mligo", line 7, characters 16-17 ,
      File "../../test/contracts/get_scope_tests/shadowing.mligo", line 8, characters 8-9 ,
      File "../../test/contracts/get_scope_tests/shadowing.mligo", line 10, characters 6-7
    (d#4 -> d)
    Range: File "../../test/contracts/get_scope_tests/shadowing.mligo", line 5, characters 6-7
    Body Range: File "../../test/contracts/get_scope_tests/shadowing.mligo", line 6, character 4 to line 8, character 13
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/shadowing.mligo", line 10, characters 10-11
    (e#2 -> e)
    Range: File "../../test/contracts/get_scope_tests/shadowing.mligo", line 6, characters 8-9
    Body Range: File "../../test/contracts/get_scope_tests/shadowing.mligo", line 6, characters 12-17
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/shadowing.mligo", line 7, characters 20-21 ,
      File "../../test/contracts/get_scope_tests/shadowing.mligo", line 8, characters 12-13
    Type definitions:
    Module definitions: |} ]

let%expect_test _ =
  run_ligo_good [ "info" ; "get-scope" ; gs "records.mligo" ; "--format" ; "dev" ; "--with-types" ] ;
  [%expect{|
    Scopes:
    [ a#1 b#4 g#5 myrec#0 ] File "../../test/contracts/get_scope_tests/records.mligo", line 16, characters 28-41
    [ a#1 b#4 myrec#0 ] File "../../test/contracts/get_scope_tests/records.mligo", line 16, characters 3-41
    [ a#1 i#2 j#3 myrec#0 ] File "../../test/contracts/get_scope_tests/records.mligo", line 6, characters 40-45
    [ a#1 i#2 myrec#0 ] File "../../test/contracts/get_scope_tests/records.mligo", line 6, characters 27-45
    [ a#1 myrec#0 ] File "../../test/contracts/get_scope_tests/records.mligo", line 6, characters 14-55
    [ myrec#0 ] File "../../test/contracts/get_scope_tests/records.mligo", line 3, characters 0-9

    Variable definitions:
    (a#1 -> a)
    Range: File "../../test/contracts/get_scope_tests/records.mligo", line 3, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/records.mligo", line 3, characters 8-9
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/records.mligo", line 6, characters 40-41 ,
      File "../../test/contracts/get_scope_tests/records.mligo", line 16, characters 23-24 ,
      File "../../test/contracts/get_scope_tests/records.mligo", line 16, characters 40-41
    (b#4 -> b)
    Range: File "../../test/contracts/get_scope_tests/records.mligo", line 6, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/records.mligo", line 6, characters 8-56
    Content: |resolved: myrec|
    references:
      File "../../test/contracts/get_scope_tests/records.mligo", line 16, characters 3-4 ,
      File "../../test/contracts/get_scope_tests/records.mligo", line 16, characters 32-33
    (e#6 -> e)
    Range: File "../../test/contracts/get_scope_tests/records.mligo", line 15, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/records.mligo", line 16, characters 3-4
    Content: |resolved: myrec|
    references: []
    (g#5 -> g)
    Range: File "../../test/contracts/get_scope_tests/records.mligo", line 16, characters 19-20
    Body Range: File "../../test/contracts/get_scope_tests/records.mligo", line 16, characters 23-24
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/records.mligo", line 16, characters 28-29
    (i#2 -> i)
    Range: File "../../test/contracts/get_scope_tests/records.mligo", line 6, characters 18-19
    Body Range: File "../../test/contracts/get_scope_tests/records.mligo", line 6, characters 22-23
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/records.mligo", line 6, characters 42-43
    (j#3 -> j)
    Range: File "../../test/contracts/get_scope_tests/records.mligo", line 6, characters 31-32
    Body Range: File "../../test/contracts/get_scope_tests/records.mligo", line 6, characters 35-36
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/records.mligo", line 6, characters 44-45
    Type definitions:
    (myrec#0 -> myrec)
    Range: File "../../test/contracts/get_scope_tests/records.mligo", line 1, characters 0-36
    Body Range: File "../../test/contracts/get_scope_tests/records.mligo", line 1, characters 13-36
    Content: : record[bar -> int , foo -> int]
    Module definitions: |} ] ;

  run_ligo_good [ "info" ; "get-scope" ; gs "constant.mligo" ; "--format" ; "dev" ; "--with-types" ] ;
  [%expect{|
    Scopes:
    [ a#0 e#3 ] File "../../test/contracts/get_scope_tests/constant.mligo", line 6, characters 20-30
    [ a#0 c#1 d#2 ] File "../../test/contracts/get_scope_tests/constant.mligo", line 5, characters 35-44
    [ a#0 c#1 ] File "../../test/contracts/get_scope_tests/constant.mligo", line 5, characters 22-44
    [ a#0 ] File "../../test/contracts/get_scope_tests/constant.mligo", line 4, character 2 to line 6, character 32
    [ ] File "../../test/contracts/get_scope_tests/constant.mligo", line 1, characters 0-9

    Variable definitions:
    (a#0 -> a)
    Range: File "../../test/contracts/get_scope_tests/constant.mligo", line 1, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/constant.mligo", line 1, characters 8-9
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/constant.mligo", line 5, characters 43-44 ,
      File "../../test/contracts/get_scope_tests/constant.mligo", line 6, characters 22-23 ,
      File "../../test/contracts/get_scope_tests/constant.mligo", line 6, characters 29-30
    (b#4 -> b)
    Range: File "../../test/contracts/get_scope_tests/constant.mligo", line 3, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/constant.mligo", line 4, character 2 to line 6, character 33
    Content: |resolved: list (int)|
    references: []
    (c#1 -> c)
    Range: File "../../test/contracts/get_scope_tests/constant.mligo", line 5, characters 10-11
    Body Range: File "../../test/contracts/get_scope_tests/constant.mligo", line 5, characters 22-44
    Content: |core: int|
    references:
      File "../../test/contracts/get_scope_tests/constant.mligo", line 5, characters 39-40
    (d#2 -> d)
    Range: File "../../test/contracts/get_scope_tests/constant.mligo", line 5, characters 26-27
    Body Range: File "../../test/contracts/get_scope_tests/constant.mligo", line 5, characters 30-31
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/constant.mligo", line 5, characters 35-36
    (e#3 -> e)
    Range: File "../../test/contracts/get_scope_tests/constant.mligo", line 6, characters 9-10
    Body Range: File "../../test/contracts/get_scope_tests/constant.mligo", line 6, characters 13-14
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/constant.mligo", line 6, characters 20-21 ,
      File "../../test/contracts/get_scope_tests/constant.mligo", line 6, characters 27-28
    Type definitions:
    Module definitions: |} ] 

let%expect_test _ =
  run_ligo_good [ "info"; "get-scope" ; gs "application.mligo" ; "--format";"dev" ; "--with-types" ] ;
  [%expect{|
    Scopes:
    [ c#4 f#2 ] File "../../test/contracts/get_scope_tests/application.mligo", line 3, characters 35-36
    [ b#3 f#2 ] File "../../test/contracts/get_scope_tests/application.mligo", line 3, characters 16-19
    [ f#2 ] File "../../test/contracts/get_scope_tests/application.mligo", line 3, characters 3-36
    [ i#0 j#1 ] File "../../test/contracts/get_scope_tests/application.mligo", line 2, characters 58-63

    Variable definitions:
    (a#5 -> a)
    Range: File "../../test/contracts/get_scope_tests/application.mligo", line 1, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/application.mligo", line 2, character 2 to line 3, character 37
    Content: |resolved: int|
    references: []
    (b#3 -> b)
    Range: File "../../test/contracts/get_scope_tests/application.mligo", line 3, characters 7-8
    Body Range: File "../../test/contracts/get_scope_tests/application.mligo", line 3, characters 11-12
    Content: |resolved: int|
    references: []
    (c#4 -> c)
    Range: File "../../test/contracts/get_scope_tests/application.mligo", line 3, characters 26-27
    Body Range: File "../../test/contracts/get_scope_tests/application.mligo", line 3, characters 30-31
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/application.mligo", line 3, characters 35-36
    (f#2 -> f)
    Range: File "../../test/contracts/get_scope_tests/application.mligo", line 2, characters 6-7
    Body Range: File "../../test/contracts/get_scope_tests/application.mligo", line 2, characters 31-63
    Content: |core: int -> int -> int|
    references:
      File "../../test/contracts/get_scope_tests/application.mligo", line 3, characters 16-17
    (i#0 -> i)
    Range: File "../../test/contracts/get_scope_tests/application.mligo", line 2, characters 36-37
    Body Range: File "../../test/contracts/get_scope_tests/application.mligo", line 2, characters 31-63
    Content: |core: int|
    references:
      File "../../test/contracts/get_scope_tests/application.mligo", line 2, characters 62-63
    (j#1 -> j)
    Range: File "../../test/contracts/get_scope_tests/application.mligo", line 2, characters 46-47
    Body Range: File "../../test/contracts/get_scope_tests/application.mligo", line 2, characters 58-63
    Content: |core: int|
    references:
      File "../../test/contracts/get_scope_tests/application.mligo", line 2, characters 58-59
    Type definitions:
    Module definitions: |} ]

let%expect_test _ =
  run_ligo_good [ "info"; "get-scope" ; gs "include.mligo" ; "--format"; "dev" ; "--with-types" ] ;
  [%expect{|
    Scopes:
    [ a#0 b#5 x#6 ] File "../../test/contracts/get_scope_tests/include.mligo", line 5, characters 8-13
    [ a#0 b#5 ] File "../../test/contracts/get_scope_tests/include.mligo", line 3, characters 0-9
    [ a#0 c#1 d#4 ] File "../../test/contracts/get_scope_tests/letin.mligo", line 10, characters 2-11
    [ a#0 c#1 e#2 f#3 ] File "../../test/contracts/get_scope_tests/letin.mligo", line 8, characters 4-17
    [ a#0 c#1 e#2 ] File "../../test/contracts/get_scope_tests/letin.mligo", line 7, characters 12-21
    [ a#0 c#1 ] File "../../test/contracts/get_scope_tests/letin.mligo", line 6, characters 12-17
    [ a#0 ] File "../../test/contracts/get_scope_tests/letin.mligo", line 4, characters 10-15
    [ ] File "../../test/contracts/get_scope_tests/letin.mligo", line 1, characters 0-9

    Variable definitions:
    (a#0 -> a)
    Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 1, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 1, characters 8-9
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/letin.mligo", line 4, characters 14-15 ,
      File "../../test/contracts/get_scope_tests/letin.mligo", line 6, characters 12-13 ,
      File "../../test/contracts/get_scope_tests/letin.mligo", line 7, characters 12-13 ,
      File "../../test/contracts/get_scope_tests/letin.mligo", line 8, characters 4-5 ,
      File "../../test/contracts/get_scope_tests/letin.mligo", line 10, characters 2-3
    (b#5 -> b)
    Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 3, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 4, character 2 to line 10, character 11
    Content: |resolved: int|
    references: []
    (c#1 -> c)
    Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 4, characters 6-7
    Body Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 4, characters 10-15
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/letin.mligo", line 6, characters 16-17 ,
      File "../../test/contracts/get_scope_tests/letin.mligo", line 7, characters 16-17 ,
      File "../../test/contracts/get_scope_tests/letin.mligo", line 8, characters 8-9 ,
      File "../../test/contracts/get_scope_tests/letin.mligo", line 10, characters 6-7
    (d#4 -> d)
    Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 5, characters 6-7
    Body Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 6, character 4 to line 8, character 17
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/letin.mligo", line 10, characters 10-11
    (e#2 -> e)
    Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 6, characters 8-9
    Body Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 6, characters 12-17
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/letin.mligo", line 7, characters 20-21 ,
      File "../../test/contracts/get_scope_tests/letin.mligo", line 8, characters 12-13
    (f#3 -> f)
    Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 7, characters 8-9
    Body Range: File "../../test/contracts/get_scope_tests/letin.mligo", line 7, characters 12-21
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/letin.mligo", line 8, characters 16-17
    (x#6 -> x)
    Range: File "../../test/contracts/get_scope_tests/include.mligo", line 3, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/include.mligo", line 3, characters 8-9
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/include.mligo", line 5, characters 8-9
    (y#7 -> y)
    Range: File "../../test/contracts/get_scope_tests/include.mligo", line 5, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/include.mligo", line 5, characters 8-13
    Content: |resolved: int|
    references: []
    Type definitions:
    Module definitions: |} ]

let%expect_test _ =
  run_ligo_good [ "info"; "get-scope" ; gs "bad_field_record.mligo" ; "--format"; "dev" ; "--with-types" ] ;
  [%expect{|
    Scopes:
    [ a#3 c#1 foo_record#0 j#4 ] File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 14, characters 2-3
    [ a#3 c#1 foo_record#0 ] File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 13, characters 10-11
    [ c#1 foo_record#0 i#2 ] File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 10, characters 2-3
    [ c#1 foo_record#0 ] File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 9, characters 10-11
    [ foo_record#0 ] File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 4, character 8 to line 5, character 9

    Variable definitions:
    (a#3 -> a)
    Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 8, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 9, character 2 to line 10, character 3
    Content: |resolved: int|
    references: []
    (b#5 -> b)
    Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 12, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 13, character 2 to line 14, character 3
    Content: |unresolved|
    references: []
    (c#1 -> c)
    Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 3, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 3, character 8 to line 6, character 1
    Content: |resolved: foo_record|
    references:
      File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 9, characters 10-11 ,
      File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 13, characters 10-11
    (i#2 -> i)
    Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 9, characters 6-7
    Body Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 9, characters 10-15
    Content: |resolved: int|
    references:
      File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 10, characters 2-3
    (j#4 -> j)
    Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 13, characters 6-7
    Body Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 13, characters 10-15
    Content: |unresolved|
    references:
      File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 14, characters 2-3
    Type definitions:
    (foo_record#0 -> foo_record)
    Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 1, characters 0-43
    Body Range: File "../../test/contracts/get_scope_tests/bad_field_record.mligo", line 1, characters 18-43
    Content: : record[bar -> int , foo -> int]
    Module definitions: |} ];

  run_ligo_good [ "info"; "get-scope" ; gs "nominal_types.mligo" ; "--format"; "dev" ; "--with-types" ] ;
  [%expect{|
    Scopes:
    [ a#2 b#3 c#4 foo_record#1 foo_variant#0 p#5 ] File "../../test/contracts/get_scope_tests/nominal_types.mligo", line 13, characters 42-43
    [ a#2 b#3 foo_record#1 foo_variant#0 ] File "../../test/contracts/get_scope_tests/nominal_types.mligo", line 9, character 8 to line 10, character 9
    [ a#2 foo_record#1 foo_variant#0 ] File "../../test/contracts/get_scope_tests/nominal_types.mligo", line 6, characters 12-14
    [ foo_record#1 foo_variant#0 ] File "../../test/contracts/get_scope_tests/nominal_types.mligo", line 4, characters 12-13

    Variable definitions:
    (a#2 -> a)
    Range: File "../../test/contracts/get_scope_tests/nominal_types.mligo", line 4, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/nominal_types.mligo", line 4, characters 8-13
    Content: |resolved: foo_variant|
    references:
      File "../../test/contracts/get_scope_tests/nominal_types.mligo", line 9, characters 8-9
    (b#3 -> b)
    Range: File "../../test/contracts/get_scope_tests/nominal_types.mligo", line 6, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/nominal_types.mligo", line 6, characters 8-14
    Content: |resolved: foo_variant|
    references:
      File "../../test/contracts/get_scope_tests/nominal_types.mligo", line 10, characters 8-9
    (c#4 -> c)
    Range: File "../../test/contracts/get_scope_tests/nominal_types.mligo", line 8, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/nominal_types.mligo", line 8, character 8 to line 11, character 1
    Content: |resolved: foo_record|
    references: []
    (main#6 -> main)
    Range: File "../../test/contracts/get_scope_tests/nominal_types.mligo", line 13, characters 4-8
    Body Range: File "../../test/contracts/get_scope_tests/nominal_types.mligo", line 13, characters 10-11
    Content: |core: foo_record -> foo_variant|
    references: []
    (p#5 -> p)
    Range: File "../../test/contracts/get_scope_tests/nominal_types.mligo", line 13, characters 10-11
    Body Range: File "../../test/contracts/get_scope_tests/nominal_types.mligo", line 13, characters 42-47
    Content: |core: foo_record|
    references:
      File "../../test/contracts/get_scope_tests/nominal_types.mligo", line 13, characters 42-43
    Type definitions:
    (foo_record#1 -> foo_record)
    Range: File "../../test/contracts/get_scope_tests/nominal_types.mligo", line 2, characters 0-58
    Body Range: File "../../test/contracts/get_scope_tests/nominal_types.mligo", line 2, characters 18-58
    Content: : record[bar -> foo_variant , foo -> foo_variant]
    (foo_variant#0 -> foo_variant)
    Range: File "../../test/contracts/get_scope_tests/nominal_types.mligo", line 1, characters 0-45
    Body Range: File "../../test/contracts/get_scope_tests/nominal_types.mligo", line 1, characters 19-45
    Content: : sum[Bar -> string , Foo -> int]
    Module definitions: |} ] ;
    
  run_ligo_good [ "info"; "get-scope" ; gs "module.mligo" ; "--format"; "dev" ; "--with-types" ] ;
  [%expect{|
    Scopes:
    [ C#6 D#7 a#5 ] File "../../test/contracts/get_scope_tests/module.mligo", line 16, characters 4-7
    [ A#1 B#3 a#2 ] File "../../test/contracts/get_scope_tests/module.mligo", line 9, characters 0-14
    [ A#1 ] File "../../test/contracts/get_scope_tests/module.mligo", line 5, characters 0-14
    [ ] File "../../test/contracts/get_scope_tests/module.mligo", line 2, character 4 to line 13, character 17

    Variable definitions:
    (a#2 -> a)
    Range: File "../../test/contracts/get_scope_tests/module.mligo", line 5, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/module.mligo", line 5, characters 8-14
    Content: |resolved: int|
    references: []
    (a#5 -> a)
    Range: File "../../test/contracts/get_scope_tests/module.mligo", line 13, characters 12-13
    Body Range: File "../../test/contracts/get_scope_tests/module.mligo", line 13, characters 16-17
    Content: |resolved: int|
    references: []
    (b#4 -> b)
    Range: File "../../test/contracts/get_scope_tests/module.mligo", line 9, characters 4-5
    Body Range: File "../../test/contracts/get_scope_tests/module.mligo", line 9, characters 8-14
    Content: |resolved: int|
    references: []
    (titi#8 -> titi)
    Range: File "../../test/contracts/get_scope_tests/module.mligo", line 11, characters 4-8
    Body Range: File "../../test/contracts/get_scope_tests/module.mligo", line 12, character 4 to line 16, character 7
    Content: |resolved: int|
    references: []
    (toto#0 -> toto)
    Range: File "../../test/contracts/get_scope_tests/module.mligo", line 2, characters 8-12
    Body Range: File "../../test/contracts/get_scope_tests/module.mligo", line 2, characters 15-16
    Content: |resolved: int|
    references: []
    Type definitions:
    Module definitions:
    (A#1 -> A)
    Range: File "../../test/contracts/get_scope_tests/module.mligo", line 1, characters 7-8
    Body Range: File "../../test/contracts/get_scope_tests/module.mligo", line 1, character 0 to line 3, character 3
    Content: Members: Variable definitions:
                      (toto#0 -> toto)
                      Range: File "../../test/contracts/get_scope_tests/module.mligo", line 2, characters 8-12
                      Body Range: File "../../test/contracts/get_scope_tests/module.mligo", line 2, characters 15-16
                      Content: |resolved: int|
                      references:
                        File "../../test/contracts/get_scope_tests/module.mligo", line 5, characters 10-14 ,
                        File "../../test/contracts/get_scope_tests/module.mligo", line 9, characters 10-14
                      Type definitions:
                      Module definitions:

    references:
      File "../../test/contracts/get_scope_tests/module.mligo", line 5, characters 8-9 ,
      File "../../test/contracts/get_scope_tests/module.mligo", line 7, characters 11-12

    (B#3 -> B)
    Range: File "../../test/contracts/get_scope_tests/module.mligo", line 7, characters 7-8
    Body Range: File "../../test/contracts/get_scope_tests/module.mligo", line 7, characters 11-12
    Content: Alias: A
    references:
      File "../../test/contracts/get_scope_tests/module.mligo", line 9, characters 8-9

    (C#6 -> C)
    Range: File "../../test/contracts/get_scope_tests/module.mligo", line 12, characters 11-12
    Body Range: File "../../test/contracts/get_scope_tests/module.mligo", line 12, character 4 to line 14, character 7
    Content: Members: Variable definitions:
                      (a#5 -> a)
                      Range: File "../../test/contracts/get_scope_tests/module.mligo", line 13, characters 12-13
                      Body Range: File "../../test/contracts/get_scope_tests/module.mligo", line 13, characters 16-17
                      Content: |resolved: int|
                      references:
                        File "../../test/contracts/get_scope_tests/module.mligo", line 16, characters 6-7
                      Type definitions:
                      Module definitions:

    references:
      File "../../test/contracts/get_scope_tests/module.mligo", line 15, characters 15-16

    (D#7 -> D)
    Range: File "../../test/contracts/get_scope_tests/module.mligo", line 15, characters 11-12
    Body Range: File "../../test/contracts/get_scope_tests/module.mligo", line 15, characters 15-16
    Content: Alias: C
    references:
      File "../../test/contracts/get_scope_tests/module.mligo", line 16, characters 4-5 |} ]

      (* TODO: tests
         
      1.
      module A = struct
        let x = 1
        module B = struct
          let y = 2
        end
        module E = B
      end
      module C = A.B
      module D = A
      module F = A.E
      let a1 = A.B.y
      let a2 = A.x
      let a3 = C.y
      let a4 = D.x
      let a5 = F.y
      
      2.
      module A = struct 
        let x = 1
      end 
      let x =
        module B = struct 
          let y = 2
          let z = A.x
          module C = struct
            let a1 = y
            let a2 = z
            let a3 = 3
          end
        end in
        module D = B in
        let b1 = B.y in
        let b2 = B.z in
        let b3 = B.C.a1 in
        let b4 = B.C.a2 in
        let b5 = B.C.a3 in
        let c1 = D.y in
        let c2 = D.z in
        let c3 = D.C.a1 in
        let c4 = D.C.a2 in
        let c5 = D.C.a3 in
        42

      *)