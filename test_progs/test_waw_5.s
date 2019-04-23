/*

	TEST PROGRAM: 

	// test for WAW 1 instr immediately with lw

	void main(void)
	{
		int a = 10;
		int a = a + a;
	}

*/

	lda	$r2,10
	addq $r2,$r2,$r2
	call_pal	0x555
