
test2.elf:     formato del fichero elf32-littleriscv


Desensamblado de la sección .text:

00000000 <main>:
   0:	00000537          	lui	a0,0x0
   4:	05056593          	ori	a1,a0,80
   8:	00500613          	li	a2,5

0000000c <call>:
   c:	014000ef          	jal	ra,20 <sum>
  10:	00c02023          	sw	a2,0(zero) # 0 <main>
  14:	00002683          	lw	a3,0(zero) # 0 <main>
  18:	0005f713          	andi	a4,a1,0
  1c:	00e00c63          	beq	zero,a4,34 <BEQ>

00000020 <sum>:
  20:	00b007b3          	add	a5,zero,a1
  24:	00000837          	lui	a6,0x0
  28:	00c86813          	ori	a6,a6,12
  2c:	00480067          	jr	4(a6) # 4 <main+0x4>
  30:	00180813          	addi	a6,a6,1

00000034 <BEQ>:
  34:	fffff8b7          	lui	a7,0xfffff
  38:	4108d893          	srai	a7,a7,0x10
  3c:	01100463          	beq	zero,a7,44 <BEQ2>
  40:	0018c913          	xori	s2,a7,1

00000044 <BEQ2>:
  44:	01089993          	slli	s3,a7,0x10
  48:	00195a13          	srli	s4,s2,0x1
  4c:	40195a93          	srai	s5,s2,0x1
  50:	01599463          	bne	s3,s5,58 <BNE>
  54:	001a0a13          	addi	s4,s4,1

00000058 <BNE>:
  58:	011a9463          	bne	s5,a7,60 <BNE2>
  5c:	01306b33          	or	s6,zero,s3

00000060 <BNE2>:
  60:	013acbb3          	xor	s7,s5,s3
  64:	40c58c33          	sub	s8,a1,a2
  68:	00b020a3          	sw	a1,1(zero) # 1 <main+0x1>
  6c:	01102123          	sw	a7,2(zero) # 2 <main+0x2>
  70:	00001c97          	auipc	s9,0x1
  74:	01804463          	bgtz	s8,7c <BLT>
  78:	00ac8c93          	addi	s9,s9,10 # 107a <finish+0xfaa>

0000007c <BLT>:
  7c:	f80c42e3          	bltz	s8,0 <main>
  80:	0005d463          	bgez	a1,88 <BGE>
  84:	00ac8c93          	addi	s9,s9,10

00000088 <BGE>:
  88:	f7107ce3          	bgeu	zero,a7,0 <main>
  8c:	00100513          	li	a0,1
  90:	ff600593          	li	a1,-10
  94:	00b021a3          	sw	a1,3(zero) # 3 <main+0x3>
  98:	00300d03          	lb	s10,3(zero) # 3 <main+0x3>
  9c:	00304d83          	lbu	s11,3(zero) # 3 <main+0x3>
  a0:	00201e03          	lh	t3,2(zero) # 2 <main+0x2>
  a4:	00205e83          	lhu	t4,2(zero) # 2 <main+0x2>
  a8:	01500223          	sb	s5,4(zero) # 4 <main+0x4>
  ac:	015012a3          	sh	s5,5(zero) # 5 <main+0x5>
  b0:	ff602f13          	slti	t5,zero,-10
  b4:	ff603f93          	sltiu	t6,zero,-10
  b8:	00100113          	li	sp,1
  bc:	002a9133          	sll	sp,s5,sp
  c0:	015021b3          	sgtz	gp,s5
  c4:	01503233          	snez	tp,s5
  c8:	010ad293          	srli	t0,s5,0x10
  cc:	410ad313          	srai	t1,s5,0x10

000000d0 <finish>:
  d0:	0000006f          	j	d0 <finish>
