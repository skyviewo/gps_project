#ifndef _BD_DAEMON_H
#define _BD_DAEMON_H

#define TRACE_LEVEL 0

#include "trace.h"
#include "gps_registers.h"

#define MAXLINE		255
#define BUF_SIZE	1024*1024	// 1 Mb
#define TIMEOUT		3000		// 3 sec
#define	BANNER_SIZE	8		// in octets

#define SECOND		1000000
#define	MINUTE		60 * SECOND

enum bd_fd_list {
	LISTEN_FD	= 0,
	GUI_FD		= 1,
	BOARD_FD	= 2,
	DUMP_FD		= 3
};

/********************************************
 *	Work definition 
 ********************************************/
typedef struct bd_data_s bd_data_t;
typedef int bd_cb_f(bd_data_t *);

struct bd_data_s {
	/* network part */
	struct pollfd	client[4];
	uint32_t	port;
	uint8_t 	recv_buf[BUF_SIZE];
	uint8_t 	send_buf[BUF_SIZE];

	uint8_t		dump_file[MAXLINE];

	/* support */
	char		cfg_name[MAXLINE];	/* config name */	
	int 		need_exit;
	int 		need_flush_now;

	pthread_t	gui_thread;
	pthread_t	rs232_thread;

	/* rs232 */
	char		upload_script[MAXLINE];	/* upload script */	
	char		name[MAXLINE];		/* rs232 dev-name */

	/* gps registers array */
	gps_reg_str_t gps_regs[10];

	/* callbcaks */
	bd_cb_f		*bd_dump_cb;
};

/* signal handlers */
static void bd_sig_INT(int sig)
{
        need_exit = 0;
        signal(15, SIG_IGN);
}

static void bd_sig_USR1(int sig)
{
        need_flush_now = 1;
        signal(15, SIG_IGN);
}

int bd_make_signals()
{
	/* registering signals */
	struct sigaction int_sig, usr1_sig;
       
	TRACE(0, "[%s] make signal handlers\n", __func__);

	int_sig.sa_handler = &bd_sig_INT;
        sigemptyset(&int_sig.sa_mask);
        int_sig.sa_flags = SA_NOMASK;
	
	usr1_sig.sa_handler = &bd_sig_USR1;
        sigemptyset(&usr1_sig.sa_mask);
        usr1_sig.sa_flags = SA_NOMASK;

        if( ( (sigaction(SIGINT,  &int_sig, NULL)) == -1 ) ||
            ( (sigaction(SIGTERM, &int_sig, NULL)) == -1 ) ||
            ( (sigaction(SIGUSR1, &usr1_sig, NULL)) == -1 )
          ){
                fprintf(I, "[err] cannot set handler. error: %s", strerror(errno));
                return -1;
        }

	return 0;
}

#endif /* */
