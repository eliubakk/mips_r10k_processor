/*
  Assembly code compiled from Decaf by 'decaf470', written by Doug Li.
*/

	  .set noat
	  .set noreorder
	  .set nomacro
	  data = 0x1000
	  global = 0x2000
	  lda		$r30, 0x7FF0	# set stack ptr to a sufficiently high addr
	  lda		$r15, 0x0000	# initialize frame ptr to something
	  lda		$r29, global	# initialize global ptr to 0x2000
	# Initialize Heap Management Table
	#   could be done at compile-time, but then we get a super large .mem file
	  heap_srl_3 = 0x1800
	  lda		$r28, heap_srl_3	# work-around since heap-start needs >15 bits
	  sll		$r28, 3, $r28	# using the $at as the heap-pointer
	# Do not write to heap-pointer!
	  stq		$r31, -32*8($r28)	# init heap table
	  stq		$r31, -31*8($r28)	# init heap table
	  stq		$r31, -30*8($r28)	# init heap table
	  stq		$r31, -29*8($r28)	# init heap table
	  stq		$r31, -28*8($r28)	# init heap table
	  stq		$r31, -27*8($r28)	# init heap table
	  stq		$r31, -26*8($r28)	# init heap table
	  stq		$r31, -25*8($r28)	# init heap table
	  stq		$r31, -24*8($r28)	# init heap table
	  stq		$r31, -23*8($r28)	# init heap table
	  stq		$r31, -22*8($r28)	# init heap table
	  stq		$r31, -21*8($r28)	# init heap table
	  stq		$r31, -20*8($r28)	# init heap table
	  stq		$r31, -19*8($r28)	# init heap table
	  stq		$r31, -18*8($r28)	# init heap table
	  stq		$r31, -17*8($r28)	# init heap table
	  stq		$r31, -16*8($r28)	# init heap table
	  stq		$r31, -15*8($r28)	# init heap table
	  stq		$r31, -14*8($r28)	# init heap table
	  stq		$r31, -13*8($r28)	# init heap table
	  stq		$r31, -12*8($r28)	# init heap table
	  stq		$r31, -11*8($r28)	# init heap table
	  stq		$r31, -10*8($r28)	# init heap table
	  stq		$r31, -9*8($r28)	# init heap table
	  stq		$r31, -8*8($r28)	# init heap table
	  stq		$r31, -7*8($r28)	# init heap table
	  stq		$r31, -6*8($r28)	# init heap table
	  stq		$r31, -5*8($r28)	# init heap table
	  stq		$r31, -4*8($r28)	# init heap table
	  stq		$r31, -3*8($r28)	# init heap table
	  stq		$r31, -2*8($r28)	# init heap table
	  stq		$r31, -1*8($r28)	# init heap table
	# End Initialize Heap Management Table
	  bsr		$r26, main	# branch to subroutine
	  call_pal	0x555		# (halt)
	  .data
	  L_DATA:			# this is where the locals and temps end up at run-time
	  .text
_divide:
	# BeginFunc 56
	  subq		$r30, 16, $r30	# decrement sp to make space to save ra, fp
	  stq		$r15, 16($r30)	# save fp
	  stq		$r26, 8($r30)	# save ra
	  addq		$r30, 16, $r15	# set up new fp
	  subq		$r30, 56, $r30	# decrement sp to make space for locals/temps
	# result = a
	  ldq		$r3, 8($r15)	# fill a to $r3 from $r15+8
	  stq		$r3, -24($r15)	# spill result from $r3 to $r15-24
__L0:
	# _tmp0 = 0
	  lda		$r3, 0		# load (signed) int constant value 0 into $r3
	  stq		$r3, -32($r15)	# spill _tmp0 from $r3 to $r15-32
	# _tmp1 = _tmp0 < result
	  ldq		$r1, -32($r15)	# fill _tmp0 to $r1 from $r15-32
	  ldq		$r2, -24($r15)	# fill result to $r2 from $r15-24
	  cmplt		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -40($r15)	# spill _tmp1 from $r3 to $r15-40
	# IfZ _tmp1 Goto __L1
	  ldq		$r1, -40($r15)	# fill _tmp1 to $r1 from $r15-40
	  blbc		$r1, __L1	# branch if _tmp1 is zero
	# _tmp2 = b * result
	  ldq		$r1, 16($r15)	# fill b to $r1 from $r15+16
	  ldq		$r2, -24($r15)	# fill result to $r2 from $r15-24
	  mulq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -56($r15)	# spill _tmp2 from $r3 to $r15-56
	# val = _tmp2
	  ldq		$r3, -56($r15)	# fill _tmp2 to $r3 from $r15-56
	  stq		$r3, -48($r15)	# spill val from $r3 to $r15-48
	# _tmp3 = val <= a
	  ldq		$r1, -48($r15)	# fill val to $r1 from $r15-48
	  ldq		$r2, 8($r15)	# fill a to $r2 from $r15+8
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -64($r15)	# spill _tmp3 from $r3 to $r15-64
	# IfZ _tmp3 Goto __L2
	  ldq		$r1, -64($r15)	# fill _tmp3 to $r1 from $r15-64
	  blbc		$r1, __L2	# branch if _tmp3 is zero
	# result = val
	  ldq		$r3, -48($r15)	# fill val to $r3 from $r15-48
	  stq		$r3, -24($r15)	# spill result from $r3 to $r15-24
	# Goto __L1
	  br		__L1		# unconditional branch
__L2:
	# result -= 1
	  ldq		$r3, -24($r15)	# fill result to $r3 from $r15-24
	  subq		$r3, 1, $r3	# perform the ALU op
	  stq		$r3, -24($r15)	# spill result from $r3 to $r15-24
	# Goto __L0
	  br		__L0		# unconditional branch
