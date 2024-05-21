

type rawpty={
    raw_controller_fd:int;
    raw_worker_fd:int;
}

type pty={
    controller_fd:Unix.file_descr;
    worker_fd:Unix.file_descr;
}

external setup_worker: int ->unit ="caml_setup_worker"
external get_raw_pty: unit ->rawpty ="caml_getpty"


(*im not even going to pretend i know what this does*)
let fd_to_int (x:int): Unix.file_descr=Obj.magic x;;
let int_of_fd (x: Unix.file_descr) : int = Obj.magic x;;

let readpout pty =
    let buffer=Bytes.create 1024 in

    match Unix.read pty.controller_fd buffer 0 1024 with
    | 0  -> ()
    | -1 -> exit 1
    | bytes_written  -> print_endline (Bytes.sub_string buffer 0 bytes_written); 
    ()

(*also reads rn*)
let execute_command pty command=
    let writecommand =(String.lowercase_ascii (String.cat command "\n")) in
    let bytes =Bytes.of_string  writecommand in
    let w =Unix.write pty.controller_fd bytes 0 (Bytes.length bytes) in
    if w > 0 then 
        readpout pty; 
        readpout pty;
        readpout pty;
    ()



let read_output pty=
    let buffer=Bytes.create 255 in
    match Unix.read pty.controller_fd buffer 0 255 with
    |0-> ""
    |_ -> String.of_bytes buffer;;
  

let start_shell pty=
    Unix.close pty.controller_fd;
    
    setup_worker (int_of_fd pty.worker_fd);

    Unix.dup2 pty.worker_fd Unix.stdin;
    Unix.dup2 pty.worker_fd Unix.stdout;
    Unix.dup2 pty.worker_fd Unix.stderr;

    Unix.close pty.worker_fd;

    Unix.execv "/bin/sh" (Array.make 1 "");;




let sanitize_pty rawpty=
    let pty={
        controller_fd=(fd_to_int rawpty.raw_controller_fd);
        worker_fd=(fd_to_int rawpty.raw_worker_fd); 
    }in
    (pty)




let get_pty()= sanitize_pty (get_raw_pty());;



let setup_controller pty=
    Unix.close pty.worker_fd;;



