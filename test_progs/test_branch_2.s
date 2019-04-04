/*

	TEST PROGRAM: 

	// test for branch speculate and squash

	void main(void)
	{
		int a, b, c;
		a = 0;
		b = 0;
		c = 1;
		if (a == c)
		{
			a = a + c;
		}
		else if (a == b)
		{
			c = a + b;
		}
		else
		{
			b = c + c;
		}
	}

*/

	lda $r2,0
	lda $r3,0
	lda $r4,1
	cmpeq $r2,$r3,$r5
	bne $r5,cond2
	addq $r4,$r4,$3
	call_pal	0x555
cond1:	addq $r2,$r4,$r2
	call_pal	0x555
cond2:	addq $r2,$r3,$r4
	call_pal 	0x555
