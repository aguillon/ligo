[@@@warning "-26-27-32"]

open Ligo_prim
open Types
module AST = Ast_core
module VVar = Value_var
module TVar = Type_var
module MVar = Module_var
module Formatter = Formatter
module Api_helper = Api_helper
module LSet = Types.LSet
module Location = Simple_utils.Location
module Trace = Simple_utils.Trace
module Types = Types

let get_location_of_module_path : Module_var.t list -> Location.t =
 fun mvs ->
  List.fold mvs ~init:Location.dummy ~f:(fun loc m ->
      Location.cover loc (Module_var.get_location m))


let defs_of_vvar ~(body : AST.expression) : VVar.t -> def list -> def list =
 fun vvar acc ->
  if VVar.is_generated vvar
  then acc
  else (
    let name = get_binder_name vvar in
    let vdef : vdef =
      let name : string = name in
      let uid : string = Types.make_def_id name (VVar.get_location vvar) in
      let range : Location.t = VVar.get_location vvar in
      let body_range : Location.t =
        match body.expression_content with
        (* For [E_recursive], we have to dig into [r.lambda.result] to get the real body range
             because otehrwise [body.location] will just return the "rec" keyword's range,
             for some reason *)
        | E_recursive r -> r.lambda.result.location
        | _ -> body.location
      in
      let t : type_case = Unresolved (* Filled in a later pass *) in
      let references : LSet.t = LSet.empty (* Filled in a later pass *) in
      let def_type : def_type = Local in
      { name; uid; range; body_range; t; references; def_type }
    in
    Variable vdef :: acc)


let defs_of_binder ~(body : AST.expression) : _ Binder.t -> def list -> def list =
 fun binder acc -> defs_of_vvar ~body (Binder.get_var binder) acc


let defs_of_tvar ~(bindee : Ast_core.type_expression) : TVar.t -> def list -> def list =
 fun tvar acc ->
  if TVar.is_generated tvar
  then acc
  else (
    let name = get_type_binder_name tvar in
    let tdef : tdef =
      let name : string = name in
      let uid : string = Types.make_def_id name (TVar.get_location tvar) in
      let range : Location.t = TVar.get_location tvar in
      let body_range : Location.t = bindee.location (* How to get this ? *) in
      let content : Ast_core.type_expression = bindee in
      let def_type : def_type = Local in
      let references : LSet.t = LSet.empty (* Filled in a later pass *) in
      { name; uid; range; body_range; content; def_type; references }
    in
    Type tdef :: acc)


let defs_of_mvar ~(bindee : Ast_core.module_expr) ~(mod_case : mod_case)
    : MVar.t -> def list -> def list
  =
 fun mvar acc ->
  if MVar.is_generated mvar
  then acc
  else (
    let name = get_mod_binder_name mvar in
    let mdef : mdef =
      let name : string = name in
      let uid : string = Types.make_def_id name (MVar.get_location mvar) in
      let range : Location.t = MVar.get_location mvar in
      let body_range : Location.t =
        match Location.unwrap bindee with
        | M_struct _ -> Location.get_location bindee
        | M_variable mvar -> MVar.get_location mvar
        | M_module_path mpath -> get_location_of_module_path @@ List.Ne.to_list mpath
      in
      let references : LSet.t = LSet.empty (* Filled in a later pass *) in
      let mod_case : mod_case = mod_case in
      let def_type : def_type = Local in
      { name; uid; range; body_range; references; mod_case; def_type }
    in
    Module mdef :: acc)


let rec defs_of_pattern ~(body : AST.expression)
    : AST.type_expression option Linear_pattern.t -> def list -> def list
  =
 fun ptrn acc ->
  let self ~body p = defs_of_pattern ~body p in
  let ptrn_binders = AST.Pattern.binders ptrn in
  let f defs binder = defs_of_binder ~body binder defs in
  let defs = List.fold ~init:acc ~f ptrn_binders in
  defs


