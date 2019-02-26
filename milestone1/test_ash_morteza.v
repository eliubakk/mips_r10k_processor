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
	logic [$clog2(`NUM_FU) - 1:0]	issue_cnt;
	RS_ROW_T   		rs_table_test [(`RS_SIZE - 1):0] ;
	RS_ROW_T 		issue_next_test   [(`NUM_FU -1 ):0]; 

	
	RS RS0(
		// inputs
		.clock(clock), 
		.reset(reset), 
		.enable(enable), 
		.CAM_en(CAM_en), 
		.CDB_in(CDB_in), 
		.dispatch_valid(dispatch_valid),
		.inst_in(inst_in), 
		.LSQ_busy(LSQ_busy),

		// outputs
		.rs_table_out(rs_table_out), 
		.issue_next(issue_next), 
		.issue_cnt(issue_cnt), 
		.rs_full(rs_full)
	 );

	
	always #5 clock = ~clock;

	// need to update this

	typedef RS_ROW_T table_t[`RS_SIZE];

	// FUNCTIONS
	function table_t clear_rs_table_test;
		begin
			for (integer i = 0; i < `RS_SIZE; i += 1) begin
				// rs_table_test[i] = '{($bits(RS_ROW_T)){0} };
				clear_rs_table_test[i].inst.opa_select = ALU_OPA_IS_REGA;
				clear_rs_table_test[i].inst.opb_select = ALU_OPB_IS_REGB;
				clear_rs_table_test[i].inst.dest_reg = DEST_IS_REGC;
				clear_rs_table_test[i].inst.alu_func = ALU_ADDQ;
				clear_rs_table_test[i].inst.fu_name = FU_ALU;
				clear_rs_table_test[i].inst.rd_mem = 0;
				clear_rs_table_test[i].inst.wr_mem = 0;
				clear_rs_table_test[i].inst.ldl_mem = 0;
				clear_rs_table_test[i].inst.stc_mem = 0;
				clear_rs_table_test[i].inst.cond_branch = 0;
				clear_rs_table_test[i].inst.uncond_branch = 0;
				clear_rs_table_test[i].inst.halt = 0;
				clear_rs_table_test[i].inst.cpuid = 0;
				clear_rs_table_test[i].inst.illegal = 0;
				clear_rs_table_test[i].inst.valid_inst = 0;
				clear_rs_table_test[i].T = `DUMMY_REG;
				clear_rs_table_test[i].T1 = `DUMMY_REG;
				clear_rs_table_test[i].T2 = `DUMMY_REG;
				// $display("dummy reg: %b", `DUMMY_REG);
				clear_rs_table_test[i].busy = 0;
			end
		end
	endfunction

	typedef RS_ROW_T issue_t[`NUM_FU];

	function issue_t clear_issue_next_test;
	begin
		for (integer i = 0; i < `NUM_FU; i += 1) begin
			clear_issue_next_test[i].inst.opa_select = ALU_OPA_IS_REGA;
			clear_issue_next_test[i].inst.opb_select = ALU_OPB_IS_REGB;
			clear_issue_next_test[i].inst.dest_reg = DEST_IS_REGC;
			clear_issue_next_test[i].inst.alu_func = ALU_ADDQ;
			clear_issue_next_test[i].inst.fu_name = FU_ALU;
			clear_issue_next_test[i].inst.rd_mem = 0;
			clear_issue_next_test[i].inst.wr_mem = 0;
			clear_issue_next_test[i].inst.ldl_mem = 0;
			clear_issue_next_test[i].inst.stc_mem = 0;
			clear_issue_next_test[i].inst.cond_branch = 0;
			clear_issue_next_test[i].inst.uncond_branch = 0;
			clear_issue_next_test[i].inst.halt = 0;
			clear_issue_next_test[i].inst.cpuid = 0;
			clear_issue_next_test[i].inst.illegal = 0;
			clear_issue_next_test[i].inst.valid_inst = 0;
			clear_issue_next_test[i].T = `DUMMY_REG;
			clear_issue_next_test[i].T1 = `DUMMY_REG;
			clear_issue_next_test[i].T2 = `DUMMY_REG;
			clear_issue_next_test[i].busy = 0;
		end
	end
	endfunction

	// TASKS
	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	task print_rs_table;
		input RS_ROW_T rs_table [(`RS_SIZE - 1):0];
		begin
			$display("**********************************************************\n");
			$display("------------------------RS TABLE----------------------------\n");

			for(integer i=0;i<`RS_SIZE;i=i+1) begin
				$display("Entry: %d", i);
				$display("\tBusy = %b", rs_table[i].busy);
				$display("\tFU_Name = %d", rs_table[i].inst.fu_name);
				$display("\tT = %7.0b", rs_table[i].T);
				$display("\tT1 = %7.0b", rs_table[i].T1);
				$display("\tT2 = %7.0b", rs_table[i].T2);
			end
			$display("*******************************************************************\n");

		end
	endtask

	task entry_exists_in_table;
		input RS_ROW_T inst_in;
		input RS_ROW_T rs_table_out [(`RS_SIZE - 1):0];
		begin
			integer i;
			for (i = 0; i < `RS_SIZE; i += 1) begin
				if (rs_table_out[i].busy) begin
					if (rs_table_out[i] == inst_in) begin
						return;
					end
				end
			end
			#1 exit_on_error;
		end
	endtask

	task entry_not_in_table;
		input RS_ROW_T inst_in;
		input RS_ROW_T rs_table_out [(`RS_SIZE - 1):0];
		begin
			integer i;
			for (i = 0; i < `RS_SIZE; i += 1) begin
				if (rs_table_out[i].busy) begin
					if (rs_table_out[i] == inst_in) begin
						#1 exit_on_error;
					end
				end
			end
			return;
		end
	endtask

	task table_has_N_entries;
		input integer count;
		input RS_ROW_T rs_table_out [(`RS_SIZE - 1):0];
		begin
			integer _count = 0;
			integer i;
			for (i = 0; i < `RS_SIZE; i += 1) begin
				if (rs_table_out[i].busy) begin
					_count += 1;
				end
			end
			assert(count == _count) else #1 exit_on_error;
		end
	endtask

	task tags_now_ready;
		input integer tag;
		input RS_ROW_T rs_table_out [(`RS_SIZE - 1):0];
		begin
			integer i;
			for (i = 0; i < `RS_SIZE; i += 1) begin
				if (rs_table_out[i].busy) begin
					if (rs_table_out[i].T1[$clog2(`NUM_PHYS_REG)-1:0] == tag) begin
						assert(rs_table_out[i].T1[$clog2(`NUM_PHYS_REG)]) else #1 exit_on_error;
					end
					if (rs_table_out[i].T2[$clog2(`NUM_PHYS_REG)-1:0] == tag) begin
						assert(rs_table_out[i].T2[$clog2(`NUM_PHYS_REG)]) else #1 exit_on_error;
					end
				end
			end
			return;
		end
	endtask

	task check_issue_next_correct;
		input RS_ROW_T issue_next [(`NUM_FU -1 ):0];
		input RS_ROW_T issue_next_test [(`NUM_FU -1 ):0];
		begin
			for (integer i = 0; i < `NUM_FU; i += 1) begin
				logic found = 1'b0;
				if (issue_next[i].busy) begin
					for (integer j = 0; j < `NUM_FU; j += 1) begin
						if (issue_next_test[j].busy) begin
							if (issue_next_test[j] == issue_next[i]) begin
								found = 1'b1;
								break;
							end
						end
					end
					if (!found) begin
						exit_on_error;
					end
				end
			end

			for (integer i = 0; i < `NUM_FU; i += 1) begin
				logic found = 1'b0;
				if (issue_next_test[i].busy) begin
					for (integer j = 0; j < `NUM_FU; j += 1) begin
						if (issue_next[j].busy) begin
							if (issue_next_test[i] == issue_next[j]) begin
								found = 1'b1;
								break;
							end
						end
					end
					if (!found) begin
						exit_on_error;
					end
				end
			end
			return;
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
		inst_in.T = 7'b1111111;
		inst_in.T1 = 7'b1111111;
		inst_in.T2 = 7'b1111111;
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
//Check reset
		reset = 1;
	@(negedge  clock);
//Check enable
		enable = 1;
	@(negedge clock);
//Dispatch
		reset = 0;
		enable = 1;
		dispatch_valid = 1;
		LSQ_busy = 0;	

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
		inst_in.T = 7'd3;
		inst_in.T1 = 7'b1000001;
		inst_in.T2 = 7'b1000010;
		inst_in.busy = 1'b1;
		
		


		@(negedge clock);
		@(negedge clock);
		@(negedge clock);
		
		
		$display("@@@Passed");
		// $finish;

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



	// Test for Reset
	reset = 0;
	enable = 0;
	CAM_en = 0;
	CDB_in = `DUMMY_REG;
	// inst_in.inst.opa_select = ALU_OPA_IS_REGA;
	// inst_in.inst.opb_select = ALU_OPB_IS_REGB;
	// inst_in.inst.dest_reg = DEST_IS_REGC;
	// inst_in.inst.alu_func = ALU_ADDQ;
	// inst_in.inst.fu_name = FU_ALU;
	// inst_in.inst.rd_mem = 0;
	inst_in.inst = '{ALU_OPA_IS_REGA, ALU_OPB_IS_REGB, DEST_IS_REGC, ALU_ADDQ, FU_ALU, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}; 
	inst_in.T = {1, 6'd3};
	inst_in.T1 = {1, 6'd2};
	inst_in.T2 = {1, 6'd1};
	inst_in.busy = 1;
	dispatch_valid = 1;
	LSQ_busy = 2'b00;


	@(negedge clock);
	// Nothing issued since it is reset
	$display("-------RESET------\n");
	reset = 1;
	rs_table_test = clear_rs_table_test();
	issue_next_test = clear_issue_next_test();

	// print_rs_table(rs_table_out);
	// print_rs_table(rs_table_test);
	assert( rs_table_out == rs_table_test ) else #1 exit_on_error;
	assert( issue_next == issue_next_test ) else #1 exit_on_error;
	assert( !issue_cnt) else #1 exit_on_error;
	assert( !rs_full ) else #1 exit_on_error;
	$display("Reset 1 passed");
	
	@(negedge clock);
	reset = 0;
	//RS is empty since it is reset
	assert( rs_table_out == rs_table_test ) else #1 exit_on_error;
	assert( issue_next == issue_next_test ) else #1 exit_on_error;
	assert( !issue_cnt) else #1 exit_on_error;
	assert( !rs_full ) else #1 exit_on_error;
	$display("Reset 2 passed");

	@(negedge clock);
	$display("-------Dispatch One Instruction------\n");
	// dispatch add p2 p1 p3
	enable = 1;
	CAM_en = 0;
	dispatch_valid = 1;
	inst_in.inst = '{ALU_OPA_IS_REGA, ALU_OPB_IS_REGB, DEST_IS_REGC, ALU_ADDQ, FU_ALU, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}; 
	inst_in.T = {1, 6'd3};
	inst_in.T1 = {1, 6'd2};
	inst_in.T2 = {1, 6'd1};
	inst_in.busy = 1;
	LSQ_busy = 2'b00;

	$display("testing dispatch...");
	entry_exists_in_table(inst_in, rs_table_out);
	$display("entry exists in table!");
	table_has_N_entries(1, rs_table_out);
	$display("table has 1 entry");
	assert( issue_next == issue_next_test ) else #1 exit_on_error;
	$display("assert 1");
	assert( !issue_cnt) else #1 exit_on_error;
	$display("assert 2");
	assert( !rs_full ) else #1 exit_on_error;
	$display("Dispatch 1 instruction passed");

	@(negedge clock);
	$display("-------Issue One Instruction------\n");
	// issue add p2 p1 p3
	dispatch_valid = 0;

	entry_not_in_table(inst_in, rs_table_out);
	table_has_N_entries(0, rs_table_out);
	assert( issue_next[0] == inst_in ) else #1 exit_on_error;
	assert( issue_next[`NUM_FU-1:1] == issue_next_test[`NUM_FU-1:1] );
	assert( issue_cnt == 1) else #1 exit_on_error;
	assert( !rs_full ) else #1 exit_on_error;
	$display("Issue 1 instruction passed");

	@(negedge clock);
	@(negedge clock);
	$display("-------Commit One Instruction------\n");
	// commit add p2 p1 p3
	CAM_en = 1;
	CDB_in = {1, 6'd3};

	tags_now_ready(3, rs_table_out);
	table_has_N_entries(0, rs_table_out);
	assert( issue_next == issue_next_test ) else #1 exit_on_error;
	assert( !issue_cnt) else #1 exit_on_error;
	assert( !rs_full ) else #1 exit_on_error;
	$display("Commit 1 Instruction passed");

	@(negedge clock);
	$display("-------Issue Multiple Instructions------\n");
	// dispatch mult p2 p3 p4
	enable = 1;
	dispatch_valid = 1;
	inst_in.inst = '{ALU_OPA_IS_REGA, ALU_OPB_IS_REGB, DEST_IS_REGC, ALU_MULQ, FU_MULT, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}; 
	inst_in.T = {1, 6'd4};
	inst_in.T1 = {1, 6'd2};
	inst_in.T2 = {1, 6'd3};
	inst_in.busy = 1;
	entry_exists_in_table(inst_in, rs_table_out);
	table_has_N_entries(1, rs_table_out);
	assert( issue_next == issue_next_test ) else #1 exit_on_error;
	assert( !issue_cnt) else #1 exit_on_error;
	assert( !rs_full ) else #1 exit_on_error;

	@(negedge clock);
	// check for issue for mult
	entry_not_in_table(inst_in, rs_table_out);
	table_has_N_entries(0, rs_table_out);
	assert( issue_next[0] == inst_in ) else #1 exit_on_error;
	assert( issue_next[`NUM_FU-1:1] == issue_next_test[`NUM_FU-1:1] );
	assert( issue_cnt == 1) else #1 exit_on_error;
	assert( !rs_full ) else #1 exit_on_error;
	// dispatch add p4 p5 p6 and
	dispatch_valid = 1;
	inst_in.inst = '{ALU_OPA_IS_REGA, ALU_OPB_IS_REGB, DEST_IS_REGC, ALU_ADDQ, FU_ALU, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}; 
	inst_in.T = {1, 6'd6};
	inst_in.T1 = {0, 6'd4};
	inst_in.T2 = {1, 6'd5};
	inst_in.busy = 1;	
	entry_exists_in_table(inst_in, rs_table_out);
	table_has_N_entries(1, rs_table_out);
	assert( issue_next == issue_next_test ) else #1 exit_on_error;
	assert( !issue_cnt) else #1 exit_on_error;
	assert( !rs_full ) else #1 exit_on_error;

	@(negedge clock);
	// check nothing is issued
	assert( issue_next == issue_next_test ) else #1 exit_on_error;
	assert( !issue_cnt) else #1 exit_on_error;
	assert( !rs_full ) else #1 exit_on_error;
	// dispatch add p4 p4 p7
	dispatch_valid = 1;
	inst_in.inst = '{ALU_OPA_IS_REGA, ALU_OPB_IS_REGB, DEST_IS_REGC, ALU_ADDQ, FU_ALU, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}; 
	inst_in.T = {1, 6'd7};
	inst_in.T1 = {0, 6'd4};
	inst_in.T2 = {0, 6'd4};
	inst_in.busy = 1;	
	entry_exists_in_table(inst_in, rs_table_out);
	table_has_N_entries(2, rs_table_out);
	assert( issue_next == issue_next_test ) else #1 exit_on_error;
	assert( !issue_cnt) else #1 exit_on_error;
	assert( !rs_full ) else #1 exit_on_error;

	@(negedge clock);
	dispatch_valid = 0;
	table_has_N_entries(2, rs_table_out);
	assert( issue_next == issue_next_test ) else #1 exit_on_error;
	assert( !issue_cnt) else #1 exit_on_error;
	assert( !rs_full ) else #1 exit_on_error;
	@(negedge clock);
	table_has_N_entries(2, rs_table_out);
	assert( issue_next == issue_next_test ) else #1 exit_on_error;
	assert( !issue_cnt) else #1 exit_on_error;
	assert( !rs_full ) else #1 exit_on_error;
	@(negedge clock);
	table_has_N_entries(2, rs_table_out);
	assert( issue_next == issue_next_test ) else #1 exit_on_error;
	assert( !issue_cnt) else #1 exit_on_error;
	assert( !rs_full ) else #1 exit_on_error;

	@(negedge clock);
	// commit mult p2 p3 p4
	CAM_en = 1;
	CDB_in = {1, 6'd4};
	tags_now_ready(4, rs_table_out);

	// check for 2 issued instructions
	table_has_N_entries(0, rs_table_out);
	inst_in.inst = '{ALU_OPA_IS_REGA, ALU_OPB_IS_REGB, DEST_IS_REGC, ALU_ADDQ, FU_ALU, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}; 
	inst_in.T = {1, 6'd6};
	inst_in.T1 = {0, 6'd4};
	inst_in.T2 = {1, 6'd5};
	issue_next_test[0] = inst_in;
	inst_in.inst = '{ALU_OPA_IS_REGA, ALU_OPB_IS_REGB, DEST_IS_REGC, ALU_ADDQ, FU_ALU, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}; 
	inst_in.T = {1, 6'd7};
	inst_in.T1 = {0, 6'd4};
	inst_in.T2 = {0, 6'd4};
	inst_in.busy = 1;	
	issue_next_test[1] = inst_in;

	check_issue_next_correct(issue_next, issue_next_test);
	assert( issue_next == issue_next_test ) else #1 exit_on_error;
	assert( issue_cnt == 2) else #1 exit_on_error;
	assert( !rs_full ) else #1 exit_on_error;
	// clear issue_next_test
	issue_next_test = clear_issue_next_test();

	$finish;

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
