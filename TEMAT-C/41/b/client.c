// Compilation:
//  clang -Wall client.c -o client -lzmq
#include <zmq.h>
#include "zhelpers.h"

int main (void)
{
    char *ping;
    char *string;
    void *context = zmq_ctx_new ();
    void *requester = zmq_socket (context, ZMQ_REQ);
    printf ("Connecting to hello world server...\n");

    zmq_connect (requester, "tcp://localhost:5555");
    printf ("Sending Ping...\n");
    zmq_send (requester, "ping", 4, 0);
    string = s_recv (requester);
    printf ("Received %s\n", string);
    
    free(string);
    zmq_close (requester);
    zmq_ctx_destroy (context);
    return 0;
}
