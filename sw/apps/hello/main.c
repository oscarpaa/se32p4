// #include "stdio.h"
#include "uart.h"

int main() {
    // printf("Hola mundo !!!\n");

    char buf[25] = "Hola mundo !!!\n";
    uart_transmit(buf, 25);
    return 0;
}