/*

	TEST PROGRAM: 

	// test for WAW mixed instr 3 immediately

	void main(void)
	{
		int a = 10;
		int b = 20;
		int c = 30;
		int d = a + b;
		int e = b + c;
		int f = a + c;
		d = a + a;
	}

*/

	lda	$r2,10
	lda $r3,20
	lda $r4,30
	nop
	nop
	nop
	nop
	nop
	addq $r2,$r3,$r5
	addq $r3,$r4,$r6
	addq $r2,$r4,$r7
	addq $r2,$r2,$r5	
	call_pal	0x555
