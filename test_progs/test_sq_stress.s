/*
	TEST PROGRAM #1: copy memory contents of 16 elements starting at
			 address 0x1000 over to starting address 0x1100. 
	

	long output[16];

	void
	main(void)
	{
	  long i;
	  *a = 0x1000;
          *b = 0x1100;
	 
	  for (i=0; i < 16; i++)
	    {
	      a[i] = i*10; 
	      b[i] = a[i]; 
	    }
	}
*/
	data = 0x1000
	lda	$r5,0xbad
	lda	$r1,data
	stq	$r5,0($r1)
	stq	$r5,4($r1)
	stq	$r5,8($r1)
	stq	$r5,12($r1)
	stq	$r5,16($r1)
	stq	$r5,20($r1)
	stq	$r5,24($r1)
	stq	$r5,28($r1)
	stq	$r5,32($r1)
	stq	$r5,36($r1)
	stq	$r5,40($r1)
	stq	$r5,44($r1)
	stq	$r5,48($r1)
	stq	$r5,52($r1)
	stq	$r5,56($r1)
	stq	$r5,60($r1)
	stq	$r5,64($r1)
	call_pal        0x555

