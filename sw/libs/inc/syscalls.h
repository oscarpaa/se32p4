#ifndef __SE32P4_SYSCALLS__
#define __SE32P4_SYSCALLS__

#include "unistd.h"
#include "uart.h"

ssize_t _read(int fd, void *buf, size_t count);
ssize_t _write(int fd, const void *buf, size_t count);

#endif
