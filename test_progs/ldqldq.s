	
	
	lda	$r0,8
	.align 3
	.quad	16,32,48,64
#	lda	$r1,16
#	lda	$r2,32
#	lda	$r3,48
#	lda	$r4,64
#	stq	$r1,0($r0)
#	stq	$r2,8($r0)
#	stq	$r3,16($r0)
#	stq	$r4,24($r0)
	.align 3	
	ldq	$r5,0($r0)
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	#ldq	$r5,8($r0)
	#ldq	$r5,16($r0)
	#ldq	$r5,24($r0)
	 
	call_pal 0x555

	
