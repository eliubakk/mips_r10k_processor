/*
	Simple test program.
*/

	lda $r1,3
	lda $r2,2
	lda $r3,4
	lda $r4,5
	addq $r1,$r2,$r5
	addq $r3,$r4,$r6
	addq $r5,$r6,$r7
	call_pal	0x555
