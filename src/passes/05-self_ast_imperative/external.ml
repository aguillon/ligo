open Ast_imperative

let destruct_args (m : expression list) : (string * expression list) option =
  match m with
  | { expression_content = E_literal (Literal_string prim) ; _ } :: args ->
     Some (Simple_utils.Ligo_string.extract prim, args)
  | _ -> None

let replace : expression -> expression = fun e ->
  match e.expression_content with
  | E_raw_code { language ; code = { expression_content = E_tuple m ; _ } }
       when String.equal language "ext" -> (
    match destruct_args m with
    | Some (code, arguments) -> (
       match read_constant' code with
       | None -> failwith @@ "Constant cannot be externalized: " ^ code
       | Some cons ->
          let expression_content = E_constant { cons_name = Const cons;
                                                arguments } in
          { e with expression_content }
    )
    | _ -> e
  )
  | E_raw_code { language ; code = { expression_content = E_literal (Literal_string code) ; _ } }
       when String.equal language "ext" -> (
    let code = (Simple_utils.Ligo_string.extract code) in
    match read_constant' code with
    | None -> failwith @@ "Constant cannot be externalized: " ^ code
    | Some cons ->
       let expression_content = E_constant { cons_name = Const cons;
                                             arguments = [] } in
       { e with expression_content }
  )
  | _ -> e
