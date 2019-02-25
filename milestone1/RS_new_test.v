`include "sys_defs.vh"
`define DEBUG

module testbench;
	logic clock, reset, enable;
	logic    		CAM_en;
	PHYS_REG 		CDB_in;
	logic			dispatch_valid;
	RS_ROW_T		inst_in;
	logic	 [1:0]		LSQ_busy;
	

	RS_ROW_T   		rs_table_out [(`RS_SIZE - 1):0] ;
	RS_ROW_T 		issue_next   [(`NUM_FU -1 ):0]; 
	logic				rs_full;


	
	RS RS0(.clock(clock), .reset(reset), .enable(enable), .CAM_en(CAM_en), .CDB_in(CDB_in), .dispatch_valid(dispatch_valid),.inst_in(inst_in), .LSQ_busy(LSQ_busy),
	.rs_table_out(rs_table_out), .issue_next(issue_next),  .rs_full(rs_full)
	 );

	
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
		
	/*	$monitor("Clock: %4.0f, reset: $b, enable:%b, CAM_en:%b, CDB_in:%h, .dispatch_valid:%b, inst_in:%h, LSQ_busy : %b, \n rs_table_out:%h", clock, reset, enable, CAM_en, CDB_in,dispatch_valid, inst_in, LSQ_busy, rs_table_out);	
 	*/
		$monitor("Clock: %4.0f, reset: %b, enable:%b, ", clock, reset, enable);	

		// Initial value
		clock = 0;
		reset = 0;
		enable = 0;
		CAM_en = 0;
		CDB_in = 0;
		dispatch_valid = 0;
		
		inst_in.inst.opa_select = ALU_OPA_IS_REGA;
		inst_in.inst.opb_select = ALU_OPB_IS_REGB;
		inst_in.inst.dest_reg = DEST_IS_REGC;
		inst_in.inst.alu_func = ALU_ADDQ;
		inst_in.inst.fu_name = FU_ALU;
		inst_in.inst.rd_mem = 1'b0;
		inst_in.inst.wr_mem = 1'b0;
		inst_in.inst.ldl_mem = 1'b0;
		inst_in.inst.stc_mem = 1'b0;
		inst_in.inst.cond_branch = 1'b0;
		inst_in.inst.uncond_branch = 1'b0;
		inst_in.inst.halt = 1'b0;
		inst_in.inst.cpuid = 1'b0;
		inst_in.inst.illegal = 1'b0;
		inst_in.inst.valid_inst = 1'b0;
		inst_in.T = `DUMMY_REG;
		inst_in.T1 = `DUMMY_REG;
		inst_in.T2 = `DUMMY_REG;
		inst_in.busy = 1'b0;

		LSQ_busy = 0;	
	
	///Things to do
	//For 1-way superscalar, multiple issue
	//1. Makefile and testbench : make it for synthesizable (for ex,
	//define DEBUG only for testing)
	//2. How can we printout, see, and compare the rs_table values? (It is
	//kind of 2 dimensional matrix structure)
	//3. Testing for functionality (enable, reset, dispatch_valid,
	//LSQ_busy, CAM_en, commit, issue, dispatch) and corner cases (Issue 2 branches at
	//a same cycle?, input is invalid instruction, etc...)    


	@(negedge clock);	
		$display("@@@Passed");
		$finish;

		/*inst_in = ;
		fu_idx = ;
		dest_tag_in = 0;	// destination reg, comes from the Free list
		tag1_in	= 0;		// Source operand, comes from map table
		tag2_in = 0;		// Source operand, comes from map table.
		*/

	// 1. Things to do : Change the source tag for 2 instruction pipeline
	// 2. Struct the input and output of the testcases
	// 3. Dispatch multiple instructions at one cycle, send CDB valid for
	// multiple instructions at the same time


	// -------------Test for reset
/*	$display("-------RESET------\n");
	reset = 0;
	enable = 1;
	CAM_in = 0;
	CDB_in = 7'd31;
	inst_in =` {ALU_OPA_IS_REGA, ALU_OPB_IS_REGB, DEST_IS_REGC, ALU_ADDQ, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}; 
	fu_idx = FU_ALU1_IDX;  
	dest_tag_in = 7'h3; 
	tag1_in = 7'h1;
	tag2_in = 7'h2;

	@(negedge clock);
	// Nothing issued since it is reset
	reset = 1;
	assert(!issue && (fu_busy_out=={(`NUM_FU){0}}) ) else #1 exit_on_error;
	
	@(negedge clock);
	reset = 0;
	//RS is empty since it is reset
	assert(!issue && (fu_busy_out=={(`NUM_FU){0}}) ) else #1 exit_on_error;
