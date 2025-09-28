MEMORY
{
    RAM(rwx) : ORIGIN = 0x0, LENGTH = 0x4000 /* 16 KB */
}

SECTIONS
{
    __stack_size = 0x800; /* 2 KB */

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

    /* End marker for heap start */
    . = ALIGN(8);
    _heap = .; /* Heap starts here and grows upwards */

    /* Stack grows downward from the end of RAM */
    _stack_top = ORIGIN(RAM) + LENGTH(RAM);
    _stack_bottom = _stack_top - __stack_size;

    ASSERT(_stack_bottom < LENGTH(RAM), "Error: Stack size too large for RAM")
    ASSERT(_heap <= _stack_bottom, "Error: Heap collides with stack")
}
