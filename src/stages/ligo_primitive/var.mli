module Location = Simple_utils.Location

module type VAR = sig
  type t [@@deriving compare, yojson, hash, sexp]

  (* Create a compiler generated variable *)
  val reset_counter : unit -> unit
  val fresh : ?loc:Location.t -> ?name:string -> unit -> t
  val fresh_like : ?loc:Location.t -> t -> t
  (* Construct a user variable directly from a string. This should only
      be used for embedding user variable names. For programmatically
      generated variables, use `fresh`. Take care not to cause
      shadowing/capture except as the user intended. *)

  val of_input_var : ?loc:Location.t -> string -> t

  (* Warning : do not use *)
  val to_name_exn : t -> string
  val get_location : t -> Location.t
  val set_location : Location.t -> t -> t
  val is_generated : t -> bool

  (* Prints vars as %s or %s#%d *)
  val pp : Format.formatter -> t -> unit

  include Comparable.S with type t := t
end

module Value_var : sig
  include VAR

  val is_name : t -> string -> bool

  (* Maybe bad *)
  val internal_get_name_and_counter : t -> string * int
  val wildcard : t
end

module Type_var : sig
  include VAR

  val is_name : t -> string -> bool
  val is_exists : t -> bool
  val fresh_exists : ?loc:Location.t -> unit -> t
end

module Module_var : sig
  include VAR

  val is_name : t -> string -> bool
end

module Layout_var : sig
  include VAR
end