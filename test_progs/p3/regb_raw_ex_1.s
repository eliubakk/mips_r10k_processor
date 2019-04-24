lda     $r1,1
lda     $r2,2
addq	$r1, $r2, $r3 
addq	$r1, $r3, $r4
call_pal	0x555
