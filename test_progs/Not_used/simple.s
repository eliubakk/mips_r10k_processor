/*
	Simple test program.
*/

	lda $r2,3
	lda $r1,2
	addq $r1,$r2,$r3
	call_pal	0x555
