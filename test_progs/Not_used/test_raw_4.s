/*

	TEST PROGRAM: 

	// test for RAW mixed instr immediately

	void main(void)
	{
		int a, b, c, d, e, f, g;
		a = 1;
		b = 2;
		c = 3;
		d = 4;
		c = a + b;
		e = c + d;
		f = e + d;
		g = c + e;
	}

*/

	lda	$r2,1
	lda $r3,2
	lda $r4,3
	lda $r5,4
	nop
	nop
	nop
	nop
	nop
	addq $r2,$r3,$r4
	addq $r4,$r5,$r6
	addq $r6,$r5,$r7
	addq $r4,$r6,$r8
	call_pal	0x555
