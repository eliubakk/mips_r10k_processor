/*

	TEST PROGRAM: 

	// test for WAW mixed instr immediately

	void main(void)
	{
		int a = 10;
		int b = 20;
		int c = a + b;
		c = a + a;
	}

*/

	lda	$r2,10
	lda $r3,20
	nop
	nop
	nop
	nop
	nop
	addq $r2,$r3,$r4
	addq $r2,$r2,$r4	
	call_pal	0x555
