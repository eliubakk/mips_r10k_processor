/*

	TEST PROGRAM: 

	// test for RAW 1 instr immediately with lw

	void main(void)
	{
		int a = 10;
		int b = a + a;
	}

*/

	lda	$r2,10
	addq $r2,$r2,$r3
	call_pal	0x555
