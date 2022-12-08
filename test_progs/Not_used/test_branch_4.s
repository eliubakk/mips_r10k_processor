/*

	TEST PROGRAM: 

	// test for branch speculate and squash

	void main(void)
	{
		int a = 1;
		for (int i = 0; i < 4; ++i)
		{
			a = a + a;
		}
	}

*/

	lda $r2,1
	lda $r3,0
loop:	cmplt $r3,4,$r5
		beq $r5,end
		addq $r2,$r2,$r2
		addq $r3,1,$r3
end: 	call_pal	0x555
