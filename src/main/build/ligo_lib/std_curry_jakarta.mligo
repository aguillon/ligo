module Tezos = struct
  let get_contract (type a) (a : address) : (a contract) = [%external "CONTRACT"] a
  let get_contract_opt (type a) (a : address) : (a contract) option = [%external "CONTRACT_OPT"] a
  let get_contract_with_error (type a) (a : address) (s : string) : a contract = [%external "CONTRACT_WITH_ERROR"] a s
  (* let get_entrypoint_opt (type a) (s : string) (a : address) : (a contract) option = [%external "CONTRACT_ENTRYPOINT_OPT"] s a *)
  [@thunk]
    let balance : tez = [%Michelson ({| { DROP ; BALANCE } |} : unit -> tez)] ()
  [@thunk]
    let amount : tez = [%Michelson ({| { DROP ; AMOUNT } |} : unit -> tez)] ()
  [@thunk]
    let now : timestamp = [%Michelson ({| { DROP ; NOW } |} : unit -> timestamp)] ()
  [@thunk]
    let sender : address = [%Michelson ({| { DROP ; SENDER } |} : unit -> address)] ()
  [@thunk]
    let source : address = [%Michelson ({| { DROP ; SOURCE } |} : unit -> address)] ()
  [@thunk]
    let level : nat = [%Michelson ({| { DROP ; LEVEL } |} : unit -> nat)] ()
  [@thunk]
    let self_address : address = [%external "SELF_ADDRESS"]
  [@thunk]
    let chain_id : chain_id = [%Michelson ({| { DROP ; CHAIN_ID } |} : unit -> chain_id)] ()
  [@thunk]
    let total_voting_power : nat = [%Michelson ({| { DROP ; TOTAL_VOTING_POWER } |} : unit -> nat)] ()
  let min_block_time : unit -> nat = [%Michelson ({| { DROP; MIN_BLOCK_TIME } |} : unit -> nat) ]
  (* [@thunk] let self (type a) (s : string) : a contract = [%external "SELF"] s *)
  let voting_power (kh : key_hash) : nat = [%Michelson ({| { VOTING_POWER } |} : key_hash -> nat)] kh
  let address (type a) (c : a contract) : address = [%external "ADDRESS"] c
  let implicit_account (kh : key_hash) : unit contract = [%external "IMPLICIT_ACCOUNT"] kh
  let create_ticket (type a) (v : a) (n : nat) : a ticket = [%Michelson ({| { UNPAIR ; TICKET } |} : a * nat -> a ticket)] (v, n)
  let join_tickets (type a) (t : a ticket * a ticket) : (a ticket) option = [%Michelson ({| { JOIN_TICKETS } |} : a ticket * a ticket -> a ticket option)] t
  let split_ticket (type a) (t : a ticket) (p : nat * nat) : (a ticket * a ticket) option =
    [%Michelson ({| { UNPAIR ; SPLIT_TICKET } |} : a ticket * (nat * nat) -> (a ticket * a ticket) option)] (t, p)
  let read_ticket (type a) (t : a ticket) : (address * (a * nat)) * a ticket =
    [%Michelson ({| { READ_TICKET ; PAIR } |} : a ticket -> (address * (a * nat)) * a ticket)] t
  (* let create_contract (type a b) (c : a * b -> operation list * b) (kh : key_hash) (mu : tez) (s : b) : operation * address = [%external "CREATE_CONTRACT"] c kh mu s *)
  let never (type a) (n : never) : a = [%Michelson ({| { NEVER } |} : never -> a)] n
  let pairing_check (l : (bls12_381_g1 * bls12_381_g2) list) : bool = [%Michelson ({| { PAIRING_CHECK } |} : (bls12_381_g1 * bls12_381_g2) list -> bool)] l
  let open_chest (ck : chest_key) (c : chest) (n : nat) : chest_opening_result = [%external "OPEN_CHEST"] ck c n
  let call_view (type a b) (s : string) (x : a) (a : address)  : b option = [%external "VIEW"] s x a
  let constant (type a) (s : string) : a = [%external "GLOBAL_CONSTANT"] s
  let transaction (type a) (a : a) (mu : tez) (c : a contract) : operation = [%external "CALL"] a mu c
  let set_delegate (o : key_hash option) : operation = [%external "SET_DELEGATE"] o
  
end

module Bitwise = struct
  (* let and (type a b) (l : a) (r : b) : (a, b) external_and = [%external "AND"] l r *)
  let xor (l : nat) (r : nat) : nat = [%external "XOR"] l r
  (* let or (l : nat) (r : nat) : nat = [%external "OR"] l r *)
  let shift_left (l : nat) (r : nat) : nat = [%external "LSL"] l r
  let shift_right (l : nat) (r : nat) : nat = [%external "LSR"] l r
end

