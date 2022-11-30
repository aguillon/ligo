module Location = Simple_utils.Location
module PP = Simple_utils.PP_helpers
open Ligo_prim

type meta = Ast_core.type_expression option [@@deriving yojson]

type t =
  { content : content
  ; meta : (meta[@equal.ignore] [@compare.ignore] [@hash.ignore] [@sexp.opaque])
  ; orig_var : (Type_var.t option[@equal.ignore] [@compare.ignore] [@hash.ignore])
  ; location : (Location.t[@equal.ignore] [@compare.ignore] [@hash.ignore] [@sexp.opaque])
  }

and content =
  | T_variable of Type_var.t
  | T_exists of Type_var.t
  | T_construct of construct
  | T_sum of row
  | T_record of row
  | T_arrow of t Arrow.t
  | T_singleton of Literal_value.t
  | T_abstraction of t Abstraction.t
  | T_for_all of t Abstraction.t
[@@deriving
  yojson
  , ez
      { prefixes =
          [ ( "make_t"
            , fun ?(loc = Location.generated) content meta : t ->
                { content; location = loc; orig_var = None; meta } )
          ; ("get", fun x -> x.content)
          ]
      ; wrap_constructor =
          ("content", fun type_content ?loc ?meta () -> make_t ?loc type_content meta)
      ; wrap_get = "content", get
      ; default_get = `Option
      }]

and row =
  { fields : row_element Record.t
  ; layout : layout
  }

and row_element = t Rows.row_element_mini_c

and construct =
  { language : string
  ; constructor : Literal_types.t
  ; parameters : t list
  }

and layout =
  | L_comb
  | L_tree
  | L_exists of Layout_var.t
[@@deriving yojson, equal, sexp, compare, hash]

type constr = ?loc:Location.t -> ?meta:Ast_core.type_expression -> unit -> t

let rec free_vars t =
  let module Set = Type_var.Set in
  match t.content with
  | T_variable tvar -> Set.singleton tvar
  | T_exists _ -> Set.empty
  | T_construct { parameters; _ } -> parameters |> List.map ~f:free_vars |> Set.union_list
  | T_sum row | T_record row -> free_vars_row row
  | T_arrow arr -> arr |> Arrow.map free_vars |> Arrow.fold Set.union Set.empty
  | T_for_all abs | T_abstraction abs ->
    abs |> Abstraction.map free_vars |> Abstraction.fold Set.union Set.empty
  | T_singleton _ -> Set.empty


and free_vars_row { fields; _ } =
  Record.fold fields ~init:Type_var.Set.empty ~f:(fun fvs row_elem ->
      Set.union (free_vars_row_elem row_elem) fvs)


and free_vars_row_elem row_elem = free_vars row_elem.associated_type

let rec orig_vars t =
  let module Set = Type_var.Set in
  Set.union (Set.of_list (Option.to_list t.orig_var))
  @@
  match t.content with
  | T_variable _ | T_exists _ | T_singleton _ -> Set.empty
  | T_construct { parameters; _ } -> parameters |> List.map ~f:orig_vars |> Set.union_list
  | T_sum row | T_record row -> orig_vars_row row
  | T_arrow arr -> arr |> Arrow.map orig_vars |> Arrow.fold Set.union Set.empty
  | T_for_all abs | T_abstraction abs ->
    abs |> Abstraction.map orig_vars |> Abstraction.fold Set.union Set.empty


and orig_vars_row { fields; _ } =
  Record.fold fields ~init:Type_var.Set.empty ~f:(fun ovs row_elem ->
      Set.union (orig_vars_row_elem row_elem) ovs)


and orig_vars_row_elem row_elem = orig_vars row_elem.associated_type

let rec subst ?(free_vars = Type_var.Set.empty) t ~tvar ~type_ =
  let subst t = subst t ~free_vars ~tvar ~type_ in
  let subst_abstraction abs = subst_abstraction abs ~free_vars ~tvar ~type_ in
  let subst_row row = subst_row row ~free_vars ~tvar ~type_ in
  let return content = { t with content } in
  match t.content with
  | T_variable tvar' ->
    if Type_var.(tvar = tvar') then type_ else return @@ T_variable tvar'
  | T_exists tvar' -> return @@ T_exists tvar'
  | T_construct { language; constructor; parameters } ->
    let parameters = List.map ~f:subst parameters in
    return @@ T_construct { language; constructor; parameters }
  | T_sum row ->
    let row = subst_row row in
    return @@ T_sum row
  | T_record row ->
    let row = subst_row row in
    return @@ T_record row
  | T_singleton literal -> return @@ T_singleton literal
  | T_arrow arr ->
    let arr = Arrow.map subst arr in
    return @@ T_arrow arr
  | T_abstraction abs ->
    let abs = subst_abstraction abs in
    return @@ T_abstraction abs
  | T_for_all abs ->
    let abs = subst_abstraction abs in
    return @@ T_for_all abs


and subst_var t ~tvar ~tvar' =
  subst
    t
    ~free_vars:(Type_var.Set.singleton tvar')
    ~tvar
    ~type_:(t_variable ~loc:(Type_var.get_location tvar') tvar' ())


and subst_abstraction
    ?(free_vars = Type_var.Set.empty)
    { ty_binder; kind; type_ }
    ~tvar
    ~type_:type_'
    : _ Abstraction.t
  =
  let subst t = subst t ~free_vars:(Set.add free_vars ty_binder) ~tvar ~type_:type_' in
  if Type_var.(tvar = ty_binder)
  then { ty_binder; kind; type_ }
  else if Set.mem free_vars ty_binder
  then (
    let ty_binder' = Type_var.fresh () in
    let type_ = subst_var type_ ~tvar:ty_binder ~tvar':ty_binder' in
    { ty_binder = ty_binder'; kind; type_ = subst type_ })
  else { ty_binder; kind; type_ = subst type_ }


and subst_row ?(free_vars = Type_var.Set.empty) { fields; layout } ~tvar ~type_ =
  { fields = Record.map fields ~f:(subst_row_elem ~free_vars ~tvar ~type_); layout }


and subst_row_elem ?(free_vars = Type_var.Set.empty) row_elem ~tvar ~type_ =
  Rows.map_row_element_mini_c (subst ~free_vars ~tvar ~type_) row_elem


let subst t ~tvar ~type_ =
  let free_vars = free_vars t in
  subst ~free_vars t ~tvar ~type_


let rec fold : type a. t -> init:a -> f:(a -> t -> a) -> a =
 fun t ~init ~f ->
  let fold acc t = fold t ~f ~init:acc in
  let init = f init t in
  match t.content with
  | T_variable _ | T_exists _ | T_singleton _ -> init
  | T_construct { parameters; _ } -> List.fold parameters ~init ~f
  | T_sum row | T_record row -> fold_row row ~init ~f
  | T_arrow arr -> Arrow.fold fold init arr
  | T_abstraction abs | T_for_all abs -> Abstraction.fold fold init abs


and fold_row : type a. row -> init:a -> f:(a -> t -> a) -> a =
 fun { fields; _ } ~init ~f ->
  Record.LMap.fold
    (fun _label row_elem init -> fold_row_elem row_elem ~init ~f)
    fields
    init


and fold_row_elem : type a. row_element -> init:a -> f:(a -> t -> a) -> a =
 fun row_elem ~init ~f -> f init row_elem.associated_type


let destruct_type_abstraction t =
  let rec loop binders t =
    match t.content with
    | T_abstraction { ty_binder; type_; _ } -> loop (ty_binder :: binders) type_
    | _ -> List.rev binders, t
  in
  loop [] t


let texists_vars t =
  fold t ~init:Type_var.Set.empty ~f:(fun texists_vars t ->
      match t.content with
      | T_exists tvar -> Set.add texists_vars tvar
      | _ -> texists_vars)


let default_layout = L_tree

let t_construct constructor parameters ?loc ?meta () : t =
  make_t
    ?loc
    (T_construct { language = Backend.Michelson.name; constructor; parameters })
    meta


let t__type_ ?loc ?meta () : t = t_construct Literal_types._type_ [] ?loc ?meta ()
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
      , "chest"
      , "tx_rollup_l2_address"
      , "michelson_contract"
      , "ast_contract"
      , "int64"
      , "michelson_program" )]


let t_michelson_code = t_michelson_program

let t__type_ t ?loc ?meta () : t = t_construct ?loc ?meta Literal_types._type_ [ t ] ()
  [@@map
    _type_
    , ("list", "set", "contract", "ticket", "sapling_state", "sapling_transaction", "gen")]


let t__type_ t t' ?loc ?meta () : t =
  t_construct ?loc ?meta Literal_types._type_ [ t; t' ] ()
  [@@map _type_, ("map", "big_map", "typed_address")]


let row_ez fields ?(layout = default_layout) () =
  let fields =
    fields
    |> List.mapi ~f:(fun i (x, y) ->
           ( Label.of_string x
           , ({ associated_type = y; michelson_annotation = None; decl_pos = i }
               : row_element) ))
    |> Record.of_list
  in
  { fields; layout }


let t_record_ez fields ?loc ?meta ?layout () =
  t_record ?loc ?meta (row_ez fields ?layout ()) ()


let t_tuple ts ?loc ?meta () =
  t_record_ez (List.mapi ts ~f:(fun i t -> Int.to_string i, t)) ?loc ?meta ()


let t_pair t1 t2 ?loc ?meta () = t_tuple [ t1; t2 ] ?loc ?meta ()
let t_triplet t1 t2 t3 ?loc ?meta () = t_tuple [ t1; t2; t3 ] ?loc ?meta ()
let t_sum_ez fields ?loc ?meta ?layout () = t_sum ?loc ?meta (row_ez fields ?layout ()) ()

let t_bool ?loc ?meta () =
  t_sum_ez ?loc ?meta [ "True", t_unit (); "False", t_unit () ] ()


let t_option t ?loc ?meta () =
  t_sum_ez ?loc ?meta [ "Some", t; "None", t_unit ?loc () ] ()


let t_mutez = t_tez

let t_record_with_orig_var row ~orig_var ?loc ?meta () =
  { (t_record row ?loc ?meta ()) with orig_var }


let t_test_baker_policy ?loc ?meta () =
  t_sum_ez
    ?loc
    ?meta
    [ "By_round", t_int ?loc ()
    ; "By_account", t_address ?loc ()
    ; "Excluding", t_list ?loc (t_address ?loc ()) ()
    ]
    ()


let t_test_exec_error ?loc ?meta () =
  t_sum_ez
    ?loc
    ?meta
    [ "Rejected", t_pair ?loc (t_michelson_code ?loc ()) (t_address ?loc ()) ()
    ; ( "Balance_too_low"
      , t_record_ez
          ?loc
          [ "contract_too_low", t_address ?loc ()
          ; "contract_balance", t_mutez ?loc ()
          ; "spend_request", t_mutez ?loc ()
          ]
          () )
    ; "Other", t_string ?loc ()
    ]
    ()


let t_test_exec_result ?loc ?meta () =
  t_sum_ez ?loc ?meta [ "Success", t_nat ?loc (); "Fail", t_test_exec_error ?loc () ] ()


let get_t_construct t constr =
  match t.content with
  | T_construct { constructor = constr'; parameters; _ }
    when Literal_types.equal constr constr' -> Some parameters
  | _ -> None


let get_t_unary_construct t constr =
  match get_t_construct t constr with
  | Some [ a ] -> Some a
  | _ -> None


let get_t_binary_construct t constr =
  match get_t_construct t constr with
  | Some [ a; b ] -> Some (a, b)
  | _ -> None


let get_t__type_ t = get_t_unary_construct t Literal_types._type_
  [@@map
    _type_, ("contract", "list", "set", "ticket", "sapling_state", "sapling_transaction")]


let get_t__type_ t = get_t_binary_construct t Literal_types._type_
  [@@map _type_, ("map", "big_map")]


let get_t_bool t : unit option =
  Option.some_if (equal_content t.content (t_bool ()).content) ()


let get_t_option t =
  let l_none = Label.of_string "None" in
  let l_some = Label.of_string "Some" in
  match t.content with
  | T_sum { fields; _ } ->
    let keys = Record.LMap.keys fields in
    (match keys with
    | [ a; b ]
      when (Label.equal a l_none && Label.equal b l_some)
           || (Label.equal a l_some && Label.equal b l_none) ->
      let some = Record.LMap.find l_some fields in
      Some some.Rows.associated_type
    | _ -> None)
  | _ -> None


module Type_var_name_tbl : sig
  type t

  (** [create ()] creates a new type variable table. *)
  val create : unit -> t

  (** [clear t] clears the table [t]. *)
  val clear : t -> unit

  (** [name_of t tvar] returns the human readable name of [tvar]. *)
  val name_of : t -> Type_var.t -> string

  module Exists : sig
    (** [clear ()] clears the table used for existential variables. *)
    val clear : unit -> unit

    (** [name_of tvar] returns the human readable name for the existential variable [tvar] *)
    val name_of : Type_var.t -> string
  end
end = struct
  type t =
    { name_tbl : (Type_var.t, string) Hashtbl.t
          (* [name_tbl] is the mapping from type variables to names *)
    ; names : string Hash_set.t
          (* [names] is the set of existing names (superset of [Hashtbl.data name_tbl]) *)
    ; mutable name_counter : int
          (* [name_counter] is a counter used to generate unique variable names *)
    }

  let create () =
    { name_tbl = Hashtbl.create (module Type_var)
    ; names = Hash_set.create (module String)
    ; name_counter = 0
    }


  let clear t =
    Hashtbl.clear t.name_tbl;
    Hash_set.clear t.names;
    t.name_counter <- 0


  let exists_tbl = create ()
  let is_used t name = Hash_set.mem t.names name || Hash_set.mem exists_tbl.names name
  let incr_name_counter t = t.name_counter <- t.name_counter + 1

  let rec create_name t =
    let name =
      if t.name_counter < 26
      then String.of_char (Char.of_int_exn (97 + t.name_counter))
      else
        String.of_char (Char.of_int_exn (97 + (t.name_counter mod 26)))
        ^ Int.to_string (t.name_counter / 26)
    in
    incr_name_counter t;
    if is_used t name then create_name t else name


  let add_name t tvar name =
    Hashtbl.add_exn t.name_tbl ~key:tvar ~data:name;
    Hash_set.add t.names name


  let name_of t tvar =
    match Hashtbl.find t.name_tbl tvar with
    | Some name -> name
    | None ->
      let name =
        if Type_var.is_generated tvar
        then create_name t
        else (
          (* User-defined name. We'd like to try keep the name. However
             a collision could occur if we've previously used this name.
             
             We resolve the collision by adding a number to the end until we reach 
             a unique name *)
          let name = Type_var.to_name_exn tvar in
          let curr_name = ref name in
          let i = ref 0 in
          while is_used t !curr_name do
            curr_name := name ^ Int.to_string !i;
            Int.incr i
          done;
          !curr_name)
      in
      add_name t tvar name;
      (* Invariant: [name] is unique (wrt table [t]) *)
      name


  module Exists = struct
    let clear () = clear exists_tbl
    let name_of tvar = name_of exists_tbl tvar
  end
end

let pp_layout ppf layout =
  match layout with
  | L_comb -> Format.fprintf ppf "comb"
  | L_tree -> Format.fprintf ppf "tree"
  | L_exists lvar -> Format.fprintf ppf "^%a" Layout_var.pp lvar


let pp_lmap_sep value sep ppf lmap =
  let lst = List.sort ~compare:(fun (a, _) (b, _) -> Label.compare a b) lmap in
  let new_pp ppf (k, v) = Format.fprintf ppf "@[<h>%a -> %a@]" Label.pp k value v in
  Format.fprintf ppf "%a" (PP.list_sep new_pp sep) lst


let pp_lmap_sep_d x = pp_lmap_sep x (PP.tag " ,@ ")

let pp_record_sep value sep ppf (m : 'a Record.t) =
  let lst = Record.LMap.to_kv_list m in
  Format.fprintf ppf "%a" (pp_lmap_sep value sep) lst


let pp_tuple_sep value sep ppf m =
  assert (Record.is_tuple m);
  let lst = Record.tuple_of_record m in
  let new_pp ppf (_, v) = Format.fprintf ppf "%a" value v in
  Format.fprintf ppf "%a" (PP.list_sep new_pp sep) lst


let pp_tuple_or_record_sep_t value format_record sep_record format_tuple sep_tuple ppf m =
  if Record.is_tuple m
  then Format.fprintf ppf format_tuple (pp_tuple_sep value (PP.tag sep_tuple)) m
  else Format.fprintf ppf format_record (pp_record_sep value (PP.tag sep_record)) m


let pp_tuple_or_record_sep_type value =
  pp_tuple_or_record_sep_t value "@[<h>record[%a]@]" " ,@ " "@[<h>( %a )@]" " *@ "


let rec pp ~name_of_tvar ~name_of_exists ppf t =
  let pp = pp ~name_of_tvar ~name_of_exists in
  if Option.is_some (get_t_bool t)
  then bool ppf
  else if Option.is_some (get_t_option t)
  then option ~name_of_tvar ~name_of_exists ppf t
  else (
    match t.content with
    | T_variable tvar -> Format.fprintf ppf "%s" (name_of_tvar tvar)
    | T_exists tvar -> Format.fprintf ppf "^%s" (name_of_exists tvar)
    | T_arrow arr -> Arrow.pp pp ppf arr
    | T_construct construct -> pp_construct ~name_of_tvar ~name_of_exists ppf construct
    | T_singleton lit -> Literal_value.pp ppf lit
    | T_abstraction abs -> pp_type_abs ~name_of_tvar ~name_of_exists ppf abs
    | T_for_all for_all -> pp_forall ~name_of_tvar ~name_of_exists ppf for_all
    | T_sum row ->
      Format.fprintf
        ppf
        "@[<h>sum[%a]@]"
        (pp_lmap_sep_d (pp_row_elem ~name_of_tvar ~name_of_exists))
        (Record.LMap.to_kv_list_rev row.fields)
    | T_record row ->
      Format.fprintf
        ppf
        "%a"
        (pp_tuple_or_record_sep_type (pp_row_elem ~name_of_tvar ~name_of_exists))
        row.fields)


and pp_construct ~name_of_tvar ~name_of_exists ppf { constructor; parameters; _ } =
  Format.fprintf
    ppf
    "%s%a"
    (Literal_types.to_string constructor)
    (PP.list_sep_d_par (pp ~name_of_tvar ~name_of_exists))
    parameters


and pp_row_elem ~name_of_tvar ~name_of_exists ppf (row_elem : row_element) =
  pp ~name_of_tvar ~name_of_exists ppf row_elem.associated_type


and pp_forall
    ~name_of_tvar
    ~name_of_exists
    ppf
    ({ ty_binder; kind; type_ } : _ Abstraction.t)
    : unit
  =
  Format.fprintf
    ppf
    "∀ %s : %a . %a"
    (name_of_tvar ty_binder)
    Kind.pp
    kind
    (pp ~name_of_tvar ~name_of_exists)
    type_


and pp_type_abs
    ~name_of_tvar
    ~name_of_exists
    ppf
    ({ ty_binder; kind; type_ } : _ Abstraction.t)
    : unit
  =
  Format.fprintf
    ppf
    "funtype %s : %a . %a"
    (name_of_tvar ty_binder)
    Kind.pp
    kind
    (pp ~name_of_tvar ~name_of_exists)
    type_


and bool ppf : unit = Format.fprintf ppf "%a" Type_var.pp Literal_types.v_bool

and option ~name_of_tvar ~name_of_exists ppf t : unit =
  match get_t_option t with
  | Some t -> Format.fprintf ppf "option (%a)" (pp ~name_of_tvar ~name_of_exists) t
  | None -> Format.fprintf ppf "option ('a)"


let pp_with_name_tbl ~tbl ppf t =
  let name_of_tvar = Type_var_name_tbl.name_of tbl in
  let name_of_exists = Type_var_name_tbl.Exists.name_of in
  pp ~name_of_tvar ~name_of_exists ppf t


(* let name_of tvar = Format.asprintf "%a" Type_var.pp tvar in
  pp ~name_of_tvar:name_of ~name_of_exists:name_of ppf t *)

let pp =
  let name_of tvar = Format.asprintf "%a" Type_var.pp tvar in
  pp ~name_of_tvar:name_of ~name_of_exists:name_of