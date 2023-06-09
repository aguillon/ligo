(*
  Due to the nature of the pattern matching compilation (Core -> Typed), FAILWITH expression are sometimes generated when
  patterns matching a given expression alternates between variable and constructors.

  Those generated failwith expressions could be avoided but would unnecessarily complicate the pattern matching compiler.

  An example of such generated FAILWITH would be:
  ```
  match (u1,u2) with
  | Nil , ys  -> 1
  | xs  , Nil -> 2
  | Cons (a,b) , Cons (c,d) -> a + b + c + d
  ```
  being compiled to
  ```
  match u1 with
  | Nil -> 1
  | Cons _ ->
    match u2 with
    | Nil -> 2
    | Cons _ ->
      match u1 with
      | Nil -> failwith "PARTIAL_MATCH"
      | Cons (a,b) ->
        match u2 with
        | Nil -> failwith "PARTIAL_MATCH"
        | Cons (c,d) -> a + b + c + d
  ```

  This pass aims to remove those partial match failwiths by folding over the AST, and simplify a case-expression that appears
  inside another case expression for the same variable.
  If failwith expressions still remain after this pass, the matching expression is anomalous (redundant/exhaustive).
  That triggers a rather 'generic' error.

  TODO: It might be desirable to allow anomalous patterns when users wants it, leaving the generated failwiths (?)
  TODO: This approach is naive, with a more sophisticated approach it is possible to descriminate between non-exhaustive/redundant/unused patterns
*)

let fold_map_expression = Ast_expanded.Helpers.fold_map_expression

open Ligo_prim
open Ast_expanded
module SimplMap = Simple_utils.Map.Make (Value_var)

type simpl_map = (Label.t * Value_var.t) list SimplMap.t

let is_generated_partial_match : expression -> bool =
 fun exp ->
  match exp.expression_content with
  (* This is bad, we probably need some constant for "internally generated failwith" ? *)
  | E_application { lamb = { expression_content = E_variable v; _ }; args = e }
    when String.equal "failwith" (Format.asprintf "%a" Value_var.pp v) ->
    (match get_a_string e with
    | Some fw -> String.equal fw (Ligo_string.extract Backend.Michelson.fw_partial_match)
    | None -> false)
  | _ -> false


let rec do_while : (expression -> bool * expression) -> expression -> expression =
 fun f exp ->
  let has_been_simpl, exp = f exp in
  if has_been_simpl then do_while f exp else exp


let make_le : _ matching_content_variant -> (Label.t * Value_var.t) list =
 fun ml ->
  List.map ~f:(fun (m : _ matching_content_case) -> m.constructor, m.pattern) ml.cases


let substitute_var_in_body : Value_var.t -> Value_var.t -> expression -> expression =
 fun to_subst new_var body ->
  let aux : unit -> expression -> bool * unit * expression =
   fun () exp ->
    let ret continue exp = continue, (), exp in
    match exp.expression_content with
    | E_variable var when Value_var.equal var to_subst ->
      ret true { exp with expression_content = E_variable new_var }
    | _ -> ret true exp
  in
  let (), res = fold_map_expression aux () body in
  res


let compress_matching : expression -> expression =
 fun exp ->
  let aux : bool * simpl_map -> expression -> bool * (bool * simpl_map) * expression =
   fun (has_been_simpl, smap) exp ->
    let continue smap = true, (has_been_simpl, smap), exp in
    let stop e = false, (true, smap), e in
    match exp.expression_content with
    | E_matching m ->
      let matchee_var = get_e_variable_opt m.matchee in
      (match m.cases with
      | Match_variant cases ->
        (match matchee_var with
        | Some v ->
          (match SimplMap.find_opt v smap with
          | Some le ->
            let fw, no_fw =
              List.partition_tf
                ~f:(fun (case : _ matching_content_case) ->
                  is_generated_partial_match case.body)
                cases.cases
            in
            (match no_fw, fw with
            | [ { constructor = Label constructor; pattern; body } ], lst
              when List.length lst >= 1 ->
              let _, proj =
                List.find_exn
                  ~f:(fun (Label constructor', _) ->
                    String.equal constructor' constructor)
                  le
              in
              let body' = substitute_var_in_body pattern proj body in
              stop body'
            | _, _ -> continue smap)
          | None -> continue (SimplMap.add v (make_le cases) smap))
        | None -> continue smap)
      | _ -> continue smap)
    | _ -> continue smap
  in
  let simplify exp =
    let (has_been_simpl, _), exp = fold_map_expression aux (false, SimplMap.empty) exp in
    has_been_simpl, exp
  in
  do_while simplify exp


let peephole_expression exp =
  let exp' = compress_matching exp in
  exp'
