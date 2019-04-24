/*

	TEST PROGRAM: 

	// test for RAW 3 instr immediately

	void main(void)
	{
		int a, b, c, d, e, f, g;
		a = 1;
		b = 2;
		d = 7;
		e = 9;
		c = a + b;
		f = d + e;
		e = d + d;
		g = c + d;
	}

*/

	lda	$r2,1
	lda $r3,2
	lda $r5,7
	lda $r6,9
	nop
	nop
	nop
	nop
	nop
	addq $r2,$r3,$r4
	addq $r5,$r6,$r7
	addq $r5,$r5,$r6
	addq $r4,$r5,$r8
	call_pal	0x555