*/

	// -------------------------------------------------------------------------------------------------------------------------------

	// -------Testing for scalar pipeline-------
	
	//---------------------------------------------------------------------------------------------------------------------------------
	// Simple test for two instruction flow (ADD r1 r2 r3, ADD r3 r4 r5)
		// Dispatch - Execute - Commit - Retire
	/*	@(negedge clock);
		$display("-----Simple test for one instruction-----\n");

		//---------Dispatch ADD r1 r2 r3-------------------
		enable = 1; //Q1. enable only when write / read RS
		CAM_in = 0;
		inst_in =` {ALU_OPA_IS_REGA, ALU_OPB_IS_REGB, DEST_IS_REGC, ALU_ADDQ, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}; // ADD without hazard detection
		fu_idx = FU_ALU1_IDX;  //Q2.  What is ALU1, ALU2, ALU3? 
		dest_tag_in = 7'h3; // 
		tag1_in = 7'h41;
		tag2_in = 7'h42;

	
		@(negedge clock);
		// Output not issued yet
		assert((!issue) && (fu_busy_out=={{(`NUM_FU-1){0}},1})) else #1 exit_on_error;

*/

		//--------- Issue ADD r1 r2 r3, Dispatch ADD r3 r4 r5-----
/*		enable = 1; //Q1. enable only when write / read RS
		CAM_in = 0;
		inst_in =` {ALU_OPA_IS_REGA, ALU_OPB_IS_REGB, DEST_IS_REGC, ALU_ADDQ, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}; // ADD without hazard detection
		fu_idx = FU_ALU1_IDX;  // Q2. What is ALU1, ALU2, ALU3? 
		dest_tag_in = 7'h5; // 
		tag1_in = 7'h3;
		tag2_in = 7'h44;


		@(negedge clock);
		// ADD r1 r2 r3 issued
		assert( (issue) && (fu_busy_out=={{(`NUM_FU-2){0}},2'b11}) && (dest_tag_out == 7'h3) && (tag1_out == 7'h41) && (tag2_out == 7'h42) && (inst_out == `{ALU_OPA_IS_REGA, ALU_OPB_IS_REGB, DEST_IS_REGC, ALU_ADDQ, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}) ) else #1 exit_on_error; 
	
*/

		//------ Execute ADD r1 r2 r3, 	Add r3 r4 r5 should not be
		//issued due to RAW hazard
/*
		enable = 0;

		@(negedge clock);
		// Add r3 r4 r5 is not issued yet
		assert(!issue && (fu_busy_out=={{(`NUM_FU-2){0}},2'b10}) ) else #1 exit_on_error;
		
		//--------- Commit ADD r1 r2 r3, Add r3 r4 r5 issued

		enable = 1;
		CAM_in = 1;
		CDB_in = 7'h3;
		tag1_in = 7'h41; // Q3. I guess that when CAM_in=1, it is for broadcasting
		tag2_in = 7'h42;
	
		@(negedge clock);
		// ADD r3 r4 r5 issued
		assert( (issue) && (fu_busy_out=={{(`NUM_FU-2){0}},2'b10})  && (dest_tag_out == 7'h5) && (tag1_out == 7'h43) && (tag2_out == 7'h44) && (inst_out == `{ALU_OPA_IS_REGA, ALU_OPB_IS_REGB, DEST_IS_REGC, ALU_ADDQ, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}) ) else #1 exit_on_error; 


		//---------Retire ADD r1 r2 r3, Add r3 r4 r5 executed

		enable = 0;
		@(negedge clock);
		assert(!issue && (fu_busy_out=={(`NUM_FU){0}}) ) else #1 exit_on_error;

		//--------Commit Add r3 r4 r5
		enable = 1;
		CAM_in = 1;
		CDB_in = 7'h5;
		tag1_in = 7'h43;
		tag2_in = 7'h44;
		
		@(negedge clock);
		assert(!issue && (fu_busy_out=={(`NUM_FU){0}}) ) else #1 exit_on_error;
*/

	// ---------------------------------------------------------------------------------------------------------------------
	// Test when fu_busy_out : included in the simple pipeline case
	/*	@(negedge clock);
		$display("----------Test for fu_busy_out---------\n");

		// -------ALU busy
		// -------LD busy
		// -------ST busy
		// -------MULT busy
        */

	// Test for simple pipeline