__L1:
	# Return result
	  ldq		$r3, -24($r15)	# fill result to $r3 from $r15-24
	  mov		$r3, $r0		# assign return value into $v0
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
_search_for:
	# BeginFunc 256
	  subq		$r30, 16, $r30	# decrement sp to make space to save ra, fp
	  stq		$r15, 16($r30)	# save fp
	  stq		$r26, 8($r30)	# save ra
	  addq		$r30, 16, $r15	# set up new fp
	  lda		$r2, 256	# stack frame size
	  subq		$r30, $r2, $r30	# decrement sp to make space for locals/temps
	# _tmp4 = low < high
	  ldq		$r1, 24($r15)	# fill low to $r1 from $r15+24
	  ldq		$r2, 32($r15)	# fill high to $r2 from $r15+32
	  cmplt		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -16($r15)	# spill _tmp4 from $r3 to $r15-16
	# IfZ _tmp4 Goto __L3
	  ldq		$r1, -16($r15)	# fill _tmp4 to $r1 from $r15-16
	  blbc		$r1, __L3	# branch if _tmp4 is zero
	# _tmp5 = low + high
	  ldq		$r1, 24($r15)	# fill low to $r1 from $r15+24
	  ldq		$r2, 32($r15)	# fill high to $r2 from $r15+32
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -32($r15)	# spill _tmp5 from $r3 to $r15-32
	# _tmp6 = 2
	  lda		$r3, 2		# load (signed) int constant value 2 into $r3
	  stq		$r3, -40($r15)	# spill _tmp6 from $r3 to $r15-40
	# PushParam _tmp6
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -40($r15)	# fill _tmp6 to $r1 from $r15-40
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam _tmp5
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -32($r15)	# fill _tmp5 to $r1 from $r15-32
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp7 = LCall _divide
	  bsr		$r26, _divide	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -48($r15)	# spill _tmp7 from $r3 to $r15-48
	# PopParams 16
	  addq		$r30, 16, $r30	# pop params off stack
	# mid = _tmp7
	  ldq		$r3, -48($r15)	# fill _tmp7 to $r3 from $r15-48
	  stq		$r3, -24($r15)	# spill mid from $r3 to $r15-24
	# _tmp8 = mid < ZERO
	  ldq		$r1, -24($r15)	# fill mid to $r1 from $r15-24
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -56($r15)	# spill _tmp8 from $r3 to $r15-56
	# _tmp9 = *(array + -8)
	  ldq		$r1, 16($r15)	# fill array to $r1 from $r15+16
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -64($r15)	# spill _tmp9 from $r3 to $r15-64
	# _tmp10 = _tmp9 <= mid
	  ldq		$r1, -64($r15)	# fill _tmp9 to $r1 from $r15-64
	  ldq		$r2, -24($r15)	# fill mid to $r2 from $r15-24
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -72($r15)	# spill _tmp10 from $r3 to $r15-72
	# _tmp11 = _tmp8 || _tmp10
	  ldq		$r1, -56($r15)	# fill _tmp8 to $r1 from $r15-56
	  ldq		$r2, -72($r15)	# fill _tmp10 to $r2 from $r15-72
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -80($r15)	# spill _tmp11 from $r3 to $r15-80
	# IfZ _tmp11 Goto __L4
	  ldq		$r1, -80($r15)	# fill _tmp11 to $r1 from $r15-80
	  blbc		$r1, __L4	# branch if _tmp11 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L4:
	# _tmp12 = mid << 3
	  ldq		$r1, -24($r15)	# fill mid to $r1 from $r15-24
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -88($r15)	# spill _tmp12 from $r3 to $r15-88
	# _tmp13 = array + _tmp12
	  ldq		$r1, 16($r15)	# fill array to $r1 from $r15+16
	  ldq		$r2, -88($r15)	# fill _tmp12 to $r2 from $r15-88
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -96($r15)	# spill _tmp13 from $r3 to $r15-96
	# _tmp14 = *(_tmp13)
	  ldq		$r1, -96($r15)	# fill _tmp13 to $r1 from $r15-96
	  ldq		$r3, 0($r1)	# load with offset
	  stq		$r3, -104($r15)	# spill _tmp14 from $r3 to $r15-104
	# _tmp15 = val ^~ _tmp14
	  ldq		$r1, 8($r15)	# fill val to $r1 from $r15+8
	  ldq		$r2, -104($r15)	# fill _tmp14 to $r2 from $r15-104
	  eqv		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -112($r15)	# spill _tmp15 from $r3 to $r15-112
	# IfZ _tmp15 Goto __L5
	  ldq		$r1, -112($r15)	# fill _tmp15 to $r1 from $r15-112
	  blbc		$r1, __L5	# branch if _tmp15 is zero
	# _tmp16 = true
	  mov		1, $r3		# load constant value 1 into $r3
	  stq		$r3, -120($r15)	# spill _tmp16 from $r3 to $r15-120
	# Return _tmp16
	  ldq		$r3, -120($r15)	# fill _tmp16 to $r3 from $r15-120
	  mov		$r3, $r0		# assign return value into $v0
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
	# Goto __L6
	  br		__L6		# unconditional branch
__L5:
	# _tmp17 = mid < ZERO
	  ldq		$r1, -24($r15)	# fill mid to $r1 from $r15-24
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -128($r15)	# spill _tmp17 from $r3 to $r15-128
	# _tmp18 = *(array + -8)
	  ldq		$r1, 16($r15)	# fill array to $r1 from $r15+16
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -136($r15)	# spill _tmp18 from $r3 to $r15-136
	# _tmp19 = _tmp18 <= mid
	  ldq		$r1, -136($r15)	# fill _tmp18 to $r1 from $r15-136
	  ldq		$r2, -24($r15)	# fill mid to $r2 from $r15-24
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -144($r15)	# spill _tmp19 from $r3 to $r15-144
	# _tmp20 = _tmp17 || _tmp19
	  ldq		$r1, -128($r15)	# fill _tmp17 to $r1 from $r15-128
	  ldq		$r2, -144($r15)	# fill _tmp19 to $r2 from $r15-144
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -152($r15)	# spill _tmp20 from $r3 to $r15-152
	# IfZ _tmp20 Goto __L7
	  ldq		$r1, -152($r15)	# fill _tmp20 to $r1 from $r15-152
	  blbc		$r1, __L7	# branch if _tmp20 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L7:
	# _tmp21 = mid << 3
	  ldq		$r1, -24($r15)	# fill mid to $r1 from $r15-24
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -160($r15)	# spill _tmp21 from $r3 to $r15-160
	# _tmp22 = array + _tmp21
	  ldq		$r1, 16($r15)	# fill array to $r1 from $r15+16
	  ldq		$r2, -160($r15)	# fill _tmp21 to $r2 from $r15-160
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -168($r15)	# spill _tmp22 from $r3 to $r15-168
	# _tmp23 = *(_tmp22)
	  ldq		$r1, -168($r15)	# fill _tmp22 to $r1 from $r15-168
	  ldq		$r3, 0($r1)	# load with offset
	  stq		$r3, -176($r15)	# spill _tmp23 from $r3 to $r15-176
	# _tmp24 = val < _tmp23
	  ldq		$r1, 8($r15)	# fill val to $r1 from $r15+8
	  ldq		$r2, -176($r15)	# fill _tmp23 to $r2 from $r15-176
	  cmplt		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -184($r15)	# spill _tmp24 from $r3 to $r15-184
	# IfZ _tmp24 Goto __L8
	  ldq		$r1, -184($r15)	# fill _tmp24 to $r1 from $r15-184
	  blbc		$r1, __L8	# branch if _tmp24 is zero
	# PushParam mid
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -24($r15)	# fill mid to $r1 from $r15-24
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam low
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, 24($r15)	# fill low to $r1 from $r15+24
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam array
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, 16($r15)	# fill array to $r1 from $r15+16
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam val
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, 8($r15)	# fill val to $r1 from $r15+8
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp25 = LCall _search_for
	  bsr		$r26, _search_for	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -192($r15)	# spill _tmp25 from $r3 to $r15-192
	# PopParams 32
	  addq		$r30, 32, $r30	# pop params off stack
	# Return _tmp25
	  ldq		$r3, -192($r15)	# fill _tmp25 to $r3 from $r15-192
	  mov		$r3, $r0		# assign return value into $v0
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
	# Goto __L9
	  br		__L9		# unconditional branch
