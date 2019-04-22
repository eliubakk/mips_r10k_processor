/*

	TEST PROGRAM: 

	BUS STORE 4096 with data 2
	STORE TO LOAD with data 2 at reg 5
	BUS STORE 4096 with data 3
	BUS STORE 4096 with data 4
	STORE TO LOAD with data 4 at reg 6
	STORE TO LOAD with data 4 at reg 7

*/

	data = 0x1000
	lda $r1,data
	lda $r2,2
	lda $r3,3
	lda $r4,4
	mulq $r2,$r3,$r2
	stq $r2,0($r1)
	ldq $r5,0($r1)
	mulq $r2,$r3,$r3
	stq $r3,0($r1)
	ldq $r6,0($r1)
	mulq $r2,$r3,$r4
	stq $r4,0($r1)
	ldq $r7,0($r1)
	call_pal	0x555

