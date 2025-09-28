#include "uart.h"
#include "stddef.h"

char uart_rx_char()
{
    while ((UART0->state & 2) == 0); // uart empty, wait...
    return UART0->fifo;
}

uint8_t uart_tx_char(char c)
{
    while (UART0->state & 1); // uart busy, wait...
    return UART0->fifo = c;
}

uint8_t uart_receive(char *buffer, uint16_t size) {
    uint16_t i = 0;
    while (i < size - 1) {
        buffer[i++] = uart_rx_char();
    }
    buffer[i] = 0;
    return UART_OK;
}

uint8_t uart_transmit(const char *buffer, uint16_t size) {
    if (buffer == NULL) {
        return UART_ERROR;
    }
    for (uint16_t i = 0; i < size; i++) {
        uart_tx_char(buffer[i]);
    }
    return UART_OK;
}