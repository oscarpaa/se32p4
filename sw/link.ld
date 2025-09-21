MEMORY
{
    RAM(rwxai) : ORIGIN = 0x0, LENGTH = 0x1000
}

SECTIONS
{
    __stack_size = 0x800;
    __heap_size  = 0x400;

    .text :
    {
        *(.text)           /* .text sections (code) */
        *(.text*)          /* .text* sections (code) */
        *(.rodata)         /* .rodata sections (constants, strings, etc.) */
        *(.rodata*)        /* .rodata* sections (constants, strings, etc.) */
        *(.srodata)        /* .rodata sections (constants, strings, etc.) */
        *(.srodata*)       /* .rodata* sections (constants, strings, etc.) */
    } > RAM

    .data : ALIGN(4)
    {
        *(.data)           /* .data sections */
        *(.data*)          /* .data* sections */
        *(.sdata)          /* .sdata sections */
        *(.sdata*)         /* .sdata* sections */
    } > RAM

     /* Uninitialized data section */
    .bss : ALIGN(4)
    {
        __bss_start = .;
        *(.bss)
        *(.bss*)
        *(.sbss)
        *(.sbss*)
        *(COMMON)
        __bss_end = .;
    } > RAM

    /* this is to define the start of the heap */
    .heap : ALIGN(4)
    {
        __heap_start = .;
        . = __heap_size;
        __heap_end = .;
    } > RAM

    /* stack */
    .stack : ALIGN(4)
    {
       __stack_start = .;
       . = __stack_size;
       _sp = .;
       __stack_end = .;
    } > RAM
}