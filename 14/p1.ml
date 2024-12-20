let dim_decl = Str.regexp "w=\\([0-9]+\\) h=\\([0-9]+\\)"
let r_decl = Str.regexp "p=\\([0-9]+\\),\\([0-9]+\\) v=\\(-?[0-9]+\\),\\(-?[0-9]+\\)"
let sim_time = 100

(* https://stackoverflow.com/a/54293631 *)
let (mod) x y = ((x mod y) + y) mod y

let simulate_robot w h x y dx dy s = (((x+s*dx) mod w), ((y+s*dy) mod h))

let rec inner_sfwd ic w h l =
    try
        let line = input_line ic in
        let _ = Str.search_forward r_decl line 0 in
        let x = int_of_string (Str.matched_group 1 line) in
        let y = int_of_string (Str.matched_group 2 line) in
        let dx = int_of_string (Str.matched_group 3 line) in
        let dy = int_of_string (Str.matched_group 4 line) in
        let (rx, ry) = simulate_robot w h x y dx dy sim_time in
            (*Printf.printf "p=%d,%d v=%d,%d -> %d,%d\n" x y dx dy rx ry;*)
            inner_sfwd ic w h ((rx, ry) :: l)
    with e ->
        l

let simulate_file_with_dim ic w h = inner_sfwd ic w h []

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

let simulate_file fp =
    let ic = open_in fp in
    try
        let line = input_line ic in
        let _ = Str.search_forward dim_decl line 0 in
        let w = int_of_string (Str.matched_group 1 line) in
        let h = int_of_string (Str.matched_group 2 line) in
        let coords = simulate_file_with_dim ic w h in
            (*Printf.printf "w=%d h=%d\n" w h;*)
            (*List.iter (fun (x, y) -> Printf.printf "%d %d\n" x y) coords;*)
        let (tl, tr, bl, br) = count_quadrants w h coords in
            (*Printf.printf "%d %d %d %d\n" tl tr bl br;*)
            Printf.printf "%d\n" (tl * tr * bl *br);
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