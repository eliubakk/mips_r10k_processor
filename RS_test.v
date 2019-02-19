module testbench;
	logic clock, reset, enable, CAM_in;
	logic  DECODED_INST	inst_in,
	logic  FU_IDX		fu_idx,
	logic  PHYS_REG 	dest_tag_in,
	logic  PHYS_REG 	tag1_in,
	logic  PHYS_REG 	tag2_in,


	logic OPCODE   	inst_out,
	logic PHYS_REG 	dest_tag_out,
	logic PHYS_REG 	tag1_out,
	logic PHYS_REG 	tag2_out,
	logic		issue,
	logic [(`NUM_FU -1):0]	fu_busy_out,
	
	RS RS0(.clock(clock), .reset(reset), .enable(enable), .CAM_in(CAM_in), .inst_in(inst_in), .fu_idx(fu_idx), .dest_tag_in(dest_tag_in), tag1_in(tag1_in), tag2_in(tag2_in), 
		.inst_out(inst_out), .dest_tag_out(dest_tag_out), .tag1_out(tag1_out), .tag2_out(tag2_out), .issue(issue), .fu_busy_out(fu_busy_out) );

	
	always #5 clock = ~clock;

	// need to update this

	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask
	
	initial begin
		

		$monitor("Clock: %4.0f, reset: $b, enable:%b, CAM_in:%b, dest_tag_in:%h, tag1_in:%h, tag2_in:%h, opcode_in:%h, opcode_out:%h, dest_tag_out:%h, tag1_out:%h, tag2_out:%h, fu_busy_out:%b", clock, reset, enable, CAM_in, dest_tag_in, tag1_in, tag2_in, opcode_in, opcode_out, dest_tag_out, tag1_out, tag2_out, fu_busy_out);	

	
		clock = 0;
		reset = 0;
		enable = 0;
		CAM_in = 0;		// CAM_in is used for retire
		inst_in = ;
		fu_idx = ;
		dest_tag_in = 0;	// destination reg, comes from the Free list
		tag1_in	= 0;		// Source operand, comes from map table
		tag2_in = 0;		// Source operand, comes from map table.


	// -------Testing for scalar pipeline-------
	
	// Test for reset
	$display("-------RESET------\n");
	@(negedge clock);
	reset = 1;
	@(negedge clock);
	reset = 0;	

	// Test for Dispatch
	

	enable = 1;
	CAM_in = 0;
	inst_in = ;
	fu_idx = ;
	dest_tag_in = ;
	tag1_in = ;
	tag2_in = ;
	
	@(negedge clock);

	// Test for Issue
	// How can we test whether it is issued?

	// Test for Execute	
	// How can we test whether the RS is cleared?

	// Test for Commit


	enable = 1;
	CAM_in = 1;
	inst_in = ;
	fu_idx = ;
	dest_tag_in = ;
	tag1_in = ;
	tag2_in = ;
	
	
	@(negedge clock);

	// Test for Retire
	// '
	

	// Test for enable
	$display("-------Enable------\n");
	

	

	// Test for simple pipeline


	// Test for complicated pipeline 

	
	// -------Testing for 3 way super-scalar pipeline-------
	//
	// May have to check the dependency


		
		/***RESET***/
		$display("-----RESET-----\n");		
		@(negedge clock)
		reset = 1;
		@(negedge clock)
		reset = 0;		

		/***CHECK THAT ALL ELEMENTS ARE INVALID***/
		$display("-----Check that all elements are invalid------\n");	
		@(negedge clock);
		assert(!hit) else #1 exit_on_error;
		
		/***INITIALIZE MEMORY****/
		$display("-----Initialize memory-----\n");
		command = WRITE;
		enable = 1;
		for(int i=0; i<`TEST_SIZE;i=i+1) begin
			write_idx = i;
			data = $random;
			@(negedge clock);
		end
		
		/***OVERWRITE***/
		$display("-----Overwrite-----\n");
		for(int i=0; i<(2**$clog2(`TEST_SIZE)); i=i+1) begin
			write_idx = i;
			data = i;
			@(negedge clock);
		end
		
		/***READ VALUES***/
		$display("-----Read values-----\n");
		command = READ;
		for(int i=0; i<`TEST_SIZE; i++) begin
			data = i;
			@(negedge clock);
			assert(hit && read_idx == i) else exit_on_error;
		end
		
		/***CHECK SIZE***/
		$display("-----Check Size-----\n");
		data = `TEST_SIZE;
		@(negedge clock);
		assert(!hit) else #1 exit_on_error;
		
		/***TEST WITH MULTIPLE COPIES OF VALUE***/
		$display("-----Test with multiple copies of value-----\n");
		command = WRITE;
		data = $random;
		write_idx = 0;
		@(negedge clock);
		repeat(5) begin
			write_idx = $random;
			@(negedge clock);
		end
		
		command = READ;
		@(negedge clock);
		assert(read_idx == 0) else exit_on_error;
		
		
		$display("@@@Passed");
		$finish;
		
	end
	
endmodule
