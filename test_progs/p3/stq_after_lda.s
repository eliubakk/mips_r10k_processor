data = 0x1000
lda     $r3,data
lda     $r4,data+8
lda     $r5,data+16
lda     $r9,2
lda     $r1,1
stq     $r1,0($r3)
stq	$r1,0($r4)
call_pal 0x555
