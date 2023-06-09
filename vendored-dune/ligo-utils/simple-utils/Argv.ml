(* Filtering the array [Core.Sys.argv]. *)

let argv_list = Array.to_list Core.Sys.argv |> List.tl_exn (* Cannot fail *)

module SSet = Caml.Set.Make (String)

(* Valid options without an argument *)

let filter ~opt_with_arg ~opt_wo_arg : unit =
  let split_by_eq s =
    match String.index s '=' with
    | Some (i) -> (String.sub s ~pos:0 ~len:i, String.sub s ~pos:(i+1) ~len:(String.length s - i - 1))
    | None -> (s, "") in

  let rec filter acc = function
      [] -> acc (* No more options. *)
    | "--"::more -> (* End of options: anonymous option. *)
       List.rev_append more ("--"::acc)
    | opt::more -> (* Named option *)
       (* Is it a valid option with an argument? *)
       if SSet.mem opt opt_with_arg then
           match more with
           (* Has [opt] an valid argument ? *)
           | arg::opts when Char.(<>) arg.[0] '-' -> (* Yes *)
              filter (arg::opt::acc) opts (* We keep both *)
           | _  when SSet.mem opt opt_wo_arg -> (* No, but argument is optional *)
              filter (opt::acc) more (* We keep only [opt] *)
           | _ ->
              acc (* An error will be reported later. *)
       else (* Maybe it passed in the [--option=arg] style ? *)
         let (name, _) = split_by_eq opt in
         if SSet.mem name opt_with_arg then (* Yes *)
           filter (opt::acc) more (* We keep it *)
       else
         if SSet.mem opt opt_wo_arg then
         (* Valid option without an argument. *)
         filter (opt::acc) more
       else (* Not a valid option: [opt] will be skipped. *)
         match more with
           [] -> acc (* [opt] has no argument and there are no more. *)
         | arg::opts -> (* Has [opt] an argument? *)
            if Char.equal arg.[0] '-' (* Cannot fail. *) then
              (* No argument: [arg] is actually the next option. *)
              filter acc more
            else (* [opt] has an argument [arg]: we skip it too. *)
              filter acc opts in
  let filtered =
    filter [] argv_list |> List.rev |> List.cons Core.Sys.argv.(0) in
  let last =
    let patch i e = Core.Sys.argv.(i) <- e; i+1 in
    List.fold_left ~f:patch ~init:0 filtered
  in for i = last to Array.length Core.Sys.argv - 1 do
       Core.Sys.argv.(i) <- ""
     done
