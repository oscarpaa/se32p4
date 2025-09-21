#include "unistd.h"
#include "stdint.h"
#include "syscalls.h"

ssize_t _read(int fd, void *buf, size_t count) {
    if (fd == STDIN_FILENO) {
        uint8_t *buffer = (uint8_t *)buf;
        uint16_t i = 0;

        while (i < count - 1) {
            uint8_t c = uart_rx_char();
            buffer[i++] = c;
            if (c == '\n' || c == '\r')
                break;
        }
        buffer[i] = 0;
        return i;
    }
    return -1;
}

ssize_t _write(int fd, const void *buf, size_t count) {
    if (fd == STDOUT_FILENO || fd == STDERR_FILENO) {
        const uint8_t *buffer = buf;
        for (size_t i = 0; i < count; i++) {
            uart_tx_char(buffer[i]);
        }
        return count;
    }
    return -1;
}