/*		@(negedge clock);
		$display("----------Test for simple pipeline in lecture ppt-------\n");

		//-------- Cycle 1, Dispatch LD(I1)
		enable = 1; //enable only when write / read RS
		CAM_in = 0;
		CDB_in = 7'd31;
		inst_in = ` {ALU_OPA_IS_MEM_DISP, ALU_OPB_IS_REGB, DEST_IS_REGA, ALU_ADDQ,
	        	   1, 0, 1, 0, 0, 0, 0, 0, 0, 1}; // structure of Decoded instruction
		fu_idx = FU_LD_IDX;  // What is ALU1, ALU2, ALU3? 
		dest_tag_in = 7'h5; // 
		tag1_in = 7'd31;//empty
		tag2_in = 7'h44;
	   
		@(negedge clock);
		// Output not issued yet
		assert((!issue) && (fu_busy_out=={3'b001,{(`NUM_FU-3){0}}})) else #1 exit_on_error;


		//-------- Cycle 2, Dispatch MULT(I2), Issue LD(I1)
		enable = 1; //
		CAM_in = 0;
		inst_in =` {ALU_OPA_IS_REGA, ALU_OPB_IS_REGB, DEST_IS_REGC, ALU_MULTQ, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}; // For mult
		fu_idx = FU_MULT_IDX;  //
		dest_tag_in = 7'h6; //
		tag1_in = 7'h41;
		tag2_in = 7'h5;


		@(negedge clock);
		// LD(I1) issued
		assert( (issue) && (fu_busy_out=={3'b101,{(`NUM_FU-3){0}}}) && (dest_tag_out == 7'h5) && (tag1_out == 7'h31) && (tag2_out == 7'h44) && (inst_out == `{ALU_OPA_IS_MEM_DISP, ALU_OPB_IS_REGB, DEST_IS_REGA, ALU_ADDQ, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1}) ) else #1 exit_on_error; 


	
		//-------- Cycle 3, dispatch STORE(I3), execute LD(I1), 
		enable = 1; //
		CAM_in = 0;
		inst_in =` {ALU_OPA_IS_MEM_DISP, ALU_OPB_IS_REGB, DEST_IS_REGA, ALU_ADDQ, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1}; // for store
		fu_idx = FU_ST_IDX;  //
		dest_tag_in = 7'd31; // No destination register
		tag1_in = 7'h6;      // 
		tag2_in = 7'h44;


		@(negedge clock);
		// No issue, executing LD(I1) -> I1 is removed from RS
		assert( (!issue) && (fu_busy_out=={3'b110,{(`NUM_FU-3){0}})  ) else #1 exit_on_error; 

		//-------- Cycle 4, dispatch ADD(I4), issue MULT(I2), commit  LD(I1)
		enable = 1; //
		CAM_in = 1;
		CDB_in = 7'h5;
		inst_in =` {ALU_OPA_IS_REGA, ALU_OPB_IS_ALU_IMM, DEST_IS_REGC, ALU_ADDQ, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}; // for add
		fu_idx = FU__ALU1_IDX;  //
		dest_tag_in = 7'h7; // No destination register
		tag1_in = 7'h44;      // 
		tag2_in = 7'd31;      // No tag, since it is immediate


		@(negedge clock);
		// Issue mult(I2), No execution
		assert( (!issue) && (fu_busy_out=={3'b110,{(`NUM_FU-2){0}}, 1'b1}) && (dest_tag_out == 7'h6) && (tag1_out == 7'h41) && (tag2_out == 7'h45) && (inst_out == `{ALU_OPA_IS_REGA, ALU_OPB_IS_REGB, DEST_IS_REGC, ALU_MULTQ, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}) ) else #1 exit_on_error; 



		//-------- Cycle 5, dispatch LD(I5), issue ADD(I4), execute
		//mult(I2)
		//
		enable = 1; //
		CAM_in = 0;
		CDB_in = 7'd31;
		inst_in = ` {ALU_OPA_IS_MEM_DISP, ALU_OPB_IS_REGB, DEST_IS_REGA, ALU_ADDQ,
	        	   1, 0, 1, 0, 0, 0, 0, 0, 0, 1}; 
		fu_idx = FU_LD_IDX; 

		dest_tag_in = 7'h8; // No destination register
		tag1_in = 7'd31;      // 
		tag2_in = 7'h7;      // No tag, since it is immediate


		@(negedge clock);
		// Issue ADD(I4), execute mult(I2)
		assert( (issue) && (fu_busy_out=={3'b010,{(`NUM_FU-2){0}}, 1'b1}) && (dest_tag_out == 7'h7) && (tag1_out == 7'h44) && (tag2_out == 7'd31) && (inst_out == `{ALU_OPA_IS_REGA, ALU_OPB_IS_ALU_IMM, DEST_IS_REGC, ALU_ADDQ, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}) ) else #1 exit_on_error; 



		//MULT(I2), retire LD(I1)

		

	// Test for complicated pipeline
	

	// Test for corner cases 
	


	
	// -------Testing for 3 way super-scalar pipeline-------
	//
	// May have to check the dependency
*/
		
	end
	
endmodule
