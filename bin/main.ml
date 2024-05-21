


type app_state_type = {
    text:string;
    pty:Term.pty;
}


let setup state =
  Raylib.init_window 800 450 "raylib [core] example - basic window";
  print_endline "setup";

  Raylib.set_target_fps 60;
  (state)


let append_int_to_state state n= 
    let nstate={
        text= String.cat state.text (String.make 1 (char_of_int n));
        pty= state.pty;
    }in
    (nstate)


let mutate_text state= 
    let key =Raylib.Key.to_int (Raylib.get_key_pressed()) in
    match key with
        | n when n >= 65 && n <= 90 -> append_int_to_state state n
        | 32 -> append_int_to_state state 32
        | 47 -> append_int_to_state state 45
        | 257 -> let _ =Term.execute_command state.pty state.text in{text="";pty=state.pty}
        |_ ->state
        


let rec loop state =
  if Raylib.window_should_close () then Raylib.close_window ()
  else
    let open Raylib in

    begin_drawing ();
    clear_background Color.black;
    draw_text state.text 190 200 20
      Color.white;
    end_drawing ();
    state |> mutate_text |> loop 



let game state = state|>setup |> loop



let child state= 
      Term.start_shell state.pty 


let setup_parent_process state =
    Term.setup_controller state.pty; 
    Unix.sleep 2;
    Term.readpout state.pty;
    state |>game;
    ()



let ()= 
  let state={
      text="";
      pty = Term.get_pty() ;
   }in
  Printf.printf "in ocaml %i  %i\n" (Term.int_of_fd state.pty.controller_fd) (Term.int_of_fd state.pty.worker_fd);
  print_endline "";

  let fres = Unix.fork() in

  match fres with
  | n when n <0 -> exit 1
  | 0 -> child state
  | _ -> setup_parent_process state;





(*entrypoint*)
