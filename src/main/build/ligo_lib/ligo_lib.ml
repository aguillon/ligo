let get () =
  match Loaded.read "std_lib.mligo" with
  | Some x -> x
  | None -> failwith "Ligo_Stdlib missing : please report to devs"
