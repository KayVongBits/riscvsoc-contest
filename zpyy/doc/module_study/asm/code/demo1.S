main:    
    lui s8 , 0x00BEB
    li t0, 0xC20
    add s8 , s8 , t0
    li s10 , 0
loop:
    li ra, 0
    mv a0,s8     
biaohao1:     
    addi a0, a0, -1
    bnez a0, biaohao1
    addi s10,s10, 1
    jal ra,loop
    nop
    nop
