MEMORY
{
    ROM (x!rw) : ORIGIN = 0x00000000, LENGTH = 0x4000
    RAM (rw!x) : ORIGIN = 0x00004000, LENGTH = 0x2000
}
SECTIONS
{
    .text :
    {
        *(.boot)
        *(.text)
    } > ROM
    .data :
    {
        *(.rodata*)
        *(.data)
        *(.sbss)
        *(.bss)
    } > RAM
}