module Big_map = struct
  let empty (type k v) : (k, v) big_map = [%external "BIG_MAP_EMPTY"]
  let mem (type k v) (k : k) (m : (k, v) big_map) : bool = [%Michelson ({| { UNPAIR ; MEM } |} : k * (k, v) big_map -> bool)] (k, m)
  let add (type k v) (k : k) (v : v) (m : (k, v) big_map) : (k, v) big_map = [%external "MAP_ADD"] k v m
  let remove (type k v) (k : k) (m : (k, v) big_map) : (k, v) big_map = [%external "MAP_REMOVE"] k m
  let update (type k v) (k : k) (v : v option) (m : (k, v) big_map) : (k, v) big_map = [%external "MAP_UPDATE"] k v m
  let get_and_update (type k v) (k : k) (v : v option) (m : (k, v) big_map) : v option * (k, v) big_map = [%external "BIG_MAP_GET_AND_UPDATE"] k v m
  let find_opt (type k v) (k : k) (m : (k, v) big_map) : v option = [%external "MAP_FIND_OPT"] k m
  let find (type k v) (k : k) (m : (k, v) big_map) : v = [%external "MAP_FIND"] k m
end

module Map = struct
  let empty (type k v) : (k, v) map = [%external "MAP_EMPTY"]
  let size (type k v) (m : (k, v) map) : nat = [%Michelson ({| { SIZE } |} : (k, v) map -> nat)] m
  let mem (type k v) (k : k) (m : (k, v) map) : bool = [%Michelson ({| { UNPAIR ; MEM } |} : k * (k, v) map -> bool)] (k, m)
  let add (type k v) (k : k) (v : v) (m : (k, v) map) : (k, v) map = [%external "MAP_ADD"] k v m
  let remove (type k v) (k : k) (m : (k, v) map) : (k, v) map = [%external "MAP_REMOVE"] k m
  let update (type k v) (k : k) (v : v option) (m : (k, v) map) : (k, v) map = [%external "MAP_UPDATE"] k v m
  let get_and_update (type k v) (k : k) (v : v option) (m : (k, v) map) : v option * (k, v) map = [%external "MAP_GET_AND_UPDATE"] k v m
  let find (type k v) (k : k) (m : (k, v) map) : v = [%external "MAP_FIND"] k m
  let find_opt (type k v) (k : k) (m : (k, v) map) : v option = [%external "MAP_FIND_OPT"] k m
  let iter (type k v) (f : k * v -> unit) (m : (k, v) map) : unit = [%external "MAP_ITER"] f m
  let map (type k v w) (f : k * v -> w) (m : (k, v) map) : (k, w) map = [%external "MAP_MAP"] f m
  let fold (type k v c) (f : c * (k * v) -> c) (m : (k, v) map) (i : c) : c = [%external "MAP_FOLD"] f m i
end

module Set = struct
  let empty (type a) : a set = [%external "SET_EMPTY"]
  let mem (type a) (x : a) (s : a set) : bool = [%external "SET_MEM"] x s
  let add (type a) (x : a) (s : a set) : a set = [%external "SET_ADD"] x s
  let remove (type a) (x : a) (s : a set) : a set = [%external "SET_REMOVE"] x s
  let update (type a) (x : a) (b : bool) (s : a set) = [%external "SET_UPDATE"] x b s
  let iter (type a) (f : a -> unit) (s : a set) : unit = [%external "SET_ITER"] f s
  let fold (type a b) (f : b * a -> b) (s : a set) (i : b) : b = [%external "SET_FOLD"] f s i
  let fold_desc (type a b) (f : a * b -> b) (s : a set) (i : b) : b = [%external "SET_FOLD_DESC"] f s i
  let size (type a) (s : a set) : nat = [%Michelson ({| { SIZE } |} : a set -> nat)]  s
  let cardinal (type a) (s : a set) : nat = [%Michelson ({| { SIZE } |} : a set -> nat)] s
end

module List = struct
  let length (type a) (xs : a list) : nat = [%Michelson ({| { SIZE } |} : a list -> nat)]  xs
  let size (type a) (xs : a list) : nat = [%Michelson ({| { SIZE } |} : a list -> nat)]  xs
  let head_opt (type a) (xs : a list) : a option = [%external "LIST_HEAD_OPT"] xs
  let tail_opt (type a) (xs : a list) : (a list) option = [%external "LIST_TAIL_OPT"] xs
  let map (type a b) (f : a -> b) (xs : a list) : b list = [%external "LIST_MAP"] f xs
  let iter (type a) (f : a -> unit) (xs : a list): unit = [%external "LIST_ITER"] f xs
  let fold (type a b) (f : b * a -> b) (xs : a list) (i : b) : b = [%external "LIST_FOLD"] f xs i
  let fold_left (type a b) (f : b * a -> b) (i : b) (xs : a list) : b = [%external "LIST_FOLD_LEFT"] f i xs
  let fold_right (type a b) (f : a * b -> b) (xs : a list) (i : b) : b = [%external "LIST_FOLD_RIGHT"] f xs i
  let cons (type a) (x : a) (xs : a list) : a list = [%external "CONS"] x xs
