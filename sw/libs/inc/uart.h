#ifndef __SE32P4_UART__
#define __SE32P4_UART__

#include "se32p4.h"
#include "stdint.h" 

typedef struct
{
    uint8_t state;
    uint8_t fifo;
    uint16_t timer_div;
} uart_handler_t;

#define UART0       ((uart_handler_t *) UART0_BASE)

#define UART_OK    0
#define UART_ERROR 1

uint8_t uart_rx_char();
uint8_t uart_tx_char(char c);
uint8_t uart_receive(char *buffer, uint16_t size);
uint8_t uart_transmit(const char *buffer, uint16_t size);

#endif