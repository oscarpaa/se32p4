#ifndef __SE32P4_SYSCALLS__
#define __SE32P4_SYSCALLS__

#include "sys/stat.h"
#include "unistd.h"
#include "uart.h"

void* _sbrk(int incr);
int _close(int file);
int _fstat(int file, struct stat *st);
int _isatty(int file);
int _lseek(int file, int ptr, int dir);
int _read(int fd, void *buf, size_t count);
int _write(int fd, const void *buf, size_t count);

#endif
