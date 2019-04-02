/*

	TEST PROGRAM: 

	// test for WAW mixed instr immediately

	void main(void)
	{
		int a, b, c, d, e;
		a = 1;
		b = 2;
		c = 3;
		d = 4;
		e = a + b;
		e = c + b;
		e = e + a;
		e = a + d;
		e = e + e;
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
	addq $r2,$r3,$r6
	addq $r4,$r3,$r6
	addq $r6,$r2,$r6
	addq $r2,$r5,$r6
	addq $r6,$r6,$r6
	call_pal	0x555