__L8:
	# PushParam high
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, 32($r15)	# fill high to $r1 from $r15+32
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam mid
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -24($r15)	# fill mid to $r1 from $r15-24
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam array
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, 16($r15)	# fill array to $r1 from $r15+16
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam val
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, 8($r15)	# fill val to $r1 from $r15+8
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp26 = LCall _search_for
	  bsr		$r26, _search_for	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -200($r15)	# spill _tmp26 from $r3 to $r15-200
	# PopParams 32
	  addq		$r30, 32, $r30	# pop params off stack
	# Return _tmp26
	  ldq		$r3, -200($r15)	# fill _tmp26 to $r3 from $r15-200
	  mov		$r3, $r0		# assign return value into $v0
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
__L9:
__L6:
	# Goto __L10
	  br		__L10		# unconditional branch
__L3:
	# _tmp27 = low < ZERO
	  ldq		$r1, 24($r15)	# fill low to $r1 from $r15+24
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -208($r15)	# spill _tmp27 from $r3 to $r15-208
	# _tmp28 = *(array + -8)
	  ldq		$r1, 16($r15)	# fill array to $r1 from $r15+16
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -216($r15)	# spill _tmp28 from $r3 to $r15-216
	# _tmp29 = _tmp28 <= low
	  ldq		$r1, -216($r15)	# fill _tmp28 to $r1 from $r15-216
	  ldq		$r2, 24($r15)	# fill low to $r2 from $r15+24
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -224($r15)	# spill _tmp29 from $r3 to $r15-224
	# _tmp30 = _tmp27 || _tmp29
	  ldq		$r1, -208($r15)	# fill _tmp27 to $r1 from $r15-208
	  ldq		$r2, -224($r15)	# fill _tmp29 to $r2 from $r15-224
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -232($r15)	# spill _tmp30 from $r3 to $r15-232
	# IfZ _tmp30 Goto __L11
	  ldq		$r1, -232($r15)	# fill _tmp30 to $r1 from $r15-232
	  blbc		$r1, __L11	# branch if _tmp30 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L11:
	# _tmp31 = low << 3
	  ldq		$r1, 24($r15)	# fill low to $r1 from $r15+24
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -240($r15)	# spill _tmp31 from $r3 to $r15-240
	# _tmp32 = array + _tmp31
	  ldq		$r1, 16($r15)	# fill array to $r1 from $r15+16
	  ldq		$r2, -240($r15)	# fill _tmp31 to $r2 from $r15-240
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -248($r15)	# spill _tmp32 from $r3 to $r15-248
	# _tmp33 = *(_tmp32)
	  ldq		$r1, -248($r15)	# fill _tmp32 to $r1 from $r15-248
	  ldq		$r3, 0($r1)	# load with offset
	  stq		$r3, -256($r15)	# spill _tmp33 from $r3 to $r15-256
	# _tmp34 = _tmp33 ^~ val
	  ldq		$r1, -256($r15)	# fill _tmp33 to $r1 from $r15-256
	  ldq		$r2, 8($r15)	# fill val to $r2 from $r15+8
	  eqv		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -264($r15)	# spill _tmp34 from $r3 to $r15-264
	# Return _tmp34
	  ldq		$r3, -264($r15)	# fill _tmp34 to $r3 from $r15-264
	  mov		$r3, $r0		# assign return value into $v0
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
__L10:
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
main:
	# BeginFunc 704
	  subq		$r30, 16, $r30	# decrement sp to make space to save ra, fp
	  stq		$r15, 16($r30)	# save fp
	  stq		$r26, 8($r30)	# save ra
	  addq		$r30, 16, $r15	# set up new fp
	  lda		$r2, 704	# stack frame size
	  subq		$r30, $r2, $r30	# decrement sp to make space for locals/temps
	# _tmp35 = 8
	  lda		$r3, 8		# load (signed) int constant value 8 into $r3
	  stq		$r3, -48($r15)	# spill _tmp35 from $r3 to $r15-48
	# size = _tmp35
	  ldq		$r3, -48($r15)	# fill _tmp35 to $r3 from $r15-48
	  stq		$r3, -32($r15)	# spill size from $r3 to $r15-32
	# _tmp36 = size < ZERO
	  ldq		$r1, -32($r15)	# fill size to $r1 from $r15-32
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -56($r15)	# spill _tmp36 from $r3 to $r15-56
	# IfZ _tmp36 Goto __L12
	  ldq		$r1, -56($r15)	# fill _tmp36 to $r1 from $r15-56
	  blbc		$r1, __L12	# branch if _tmp36 is zero
	# Throw Exception: Array size is <= 0
	  call_pal	0xDECAF		# (exception: Array size is <= 0)
	  call_pal	0x555		# (halt)
