#include <string.h>
#include <stddef.h>
#include <stdlib.h>

#include <sys/types.h>
#include <sys/time.h>
#include <sys/socket.h>

#include <errno.h>
#include <netdb.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <netinet/ip_icmp.h>
#include <poll.h>
#include <resolv.h>
#include <arpa/inet.h>

#include <evfibers/fiber.h>

#include "libicmp.h"

struct send_fiber_args {
    int len;
    char **ips;
};

struct recv_fiber_args {
    struct ev_loop *loop;
};

#define MAX_HOSTS_LEN 1024
int pinger_socket = -1;
libicmp_t hosts[MAX_HOSTS_LEN];

static void send_pings(FBR_P_ void *_args) {
    struct send_fiber_args *args = (struct send_fiber_args *)_args;
    int i, len, n, cnt;
    libicmp_t *isock;
    char buf[1024];
    cnt = 0;
    for (i = 0; i < args->len; i++) {
        isock = icmp_open(&hosts[i], pinger_socket, args->ips[i], 100+i, 0);
        if (!isock) {
            fbr_log_e(FBR_A_ "error opening socket to %s", args->ips[i]);
            continue;
        }
    }

    for (n = 0; n < 10; n ++) {
      for (i = 0; i < args->len; i++) {
        if (!hosts[i].addr) continue;

        fbr_log_i(FBR_A_ "send ping to: %s", args->ips[i]);
        len = sprintf(buf, "ping #%d", cnt++ );

        if (!icmp_send(FBR_A_ &hosts[i], ICMP_ECHO, buf, len)) {
            fbr_log_e(FBR_A_ "error in sending ping to %s", hosts[i].host);
            continue;
        }
        fbr_sleep(FBR_A_ 1);
      }
    }
}

static void recv_pings(FBR_P_ void *_args) {
    //struct recv_fiber_args *args = (struct recv_fiber_args *)_args;
    (void )_args;
    int retval;
    char *buf = calloc(2048, sizeof(char));
    libicmp_t *isock = calloc(1, sizeof(libicmp_t));

    while(1) {
        fbr_log_i(FBR_A_ "waiting for reply");
        retval = icmp_recv_one(FBR_A_ ICMP_ECHOREPLY, pinger_socket, buf, isock);
        if (0 == retval) {
            fbr_log_e(FBR_A_ "recv failed: %s",
                      fbr_strerror(FBR_A_ fctx->f_errno));
            icmp_close(isock);
            continue;
        }
        fbr_log_i(FBR_A_ "received: %s id=%d seq=%d", buf, isock->id, isock->seqno);
        icmp_close(isock);
    }
}

int main(int argc, char **argv) {
    struct fbr_context fbr;
    struct ev_loop *loop = EV_DEFAULT;
    fbr_id_t sfiber;
    fbr_id_t rfiber;
    int retval;

    struct send_fiber_args fargs = { .len = argc-1, .ips = argv+1 };
    signal(SIGPIPE, SIG_IGN);

    fbr_init(&fbr, loop);
    fbr_set_log_level(&fbr, FBR_LOG_DEBUG);

    //init resolver
    res_init();

    pinger_socket = socket(AF_INET, SOCK_RAW, 1);
    if (pinger_socket < 0) {
        fbr_log_e(&fbr, "error creating socket");
        return 1;
    }

    rfiber = fbr_create(&fbr, "recv_pings", recv_pings, NULL, 0);
    sfiber = fbr_create(&fbr, "send_pings", send_pings, &fargs, 0);

    retval = fbr_transfer(&fbr, sfiber);
    assert(0 == retval);

    retval = fbr_transfer(&fbr, rfiber);
    assert(0 == retval);

    //send_pings(&fbr, (void *)&fargs);

    fbr_log_i(&fbr, "Starting main loop");
    ev_loop(loop, 0);
    fbr_log_i(&fbr, "Exiting");

    fbr_destroy(&fbr);
    return 0;
}
