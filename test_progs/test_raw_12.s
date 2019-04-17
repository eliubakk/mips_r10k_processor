/*

	TEST PROGRAM: 
	ldq $r6,0($r1)
	stq $r3,0($r1)

*/

	data = 0x1000
	lda $r5,10
	lda $r3,20
	lda $r1,data
	stq $r5,0($r1)
	ldq $r6,0($r1)
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ldq $r4,0($r1)
	stq $r3,0($r1)
	addq $r3,$r5,$r4
	call_pal	0x555

