/*
	Simple test program.
*/

	lda $r1,3
	lda $r2,2
	lda $r3,4
	lda $r4,5
	mulq $r1,$r2,$r5
	addq $r3,$r4,$r6
	mulq $r5,$r6,$r7
	addq $r7,$r7,$r8
	call_pal	0x555
