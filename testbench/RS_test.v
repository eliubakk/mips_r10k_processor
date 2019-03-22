`include "sys_defs.vh"
`define DEBUG

`define DELAY #2

module testbench;
	logic 	 clock, reset, enable;
	logic    [(`SS_SIZE-1):0] CAM_en;
	PHYS_REG [(`SS_SIZE-1):0] CDB_in;
	logic	 dispatch_valid;
	RS_ROW_T [(`SS_SIZE-1):0] inst_in;
	logic 	 branch_not_taken;
	
	RS_ROW_T	[(`RS_SIZE-1):0]		rs_table_out;
	RS_ROW_T	[(`NUM_FU_TOTAL-1):0]	issue_next; 
	logic		[$clog2(`RS_SIZE):0]	free_rows_next;
	logic	 rs_full;

	//TEST VARIABLES
	RS_ROW_T   	[(`RS_SIZE-1):0] 		rs_table_test;
	RS_ROW_T   	[(`RS_SIZE-1):0] 		rs_table_next_out;
	RS_ROW_T 	[(`NUM_FU_TOTAL-1):0]	issue_next_test; 
	
	RS RS0(
		// inputs
		.clock(clock), 
		.reset(reset), 
		.enable(enable), 
		.CAM_en(CAM_en), 
		.CDB_in(CDB_in), 
		.dispatch_valid(dispatch_valid),
		.inst_in(inst_in),
		.branch_not_taken(branch_not_taken),

		// outputs
		.rs_table_out(rs_table_out),
		.rs_table_next_out(rs_table_next_out), 
		.issue_out(issue_next),
		.free_rows_next(free_rows_next),
		.rs_full(rs_full)
	 );

	
	always #5 clock = ~clock;

	// need to update this

	typedef RS_ROW_T [`RS_SIZE] table_t;

	// FUNCTIONS
	function table_t clear_rs_table_test;
		begin
			for (integer i = 0; i < `RS_SIZE; i += 1) begin
				// rs_table_test[i] = '{($bits(RS_ROW_T)){0} };
				clear_rs_table_test[i] = EMPTY_ROW;
			end
		end
	endfunction

	typedef RS_ROW_T [`NUM_FU_TOTAL] issue_t;

	function issue_t clear_issue_next_test;
	begin
		for (integer i = 0; i < `NUM_FU_TOTAL; i += 1) begin
			clear_issue_next_test[i] = EMPTY_ROW;
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

	task table_out;

		begin
				$display("**********************************************************\n");
				$display("------------------------RS TABLE----------------------------\n");

			for(integer i=0;i<`RS_SIZE;i=i+1) begin
				$display("RS_Row = %d,  busy = %d, Function = %d, T = %7.0b T1 = %7.0b, T2 = %7.0b ", i, rs_table_out[i].busy, rs_table_out[i].inst.fu_name,rs_table_out[i].T, rs_table_out[i].T1, rs_table_out[i].T2);
			end
				$display("**********************************************************\n");
				$display("------------------------RS TABLE NEXT----------------------------\n");

			for(integer i=0;i<`RS_SIZE;i=i+1) begin
				$display("RS_Row = %d,  busy = %d, Function = %d, T = %7.0b T1 = %7.0b, T2 = %7.0b ", i, rs_table_next_out[i].busy, rs_table_next_out[i].inst.fu_name,rs_table_next_out[i].T, rs_table_next_out[i].T1, rs_table_next_out[i].T2);
			end
				$display("RS full = %b, free_rows_next = %d",rs_full, free_rows_next);
				$display("-----------------------Issue table-----------------------------------\n");
			for(integer i=0;i<`NUM_FU_TOTAL;i=i+1) begin
				$display("Issue_row = %d, busy = %d, T = %7.0b T1 = %7.0b, T2 = %7.0b ",i, issue_next[i].busy, issue_next[i].T, issue_next[i].T1, issue_next[i].T2 );
			
			end
			$display("*******************************************************************\n");

		end
	endtask

	task entry_exists_in_table;
		input RS_ROW_T inst_in;
		input RS_ROW_T [(`RS_SIZE - 1):0] rs_table_out;
		begin
			integer i;
			for (i = 0; i < `RS_SIZE; i += 1) begin
				if (rs_table_out[i].busy) begin
					if (rs_table_out[i] == inst_in) begin
						return;
					end
				end
			end
			$display("failed in entry_exists_in_table");
			#1 exit_on_error;
		end
	endtask

	task entry_not_in_table;
		input RS_ROW_T inst_in;
		input RS_ROW_T [(`RS_SIZE - 1):0] rs_table_out;
		begin
			integer i;
			for (i = 0; i < `RS_SIZE; i += 1) begin
				if (rs_table_out[i].busy) begin
					if (rs_table_out[i] == inst_in) begin
						$display("failed in entry_not_in_table");
						#1 exit_on_error;
					end
				end
			end
			return;
		end
	endtask

	task table_has_N_entries;
		input integer count;
		input RS_ROW_T [(`RS_SIZE - 1):0] rs_table_out;
		begin
			integer _count = 0;
			integer i;
			_count = 0;
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
		input RS_ROW_T [(`RS_SIZE - 1):0] rs_table_out;
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
		input RS_ROW_T [(`NUM_FU_TOTAL - 1):0] issue_next;
		input RS_ROW_T [(`NUM_FU_TOTAL - 1):0] issue_next_test;
		begin
			for (int i = 0; i < `NUM_FU_TOTAL; i += 1) begin
				if (issue_next[i] != issue_next_test[i]) begin
					$display("failed at check_issue_next_correct");
					exit_on_error;
				end
			end
			return;
		end
	endtask

	task check_has_func;
		input RS_ROW_T [(`RS_SIZE - 1):0] rs_table;
		input FU_NAME func;
		begin
			for (int i = 0; i < `RS_SIZE; i += 1) begin
				if (rs_table[i].inst.fu_name == func) begin
					return;
				end
			end
			exit_on_error;
		end
	endtask

	task rs_table_equal;
		input RS_ROW_T [(`RS_SIZE - 1):0] rs_table;
		input RS_ROW_T [(`RS_SIZE - 1):0] rs_table_test;
		begin
			for (int i = 0; i < `RS_SIZE; i += 1) begin
				assert(rs_table_test[i] === rs_table[i]) else #1 exit_on_error;
			end
		end
	endtask

	// helper variables
	logic first = 1'b0;
	logic second = 1'b0;
	RS_ROW_T inst_1;
	RS_ROW_T inst_2;
	
	initial begin
		
		$monitor("Clock: %4.0f, reset: %b, enable:%b, ", clock, reset, enable);	

		// Initial value
		clock = 1'b0;
		reset = 1'b0;
		enable = 1'b0;
		CAM_en = {`SS_SIZE{1'b0}};
		CDB_in = {`SS_SIZE*$clog2(`NUM_PHYS_REG){1'b0}};
		dispatch_valid = 1'b0;
		for(int i = 0; i < `SS_SIZE; i += 1) begin
			inst_in[i] = EMPTY_ROW;
		end
		branch_not_taken = 1'b0;
	
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
		reset = 1;
		@(negedge  clock);
		enable = 1;
		@(negedge clock);
		//Dispatch
		reset = 0;
		enable = 1;
		$display("****************************************DISPATCH MULT R1 R2 R3************************************************");

		// At this cycle, rs_table should be empty
		// because currently dispatched instruction is seen
		// in rs_table on the next cycle

		inst_in[0].inst.alu_func = ALU_MULQ;
		inst_in[0].inst.fu_name = FU_MULT;
		inst_in[0].inst.valid_inst = 1'b1;
		inst_in[0].T = 7'd3;
		inst_in[0].T1 = 7'b1000001;
		inst_in[0].T2 = 7'b1000010;
		dispatch_valid = 1;

		table_out();
		@(posedge clock);
		dispatch_valid = 0;
		@(negedge clock)
		`DELAY;
		table_out();
		table_has_N_entries(1, rs_table_out);
		inst_in[0].busy = 1'b1;
		entry_exists_in_table(inst_in[0], rs_table_out);
		//inst_in.busy = 1'b1;
		issue_next_test = clear_issue_next_test();
		issue_next_test[FU_MULT_IDX] = inst_in[0];
		check_issue_next_correct(issue_next_test, issue_next);
		assert(~rs_full) else #1 exit_on_error;
		table_out();
		assert(free_rows_next == `RS_SIZE) else #1 exit_on_error;

		// At this cycle, rs_table should have the previously dispatched
		// instruction. 
		// The previously dispatched instruction should be issued

		$display("**********************************************DISPATCH BR R1 R2 R4, Issue MULT R1 R2 R3****************************");	
		inst_in[0].inst.alu_func = ALU_ADDQ;
		inst_in[0].inst.fu_name = FU_BR; // Branch
		inst_in[0].inst.valid_inst = 1'b1;
		inst_in[0].T = 7'd4;
		inst_in[0].T1 = 7'b1000001;
		inst_in[0].T2 = 7'b1000010;
		inst_in[0].busy = 1'b0;

		// The previously dispatched instruction should be the next
		// issued instruction. 

		dispatch_valid = 1;

		@(posedge clock);
		dispatch_valid = 1'b0;
		@(negedge clock);
		`DELAY;
		inst_in[0].busy = 1'b1;
		table_has_N_entries(1, rs_table_out);
		entry_exists_in_table(inst_in[0], rs_table_out);
		issue_next_test = clear_issue_next_test();
		issue_next_test[FU_BR_IDX] = inst_in[0];
		check_issue_next_correct(issue_next, issue_next_test);
		assert(~rs_full) else #1 exit_on_error;
		assert(free_rows_next == `RS_SIZE) else #1 exit_on_error;

		//@(negedge clock);

		// At this cycle, the table should have the dispatched BR
		// instruction and the first instruction should be cleared.

		// The BR instruction should be the next issued instruction.

		// Dispatch an instruction when branch is taken.
		// This means we were trying to dispatch an instruction
		// according to the branch location; however, since the
		// branch is not taken, this dispatched instruction is not
		// the correct instruction to insert into rs_table. 
		// Therefore, on the next cycle, the instruction should
		// not be in the rs_table. 
		inst_in[0].inst.opa_select = ALU_OPA_IS_MEM_DISP;
		inst_in[0].inst.dest_reg = DEST_IS_REGA;
		inst_in[0].inst.alu_func = ALU_ADDQ;
		inst_in[0].inst.fu_name = FU_LD;
		inst_in[0].inst.rd_mem = 1'b1;
		inst_in[0].inst.ldl_mem = 1'b1;
		inst_in[0].inst.valid_inst = 1'b1;
		inst_in[0].T = 7'd5;
		inst_in[0].T1 = 7'b1111111;
		inst_in[0].T2 = 7'b1000001;
		inst_in[0].busy = 1'b0;
		branch_not_taken= 1'b1;
		dispatch_valid = 1'b1;
		@(posedge clock)
		dispatch_valid = 1'b0;
		@(negedge clock);
		`DELAY;
		// Because branch is not taken, the dispatched instruction
		// should not be in the rs_table.
		table_has_N_entries(0, rs_table_out);
		inst_in[0].busy = 1'b1;
		entry_not_in_table(inst_in[0], rs_table_out);
		assert(~rs_full) else #1 exit_on_error;
		assert(free_rows_next == `RS_SIZE) else #1 exit_on_error;

		// At this cycle, dispatch this next instruction. 
		// Nothing should be issued for the next cycle since 
		// rs_table has been cleared in the previous cycle. 

		$display("*******************************************DISPATCH ST R1 DISP R6, ISSUE LD R1 DISP R5, EXECUTE BR R1 R2 R4************************");	
		inst_in[0] = EMPTY_ROW;
		inst_in[0].inst.opa_select = ALU_OPA_IS_MEM_DISP;
		inst_in[0].inst.opb_select = ALU_OPB_IS_REGB;
		inst_in[0].inst.dest_reg = DEST_IS_REGA;
		inst_in[0].inst.alu_func = ALU_ADDQ;
		inst_in[0].inst.fu_name = FU_ST;
		inst_in[0].inst.wr_mem = 1'b1;
		inst_in[0].inst.stc_mem = 1'b1;
		inst_in[0].inst.valid_inst = 1'b1;
		inst_in[0].T = 7'b1111111;
		inst_in[0].T1 = 7'b0000001;
		inst_in[0].T2 = 7'b0000110;
		inst_in[0].busy = 1'b0;
		branch_not_taken= 1'b0;
		dispatch_valid = 1'b1;
		@(posedge clock);
		dispatch_valid = 1'b0;
		@(negedge clock);
		`DELAY;

		// ST should not be issued because both tags are not ready.
		inst_in[0].busy = 1'b1;
		table_has_N_entries(1, rs_table_out);
		entry_exists_in_table(inst_in[0], rs_table_out);
		issue_next_test = clear_issue_next_test();
		check_issue_next_correct(issue_next, issue_next_test);
		assert(~rs_full) else #1 exit_on_error;
		assert(free_rows_next == (`RS_SIZE-1)) else #1 exit_on_error;

		@(posedge clock);

		$display("*************************************RESET *********************************");	
		reset = 1'b1;
		
		@(posedge clock);
		table_out();
		`DELAY;

		rs_table_test = clear_rs_table_test();
		issue_next_test = clear_issue_next_test();
		assert(rs_table_out == rs_table_test) else #1 exit_on_error;
		assert(issue_next_test == issue_next) else #1 exit_on_error;
		assert(~rs_full) else #1 exit_on_error;
		assert(free_rows_next == `RS_SIZE) else #1 exit_on_error;

  //       $display("###########################################################################");
		// $display("***********************TEST2 : Multiple issue and CAM*********************");
		// $display("###########################################################################\n");
	
		// @(negedge clock);
		// reset = 0;
		// enable = 1;
		// dispatch_valid = 1;
		// branch_not_taken = 0;		
		// $display("****************************************DISPATCH MULT R1(Xready) R2 R3************************************************");

		// 	inst_in.inst.opa_select = ALU_OPA_IS_REGA;
		// 	inst_in.inst.opb_select = ALU_OPB_IS_REGB;
		// 	inst_in.inst.dest_reg = DEST_IS_REGC;
		// 	inst_in.inst.alu_func = ALU_MULQ;
		// 	inst_in.inst.fu_name = FU_MULT;
		// 	inst_in.inst.rd_mem = 1'b0;
		// 	inst_in.inst.wr_mem = 1'b0;
		// 	inst_in.inst.ldl_mem = 1'b0;
		// 	inst_in.inst.stc_mem = 1'b0;
		// 	inst_in.inst.cond_branch = 1'b0;
		// 	inst_in.inst.uncond_branch = 1'b0;
		// 	inst_in.inst.halt = 1'b0;
		// 	inst_in.inst.cpuid = 1'b0;
		// 	inst_in.inst.illegal = 1'b0;
		// 	inst_in.inst.valid_inst = 1'b1;
		// 	inst_in.T = 7'd3;
		// 	inst_in.T1 = 7'b0000001;
		// 	inst_in.T2 = 7'b1000010;
		// 	inst_in.busy = 1'b0;
		// 	branch_not_taken=1'b0;
		
		// // table_out();
		// table_has_N_entries(0, rs_table_out);

		// @(posedge clock);
		// `DELAY;

		// inst_in.busy = 1'b1;
		// table_has_N_entries(1, rs_table_out);
		// entry_exists_in_table(inst_in, rs_table_out);
		// issue_next_test = clear_issue_next_test();
		// check_issue_next_correct(issue_next, issue_next_test);


		// @(negedge clock);

		// reset = 0;
		// enable = 1;
		// dispatch_valid = 1;
		// branch_not_taken = 0;

		// $display("****************************************DISPATCH ADD R1(Xready) R2 R4************************************************");

		// inst_in.inst.opa_select = ALU_OPA_IS_REGA;
		// inst_in.inst.opb_select = ALU_OPB_IS_REGB;
		// inst_in.inst.dest_reg = DEST_IS_REGC;
		// inst_in.inst.alu_func = ALU_ADDQ;
		// inst_in.inst.fu_name = FU_ALU;
		// inst_in.inst.rd_mem = 1'b0;
		// inst_in.inst.wr_mem = 1'b0;
		// inst_in.inst.ldl_mem = 1'b0;
		// inst_in.inst.stc_mem = 1'b0;
		// inst_in.inst.cond_branch = 1'b0;
		// inst_in.inst.uncond_branch = 1'b0;
		// inst_in.inst.halt = 1'b0;
		// inst_in.inst.cpuid = 1'b0;
		// inst_in.inst.illegal = 1'b0;
		// inst_in.inst.valid_inst = 1'b1;
		// inst_in.T = 7'd4;
		// inst_in.T1 = 7'b0000001;
		// inst_in.T2 = 7'b1000010;
		// inst_in.busy = 1'b0;
		// branch_not_taken=1'b0;
		// inst_1 = inst_in;
		// inst_1.busy = 1'b1;
		// inst_1.T1 = 7'b1000001;
  //       table_has_N_entries(1, rs_table_out);

		
		// // table_out();
		// @(posedge clock);
		// `DELAY;
		
		// inst_in.busy = 1'b1;
		// table_has_N_entries(2, rs_table_out);
		// entry_exists_in_table(inst_in, rs_table_out);
		// issue_next_test = clear_issue_next_test();
		// check_issue_next_correct(issue_next, issue_next_test);
		// reset = 0;
		// enable = 1;
		// dispatch_valid = 1;
		// branch_not_taken = 0;

		// $display("****************************************DISPATCH ADD R1(Xready) R2 R5************************************************");

		// @(negedge clock);

		// inst_in.inst.opa_select = ALU_OPA_IS_REGA;
		// inst_in.inst.opb_select = ALU_OPB_IS_REGB;
		// inst_in.inst.dest_reg = DEST_IS_REGC;
		// inst_in.inst.alu_func = ALU_ADDQ;
		// inst_in.inst.fu_name = FU_ALU;
		// inst_in.inst.rd_mem = 1'b0;
		// inst_in.inst.wr_mem = 1'b0;
		// inst_in.inst.ldl_mem = 1'b0;
		// inst_in.inst.stc_mem = 1'b0;
		// inst_in.inst.cond_branch = 1'b0;
		// inst_in.inst.uncond_branch = 1'b0;
		// inst_in.inst.halt = 1'b0;
		// inst_in.inst.cpuid = 1'b0;
		// inst_in.inst.illegal = 1'b0;
		// inst_in.inst.valid_inst = 1'b1;
		// inst_in.T = 7'd5;
		// inst_in.T1 = 7'b0000001;
		// inst_in.T2 = 7'b1000010;
		// inst_in.busy = 1'b0;
		// branch_not_taken=1'b0;
		// inst_2 = inst_in;
		// inst_2.busy = 1'b1;
		// inst_2.T1 = 7'b1000001;
		
		// // table_out();

		// table_has_N_entries(2, rs_table_out);
		// @(posedge clock);
		// `DELAY;

		// inst_in.busy = 1'b1;
		// table_has_N_entries(3, rs_table_out);
		// entry_exists_in_table(inst_in, rs_table_out);
		// issue_next_test = clear_issue_next_test();
		// check_issue_next_correct(issue_next, issue_next_test);

		// @(negedge clock);
		// reset = 0;
		// enable = 1;
		// dispatch_valid = 0;
		// branch_not_taken = 0;

		// $display("****************************************Commit R1, Issue MULT R1 R2 R3, Issue ADD R1 R2 R4, Not issue Add R1 R2 R5************************************************");

		// CAM_en = 1;
		// CDB_in = 7'b0000001;

		// issue_next_test = clear_issue_next_test();
		// // set inst_in to mult inst
		// inst_in.inst.opa_select = ALU_OPA_IS_REGA;
		// inst_in.inst.opb_select = ALU_OPB_IS_REGB;
		// inst_in.inst.dest_reg = DEST_IS_REGC;
		// inst_in.inst.alu_func = ALU_MULQ;
		// inst_in.inst.fu_name = FU_MULT;
		// inst_in.inst.rd_mem = 1'b0;
		// inst_in.inst.wr_mem = 1'b0;
		// inst_in.inst.ldl_mem = 1'b0;
		// inst_in.inst.stc_mem = 1'b0;
		// inst_in.inst.cond_branch = 1'b0;
		// inst_in.inst.uncond_branch = 1'b0;
		// inst_in.inst.halt = 1'b0;
		// inst_in.inst.cpuid = 1'b0;
		// inst_in.inst.illegal = 1'b0;
		// inst_in.inst.valid_inst = 1'b1;
		// inst_in.T = 7'd3;
		// inst_in.T1 = 7'b1000001;
		// inst_in.T2 = 7'b1000010;
		// inst_in.busy = 1'b1;

		// issue_next_test[3] = inst_in;

		// // set the mult

		// @(posedge clock);

		// assert(issue_next_test[3] == issue_next[3]) else #1 exit_on_error;

		// // check that just one of the alu inst was issued
		// if (issue_next[0] == inst_1) begin
		// 	first = 1'b1;
		// end else if (issue_next[0] == inst_2) begin
		// 	second = 1'b1;
		// end else begin
		// 	// if we exit here, it's because none of the ready
		// 	// add instructions were issued
		// 	exit_on_error;
		// end

		// `DELAY;		

		// @(posedge clock);
		// inst_in.busy = 1'b1;
		// table_has_N_entries(1, rs_table_out);
		// if (first) begin
		// 	assert(issue_next[0] == inst_2) else #1 exit_on_error;
		// end else if (second) begin
		// 	assert(issue_next[0] == inst_1) else #1 exit_on_error;
		// end else begin
		// 	// if we got here, that means there is a bigger problem
		// 	// than we know
		// 	exit_on_error;
		// end

		// @(negedge clock);
		// table_has_N_entries(0, rs_table_out);

		// @(negedge clock);
		// $display("###########################################################################");
		// $display("***********************TEST3 : Do not dispatch when RS is full*********************");
		// $display("###########################################################################\n");
	
		// $display("****************************************DISPATCH MULT R1(Xready) R2 R3 for 16 several times / ADD R1 R2 R4 should not be dispatched************************************************");

		// CAM_en = 0;
		// for(integer i=0; i<`RS_SIZE-5; i=i+1) begin

		// 	@(negedge clock); 
		// 	// dispatch mult
			
		// 	reset = 0;
		// 	enable = 1;
		// 	dispatch_valid = 1;
		// 	branch_not_taken = 0;		
		
		// 	inst_in.inst.opa_select = ALU_OPA_IS_REGA;
		// 	inst_in.inst.opb_select = ALU_OPB_IS_REGB;
		// 	inst_in.inst.dest_reg = DEST_IS_REGC;
		// 	inst_in.inst.alu_func = ALU_MULQ;
		// 	inst_in.inst.fu_name = FU_MULT;
		// 	inst_in.inst.rd_mem = 1'b0;
		// 	inst_in.inst.wr_mem = 1'b0;
		// 	inst_in.inst.ldl_mem = 1'b0;
		// 	inst_in.inst.stc_mem = 1'b0;
		// 	inst_in.inst.cond_branch = 1'b0;
		// 	inst_in.inst.uncond_branch = 1'b0;
		// 	inst_in.inst.halt = 1'b0;
		// 	inst_in.inst.cpuid = 1'b0;
		// 	inst_in.inst.illegal = 1'b0;
		// 	inst_in.inst.valid_inst = 1'b1;
		// 	inst_in.T = 7'd3;
		// 	inst_in.T1 = 7'b0000001;
		// 	inst_in.T2 = 7'b1000010;
		// 	inst_in.busy = 1'b0;
		// 	branch_not_taken=1'b0;
		
		

		// end

		// @(negedge clock); 
		
		// // dispatch mult

		// reset = 0;
		// enable = 1;
		// dispatch_valid = 1;
		// branch_not_taken = 0;		
	
		// inst_in.inst.opa_select = ALU_OPA_IS_REGA;
		// inst_in.inst.opb_select = ALU_OPB_IS_REGB;
		// inst_in.inst.dest_reg = DEST_IS_REGC;
		// inst_in.inst.alu_func = ALU_MULQ;
		// inst_in.inst.fu_name = FU_MULT;
		// inst_in.inst.rd_mem = 1'b0;
		// inst_in.inst.wr_mem = 1'b0;
		// inst_in.inst.ldl_mem = 1'b0;
		// inst_in.inst.stc_mem = 1'b0;
		// inst_in.inst.cond_branch = 1'b0;
		// inst_in.inst.uncond_branch = 1'b0;
		// inst_in.inst.halt = 1'b0;
		// inst_in.inst.cpuid = 1'b0;
		// inst_in.inst.illegal = 1'b0;
		// inst_in.inst.valid_inst = 1'b1;
		// inst_in.T = 7'd3;
		// inst_in.T1 = 7'b0001001;
		// inst_in.T2 = 7'b1001010;
		// inst_in.busy = 1'b0;
		// branch_not_taken=1'b0;
		

		// @(negedge clock); 
		
		// reset = 0;
		// enable = 1;
		// dispatch_valid = 1;
		// branch_not_taken = 0;		
	
		// // dispatch branch
		// inst_in.inst.opa_select = ALU_OPA_IS_REGA;
		// inst_in.inst.opb_select = ALU_OPB_IS_REGB;
		// inst_in.inst.dest_reg = DEST_IS_REGC;
		// inst_in.inst.alu_func = ALU_ADDQ;
		// inst_in.inst.fu_name = FU_BR;
		// inst_in.inst.rd_mem = 1'b0;
		// inst_in.inst.wr_mem = 1'b0;
		// inst_in.inst.ldl_mem = 1'b0;
		// inst_in.inst.stc_mem = 1'b0;
		// inst_in.inst.cond_branch = 1'b0;
		// inst_in.inst.uncond_branch = 1'b0;
		// inst_in.inst.halt = 1'b0;
		// inst_in.inst.cpuid = 1'b0;
		// inst_in.inst.illegal = 1'b0;
		// inst_in.inst.valid_inst = 1'b1;
		// inst_in.T = 7'd7;
		// inst_in.T1 = 7'b0001001;
		// inst_in.T2 = 7'b1001010;
		// inst_in.busy = 1'b0;
		// branch_not_taken=1'b0;

		// @(negedge clock); 
	
		// reset = 0;
		// enable = 1;
		// dispatch_valid = 1;
		// branch_not_taken = 0;		

		// // dispatch alu
		// inst_in.inst.opa_select = ALU_OPA_IS_REGA;
		// inst_in.inst.opb_select = ALU_OPB_IS_REGB;
		// inst_in.inst.dest_reg = DEST_IS_REGC;
		// inst_in.inst.alu_func = ALU_ADDQ;
		// inst_in.inst.fu_name = FU_ALU;
		// inst_in.inst.rd_mem = 1'b0;
		// inst_in.inst.wr_mem = 1'b0;
		// inst_in.inst.ldl_mem = 1'b0;
		// inst_in.inst.stc_mem = 1'b0;
		// inst_in.inst.cond_branch = 1'b0;
		// inst_in.inst.uncond_branch = 1'b0;
		// inst_in.inst.halt = 1'b0;
		// inst_in.inst.cpuid = 1'b0;
		// inst_in.inst.illegal = 1'b0;
		// inst_in.inst.valid_inst = 1'b1;
		// inst_in.T = 7'd7;
		// inst_in.T1 = 7'b0001001;
		// inst_in.T2 = 7'b1001010;
		// inst_in.busy = 1'b0;
		// branch_not_taken=1'b0;

		// @(negedge clock); 
	
		// reset = 0;
		// enable = 1;
		// dispatch_valid = 1;
		// branch_not_taken = 0;		

		// // dispatch load
		// inst_in.inst.opa_select = ALU_OPA_IS_REGA;
		// inst_in.inst.opb_select = ALU_OPB_IS_REGB;
		// inst_in.inst.dest_reg = DEST_IS_REGC;
		// inst_in.inst.alu_func = ALU_ADDQ;
		// inst_in.inst.fu_name = FU_LD;
		// inst_in.inst.rd_mem = 1'b0;
		// inst_in.inst.wr_mem = 1'b0;
		// inst_in.inst.ldl_mem = 1'b0;
		// inst_in.inst.stc_mem = 1'b0;
		// inst_in.inst.cond_branch = 1'b0;
		// inst_in.inst.uncond_branch = 1'b0;
		// inst_in.inst.halt = 1'b0;
		// inst_in.inst.cpuid = 1'b0;
		// inst_in.inst.illegal = 1'b0;
		// inst_in.inst.valid_inst = 1'b1;
		// inst_in.T = 7'd7;
		// inst_in.T1 = 7'b0001001;
		// inst_in.T2 = 7'b1001010;
		// inst_in.busy = 1'b0;
		// branch_not_taken=1'b0;

		// @(posedge clock);
		// `DELAY;

		// table_has_N_entries(15, rs_table_out);

		// @(negedge clock); 
	
		// reset = 0;
		// enable = 1;
		// dispatch_valid = 1;
		// branch_not_taken = 0;		

		// inst_in.inst.opa_select = ALU_OPA_IS_REGA;
		// inst_in.inst.opb_select = ALU_OPB_IS_REGB;
		// inst_in.inst.dest_reg = DEST_IS_REGC;
		// inst_in.inst.alu_func = ALU_ADDQ;
		// inst_in.inst.fu_name = FU_ST;
		// inst_in.inst.rd_mem = 1'b0;
		// inst_in.inst.wr_mem = 1'b0;
		// inst_in.inst.ldl_mem = 1'b0;
		// inst_in.inst.stc_mem = 1'b0;
		// inst_in.inst.cond_branch = 1'b0;
		// inst_in.inst.uncond_branch = 1'b0;
		// inst_in.inst.halt = 1'b0;
		// inst_in.inst.cpuid = 1'b0;
		// inst_in.inst.illegal = 1'b0;
		// inst_in.inst.valid_inst = 1'b1;
		// inst_in.T = 7'd7;
		// inst_in.T1 = 7'b0001001;
		// inst_in.T2 = 7'b1001010;
		// inst_in.busy = 1'b0;
		// branch_not_taken=1'b0;

		// @(posedge clock);
		// `DELAY;

		// table_has_N_entries(16, rs_table_out);
		// assert(rs_full) else #1 exit_on_error;
		// check_has_func(rs_table_out, FU_ALU);
		// check_has_func(rs_table_out, FU_LD);
		// check_has_func(rs_table_out, FU_ST);
		// check_has_func(rs_table_out, FU_MULT);
		// check_has_func(rs_table_out, FU_BR);

		// // since RS is full, check that dispatching another
		// // instruction doesn't actually dispatch it
		// @(negedge clock);

		// reset = 0;
		// enable = 1;
		// dispatch_valid = 1;
		// branch_not_taken = 0;		
	
		// inst_in.inst.opa_select = ALU_OPA_IS_REGA;
		// inst_in.inst.opb_select = ALU_OPB_IS_REGB;
		// inst_in.inst.dest_reg = DEST_IS_REGC;
		// inst_in.inst.alu_func = ALU_ADDQ;
		// inst_in.inst.fu_name = FU_ALU;
		// inst_in.inst.rd_mem = 1'b0;
		// inst_in.inst.wr_mem = 1'b0;
		// inst_in.inst.ldl_mem = 1'b0;
		// inst_in.inst.stc_mem = 1'b0;
		// inst_in.inst.cond_branch = 1'b0;
		// inst_in.inst.uncond_branch = 1'b0;
		// inst_in.inst.halt = 1'b0;
		// inst_in.inst.cpuid = 1'b0;
		// inst_in.inst.illegal = 1'b0;
		// inst_in.inst.valid_inst = 1'b1;
		// inst_in.T = 7'd4;
		// inst_in.T1 = 7'b1001111;
		// inst_in.T2 = 7'b1001111;
		// inst_in.busy = 1'b0;
		// branch_not_taken=1'b0;

		// @(posedge clock);
		// `DELAY;
		// inst_in.busy = 1'b1;
		// entry_not_in_table(inst_in, rs_table_out);

		// @(negedge clock);
		// inst_in.inst.valid_inst = 1'b0;
		// CAM_en = 1;
		// CDB_in = 7'b0001001;
		// `DELAY;
		// // check issue_next all valid
		// for (int i = 0; i < `NUM_FU_TOTAL; i += 1) begin
		// 	assert(issue_next[i].busy) else #1 exit_on_error;
		// 	assert(issue_next[i].inst.valid_inst) else #1 exit_on_error;
		// end
		// issue_next_test = issue_next;

		// @(posedge clock);
		// `DELAY;
		// $display("------------------------Issue 5 instructions----------");
		// table_has_N_entries(11, rs_table_out);
		// // check all of the previously issued instructions are
		// // no longer in the table
		// for (int i = 0; i < `NUM_FU_TOTAL; i += 1) begin
		// 	entry_not_in_table(issue_next_test[i], rs_table_out);
		// end

		// @(negedge clock);
		// $display("------------------------Check Enable Signal----------");
		// rs_table_test = rs_table_out;
		// issue_next_test = issue_next;
		// enable = 1'b0;
		// dispatch_valid = 1'b1;

		// @(posedge clock);
		// `DELAY;
		// rs_table_equal(rs_table_test, rs_table_out);
		// assert(issue_next_test == issue_next) else #1 exit_on_error;

		// @(posedge clock);
		// `DELAY;
		// rs_table_equal(rs_table_test, rs_table_out);
		// assert(issue_next_test == issue_next) else #1 exit_on_error;

		// @(negedge clock);
		// $display("------------------------Check for dispatch invalid inst----------");
		// reset = 1;
		// enable = 1;

		// @(posedge clock);
		// `DELAY;
		// reset = 0;
		// dispatch_valid = 1'b1;

		// @(negedge clock);
		// inst_in.inst.opa_select = ALU_OPA_IS_REGA;
		// inst_in.inst.opb_select = ALU_OPB_IS_REGB;
		// inst_in.inst.dest_reg = DEST_IS_REGC;
		// inst_in.inst.alu_func = ALU_ADDQ;
		// inst_in.inst.fu_name = FU_ALU;
		// inst_in.inst.rd_mem = 1'b0;
		// inst_in.inst.wr_mem = 1'b0;
		// inst_in.inst.ldl_mem = 1'b0;
		// inst_in.inst.stc_mem = 1'b0;
		// inst_in.inst.cond_branch = 1'b0;
		// inst_in.inst.uncond_branch = 1'b0;
		// inst_in.inst.halt = 1'b0;
		// inst_in.inst.cpuid = 1'b0;
		// inst_in.inst.illegal = 1'b0;
		// inst_in.inst.valid_inst = 1'b0;
		// inst_in.T = 7'd4;
		// inst_in.T1 = 7'b1001111;
		// inst_in.T2 = 7'b1001111;
		// inst_in.busy = 1'b0;
		// branch_not_taken=1'b0;

		// @(posedge clock);
		// `DELAY;
		// table_has_N_entries(0, rs_table_out);

		@(negedge clock);	

		$display("@@@Passed");
		$finish;
	end
	
endmodule
