#ifndef _ASYNC_PROCESS_H_
#define _ASYNC_PROCESS_H_

#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#include "gend.h"


#ifdef _WIN32
# include <windows.h>
#else
# define _GNU_SOURCE
# include <signal.h>
# include <errno.h>
# include <fcntl.h>
# include <sys/wait.h>
#endif

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>


#ifdef _WIN32
# define ASYNCPAPI __declspec(dllexport)
#else
# define ASYNCPAPI
#endif

struct process {
  char buffer[1024*4];
#ifdef _WIN32
  PROCESS_INFORMATION pi;
  HANDLE hInputWrite;
  HANDLE hOutputRead;
  bool nonblock;
#else
  int fd;
  char *pty_name;
  pid_t pid;
#endif
};

ASYNCPAPI struct process* cl_async_process_create(char *const command[], bool nonblock,unsigned int buffer_size);
ASYNCPAPI void cl_async_process_delete(struct process *process);
ASYNCPAPI int cl_async_process_pid(struct process *process);
ASYNCPAPI void cl_async_process_send_input(struct process *process, const char *string);
ASYNCPAPI const char* cl_async_process_receive_output(struct process *process);
ASYNCPAPI int cl_async_process_alive_p(struct process *process);
ASYNCPAPI const char* cl_async_process_version(void);

#endif
