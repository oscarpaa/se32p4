#!/bin/bash
#$ ./c2hex.sh [file.c] [-c]

CC=riscv64-linux-gnu
cfile=$1
out=$(echo $cfile | awk -F. '{print $1}')


if [ "$1" == "-c" ]; then
    rm -f *.o *.bin *.hex *.elf
    echo "[-] Cleaned all *.o, *.bin, *.elf and *.hex files"
    exit 0
elif [ "$2" == "-c" ]; then
    rm -f $out.o $out.bin $out.hex $out.elf 
    echo "[-] Cleaned $out.o $out.bin, $out.elf and $out.hex files"
    exit 0
fi

$CC-as -march=rv32i -mabi=ilp32 -r $cfile -o $out.o
#$CC-gcc -march=rv32i -mabi=ilp32 -r -S $cfile -o $out.s
$CC-ld -m elf32lriscv -T riscv.ld $out.o -o $out.elf 
$CC-objcopy -O binary $out.elf $out.bin
$CC-objdump -D $out.elf > $out.d
hexdump -ve '1/4 "%08x\n"' $out.bin > $out.hex