MEMORY
{
    RAM(rwxai) : ORIGIN = 0x0, LENGTH = 0x4000 /* 32 KB */
}

SECTIONS
{
    __stack_size = 0x800; /* 2 KB */
    __heap_size  = 0x400; /* 1 KB */

    /* Code and read-only data section */
    .text : ALIGN_WITH_INPUT
    {
        *(.text.start)     /* C Runtime Zero */
        *(.text)           /* All code (.text) */
        *(.text*)          /* Any .text* sections */
        _etext = .;        /* End of .text section */
    } > RAM

    /* Initialized data section */
    .data : ALIGN(4)
    {
        *(.rodata)         /* Read-only constants */
        *(.rodata*)        /* Read-only constants variants */
        *(.srodata)        /* Small read-only data */
        *(.srodata*)       /* Small read-only data variants */
        *(.data)           /* Initialized data */
        *(.data*)          /* Variants */
        *(.sdata)          /* Small initialized data */
        *(.sdata*)
        /* Global pointer symbol for small data access */
        PROVIDE( __global_pointer$ = . + 0x800 );
    } > RAM

    /* Uninitialized data (BSS) section */
    .bss : ALIGN(4)
    {
        __bss_start = .;          /* Start of bss */
        *(.bss)             /* Uninitialized data */
        *(.bss*)
        *(.sbss)            /* Small uninitialized data */
        *(.sbss*)
        *(COMMON)           /* Common symbols */
        __bss_end = .;          /* End of bss */
    } > RAM

    /* Heap section (dynamic memory) */
    .heap (NOLOAD) : ALIGN(4)
    {
        __heap_start = .;
        . += __heap_size;   /* Reserve heap space */
        __heap_end = .;
    } > RAM

    /* Stack section */
    .stack (NOLOAD) : ALIGN(4)
    {
        __stack_start = .;
        . += __stack_size;
        __stack_end = .;
    } > RAM

    /* Symbol for top of stack to initialize SP */
    _stack = __stack_end;
}
