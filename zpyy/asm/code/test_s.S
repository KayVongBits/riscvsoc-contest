.text
.globl	_test_s
_test_s:
	li  t0,0
    li  t1,0
    lui t2,0x00001
loop:
    sw  t0,0(t1)
    addi t1,t1,4
    addi t0,t0,1
    bne  t0,t2,loop

    li t0,0
    li t1,0