/*
	Simple test program.
*/

	data = 0x1000	
	lda     $r2,4
	lda	$r3,data
	stq	$r2,0($r3)
	call_pal        0x555
