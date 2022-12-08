/*

	TEST PROGRAM: 

	// test for RAW 2 instr immediately with lw

	void main(void)
	{
		int a = 10;
		int b = 20;
		int c = a + a;
		int d = a + a;
	}

*/

	lda	$r2,10
	lda $r3,20
	addq $r2,$r2,$r4
	addq $r2,$r2,$r5
	call_pal	0x555
