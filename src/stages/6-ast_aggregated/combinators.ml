module Location = Simple_utils.Location
module List = Simple_utils.List
module Ligo_string = Simple_utils.Ligo_string
open Ligo_prim
open Literal_types
open Types

(* Helpers for accessing and constructing elements are derived using
   `ppx_woo` (`@@deriving ez`) *)

type expression_content = [%import: Types.expression_content]
[@@deriving
  ez
    { prefixes =
        [ ( "make_e"
          , fun ~loc expression_content type_expression : expression ->
              { expression_content; location = loc; type_expression } )
        ; ("get", fun x -> x.expression_content)
        ; ("get_type", fun x -> x.type_expression)
        ]
    ; wrap_constructor =
        ("expression_content", fun content type_ ~loc -> make_e ~loc content type_)
    ; wrap_get = "expression_content", get
    }]

type type_content = [%import: Types.type_content]
[@@deriving
  ez
    { prefixes =
        [ ( "make_t"
          , fun ~loc ?source_type type_content : type_expression ->
              { type_content; location = loc; orig_var = None; source_type } )
        ; ("get", fun x -> x.type_content)
        ]
    ; wrap_constructor =
        ( "type_content"
        , fun type_content ~loc ?source_type () -> make_t ~loc ?source_type type_content
        )
    ; wrap_get = "type_content", get
    ; default_get = `Option
    }]

let t_constant ~loc injection parameters : type_expression =
  t_constant ~loc { language = Backend.Michelson.name; injection; parameters } ()


(* TODO?: X_name here should be replaced by X_injection *)
let t__type_ ~loc () : type_expression = t_constant ~loc _type_ []
  [@@map
    _type_
    , ( "signature"
      , "chain_id"
      , "string"
      , "bytes"
      , "key"
      , "key_hash"
      , "int"
      , "address"
      , "operation"
      , "nat"
      , "tez"
      , "timestamp"
      , "unit"
      , "bls12_381_g1"
      , "bls12_381_g2"
      , "bls12_381_fr"
      , "never"
      , "mutation"
      , "pvss_key"
      , "baker_hash"
      , "chest_key"
      , "chest" )]


let t__type_ ~loc t : type_expression = t_constant ~loc _type_ [ t ]
  [@@map _type_, ("list", "set", "contract", "ticket")]


let t__type_ ~loc t t' : type_expression = t_constant ~loc _type_ [ t; t' ]
  [@@map _type_, ("map", "big_map", "typed_address")]


let t_mutez = t_tez
let default_layout = Layout.default

let fields_with_no_annot fields =
  List.map ~f:(fun (name, _) -> Layout.{ name; annot = None }) fields


let ez_t_record ~loc ?(layout = default_layout) lst : type_expression =
  let layout = layout @@ fields_with_no_annot lst in
  let row = Row.of_alist_exn ~layout lst in
  make_t ~loc (T_record row)


(* hmm *)
let ez_t_record_hmm ~loc ~layout lst : type_expression =
  let row = Row.of_alist_exn ~layout lst in
  make_t ~loc (T_record row)


let make_t_ez_record
    ~loc
    ?(layout = default_layout)
    (lst : (string * type_expression) list)
    : type_expression
  =
  let lst = List.map ~f:(fun (name, t) -> Label.of_string name, t) lst in
  ez_t_record ~loc ~layout lst


let t_pair ~loc a b : type_expression =
  ez_t_record ~loc [ Label.of_int 0, a; Label.of_int 1, b ]


let t_triplet ~loc a b c : type_expression =
  ez_t_record ~loc [ Label "0", a; Label "1", b; Label "2", c ]


let t_unforged_ticket ~loc ty : type_expression =
  ez_t_record
    ~loc
    [ Label "ticketer", t_address ~loc ()
    ; Label "value", ty
    ; Label "amount", t_nat ~loc ()
    ]


let t_sum_ez ~loc ?(layout = default_layout) (lst : (string * type_expression) list)
    : type_expression
  =
  let lst = List.map ~f:(fun (name, t) -> Label.of_string name, t) lst in
  let layout = layout @@ fields_with_no_annot lst in
  let map = Row.of_alist_exn ~layout lst in
  make_t ~loc (T_sum map)


let t_bool ~loc () : type_expression =
  t_sum_ez ~loc [ "True", t_unit ~loc (); "False", t_unit ~loc () ]


let t_option ~loc typ : type_expression =
  t_sum_ez ~loc [ "Some", typ; "None", t_unit ~loc () ]


(* types specific to LIGO test framework*)
let t_michelson_code ~loc () : type_expression =
  t_constant ~loc Ligo_prim.Literal_types.Michelson_program []


let t_test_exec_error ~loc () : type_expression =
  t_sum_ez
    ~loc
    [ "Rejected", t_pair ~loc (t_michelson_code ~loc ()) (t_address ~loc ())
    ; "Other", t_unit ~loc ()
    ]


let t_test_exec_result ~loc () : type_expression =
  t_sum_ez
    ~loc
    [ "Success", t_unit ~loc ()
    ; ( "Fail"
      , t_sum_ez
          ~loc
          [ "Rejected", t_pair ~loc (t_michelson_code ~loc ()) (t_address ~loc ())
          ; "Other", t_unit ~loc ()
          ] )
    ]


let t_arrow param result ~loc ?source_type () : type_expression =
  t_arrow ~loc ?source_type { type1 = param; type2 = result } ()


let t_shallow_closure param result ~loc () : type_expression =
  make_t ~loc (T_arrow { type1 = param; type2 = result })


let t_chest_opening_result ~loc () : type_expression =
  t_sum_ez
    ~loc
    [ "Ok_opening", t_bytes ~loc ()
    ; "Fail_decrypt", t_unit ~loc ()
    ; "Fail_timelock", t_unit ~loc ()
    ]


let get_t_bool (t : type_expression) : unit option =
  let t_bool = t_bool ~loc:t.location () in
  Option.some_if (equal_type_content t.type_content t_bool.type_content) ()


let get_t_option (t : type_expression) : type_expression option =
  let l_none = Label.of_string "None" in
  let l_some = Label.of_string "Some" in
  match t.type_content with
  | T_sum { fields; _ } ->
    let keys = Record.labels fields in
    (match keys with
    | [ a; b ]
      when (Label.equal a l_none && Label.equal b l_some)
           || (Label.equal a l_some && Label.equal b l_none) ->
      Record.find_opt fields l_some
    | _ -> None)
  | _ -> None


let get_param_inj (t : type_expression)
    : (string * Ligo_prim.Literal_types.t * type_expression list) option
  =
  match t.type_content with
  | T_constant { language; injection; parameters } ->
    Some (language, injection, parameters)
  | _ -> None


let get_t_inj (t : type_expression) (v : Ligo_prim.Literal_types.t)
    : type_expression list option
  =
  match t.type_content with
  | T_constant { language = _; injection; parameters }
    when Ligo_prim.Literal_types.equal injection v -> Some parameters
  | _ -> None


let get_t_base_inj (t : type_expression) (v : Ligo_prim.Literal_types.t) : unit option =
  match get_t_inj t v with
  | Some [] -> Some ()
  | _ -> None


let get_t_unary_inj (t : type_expression) (v : Ligo_prim.Literal_types.t)
    : type_expression option
  =
  match get_t_inj t v with
  | Some [ a ] -> Some a
  | _ -> None


let get_t_binary_inj (t : type_expression) (v : Ligo_prim.Literal_types.t)
    : (type_expression * type_expression) option
  =
  match get_t_inj t v with
  | Some [ a; b ] -> Some (a, b)
  | _ -> None


let get_t__type_ (t : type_expression) : unit option = get_t_base_inj t _type_
  [@@map
    _type_
    , ( "int"
      , "nat"
      , "unit"
      , "tez"
      , "timestamp"
      , "address"
      , "bytes"
      , "string"
      , "key"
      , "signature"
      , "key_hash"
      , "chest"
      , "chest_key"
      , "michelson_program"
      , "bls12_381_g1"
      , "bls12_381_g2"
      , "bls12_381_fr" )]


let get_t__type_ (t : type_expression) : type_expression option = get_t_unary_inj t _type_
  [@@map
    _type_
    , ("contract", "list", "set", "ticket", "sapling_state", "sapling_transaction", "gen")]


let get_t_mutez (t : type_expression) : unit option = get_t_tez t
let get_t_michelson_code (t : type_expression) : unit option = get_t_michelson_program t

let tuple_of_record (m : _ Record.t) =
  let aux i =
    let opt = Record.find_opt m (Label.of_int i) in
    Option.bind ~f:(fun opt -> Some (opt, i + 1)) opt
  in
  Base.Sequence.to_list @@ Base.Sequence.unfold ~init:0 ~f:aux


let t_tuple ~loc xs : type_expression =
  ez_t_record ~loc @@ List.mapi ~f:(fun i t -> Label.of_int i, t) xs


let get_t_tuple (t : type_expression) : type_expression list option =
  match t.type_content with
  | T_record struct_ -> Some (tuple_of_record struct_.fields)
  | _ -> None


let get_t_pair (t : type_expression) : (type_expression * type_expression) option =
  match t.type_content with
  | T_record m ->
    let lst = tuple_of_record m.fields in
    (match List.(length lst = 2) with
    | true -> Some List.(nth_exn lst 0, nth_exn lst 1)
    | false -> None)
  | _ -> None


let get_t_map (t : type_expression) : (type_expression * type_expression) option =
  match t.type_content with
  | T_constant { language = _; injection; parameters = [ k; v ] }
    when Ligo_prim.Literal_types.equal injection Ligo_prim.Literal_types.Map -> Some (k, v)
  | _ -> None


let get_t_typed_address (t : type_expression) : (type_expression * type_expression) option
  =
  match t.type_content with
  | T_constant { language = _; injection; parameters = [ k; v ] }
    when Ligo_prim.Literal_types.equal injection Ligo_prim.Literal_types.Typed_address ->
    Some (k, v)
  | _ -> None


let get_t_big_map (t : type_expression) : (type_expression * type_expression) option =
  match t.type_content with
  | T_constant { language = _; injection; parameters = [ k; v ] }
    when Ligo_prim.Literal_types.equal injection Ligo_prim.Literal_types.Big_map ->
    Some (k, v)
  | _ -> None


let get_t_map_or_big_map (t : type_expression)
    : (type_expression * type_expression) option
  =
  match t.type_content with
  | T_constant { language = _; injection; parameters = [ k; v ] }
    when Ligo_prim.Literal_types.equal injection Ligo_prim.Literal_types.Big_map ->
    Some (k, v)
  | T_constant { language = _; injection; parameters = [ k; v ] }
    when Ligo_prim.Literal_types.equal injection Ligo_prim.Literal_types.Map -> Some (k, v)
  | _ -> None


let get_t__type__exn t =
  match get_t__type_ t with
  | Some x -> x
  | None -> raise (Failure ("Internal error: broken invariant at " ^ __LOC__))
  [@@map _type_, ("list", "set", "map", "typed_address", "big_map", "gen")]


let assert_t_contract (t : type_expression) : unit option =
  match get_t_unary_inj t Ligo_prim.Literal_types.Contract with
  | Some _ -> Some ()
  | _ -> None


let is_t__type_ t = Option.is_some (get_t__type_ t)
  [@@map
    _type_
    , ( "list"
      , "set"
      , "nat"
      , "string"
      , "bytes"
      , "int"
      , "unit"
      , "address"
      , "tez"
      , "contract"
      , "map"
      , "big_map"
      , "typed_address" )]


let is_t_mutez t = is_t_tez t

let is_t_bool t =
  match t.type_content with
  | T_sum { fields; _ } ->
    (match Record.labels fields with
    | [ Label "True"; Label "False" ] -> true
    | _ -> false)
  | _ -> false


let assert_t_list_operation (t : type_expression) : unit option =
  match get_t_list t with
  | Some t' -> get_t_base_inj t' Ligo_prim.Literal_types.Operation
  | None -> None


let assert_t__type_ : type_expression -> unit option = fun t -> get_t__type_ t
 [@@map
   _type_
   , ( "int"
     , "nat"
     , "unit"
     , "mutez"
     , "key"
     , "signature"
     , "key_hash"
     , "bytes"
     , "string"
     , "michelson_code" )]


let assert_t__type_ : type_expression -> unit option =
 fun v -> Option.map ~f:(fun _ -> ()) @@ get_t__type_ v
 [@@map _type_, ("set", "list")]


let ez_e_record (lst : (Label.t * expression) list) : expression_content =
  E_record (Record.of_list lst)


let e__ct_ () : expression_content = E_constant { cons_name = C__CT_; arguments = [] }
  [@@map _ct_, ("none", "nil", "set_empty", "map_empty", "big_map_empty")]


let e__ct_ p : expression_content = E_constant { cons_name = C__CT_; arguments = [ p ] }
  [@@map _ct_, "some"]


let e__ct_ p p' : expression_content =
  E_constant { cons_name = C__CT_; arguments = [ p; p' ] }
  [@@map _ct_, ("cons", "set_add", "map_remove")]


let e_map_add k v tl : expression_content =
  E_constant { cons_name = C_MAP_ADD; arguments = [ k; v; tl ] }


let e__type_ p : expression_content = E_literal (Literal__type_ p)
  [@@map
    _type_
    , ( "int"
      , "nat"
      , "mutez"
      , "string"
      , "bytes"
      , "timestamp"
      , "address"
      , "signature"
      , "key"
      , "key_hash"
      , "chain_id"
      , "operation"
      , "bls12_381_g1"
      , "bls12_381_g2"
      , "bls12_381_fr"
      , "chest"
      , "chest_key" )]


let e_unit () : expression_content = E_literal Literal_unit
let e_pair a b : expression_content = ez_e_record [ Label.of_int 0, a; Label.of_int 1, b ]

let e_bool ~loc b : expression_content =
  if b
  then
    E_constructor
      { constructor = Label "True"; element = make_e ~loc (e_unit ()) (t_unit ~loc ()) }
  else
    E_constructor
      { constructor = Label "False"; element = make_e ~loc (e_unit ()) (t_unit ~loc ()) }


let e_a_literal ~loc l t = make_e ~loc (E_literal l) t

let e_a__type_ ~loc p = make_e ~loc (e__type_ p) (t__type_ ~loc ())
  [@@map
    _type_
    , ( "unit"
      , "int"
      , "nat"
      , "mutez"
      , "timestamp"
      , "key_hash"
      , "string"
      , "bytes"
      , "address"
      , "key"
      , "signature"
      , "bls12_381_g1"
      , "bls12_381_g2"
      , "bls12_381_fr"
      , "chest"
      , "chest_key"
      , "chain_id" )]


let e_a_pair ~loc a b =
  make_e ~loc (e_pair a b) (t_pair ~loc a.type_expression b.type_expression)


let e_a_constructor ~loc constructor element t =
  e_constructor ~loc { constructor = Label constructor; element } t


let e_a_record_accessor ~loc struct_ path t = e_accessor ~loc { struct_; path } t

let e_a_record ~loc ?(layout = default_layout) r =
  e_record
    ~loc
    r
    (ez_t_record
       ~loc
       ~layout
       (List.map ~f:(fun (label, expr) -> label, expr.type_expression) (Record.to_list r)))


let ez_e_a_record ~loc ?layout r =
  make_e
    ~loc
    (ez_e_record r)
    (ez_t_record ~loc ?layout (List.map ~f:(fun (x, y) -> x, y.type_expression) r))


(* hmm *)
let ez_e_a_record_hmm ~loc ~layout r =
  make_e
    ~loc
    (ez_e_record r)
    (ez_t_record_hmm ~loc ~layout (List.map ~f:(fun (x, y) -> x, y.type_expression) r))


let e_a_variable ~loc v ty = e_variable ~loc v ty
let e_a_application ~loc lamb args t = e_application ~loc { lamb; args } t
let e_a_lambda ~loc l in_ty out_ty = e_lambda ~loc l (t_arrow ~loc in_ty out_ty ())
let e_a_recursive ~loc l = e_recursive ~loc l l.fun_type

let e_a_let_in ~loc let_binder rhs let_result attributes =
  e_let_in ~loc { let_binder; rhs; let_result; attributes } (get_type let_result)


let e_a_matching ~loc matchee cases t = e_matching ~loc { matchee; cases } t
let e_a_raw_code ~loc language code t = e_raw_code ~loc { language; code } t
let e_a_type_inst ~loc forall type_ u = e_type_inst ~loc { forall; type_ } u
let e_a_bool ~loc b = make_e ~loc (e_bool ~loc b) (t_bool ~loc ())

(* Constants *)
let e_a_nil ~loc t = make_e ~loc (e_nil ()) (t_list ~loc t)
let e_a_none ~loc t = make_e ~loc (e_none ()) (t_option ~loc t)
let e_a_cons ~loc hd tl = make_e ~loc (e_cons hd tl) (t_list ~loc hd.type_expression)
let e_a_set_empty ~loc t = make_e ~loc (e_set_empty ()) (t_set ~loc t)
let e_a_set_add ~loc hd tl = make_e ~loc (e_set_add hd tl) (t_set ~loc hd.type_expression)
let e_a_map_empty ~loc kt vt = make_e ~loc (e_map_empty ()) (t_map ~loc kt vt)

let e_a_map_add ~loc k v tl =
  make_e ~loc (e_map_add k v tl) (t_map ~loc k.type_expression v.type_expression)


let e_a_big_map_empty ~loc kt vt = make_e ~loc (e_big_map_empty ()) (t_big_map ~loc kt vt)

let e_a_big_map_add ~loc k v tl =
  make_e ~loc (e_map_add k v tl) (t_big_map ~loc k.type_expression v.type_expression)


let e_a_big_map_remove ~loc k tl = make_e ~loc (e_map_remove k tl) tl.type_expression

let e_contract_opt ~loc a : expression_content =
  let language = "Michelson" in
  let code = Format.asprintf "{ PUSH address \"%s\" ; CONTRACT }" a in
  let code = e_a_string ~loc @@ Ligo_string.verbatim code in
  E_raw_code { language; code }


let e_a_contract_opt ~loc a t =
  make_e ~loc (e_contract_opt ~loc a) (t_option ~loc (t_contract ~loc t))


let e_contract_entrypoint_opt ~loc e a : expression_content =
  let language = "Michelson" in
  let code = Format.asprintf "{ PUSH address \"%s\" ; CONTRACT %%%s }" a e in
  let code = e_a_string ~loc @@ Ligo_string.verbatim code in
  E_raw_code { language; code }


let e_a_contract_entrypoint_opt ~loc e a t =
  make_e ~loc (e_contract_entrypoint_opt ~loc e a) (t_option ~loc (t_contract ~loc t))


let get_a_int (t : expression) =
  match t.expression_content with
  | E_literal (Literal_int n) -> Some n
  | _ -> None


let get_a_string (t : expression) =
  match t.expression_content with
  | E_literal (Literal_string s) -> Some (Ligo_string.extract s)
  | _ -> None


let get_a_verbatim (t : expression) =
  match t.expression_content with
  | E_literal (Literal_string (Verbatim v)) -> Some v
  | _ -> None


let get_a_unit (t : expression) =
  match t.expression_content with
  | E_literal Literal_unit -> Some ()
  | _ -> None


let get_a_bool (t : expression) =
  match t.expression_content with
  | E_constructor { constructor = Label name; element }
    when String.equal name "True"
         && compare_expression_content element.expression_content @@ e_unit () = 0 ->
    Some true
  | E_constructor { constructor = Label name; element }
    when String.equal name "False"
         && compare_expression_content element.expression_content @@ e_unit () = 0 ->
    Some false
  | _ -> None


let get_record_field_type (t : type_expression) (label : Label.t) : type_expression option
  =
  match get_t_record_opt t with
  | None -> None
  | Some struct_ -> Record.find_opt struct_.fields label


let get_variant_field_type (t : type_expression) (label : Label.t)
    : type_expression option
  =
  match get_t_sum_opt t with
  | None -> None
  | Some struct_ -> Record.find_opt struct_.fields label


let get_type_abstractions (e : expression) =
  let rec aux tv e =
    match get_e_type_abstraction e with
    | None -> tv, e
    | Some { type_binder; result } -> aux (type_binder :: tv) result
  in
  aux [] e


(* This function re-builds a term prefixed with E_type_abstraction:
   given an expression e and a list of type variables [t1; ...; tn],
   it constructs an expression /\ t1 . ... . /\ tn . e *)
let build_type_abstractions init =
  let t_for_all ty_binder kind type_ = t_for_all { ty_binder; kind; type_ } () in
  let f e abs_var =
    { e with
      expression_content = E_type_abstraction { type_binder = abs_var; result = e }
    ; type_expression = t_for_all ~loc:e.location abs_var Type e.type_expression
    }
  in
  List.fold_left ~init ~f


(* This function re-builds a term prefixed with E_type_inst:
   given an expression e and a list of type variables [t1; ...; tn],
   it constructs an expression e@{t1}@...@{tn} *)
let build_type_insts_opt ~loc init =
  let open Simple_utils.Option in
  let f av forall =
    let* forall in
    let* Abstraction.{ ty_binder; type_ = t; kind = _ } =
      get_t_for_all forall.type_expression
    in
    let type_ = t_variable ~loc av () in
    return
      (make_e ~loc (E_type_inst { forall; type_ }) (Helpers.subst_type ty_binder type_ t))
  in
  List.fold_right ~init:(return init) ~f


(* This function expands a function with a type T_for_all but not with
   the same amount of E_type_abstraction *)
let forall_expand_opt ~loc (e : expression) =
  let open Simple_utils.Option in
  let tvs, _ = Helpers.destruct_for_alls e.type_expression in
  let evs, e_without_type_abs = get_type_abstractions e in
  if List.equal Ligo_prim.Type_var.equal tvs evs
  then return e
  else
    let* e = build_type_insts_opt ~loc e_without_type_abs tvs in
    return @@ build_type_abstractions e tvs


let context_decl
    ~loc
    (binder : type_expression Binder.t)
    (expr : expression)
    (attr : ValueAttr.t)
    : context
  =
  [ Location.wrap ~loc @@ D_value { binder; expr; attr } ]


let context_decl_pattern
    ~loc
    (pattern : type_expression Pattern.t)
    (expr : expression)
    (attr : ValueAttr.t)
    : context
  =
  [ Location.wrap ~loc @@ D_irrefutable_match { pattern; expr; attr } ]


let context_id : context = []
let context_append (l : context) (r : context) : context = l @ r

let context_apply (p : context) (e : expression) : expression =
  let f d e =
    let loc = Location.get_location d in
    match Location.unwrap d with
    | D_value { binder; expr; attr } ->
      e_a_let_in ~loc (Types.Pattern.var ~loc binder) expr e attr
    | D_irrefutable_match { pattern; expr; attr } -> e_a_let_in ~loc pattern expr e attr
  in
  List.fold_right ~f ~init:e p


let get_e_tuple t =
  match t with
  | E_record r -> Some (List.map ~f:snd @@ Record.tuple_of_record r)
  | _ -> None
