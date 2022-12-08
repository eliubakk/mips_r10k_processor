start:	data = 0x1000
	lda     $r2,4
	lda     $r3,data
	lda     $r4,3
    stq		$r2,0($r3)
    stq     $r3,8($r3)
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ldq		$r5,0($r3)
    ldq     $r7,8($r3)

	call_pal        0x555
