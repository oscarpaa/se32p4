put1:
    addi a0, zero, 65    # a0 = A
    jal ra, put

put2: 
    addi a0, zero, 82    # a0 = R
    jal ra, put

finish:
    jal x0, finish

put:
    lui a5, 0x80000      # 80000000 <io+0x0>
    lbu	a5,0(a5)         # stat
    andi a5,a5,1         # stat & 1
    bne a5, zero, put    # uart busy, wait...
    lui a5, 0x80000      # 80000000 <io+0x0>
    andi a4,a0,255       # a4 = char
    sb a4,1(a5)          # send to uart
    addi a0, a4, 0       # a0 = a4 = char
    jalr zero, ra, 0 