__L12:
	# _tmp37 = size + 1
	  ldq		$r1, -32($r15)	# fill size to $r1 from $r15-32
	  addq		$r1, 1, $r3	# perform the ALU op
	  stq		$r3, -64($r15)	# spill _tmp37 from $r3 to $r15-64
	# PushParam _tmp37
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -64($r15)	# fill _tmp37 to $r1 from $r15-64
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp38 = LCall __Alloc
	  bsr		$r26, __Alloc	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -72($r15)	# spill _tmp38 from $r3 to $r15-72
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# *(_tmp38) = size
	  ldq		$r1, -32($r15)	# fill size to $r1 from $r15-32
	  ldq		$r3, -72($r15)	# fill _tmp38 to $r3 from $r15-72
	  stq		$r1, 0($r3)	# store with offset
	# _tmp39 = _tmp38 + 8
	  ldq		$r1, -72($r15)	# fill _tmp38 to $r1 from $r15-72
	  addq		$r1, 8, $r3	# perform the ALU op
	  stq		$r3, -80($r15)	# spill _tmp39 from $r3 to $r15-80
	# array = _tmp39
	  ldq		$r3, -80($r15)	# fill _tmp39 to $r3 from $r15-80
	  stq		$r3, -16($r15)	# spill array from $r3 to $r15-16
	# _tmp40 = 0
	  lda		$r3, 0		# load (signed) int constant value 0 into $r3
	  stq		$r3, -88($r15)	# spill _tmp40 from $r3 to $r15-88
	# _tmp41 = _tmp40 < ZERO
	  ldq		$r1, -88($r15)	# fill _tmp40 to $r1 from $r15-88
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -96($r15)	# spill _tmp41 from $r3 to $r15-96
	# _tmp42 = *(array + -8)
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -104($r15)	# spill _tmp42 from $r3 to $r15-104
	# _tmp43 = _tmp42 <= _tmp40
	  ldq		$r1, -104($r15)	# fill _tmp42 to $r1 from $r15-104
	  ldq		$r2, -88($r15)	# fill _tmp40 to $r2 from $r15-88
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -112($r15)	# spill _tmp43 from $r3 to $r15-112
	# _tmp44 = _tmp41 || _tmp43
	  ldq		$r1, -96($r15)	# fill _tmp41 to $r1 from $r15-96
	  ldq		$r2, -112($r15)	# fill _tmp43 to $r2 from $r15-112
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -120($r15)	# spill _tmp44 from $r3 to $r15-120
	# IfZ _tmp44 Goto __L13
	  ldq		$r1, -120($r15)	# fill _tmp44 to $r1 from $r15-120
	  blbc		$r1, __L13	# branch if _tmp44 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L13:
	# _tmp45 = _tmp40 << 3
	  ldq		$r1, -88($r15)	# fill _tmp40 to $r1 from $r15-88
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -128($r15)	# spill _tmp45 from $r3 to $r15-128
	# _tmp46 = array + _tmp45
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  ldq		$r2, -128($r15)	# fill _tmp45 to $r2 from $r15-128
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -136($r15)	# spill _tmp46 from $r3 to $r15-136
	# _tmp47 = 1
	  lda		$r3, 1		# load (signed) int constant value 1 into $r3
	  stq		$r3, -144($r15)	# spill _tmp47 from $r3 to $r15-144
	# *(_tmp46) = _tmp47
	  ldq		$r1, -144($r15)	# fill _tmp47 to $r1 from $r15-144
	  ldq		$r3, -136($r15)	# fill _tmp46 to $r3 from $r15-136
	  stq		$r1, 0($r3)	# store with offset
	# _tmp48 = 1
	  lda		$r3, 1		# load (signed) int constant value 1 into $r3
	  stq		$r3, -152($r15)	# spill _tmp48 from $r3 to $r15-152
	# _tmp49 = _tmp48 < ZERO
	  ldq		$r1, -152($r15)	# fill _tmp48 to $r1 from $r15-152
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -160($r15)	# spill _tmp49 from $r3 to $r15-160
	# _tmp50 = *(array + -8)
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -168($r15)	# spill _tmp50 from $r3 to $r15-168
	# _tmp51 = _tmp50 <= _tmp48
	  ldq		$r1, -168($r15)	# fill _tmp50 to $r1 from $r15-168
	  ldq		$r2, -152($r15)	# fill _tmp48 to $r2 from $r15-152
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -176($r15)	# spill _tmp51 from $r3 to $r15-176
	# _tmp52 = _tmp49 || _tmp51
	  ldq		$r1, -160($r15)	# fill _tmp49 to $r1 from $r15-160
	  ldq		$r2, -176($r15)	# fill _tmp51 to $r2 from $r15-176
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -184($r15)	# spill _tmp52 from $r3 to $r15-184
	# IfZ _tmp52 Goto __L14
	  ldq		$r1, -184($r15)	# fill _tmp52 to $r1 from $r15-184
	  blbc		$r1, __L14	# branch if _tmp52 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L14:
	# _tmp53 = _tmp48 << 3
	  ldq		$r1, -152($r15)	# fill _tmp48 to $r1 from $r15-152
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -192($r15)	# spill _tmp53 from $r3 to $r15-192
	# _tmp54 = array + _tmp53
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  ldq		$r2, -192($r15)	# fill _tmp53 to $r2 from $r15-192
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -200($r15)	# spill _tmp54 from $r3 to $r15-200
	# _tmp55 = 3
	  lda		$r3, 3		# load (signed) int constant value 3 into $r3
	  stq		$r3, -208($r15)	# spill _tmp55 from $r3 to $r15-208
	# *(_tmp54) = _tmp55
	  ldq		$r1, -208($r15)	# fill _tmp55 to $r1 from $r15-208
	  ldq		$r3, -200($r15)	# fill _tmp54 to $r3 from $r15-200
	  stq		$r1, 0($r3)	# store with offset
	# _tmp56 = 2
	  lda		$r3, 2		# load (signed) int constant value 2 into $r3
	  stq		$r3, -216($r15)	# spill _tmp56 from $r3 to $r15-216
	# _tmp57 = _tmp56 < ZERO
	  ldq		$r1, -216($r15)	# fill _tmp56 to $r1 from $r15-216
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -224($r15)	# spill _tmp57 from $r3 to $r15-224
	# _tmp58 = *(array + -8)
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -232($r15)	# spill _tmp58 from $r3 to $r15-232
	# _tmp59 = _tmp58 <= _tmp56
	  ldq		$r1, -232($r15)	# fill _tmp58 to $r1 from $r15-232
	  ldq		$r2, -216($r15)	# fill _tmp56 to $r2 from $r15-216
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -240($r15)	# spill _tmp59 from $r3 to $r15-240
	# _tmp60 = _tmp57 || _tmp59
	  ldq		$r1, -224($r15)	# fill _tmp57 to $r1 from $r15-224
	  ldq		$r2, -240($r15)	# fill _tmp59 to $r2 from $r15-240
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -248($r15)	# spill _tmp60 from $r3 to $r15-248
	# IfZ _tmp60 Goto __L15
	  ldq		$r1, -248($r15)	# fill _tmp60 to $r1 from $r15-248
	  blbc		$r1, __L15	# branch if _tmp60 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L15:
	# _tmp61 = _tmp56 << 3
	  ldq		$r1, -216($r15)	# fill _tmp56 to $r1 from $r15-216
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -256($r15)	# spill _tmp61 from $r3 to $r15-256
	# _tmp62 = array + _tmp61
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  ldq		$r2, -256($r15)	# fill _tmp61 to $r2 from $r15-256
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -264($r15)	# spill _tmp62 from $r3 to $r15-264
	# _tmp63 = 4
	  lda		$r3, 4		# load (signed) int constant value 4 into $r3
	  stq		$r3, -272($r15)	# spill _tmp63 from $r3 to $r15-272
	# *(_tmp62) = _tmp63
	  ldq		$r1, -272($r15)	# fill _tmp63 to $r1 from $r15-272
	  ldq		$r3, -264($r15)	# fill _tmp62 to $r3 from $r15-264
	  stq		$r1, 0($r3)	# store with offset
	# _tmp64 = 3
	  lda		$r3, 3		# load (signed) int constant value 3 into $r3
	  stq		$r3, -280($r15)	# spill _tmp64 from $r3 to $r15-280
	# _tmp65 = _tmp64 < ZERO
	  ldq		$r1, -280($r15)	# fill _tmp64 to $r1 from $r15-280
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -288($r15)	# spill _tmp65 from $r3 to $r15-288
	# _tmp66 = *(array + -8)
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -296($r15)	# spill _tmp66 from $r3 to $r15-296
	# _tmp67 = _tmp66 <= _tmp64
	  ldq		$r1, -296($r15)	# fill _tmp66 to $r1 from $r15-296
	  ldq		$r2, -280($r15)	# fill _tmp64 to $r2 from $r15-280
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -304($r15)	# spill _tmp67 from $r3 to $r15-304
	# _tmp68 = _tmp65 || _tmp67
	  ldq		$r1, -288($r15)	# fill _tmp65 to $r1 from $r15-288
	  ldq		$r2, -304($r15)	# fill _tmp67 to $r2 from $r15-304
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -312($r15)	# spill _tmp68 from $r3 to $r15-312
	# IfZ _tmp68 Goto __L16
	  ldq		$r1, -312($r15)	# fill _tmp68 to $r1 from $r15-312
	  blbc		$r1, __L16	# branch if _tmp68 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L16:
	# _tmp69 = _tmp64 << 3
	  ldq		$r1, -280($r15)	# fill _tmp64 to $r1 from $r15-280
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -320($r15)	# spill _tmp69 from $r3 to $r15-320
	# _tmp70 = array + _tmp69
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  ldq		$r2, -320($r15)	# fill _tmp69 to $r2 from $r15-320
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -328($r15)	# spill _tmp70 from $r3 to $r15-328
	# _tmp71 = 4
	  lda		$r3, 4		# load (signed) int constant value 4 into $r3
	  stq		$r3, -336($r15)	# spill _tmp71 from $r3 to $r15-336
	# *(_tmp70) = _tmp71
	  ldq		$r1, -336($r15)	# fill _tmp71 to $r1 from $r15-336
	  ldq		$r3, -328($r15)	# fill _tmp70 to $r3 from $r15-328
	  stq		$r1, 0($r3)	# store with offset
	# _tmp72 = 4
	  lda		$r3, 4		# load (signed) int constant value 4 into $r3
	  stq		$r3, -344($r15)	# spill _tmp72 from $r3 to $r15-344
	# _tmp73 = _tmp72 < ZERO
	  ldq		$r1, -344($r15)	# fill _tmp72 to $r1 from $r15-344
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -352($r15)	# spill _tmp73 from $r3 to $r15-352
	# _tmp74 = *(array + -8)
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -360($r15)	# spill _tmp74 from $r3 to $r15-360
	# _tmp75 = _tmp74 <= _tmp72
	  ldq		$r1, -360($r15)	# fill _tmp74 to $r1 from $r15-360
	  ldq		$r2, -344($r15)	# fill _tmp72 to $r2 from $r15-344
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -368($r15)	# spill _tmp75 from $r3 to $r15-368
	# _tmp76 = _tmp73 || _tmp75
	  ldq		$r1, -352($r15)	# fill _tmp73 to $r1 from $r15-352
	  ldq		$r2, -368($r15)	# fill _tmp75 to $r2 from $r15-368
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -376($r15)	# spill _tmp76 from $r3 to $r15-376
	# IfZ _tmp76 Goto __L17
	  ldq		$r1, -376($r15)	# fill _tmp76 to $r1 from $r15-376
	  blbc		$r1, __L17	# branch if _tmp76 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L17:
	# _tmp77 = _tmp72 << 3
	  ldq		$r1, -344($r15)	# fill _tmp72 to $r1 from $r15-344
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -384($r15)	# spill _tmp77 from $r3 to $r15-384
	# _tmp78 = array + _tmp77
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  ldq		$r2, -384($r15)	# fill _tmp77 to $r2 from $r15-384
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -392($r15)	# spill _tmp78 from $r3 to $r15-392
	# _tmp79 = 8
	  lda		$r3, 8		# load (signed) int constant value 8 into $r3
	  stq		$r3, -400($r15)	# spill _tmp79 from $r3 to $r15-400
	# *(_tmp78) = _tmp79
	  ldq		$r1, -400($r15)	# fill _tmp79 to $r1 from $r15-400
	  ldq		$r3, -392($r15)	# fill _tmp78 to $r3 from $r15-392
	  stq		$r1, 0($r3)	# store with offset
	# _tmp80 = 5
	  lda		$r3, 5		# load (signed) int constant value 5 into $r3
	  stq		$r3, -408($r15)	# spill _tmp80 from $r3 to $r15-408
	# _tmp81 = _tmp80 < ZERO
	  ldq		$r1, -408($r15)	# fill _tmp80 to $r1 from $r15-408
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -416($r15)	# spill _tmp81 from $r3 to $r15-416
	# _tmp82 = *(array + -8)
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -424($r15)	# spill _tmp82 from $r3 to $r15-424
	# _tmp83 = _tmp82 <= _tmp80
	  ldq		$r1, -424($r15)	# fill _tmp82 to $r1 from $r15-424
	  ldq		$r2, -408($r15)	# fill _tmp80 to $r2 from $r15-408
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -432($r15)	# spill _tmp83 from $r3 to $r15-432
	# _tmp84 = _tmp81 || _tmp83
	  ldq		$r1, -416($r15)	# fill _tmp81 to $r1 from $r15-416
	  ldq		$r2, -432($r15)	# fill _tmp83 to $r2 from $r15-432
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -440($r15)	# spill _tmp84 from $r3 to $r15-440
	# IfZ _tmp84 Goto __L18
	  ldq		$r1, -440($r15)	# fill _tmp84 to $r1 from $r15-440
	  blbc		$r1, __L18	# branch if _tmp84 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L18:
	# _tmp85 = _tmp80 << 3
	  ldq		$r1, -408($r15)	# fill _tmp80 to $r1 from $r15-408
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -448($r15)	# spill _tmp85 from $r3 to $r15-448
	# _tmp86 = array + _tmp85
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  ldq		$r2, -448($r15)	# fill _tmp85 to $r2 from $r15-448
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -456($r15)	# spill _tmp86 from $r3 to $r15-456
	# _tmp87 = 69
	  lda		$r3, 69		# load (signed) int constant value 69 into $r3
	  stq		$r3, -464($r15)	# spill _tmp87 from $r3 to $r15-464
	# *(_tmp86) = _tmp87
	  ldq		$r1, -464($r15)	# fill _tmp87 to $r1 from $r15-464
	  ldq		$r3, -456($r15)	# fill _tmp86 to $r3 from $r15-456
	  stq		$r1, 0($r3)	# store with offset
	# _tmp88 = 6
	  lda		$r3, 6		# load (signed) int constant value 6 into $r3
	  stq		$r3, -472($r15)	# spill _tmp88 from $r3 to $r15-472
	# _tmp89 = _tmp88 < ZERO
	  ldq		$r1, -472($r15)	# fill _tmp88 to $r1 from $r15-472
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -480($r15)	# spill _tmp89 from $r3 to $r15-480
	# _tmp90 = *(array + -8)
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -488($r15)	# spill _tmp90 from $r3 to $r15-488
	# _tmp91 = _tmp90 <= _tmp88
	  ldq		$r1, -488($r15)	# fill _tmp90 to $r1 from $r15-488
	  ldq		$r2, -472($r15)	# fill _tmp88 to $r2 from $r15-472
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -496($r15)	# spill _tmp91 from $r3 to $r15-496
	# _tmp92 = _tmp89 || _tmp91
	  ldq		$r1, -480($r15)	# fill _tmp89 to $r1 from $r15-480
	  ldq		$r2, -496($r15)	# fill _tmp91 to $r2 from $r15-496
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -504($r15)	# spill _tmp92 from $r3 to $r15-504
	# IfZ _tmp92 Goto __L19
	  ldq		$r1, -504($r15)	# fill _tmp92 to $r1 from $r15-504
	  blbc		$r1, __L19	# branch if _tmp92 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L19:
	# _tmp93 = _tmp88 << 3
	  ldq		$r1, -472($r15)	# fill _tmp88 to $r1 from $r15-472
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -512($r15)	# spill _tmp93 from $r3 to $r15-512
	# _tmp94 = array + _tmp93
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  ldq		$r2, -512($r15)	# fill _tmp93 to $r2 from $r15-512
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -520($r15)	# spill _tmp94 from $r3 to $r15-520
	# _tmp95 = 69
	  lda		$r3, 69		# load (signed) int constant value 69 into $r3
	  stq		$r3, -528($r15)	# spill _tmp95 from $r3 to $r15-528
	# *(_tmp94) = _tmp95
	  ldq		$r1, -528($r15)	# fill _tmp95 to $r1 from $r15-528
	  ldq		$r3, -520($r15)	# fill _tmp94 to $r3 from $r15-520
	  stq		$r1, 0($r3)	# store with offset
	# _tmp96 = 7
	  lda		$r3, 7		# load (signed) int constant value 7 into $r3
	  stq		$r3, -536($r15)	# spill _tmp96 from $r3 to $r15-536
	# _tmp97 = _tmp96 < ZERO
	  ldq		$r1, -536($r15)	# fill _tmp96 to $r1 from $r15-536
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -544($r15)	# spill _tmp97 from $r3 to $r15-544
	# _tmp98 = *(array + -8)
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -552($r15)	# spill _tmp98 from $r3 to $r15-552
	# _tmp99 = _tmp98 <= _tmp96
	  ldq		$r1, -552($r15)	# fill _tmp98 to $r1 from $r15-552
	  ldq		$r2, -536($r15)	# fill _tmp96 to $r2 from $r15-536
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -560($r15)	# spill _tmp99 from $r3 to $r15-560
	# _tmp100 = _tmp97 || _tmp99
	  ldq		$r1, -544($r15)	# fill _tmp97 to $r1 from $r15-544
	  ldq		$r2, -560($r15)	# fill _tmp99 to $r2 from $r15-560
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -568($r15)	# spill _tmp100 from $r3 to $r15-568
	# IfZ _tmp100 Goto __L20
	  ldq		$r1, -568($r15)	# fill _tmp100 to $r1 from $r15-568
	  blbc		$r1, __L20	# branch if _tmp100 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L20:
	# _tmp101 = _tmp96 << 3
	  ldq		$r1, -536($r15)	# fill _tmp96 to $r1 from $r15-536
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -576($r15)	# spill _tmp101 from $r3 to $r15-576
	# _tmp102 = array + _tmp101
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  ldq		$r2, -576($r15)	# fill _tmp101 to $r2 from $r15-576
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -584($r15)	# spill _tmp102 from $r3 to $r15-584
	# _tmp103 = 69
	  lda		$r3, 69		# load (signed) int constant value 69 into $r3
	  stq		$r3, -592($r15)	# spill _tmp103 from $r3 to $r15-592
	# *(_tmp102) = _tmp103
	  ldq		$r1, -592($r15)	# fill _tmp103 to $r1 from $r15-592
	  ldq		$r3, -584($r15)	# fill _tmp102 to $r3 from $r15-584
	  stq		$r1, 0($r3)	# store with offset
	# _tmp104 = 0
	  lda		$r3, 0		# load (signed) int constant value 0 into $r3
	  stq		$r3, -600($r15)	# spill _tmp104 from $r3 to $r15-600
	# i = _tmp104
	  ldq		$r3, -600($r15)	# fill _tmp104 to $r3 from $r15-600
	  stq		$r3, -24($r15)	# spill i from $r3 to $r15-24
