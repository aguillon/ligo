(**************************************************************************)
(*                                                                        *)
(*    Copyright (c) 2014 - 2017.                                          *)
(*    Dynamic Ledger Solutions, Inc. <contact@tezos.com>                  *)
(*                                                                        *)
(*    All rights reserved. No warranty, explicit or implicit, provided.   *)
(*                                                                        *)
(**************************************************************************)

open Error_monad

module Make(Param : sig val name: string end)() = struct

  include Pervasives
  module Pervasives = Pervasives
  module Compare = Compare
  module Array = Array
  module List = List
  module Bytes = struct
    include Bytes
    include EndianBytes.BigEndian
    module LE = EndianBytes.LittleEndian
  end
  module String = struct
    include String
    include EndianString.BigEndian
    module LE = EndianString.LittleEndian
  end
  module Set = Set
  module Map = Map
  module Int32 = Int32
  module Int64 = Int64
  module Nativeint = Nativeint
  module Buffer = Buffer
  module Format = Format
  module Z = Z
  module Lwt_sequence = Lwt_sequence
  module Lwt = Lwt
  module Lwt_list = Lwt_list
  module MBytes = MBytes
  module Uri = Uri
  module Data_encoding = Data_encoding
  module Time = Time
  module Ed25519 = Ed25519
  module S = struct
    include Tezos_crypto.S
    include S
  end
  module Block_hash = Block_hash
  module Operation_hash = Operation_hash
  module Operation_list_hash = Operation_list_hash
  module Operation_list_list_hash = Operation_list_list_hash
  module Context_hash = Context_hash
  module Protocol_hash = Protocol_hash
  module Blake2B = Blake2B
  module Fitness = Fitness
  module Operation = Operation
  module Block_header = Block_header
  module Protocol = Protocol
  module RPC_arg = RPC_arg
  module RPC_path = RPC_path
  module RPC_query = RPC_query
  module RPC_service = RPC_service
  module RPC_answer = RPC_answer
  module RPC_directory = RPC_directory
  module Error_monad = struct
    type error_category = [ `Branch | `Temporary | `Permanent ]
    include Error_monad.Make()
  end
  module Micheline = Micheline
  module Logging = Logging.Make(Param)

  type error += Ecoproto_error of Error_monad.error list

  let () =
    let id = Format.asprintf "Ecoproto.%s" Param.name in
    register_wrapped_error_kind
      (fun ecoerrors -> Error_monad.classify_errors ecoerrors)
      ~id ~title:"Error returned by the protocol"
      ~description:"Wrapped error for the economic protocol."
      ~pp:(fun ppf ->
          Format.fprintf ppf
            "@[<v 2>Economic error:@ %a@]"
            (Format.pp_print_list Error_monad.pp))
      Data_encoding.(obj1 (req "ecoproto"
                             (list Error_monad.error_encoding)))
      (function Ecoproto_error ecoerrors -> Some ecoerrors
              | _ -> None )
      (function ecoerrors -> Ecoproto_error ecoerrors)

  let wrap_error = function
    | Ok _ as ok -> ok
    | Error errors -> Error [Ecoproto_error errors]

  module Option = Option

end
