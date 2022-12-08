data = 0x1000
lda     $r1,data
lda     $r2,2
lda		$r3,4
stq     $r2,0($r1)
ldq		$r4,0($r1)
addq	$r4,$r3,$r5
call_pal 0x555
