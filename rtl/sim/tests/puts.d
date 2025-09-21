
puts.elf:     formato del fichero elf32-littleriscv


Desensamblado de la sección .text:

00000000 <put1>:
   0:	04100513          	li	a0,65
   4:	010000ef          	jal	ra,14 <put>

00000008 <put2>:
   8:	05200513          	li	a0,82
   c:	008000ef          	jal	ra,14 <put>

00000010 <finish>:
  10:	0000006f          	j	10 <finish>

00000014 <put>:
  14:	800007b7          	lui	a5,0x80000
  18:	0007c783          	lbu	a5,0(a5) # 80000000 <put+0x7fffffec>
  1c:	0017f793          	andi	a5,a5,1
  20:	fe079ae3          	bnez	a5,14 <put>
  24:	800007b7          	lui	a5,0x80000
  28:	0ff57713          	andi	a4,a0,255
  2c:	00e780a3          	sb	a4,1(a5) # 80000001 <put+0x7fffffed>
  30:	00070513          	mv	a0,a4
  34:	00008067          	ret
