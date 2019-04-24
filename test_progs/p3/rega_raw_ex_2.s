lda     $r1,1
lda     $r2,2
lda     $r3,3
addq	$r1, $r2, $r4
addq	$r1, $r3, $r5
addq	$r4, $r5, $r6
call_pal	0x555
