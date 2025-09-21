
.section text.start

_init:
    la sp, _sp
    # la gp, 

/* clear the bss segment */
_init_bss:
    la a0, __bss_start
    la a2, __bss_end
    sub a2, a2, a0
    li a1, 0
    call memset

    call banner

    call main