__L21:
	# _tmp105 = i < size
	  ldq		$r1, -24($r15)	# fill i to $r1 from $r15-24
	  ldq		$r2, -32($r15)	# fill size to $r2 from $r15-32
	  cmplt		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -608($r15)	# spill _tmp105 from $r3 to $r15-608
	# IfZ _tmp105 Goto __L22
	  ldq		$r1, -608($r15)	# fill _tmp105 to $r1 from $r15-608
	  blbc		$r1, __L22	# branch if _tmp105 is zero
	# _tmp106 = i < ZERO
	  ldq		$r1, -24($r15)	# fill i to $r1 from $r15-24
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -616($r15)	# spill _tmp106 from $r3 to $r15-616
	# _tmp107 = *(array + -8)
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -624($r15)	# spill _tmp107 from $r3 to $r15-624
	# _tmp108 = _tmp107 <= i
	  ldq		$r1, -624($r15)	# fill _tmp107 to $r1 from $r15-624
	  ldq		$r2, -24($r15)	# fill i to $r2 from $r15-24
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -632($r15)	# spill _tmp108 from $r3 to $r15-632
	# _tmp109 = _tmp106 || _tmp108
	  ldq		$r1, -616($r15)	# fill _tmp106 to $r1 from $r15-616
	  ldq		$r2, -632($r15)	# fill _tmp108 to $r2 from $r15-632
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -640($r15)	# spill _tmp109 from $r3 to $r15-640
	# IfZ _tmp109 Goto __L23
	  ldq		$r1, -640($r15)	# fill _tmp109 to $r1 from $r15-640
	  blbc		$r1, __L23	# branch if _tmp109 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L23:
	# _tmp110 = i << 3
	  ldq		$r1, -24($r15)	# fill i to $r1 from $r15-24
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -648($r15)	# spill _tmp110 from $r3 to $r15-648
	# _tmp111 = array + _tmp110
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  ldq		$r2, -648($r15)	# fill _tmp110 to $r2 from $r15-648
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -656($r15)	# spill _tmp111 from $r3 to $r15-656
	# _tmp112 = *(_tmp111)
	  ldq		$r1, -656($r15)	# fill _tmp111 to $r1 from $r15-656
	  ldq		$r3, 0($r1)	# load with offset
	  stq		$r3, -664($r15)	# spill _tmp112 from $r3 to $r15-664
	# _tmp113 = 0
	  lda		$r3, 0		# load (signed) int constant value 0 into $r3
	  stq		$r3, -672($r15)	# spill _tmp113 from $r3 to $r15-672
	# _tmp114 = 1
	  lda		$r3, 1		# load (signed) int constant value 1 into $r3
	  stq		$r3, -680($r15)	# spill _tmp114 from $r3 to $r15-680
	# _tmp115 = size - _tmp114
	  ldq		$r1, -32($r15)	# fill size to $r1 from $r15-32
	  ldq		$r2, -680($r15)	# fill _tmp114 to $r2 from $r15-680
	  subq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -688($r15)	# spill _tmp115 from $r3 to $r15-688
	# PushParam _tmp115
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -688($r15)	# fill _tmp115 to $r1 from $r15-688
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam _tmp113
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -672($r15)	# fill _tmp113 to $r1 from $r15-672
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam array
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam _tmp112
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -664($r15)	# fill _tmp112 to $r1 from $r15-664
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp116 = LCall _search_for
	  bsr		$r26, _search_for	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -696($r15)	# spill _tmp116 from $r3 to $r15-696
	# PopParams 32
	  addq		$r30, 32, $r30	# pop params off stack
	# found = _tmp116
	  ldq		$r3, -696($r15)	# fill _tmp116 to $r3 from $r15-696
	  stq		$r3, -40($r15)	# spill found from $r3 to $r15-40
	# i += 1
	  ldq		$r3, -24($r15)	# fill i to $r3 from $r15-24
	  addq		$r3, 1, $r3	# perform the ALU op
	  stq		$r3, -24($r15)	# spill i from $r3 to $r15-24
	# Goto __L21
	  br		__L21		# unconditional branch
