


#include <caml/misc.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/callback.h>


#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <pty.h>
#include <utmp.h>
#include <string.h>




typedef struct {
    int controller_fd;
    int worker_fd;
}pty;





static struct custom_operations pty_ops={
    "pty",
    custom_finalize_default,
    custom_compare_default,
    custom_hash_default,
    custom_serialize_default,
    custom_deserialize_default,
    custom_compare_ext_default
};




void setupWorker(int worker_fd){

    printf("child has filedescriptor %i\n",worker_fd);

    // Become the controlling terminal
    if (setsid() == -1) {
        printf("setttdir error\n");
        perror("setsid");
        exit(EXIT_FAILURE);
    }

    // Set the slave as the controlling terminal
    // bash: cannot set terminal process group (-1): Inappropriate ioctl for device
    if (ioctl(worker_fd, TIOCSCTTY, 0) == -1) {
        printf("ioctl call error\n");
        perror("ioctl TIOCSCTTY");
        exit(EXIT_FAILURE); 
    }

};








//internal get file descriptors
pty getFileDescriptors(){
    pty rpty={0};
    
    openpty(&rpty.controller_fd, &rpty.worker_fd, NULL, NULL, NULL);

    return rpty;
};




CAMLprim value caml_setup_worker(value fd){
    CAMLparam1(fd);
    setupWorker(Int_val(fd));
    CAMLreturn(Val_unit);
}



//here we are returning a custom struct that is defined in c
CAMLprim value caml_getpty(){
    CAMLparam0();

    CAMLlocal1(res);
    pty temp=getFileDescriptors();
    printf("in c %i %i\n",temp.controller_fd, temp.worker_fd);

    res = caml_alloc_custom(&pty_ops, sizeof(pty), 0, 1);

    if (res) {
        pty *ast = (pty *)Data_custom_val(res);
        Store_field(res, 0, Val_int(temp.controller_fd));
        Store_field(res, 1, Val_int(temp.worker_fd));
    } 

    CAMLreturn(res);
}



