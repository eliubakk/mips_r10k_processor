/*

	TEST PROGRAM: 

	// test for RAW mixed instr immediately with lw

	void main(void)
	{
		int a = 10;
		int b = 20;
		int c = a + b;
	}

*/

	lda	$r2,10
	lda $r3,20
	addq $r2,$r3,$r4
	call_pal	0x555
