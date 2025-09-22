/* An extremely minimalist syscalls.c for newlib
 * Based on riscv newlib libgloss/riscv/sys_*.c
 *
 * Copyright 2019 Clifford Wolf
 * Copyright 2019 ETH Zürich and University of Bologna
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
 * REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
 * LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
 * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 */

#include "sys/stat.h"
#include "sys/types.h"
#include "unistd.h"
#include "stdint.h"
#include "syscalls.h"

extern char __heap_start[];
extern char __heap_end[];
static char *brk = __heap_start;

void *_sbrk(ptrdiff_t incr)
{
    char *old_brk = brk;

    if (__heap_start == __heap_end) {
        return NULL; 
    }

    if (brk + incr < __heap_end && brk + incr >= __heap_start) {
        brk += incr;
    } else {
        return (void *)-1; 
    }
    return old_brk;
}

int _close(int file) {
    return -1;
}

int _fstat(int file, struct stat *st) {
    st->st_mode = S_IFCHR;
    return 0;
}

int _isatty(int file) {
    return 1;
}

int _lseek(int file, int ptr, int dir) {
    return 0;
}

int _read(int fd, void *buf, size_t count) {
    if (fd == STDIN_FILENO) {
        uint8_t *buffer = (uint8_t *)buf;
        uint16_t i = 0;

        while (i < count - 1) {
            uint8_t c = uart_rx_char();
            if (c == '\n' || c == '\r')
                break;
            buffer[i++] = c;
        }
        buffer[i] = 0;
        return i;
    }
    return -1;
}

int _write(int fd, const void *buf, size_t count) {
    if (fd == STDOUT_FILENO || fd == STDERR_FILENO) {
        const uint8_t *buffer = buf;
        for (size_t i = 0; i < count; i++) {
            uart_tx_char(buffer[i]);
        }
        return count;
    }
    return -1;
}