end

module String = struct
  let concat (b1 : string) (b2 : string) : string = [%Michelson ({| { UNPAIR ; CONCAT } |} : string * string -> string)] (b1, b2)
  let sub (s : nat) (l : nat) (b : string) : string =
    [%Michelson ({| { UNPAIR ; UNPAIR ; SLICE ; IF_NONE { PUSH string "SLICE" ; FAILWITH } {} } |} : nat * nat * string -> string)] (s, l, b)
  let length (b : string) : nat = [%Michelson ({| { SIZE } |} : string -> nat)] b
end

module Option = struct
  let unopt (type a) (v : a option) : a = [%external "UNOPT"] v
  let unopt_with_error (type a) (v : a option) (s : string) : a = [%external "UNOPT_WITH_ERROR"] v s
  (* let map (type a b) (f : a -> b) (v : a option) : b option = [%external "OPTION_MAP"] f v *)
end

module Bytes = struct
  let concat (b1 : bytes) (b2 : bytes) : bytes = [%Michelson ({| { UNPAIR ; CONCAT } |} : bytes * bytes -> bytes)] (b1, b2)
  let sub (s : nat) (l : nat) (b : bytes) : bytes =
    [%Michelson ({| { UNPAIR ; UNPAIR ; SLICE ; IF_NONE { PUSH string "SLICE" ; FAILWITH } {} } |} : nat * nat * bytes -> bytes)] (s, l, b)
  let pack (type a) (v : a) : bytes = [%Michelson ({| { PACK } |} : a -> bytes)] v
  let unpack (type a) (b : bytes) : a option = [%external "BYTES_UNPACK"] b
  let length (b : bytes) : nat = [%Michelson ({| { SIZE } |} : bytes -> nat)] b
end

module Crypto = struct
  let blake2b (b : bytes) : bytes = [%Michelson ({| { BLAKE2B } |} : bytes -> bytes)] b
  let sha256 (b : bytes) : bytes = [%Michelson ({| { SHA256 } |} : bytes -> bytes)] b
  let sha512 (b : bytes) : bytes = [%Michelson ({| { SHA512 } |} : bytes -> bytes)] b
  let sha3 (b : bytes) : bytes = [%Michelson ({| { SHA3 } |} : bytes -> bytes)] b
  let keccak (b : bytes) : bytes = [%Michelson ({| { KECCAK } |} : bytes -> bytes)] b
  let hash_key (k : key) : key_hash = [%Michelson ({| { HASH_KEY } |} : key -> key_hash)] k
  let check (k : key) (s : signature) (b : bytes) : bool = [%Michelson ({| { UNPAIR ; UNPAIR ; CHECK_SIGNATURE } |} : key * signature * bytes -> bool)] (k, s, b)
end

[@private]
  let assert (b : bool) : unit = [%Michelson ({| { IF { UNIT } { PUSH string "failed assertion" ; FAILWITH } } |} : bool -> unit)] b
[@private]
  let assert_with_error (b : bool) (s : string) =
    [%Michelson ({| { UNPAIR ; IF { DROP ; UNIT } { FAILWITH } } |} : bool * string -> unit)] (b, s)
[@private]
  let assert_some (type a) (v : a option) : unit =
    [%Michelson ({| { IF_NONE { PUSH string "failed assert some" ; FAILWITH } { DROP ; UNIT } } |} : a option -> unit)] v
[@private]
  let assert_some_with_error (type a) (v : a option) (s : string) : unit =
    [%Michelson ({| { UNPAIR ; IF_NONE { FAILWITH } { DROP 2 ; UNIT } } |} : a option * string -> unit)] (v, s)
[@private]
  let assert_none (type a) (v : a option) : unit =
    [%Michelson ({| { IF_NONE { UNIT } { PUSH string "failed assert none" ; FAILWITH } } |} : a option -> unit)] v
[@private]
  let assert_none_with_error (type a) (v : a option) (s : string) : unit =
    [%Michelson ({| { UNPAIR ; IF_NONE { DROP ; UNIT } { DROP ; FAILWITH } } |} : a option * string -> unit)] (v, s)
[@private]
  let abs (i : int) : nat = [%Michelson ({| { ABS } |} : int -> nat)] i
[@private]
  let is_nat (i : int) : nat option = [%Michelson ({| { ISNAT } |} : int -> nat option)] i
[@private]
  let true : bool = [%external "TRUE"]
[@private]
  let false : bool = [%external "FALSE"]
[@private]
  let unit : unit = [%external "UNIT"]
[@private]
  let failwith (type a) (v : a) : a external_failwith = [%external "FAILWITH"] v
[@private]
  let int (type a) (v : a) : a external_int = [%Michelson ({| { INT } |} : a -> a external_int)] v
[@private]
  let ediv (type a b) (l : a) (r : b) : (a, b) external_ediv = [%Michelson ({| { UNPAIR ; EDIV } |} : a * b -> (a, b) external_ediv)] (l, r)