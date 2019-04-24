/*

	TEST PROGRAM: 

	// test for RAW 2 instr immediately

	void main(void)
	{
		int a, b, c, d, e, f;
		a = 1;
		b = 2;
		d = 7;
		c = a + b;
		e = b + d;
		f = c + d;
	}

*/

	lda	$r2,1
	lda $r3,2
	lda $r5,7
	nop
	nop
	nop
	nop
	nop
	addq $r2,$r3,$r4
	addq $r3,$r5,$r6
	addq $r4,$r5,$r7
	call_pal	0x555