__L22:
	# _tmp117 = *(array + -8)
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -704($r15)	# spill _tmp117 from $r3 to $r15-704
	# _tmp117 += 1
	  ldq		$r3, -704($r15)	# fill _tmp117 to $r3 from $r15-704
	  addq		$r3, 1, $r3	# perform the ALU op
	  stq		$r3, -704($r15)	# spill _tmp117 from $r3 to $r15-704
	# _tmp118 = array - 8
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  subq		$r1, 8, $r3	# perform the ALU op
	  stq		$r3, -712($r15)	# spill _tmp118 from $r3 to $r15-712
	# PushParam _tmp118
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -712($r15)	# fill _tmp118 to $r1 from $r15-712
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam _tmp117
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -704($r15)	# fill _tmp117 to $r1 from $r15-704
	  stq		$r1, 8($r30)	# copy param value to stack
	# LCall __Free
	  bsr		$r26, __Free	# branch to function
	# PopParams 16
	  addq		$r30, 16, $r30	# pop params off stack
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
	# EndProgram
	#
	# (below is reserved for auto-appending of built-in functions)
	#
__Alloc:
	  ldq		$r16, 8($r30)	# fill arg0 to $r16 from $r30+8
	#
	# $r28 holds addr of heap-start
	# $r16 is the number of lines we want
	# $r1 holds the number of lines remaining to be allocated
	# $r2 holds the curent heap-table-entry
	# $r3 holds temp results of various comparisons
	# $r4 is used to generate various bit-masks
	# $r24 holds the current starting "bit-addr" in the heap-table
	# $r25 holds the bit-pos within the current heap-table-entry
	# $r27 holds the addr of the current heap-table-entry
	#
	  lda		$r4, 0x100
	  subq		$r28, $r4, $r27	# make addr of heap-table start
    __AllocFullReset:
	  mov		$r16, $r1	# reset goal amount
	  sll		$r27, 3, $r24	# reset bit-addr into heap-table
	  clr		$r25		# clear bit-pos marker
    __AllocSearchStart:
	  cmpult	$r27, $r28, $r3	# check if pass end of heap-table
	  blbc		$r3, __AllocReturnFail
	  ldq		$r2, 0($r27)	# dereference, to get current heap-table entry
	  cmpult	$r1, 64, $r3	# less than a page to allocate?
	  blbs		$r3, __AllocSearchStartLittle
	  blt		$r2, __AllocSearchStartSetup	# MSB set?
	  lda		$r4, -1		# for next code-block
    __AllocSearchStartShift:
	  and		$r2, $r4, $r3
	  beq		$r3, __AllocSearchStartDone
	  sll		$r4, 1, $r4
	  addq		$r24, 1, $r24
	  and		$r24, 63, $r25
	  bne		$r25, __AllocSearchStartShift
    __AllocSearchStartSetup:
	  srl		$r24, 6, $r27
	  sll		$r27, 3, $r27
	  br		__AllocSearchStart	# unconditional branch
    __AllocSearchStartLittle:
	  lda		$r4, 1
	  sll		$r4, $r1, $r4
	  subq		$r4, 1, $r4
	  br		__AllocSearchStartShift	# unconditional branch
    __AllocSearchStartDone:
	  subq		$r1, 64, $r1
	  addq		$r1, $r25, $r1
	  bgt		$r1, __AllocNotSimple
    __AllocSimpleCommit:
	  bis		$r2, $r4, $r2
	  stq		$r2, 0($r27)
	  br		__AllocReturnGood	# unconditional branch
    __AllocNotSimple:
	  srl		$r24, 6, $r27
	  sll		$r27, 3, $r27
    __AllocSearchBlock:
	  cmpult	$r1, 64, $r3
	  blbs		$r3, __AllocSearchEnd
	  addq		$r27, 8, $r27	# next heap-table entry
	  cmpult	$r27, $r28, $r3	# check if pass end of heap-table
	  blbc		$r3, __AllocReturnFail
	  ldq		$r2, 0($r27)	# dereference, to get current heap-table entry
	  bne		$r2, __AllocFullReset
	  subq		$r1, 64, $r1
	  br		__AllocSearchBlock	# unconditional branch
    __AllocSearchEnd:
	  beq		$r1,__AllocCommitStart
	  addq		$r27, 8, $r27	# next heap-table entry
	  cmpult	$r27, $r28, $r3	# check if pass end of heap-table
	  blbc		$r3, __AllocReturnFail
	  ldq		$r2, 0($r27)	# dereference, to get current heap-table entry
	  lda		$r4, 1
	  sll		$r4, $r1, $r4
	  subq		$r4, 1, $r4
	  and		$r2, $r4, $r3
	  bne		$r3, __AllocFullReset
    __AllocCommitEnd:
	  bis		$r2, $r4, $r2
	  stq		$r2, 0($r27)
	  subq		$r16, $r1, $r16
    __AllocCommitStart:
	  srl		$r24, 6, $r27
	  sll		$r27, 3, $r27
	  ldq		$r2, 0($r27)
	  lda		$r4, -1
	  sll		$r4, $r25, $r4
	  bis		$r2, $r4, $r2
	  stq		$r2, 0($r27)
	  subq		$r16, 64, $r16
	  addq		$r16, $r25, $r16
	  lda		$r4, -1		# for next code-block
    __AllocCommitBlock:
	  cmpult	$r16, 64, $r3
	  blbs		$r3, __AllocReturnCheck
	  addq		$r27, 8, $r27	# next heap-table entry
	  stq		$r4, 0($r27)	# set all bits in that entry
	  subq		$r16, 64, $r16
	  br		__AllocCommitBlock	# unconditional branch
    __AllocReturnCheck:
	  beq		$r16, __AllocReturnGood	# verify we are done
	  call_pal	0xDECAF		# (exception: this really should not happen in Malloc)
	  call_pal	0x555		# (halt)
    __AllocReturnGood:
	# magically compute address for return value
	  lda		$r0, 0x2F
	  sll		$r0, 13, $r0
	  subq		$r24, $r0, $r0
	  sll		$r0, 3, $r0
	  ret				# return to caller
    __AllocReturnFail:
	  call_pal	0xDECAF		# (exception: Malloc failed to find space in heap)
	  call_pal	0x555		# (halt)
	# EndFunc
