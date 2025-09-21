.section .text.start
.globl _start

_start:
    /* Initialize stack pointer */
    la sp, _stack

    /* Initialize global pointer */
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    /* Clear .bss segment */
    la a0, __bss_start
    la a1, __bss_end
    sub a1, a1, a0       /* length = __bss_end - __bss_start */
    li a2, 0
    call memset

    /* Call user initialization if any */
    call banner

    /* Call main function */
    call main

    /* If main returns, loop here */
# 1:
#     j 1b

    j _start
