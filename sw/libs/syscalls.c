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

#include <sys/reent.h>
#include "sys/stat.h"
#include "unistd.h"
#include "stdint.h"
#include "string.h"
#include "syscalls.h"

void *_sbrk(int incr) {
    extern char _heap;         // Defined by the linker - start of heap
    extern char _stack_bottom; // Defined in our linker script - bottom of stack area

    static char *heap_end = &_heap;
    char *prev_heap_end = heap_end;

    // Calculate safe stack limit - stack grows down from _stack_top towards _stack_bottom
    char *stack_limit = &_stack_bottom;

    // Check if heap would grow too close to stack
    if (heap_end + incr > stack_limit) {
        return (void*) -1; // Return error
    }

    heap_end += incr;
    return (void*) prev_heap_end;
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
        char *buffer = buf;
        uint16_t i = 0;

        while (i < count - 1) {
            char c = uart_rx_char();
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
        const char *buffer = buf;
        for (size_t i = 0; i < count; i++) {
            uart_tx_char(buffer[i]);
        }
        return count;
    }
    return -1;
}