__Free:
	  ldq		$r16, 8($r30)	# fill arg0 to $r16 from $r30+8
	  ldq		$r17, 16($r30)	# fill arg1 to $r17 from $r30+16
	  cmpult	$r17, $r28, $r3
	  blbc		$r3, __FreeCheck1Pass
	  call_pal	0xDECAF		# (exception: addr passed to Free is pass end of heap (and out-of-bounds memory access))
	  call_pal	0x555		# (halt)
    __FreeCheck1Pass:
	  srl		$r17, 3, $r24
	  lda		$r4, 0x2F
	  sll		$r4, 13, $r4
	  addq		$r24, $r4, $r24
	  srl		$r24, 6, $r27
	  sll		$r27, 3, $r27
	  and		$r24, 63, $r25
	  beq		$r25, __FreeBlock
	  cmpult	$r27, $r28, $r3	# check if pass end of heap-table
	  blbs		$r3, __FreeCheck2Pass
	  call_pal	0xDECAF		# (exception: passed end of heap-table in Free)
	  call_pal	0x555		# (halt)
    __FreeCheck2Pass:
	  ldq		$r2, 0($r27)
	  addq		$r16, $r25, $r4	# compute ending bit-pos + 1
	  cmpult	$r4, 64, $r3
	  blbs		$r3, __FreeLittle
	  lda		$r4, 1
	  sll		$r4, $r25, $r4
	  subq		$r4, 1, $r4
	  and		$r2, $r4, $r2
	  stq		$r2, 0($r27)
	  subq		$r16, 64, $r16
	  addq		$r16, $r25, $r16
	  addq		$r27, 8, $r27	# next heap-table entry
	  br		__FreeBlock	# unconditional branch
    __FreeLittle:
	  lda		$r4, 1
	  sll		$r4, $r16, $r4
	  subq		$r4, 1, $r4
	  sll		$r4, $r25, $r4
	  bic		$r2, $r4, $r2
	  stq		$r2, 0($r27)
	  ret				# return to caller
    __FreeBlock:
	  cmpult	$r16, 64, $r3	# less than a page remaining?
	  blbs		$r3, __FreeEnd
	  addq		$r27, 8, $r27	# next heap-table entry
	  cmpult	$r27, $r28, $r3	# check if pass end of heap-table
	  blbs		$r3, __FreeCheck3Pass
	  call_pal	0xDECAF		# (exception: passed end of heap-table in Free)
	  call_pal	0x555		# (halt)
    __FreeCheck3Pass:
	  stq		$r31, 0($r27)
	  subq		$r16, 64, $r16
	  br		__FreeBlock	# unconditional branch
    __FreeEnd:
	  beq		$r16, __FreeDone
	  cmpult	$r27, $r28, $r3
	  blbs		$r3, __FreeCheck4Pass
	  call_pal	0xDECAF		# (exception: passed end of heap-table in Free)
	  call_pal	0x555		# (halt)
    __FreeCheck4Pass:
	  ldq		$r2, 0($r27)
	  lda		$r4, 1
	  sll		$r4, $r16, $r4
	  subq	$r4, 1, $r4
	  bic		$r2, $r4, $r2
	  stq		$r2, 0($r27)
    __FreeDone:
	  ret				# return to caller
	# EndFunc
