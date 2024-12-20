let dim_decl = Str.regexp "w=\\([0-9]+\\) h=\\([0-9]+\\)"
let r_decl = Str.regexp "p=\\([0-9]+\\),\\([0-9]+\\) v=\\(-?[0-9]+\\),\\(-?[0-9]+\\)"

(* https://stackoverflow.com/a/54293631 *)
let (mod) x y = ((x mod y) + y) mod y

let simulate_robot w h x y dx dy = (((x+dx) mod w), ((y+dy) mod h))

let simulate_robots w h =
    List.map (
        fun (x, y, dx, dy) ->
            let (nx, ny) = simulate_robot w h x y dx dy in
                (nx, ny, dx, dy)
    )

(*let all_true = Array.for_all (fun c -> c)*)

let rec inner_hct robots board =
    match robots with
    | [] -> false (*Array.exists (Array.for_all (fun c -> c)) board*)
    | (x, y, _, _) :: rs ->
        board.(y).(x) <- true;
        inner_hct rs board

let has_christmas_tree w h robots =
    let board = Array.init h (fun _ -> Array.make w false) in
    let ok = inner_hct robots board in
        Array.iter (
            fun row ->
                Array.iter (fun c -> (Printf.printf (if c then "#" else " "))) row;
                Printf.printf "\n";
        ) board;
        ok

let rec inner_rr ic l =
    try
        let line = input_line ic in
        let _ = Str.search_forward r_decl line 0 in
        let x = int_of_string (Str.matched_group 1 line) in
        let y = int_of_string (Str.matched_group 2 line) in
        let dx = int_of_string (Str.matched_group 3 line) in
        let dy = int_of_string (Str.matched_group 4 line) in
            inner_rr ic ((x, y, dx, dy) :: l)
    with e ->
        l

let read_robots ic = inner_rr ic []

let rec inner_cq mw mh robots tl tr bl br =
    match robots with
    | [] -> (tl, tr, bl, br)
    | (x, y) :: rs ->
        if x < mw && y < mh then
            inner_cq mw mh rs (tl+1) tr bl br
        else if x > mw && y < mh then
            inner_cq mw mh rs tl (tr+1) bl br
        else if x < mw && y > mh then
            inner_cq mw mh rs tl tr (bl+1) br
        else if x > mw && y > mh then
            inner_cq mw mh rs tl tr bl (br+1)
        else
            inner_cq mw mh rs tl tr bl br

let count_quadrants w h robots =
    let mw = w / 2 in
    let mh = h / 2 in
        inner_cq mw mh robots 0 0 0 0

let rec inner_ft w h s robots =
    Printf.printf "%d\n" s;
    if s > 10000 || has_christmas_tree w h robots then
        s
    else
        inner_ft w h (s+1) (simulate_robots w h robots)

let find_tree w h robots = inner_ft w h 0 robots

let simulate_file fp =
    let ic = open_in fp in
    try
        let line = input_line ic in
        let _ = Str.search_forward dim_decl line 0 in
        let w = int_of_string (Str.matched_group 1 line) in
        let h = int_of_string (Str.matched_group 2 line) in
        let robots = read_robots ic in
            (*List.iter (
                fun (x, y, dx, dy) ->
                    Printf.printf "p=%d,%d v=%d,%d\n" x y dx dy
            ) robots;*)
        let s = find_tree w h robots in
            Printf.printf "%d\n" s;
            close_in ic;
    with e ->
        close_in_noerr ic;
        raise e;;

let () =
    let argv = Sys.argv in
    let argc = Array.length Sys.argv in
        if argc < 2 then
            Printf.printf "No file included!\n"
        else
            simulate_file argv.(1)