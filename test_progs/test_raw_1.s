/*

	TEST PROGRAM: 

	// test for RAW 1 instr immediately

	void main(void)
	{
		int a, b, c;
		a = 1;
		b = a + a;
		c = a + b;
	}

*/

	lda	$r2,1
	nop
	nop
	nop
	nop
	nop
	addq $r2,$r2,$r3
	addq $r2,$r3,$r4
	call_pal	0x555
