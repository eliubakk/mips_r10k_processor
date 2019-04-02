/*

	TEST PROGRAM: 

	// test for WAW mixed instr 2 immediately

	void main(void)
	{
		int a = 10;
		int b = 20;
		int c = a + b;
		int d = b + b;
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
	addq $r3,$r3,$r5
	addq $r2,$r2,$r4	
	call_pal	0x555
