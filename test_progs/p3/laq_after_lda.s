data = 0x1000
lda $r5, 10
lda $r1, data
nop
nop
nop
nop
nop
ldq $r6, 0($r1)
addq $r6, $r5, $r2
call_pal  0x555
