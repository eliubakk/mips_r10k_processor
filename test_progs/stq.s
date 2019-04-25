	
	
	lda	$r0,80
	lda	$r1,ffff
	stq	$r1,0($r0)
	call_pal 0x555

	
