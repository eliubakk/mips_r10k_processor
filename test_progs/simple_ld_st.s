/*
	Simple test program.
*/
	br	start

	.align 3
	.quad	3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5, 8, 9, 7, 9, 3

	.align 3
start:	data = 0x0008
	lda     $r2,4
	lda     $r3,data
	ldq		$r4,0($r3)
	stq     $r2,0($r3)
	call_pal        0x555