let rec defs_of_expr : AST.expression -> def list -> def list =
 fun e acc ->
  let self = defs_of_expr in
  let defs_of_lambda : _ Lambda.t -> def list -> def list =
   fun { binder; output_type; result } acc ->
    let vvar = Param.get_var binder in
    self result @@ defs_of_vvar ~body:result vvar @@ acc
  in
  match e.expression_content with
  (* Base *)
  | E_variable v -> acc
  | E_literal l -> acc
  | E_constant c -> acc
  | E_application { lamb; args } -> self lamb @@ self args @@ acc
  | E_lambda lambda -> defs_of_lambda lambda acc
  | E_recursive { fun_name; fun_type; lambda; force_lambdarec } ->
    (* fun_name is already added by the parent E_let_in so don't need to add it here *)
    defs_of_lambda lambda acc
  | E_type_abstraction { type_binder; result } -> self result acc
  | E_let_in { let_binder; rhs; let_result; attributes }
  | E_let_mut_in { let_binder; rhs; let_result; attributes } ->
    defs_of_pattern ~body:rhs let_binder @@ self rhs @@ self let_result @@ acc
  | E_type_in { type_binder; rhs; let_result } ->
    defs_of_tvar ~bindee:rhs type_binder @@ self let_result @@ acc
  | E_mod_in { module_binder; rhs; let_result } ->
    let mod_case = mod_case_of_mod_expr ~defs_of_decls rhs in
    defs_of_mvar ~mod_case ~bindee:rhs module_binder @@ self let_result @@ acc
  | E_raw_code { language; code } -> []
  (* Variant *)
  | E_constructor { constructor; element } -> self element acc
  | E_matching { matchee; cases } ->
    let defs_of_match_cases cases acc =
      let defs_of_match_case acc ({ pattern; body } : _ AST.Match_expr.match_case) =
        defs_of_pattern ~body pattern @@ defs_of_expr body @@ acc
      in
      List.fold ~init:acc ~f:defs_of_match_case cases
    in
    defs_of_match_cases cases @@ self matchee @@ acc
  (* Record *)
  | E_record r -> Record.fold ~init:acc ~f:(fun acc entry -> self entry acc) r
  | E_accessor { struct_; path } ->
    self struct_ acc (* Is it possible to have decl in there ? *)
  | E_update { struct_; path; update } -> self struct_ @@ self update @@ acc
  (* Advanced *)
  | E_ascription { anno_expr; type_annotation } -> self anno_expr acc
  | E_module_accessor macc -> acc
  (* Imperative *)
  | E_assign { binder; expression } ->
    (* binder := new_value, the binder is already declared so we don't add it to the dec list *)
    self expression acc
  | E_for { binder; start; final; incr; f_body } ->
    defs_of_vvar ~body:f_body binder
    @@ self start
    @@ self final
    @@ self incr
    @@ self f_body
    @@ acc
  | E_for_each { fe_binder = vvar1, vvar2_opt; collection; collection_type = _; fe_body }
    ->
    let body = fe_body in
    let acc =
      match vvar2_opt with
      | Some vvar -> defs_of_vvar ~body vvar acc
      | None -> acc
    in
    self fe_body @@ self collection @@ defs_of_vvar ~body vvar1 @@ acc
  | E_while { cond; body } -> self cond @@ self body @@ acc


and mod_case_of_mod_expr
    :  defs_of_decls:(AST.declaration list -> def list -> def list) -> AST.module_expr
    -> mod_case
  =
 fun ~defs_of_decls mod_expr ->
  let alias_of_mvars : Module_var.t list -> mod_case =
   fun mvars ->
    let path = List.map ~f:(fun mvar -> Format.asprintf "%a" MVar.pp mvar) mvars in
    Alias path
  in
  match Location.unwrap mod_expr with
  | M_struct decls -> Def (defs_of_decls decls [])
  | M_variable mod_var -> alias_of_mvars [ mod_var ]
  | M_module_path mod_path -> alias_of_mvars @@ List.Ne.to_list mod_path


and defs_of_decl : AST.declaration -> def list -> def list =
 fun decl acc ->
  match Location.unwrap decl with
  | D_value { binder; expr; attr } ->
    defs_of_binder ~body:expr binder @@ defs_of_expr expr @@ acc
  | D_irrefutable_match { pattern; expr; attr } ->
    defs_of_pattern ~body:expr pattern @@ defs_of_expr expr @@ acc
  | D_type { type_binder; type_expr; type_attr } ->
    defs_of_tvar ~bindee:type_expr type_binder acc
  | D_module { module_binder; module_; module_attr } ->
    (* Here, the module body's defs are within the lhs_def,
         mod_case_of_mod_expr recursively calls defs_of_decl *)
    let mod_case : mod_case = mod_case_of_mod_expr ~defs_of_decls module_ in
    defs_of_mvar ~mod_case ~bindee:module_ module_binder @@ acc


and defs_of_decls : AST.declaration list -> def list -> def list =
 fun decls acc -> List.fold ~init:acc ~f:(fun accu decl -> defs_of_decl decl accu) decls


let definitions : AST.program -> def list -> def list =
 fun prg acc -> defs_of_decls prg acc


module Of_Stdlib = struct
  let rec defs_of_decl : AST.declaration -> def list -> def list =
   fun decl acc ->
    match Location.unwrap decl with
    | D_value { binder; expr; attr } -> defs_of_binder ~body:expr binder acc
    | D_irrefutable_match { pattern; expr; attr } ->
      defs_of_pattern ~body:expr pattern acc
    | D_type { type_binder; type_expr; type_attr } ->
      defs_of_tvar ~bindee:type_expr type_binder acc
    | D_module { module_binder; module_; module_attr } ->
      (* Here, the module body's defs are within the lhs_def,
         mod_case_of_mod_expr recursively calls defs_of_decl *)
      let mod_case : mod_case = mod_case_of_mod_expr module_ ~defs_of_decls in
      defs_of_mvar ~mod_case ~bindee:module_ module_binder acc


  and defs_of_decls : AST.declaration list -> def list -> def list =
   fun decls acc -> List.fold ~init:acc ~f:(fun accu decl -> defs_of_decl decl accu) decls


  let definitions : AST.program -> def list = fun prg -> defs_of_decls prg []
end
