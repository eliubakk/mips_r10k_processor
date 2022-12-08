`include "../../sys_defs.vh"
`define DEBUG

`define DELAY #2

module testbench;
	parameter FU_NAME [0:(`NUM_TYPE_FU - 1)] FU_NAME_VAL = {FU_ALU, FU_LD, FU_MULT, FU_BR};
	parameter FU_IDX [0:(`NUM_TYPE_FU - 1)] FU_BASE_IDX = {FU_ALU_IDX, FU_LD_IDX, FU_MULT_IDX, FU_BR_IDX};
	parameter [0:(`NUM_TYPE_FU - 1)][1:0] NUM_OF_FU_TYPE = {2'b10,2'b01,2'b01,2'b01};

	logic 	 clock, reset, enable;
	logic    [(`SS_SIZE-1):0] CAM_en;
	PHYS_REG [(`SS_SIZE-1):0] CDB_in;
	logic	 [(`SS_SIZE-1):0] dispatch_valid;
	logic	 [(`NUM_FU_TOTAL-1):0] issue_stall;
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
	
	RS #(.FU_NAME_VAL(FU_NAME_VAL),
	.FU_BASE_IDX(FU_BASE_IDX),
	.NUM_OF_FU_TYPE(NUM_OF_FU_TYPE)) RS0(
		// inputs
		.clock(clock), 
		.reset(reset), 
		.enable(enable), 
		.CAM_en(CAM_en), 
		.CDB_in(CDB_in), 
		.dispatch_valid(dispatch_valid),
		.issue_stall(issue_stall),
		.inst_in(inst_in),
		.branch_not_taken(branch_not_taken),

		// outputs
		.rs_table_out(rs_table_out),
		.rs_table_next_out(rs_table_next_out), 
		.issue_out(issue_next),
		.free_rows_next(free_rows_next),
		.rs_full(rs_full)
	 );

	
	always #30 clock = ~clock;

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
				$display("RS_Row = %d,  busy = %d, Function = %d, T = %b T1 = %b, T2 = %b ", i, rs_table_out[i].busy, rs_table_out[i].inst.fu_name,rs_table_out[i].T, rs_table_out[i].T1, rs_table_out[i].T2);
			end
				$display("**********************************************************\n");
				$display("------------------------RS TABLE NEXT----------------------------\n");

			for(integer i=0;i<`RS_SIZE;i=i+1) begin
				$display("RS_Row = %d,  busy = %d, Function = %d, T = %b T1 = %b, T2 = %b ", i, rs_table_next_out[i].busy, rs_table_next_out[i].inst.fu_name,rs_table_next_out[i].T, rs_table_next_out[i].T1, rs_table_next_out[i].T2);
			end
				$display("RS full = %b, free_rows_next = %d",rs_full, free_rows_next);
				$display("-----------------------Issue table-----------------------------------\n");
			for(integer i=0;i<`NUM_FU_TOTAL;i=i+1) begin
				$display("Issue_row = %d, busy = %d, T = %b T1 = %b, T2 = %b ",i, issue_next[i].busy, issue_next[i].T, issue_next[i].T1, issue_next[i].T2 );
			
			end
				$display("-----------------------Issue table test-----------------------------------\n");
			for(integer i=0;i<`NUM_FU_TOTAL;i=i+1) begin
				$display("Issue_row = %d, busy = %d, T = %b T1 = %b, T2 = %b ",i, issue_next_test[i].busy, issue_next_test[i].T, issue_next_test[i].T1, issue_next_test[i].T2 );
			
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
	logic [$clog2(`NUM_PHYS_REG)-1:0] inst_T1;
	logic [$clog2(`NUM_PHYS_REG)-1:0] inst_T2;
	logic [$clog2(`NUM_PHYS_REG)-1:0] inst_T;
	logic test_multiple_fu = 1'b0;
	logic [(`NUM_TYPE_FU - 1):0] test_fu;
	
	initial begin
		
		$monitor("Clock: %4.0f, reset: %b, enable:%b, ", clock, reset, enable);	

		// Initial value
		clock = 1'b0;
		reset = 1'b0;
		enable = 1'b0;
		CAM_en = {`SS_SIZE{1'b0}};
		CDB_in = {`SS_SIZE*$clog2(`NUM_PHYS_REG){1'b0}};
		for(int i = 0; i < `SS_SIZE; i += 1) begin
			inst_in[i] = EMPTY_ROW;
			dispatch_valid[(`SS_SIZE-1)] = 1'b0;
		end
		for(int i = 0; i < `NUM_FU_TOTAL; i += 1) begin
			issue_stall[i] = 1'b0;
		end
		branch_not_taken = 1'b0;
		issue_next_test = clear_issue_next_test();
	
		///Things to do
		//For 1-way superscalar, multiple issue
		//1. Makefile and testbench : make it for synthesizable (for ex,
		//define DEBUG only for testing)
		//2. How can we printout, see, and compare the rs_table values? (It is
		//kind of 2 dimensional matrix structure)
		//3. Testing for functionality (enable, reset, dispatch_valid,
		//LSQ_busy, CAM_en, commit, issue, dispatch) and corner cases (Issue 2 branches at
		//a same cycle?, input is invalid instruction, etc...)  
		$display("###########################################################################");
		$display("********** TEST1 : Dispatch and Branch incorrectly predicted *************");
		$display("###########################################################################\n");  
		
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

		inst_in[(`SS_SIZE-1)].inst.alu_func = ALU_MULQ;
		inst_in[(`SS_SIZE-1)].inst.fu_name = FU_MULT;
		inst_in[(`SS_SIZE-1)].inst.valid_inst = 1'b1;
		inst_in[(`SS_SIZE-1)].T[$clog2(`NUM_PHYS_REG)-1:0] = 3;
		inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)-1:0] = 1;
		inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)] = 1'b1;
		inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)-1:0] = 2;
		inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)] = 1'b1;
		dispatch_valid[(`SS_SIZE-1)] = 1'b1;

		table_out();
		@(posedge clock);
		dispatch_valid[(`SS_SIZE-1)] = 1'b0;
		@(negedge clock)
		`DELAY;

		// At this cycle, rs_table should have the previously dispatched
		// instruction. 
		// The previously dispatched instruction should be issued
		table_out();
		table_has_N_entries(1, rs_table_out);
		inst_in[(`SS_SIZE-1)].busy = 1'b1;
		entry_exists_in_table(inst_in[(`SS_SIZE-1)], rs_table_out);
		issue_next_test = clear_issue_next_test();
		issue_next_test[FU_MULT_IDX + NUM_OF_FU_TYPE[FU_MULT] - 1] = inst_in[(`SS_SIZE-1)];
		check_issue_next_correct(issue_next_test, issue_next);
		assert(~rs_full) else #1 exit_on_error;
		table_out();
		assert(free_rows_next == `RS_SIZE) else #1 exit_on_error;


		// Issue Branch instruction
		$display("**********************************************DISPATCH BR R1 R2 R4, Issue MULT R1 R2 R3****************************");	
		inst_in[(`SS_SIZE-1)].inst.alu_func = ALU_ADDQ;
		inst_in[(`SS_SIZE-1)].inst.fu_name = FU_BR; // Branch
		inst_in[(`SS_SIZE-1)].inst.valid_inst = 1'b1;
		inst_in[(`SS_SIZE-1)].T[$clog2(`NUM_PHYS_REG)-1:0] = 4;
		inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)-1:0] = 1;
		inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)] = 1'b1;
		inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)-1:0] = 2;
		inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)] = 1'b1;
		inst_in[(`SS_SIZE-1)].busy = 1'b0;

		dispatch_valid[(`SS_SIZE-1)] = 1'b1;
		@(posedge clock);
		dispatch_valid[(`SS_SIZE-1)] = 1'b0;
		@(negedge clock);
		`DELAY;

		// At this cycle, the table should have the dispatched BR
		// instruction and the first instruction should be cleared.

		// The BR instruction should be the next issued instruction.

		inst_in[(`SS_SIZE-1)].busy = 1'b1;
		table_has_N_entries(1, rs_table_out);
		entry_exists_in_table(inst_in[(`SS_SIZE-1)], rs_table_out);
		issue_next_test = clear_issue_next_test();
		issue_next_test[FU_BR_IDX + NUM_OF_FU_TYPE[FU_BR] - 1] = inst_in[(`SS_SIZE-1)];
		check_issue_next_correct(issue_next, issue_next_test);
		assert(~rs_full) else #1 exit_on_error;
		assert(free_rows_next == `RS_SIZE) else #1 exit_on_error;

		// Dispatch an instruction when branch is taken.
		// This means we were trying to dispatch an instruction
		// according to the branch location; however, since the
		// branch is not taken, this dispatched instruction is not
		// the correct instruction to insert into rs_table. 
		// Therefore, on the next cycle, the instruction should
		// not be in the rs_table. 
		inst_in[(`SS_SIZE-1)].inst.opa_select = ALU_OPA_IS_MEM_DISP;
		inst_in[(`SS_SIZE-1)].inst.dest_reg = DEST_IS_REGA;
		inst_in[(`SS_SIZE-1)].inst.alu_func = ALU_ADDQ;
		inst_in[(`SS_SIZE-1)].inst.fu_name = FU_LD;
		inst_in[(`SS_SIZE-1)].inst.rd_mem = 1'b1;
		inst_in[(`SS_SIZE-1)].inst.ldl_mem = 1'b1;
		inst_in[(`SS_SIZE-1)].inst.valid_inst = 1'b1;
		inst_in[(`SS_SIZE-1)].T[$clog2(`NUM_PHYS_REG)-1:0] = 5;
		inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)-1:0] = {$clog2(`NUM_PHYS_REG){1'b1}};
		inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)] = 1'b1;
		inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)-1:0] = 1;
		inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)] = 1'b1;
		inst_in[(`SS_SIZE-1)].busy = 1'b0;
		branch_not_taken= 1'b1;

		dispatch_valid[(`SS_SIZE-1)] = 1'b1;
		@(posedge clock)
		dispatch_valid[(`SS_SIZE-1)] = 1'b0;
		@(negedge clock);
		`DELAY;

		// Because branch is not taken, the dispatched instruction
		// should not be in the rs_table.
		table_has_N_entries(0, rs_table_out);
		inst_in[(`SS_SIZE-1)].busy = 1'b1;
		entry_not_in_table(inst_in[(`SS_SIZE-1)], rs_table_out);
		assert(~rs_full) else #1 exit_on_error;
		assert(free_rows_next == `RS_SIZE) else #1 exit_on_error;

		// At this cycle, dispatch this next instruction. 
		// Nothing should be issued for the next cycle since 
		// rs_table has been cleared in the previous cycle. 

		$display("*******************************************DISPATCH ST R1 DISP R6, ISSUE LD R1 DISP R5, EXECUTE BR R1 R2 R4************************");	
		inst_in[(`SS_SIZE-1)] = EMPTY_ROW;
		inst_in[(`SS_SIZE-1)].inst.opa_select = ALU_OPA_IS_MEM_DISP;
		inst_in[(`SS_SIZE-1)].inst.opb_select = ALU_OPB_IS_REGB;
		inst_in[(`SS_SIZE-1)].inst.dest_reg = DEST_IS_REGA;
		inst_in[(`SS_SIZE-1)].inst.alu_func = ALU_ADDQ;
		inst_in[(`SS_SIZE-1)].inst.fu_name = FU_ALU;
		inst_in[(`SS_SIZE-1)].inst.wr_mem = 1'b1;
		inst_in[(`SS_SIZE-1)].inst.stc_mem = 1'b1;
		inst_in[(`SS_SIZE-1)].inst.valid_inst = 1'b1;
		inst_in[(`SS_SIZE-1)].T[$clog2(`NUM_PHYS_REG)-1:0] = `NUM_PHYS_REG-1;
		inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)-1:0] = 1;
		inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)] = 1'b0;
		inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)-1:0] = 6;
		inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)] = 1'b0;
		inst_in[(`SS_SIZE-1)].busy = 1'b0;
		branch_not_taken= 1'b0;

		dispatch_valid[(`SS_SIZE-1)] = 1'b1;
		@(posedge clock);
		dispatch_valid[(`SS_SIZE-1)] = 1'b0;
		@(negedge clock);
		`DELAY;

		// ST should not be issued because both tags are not ready.
		inst_in[(`SS_SIZE-1)].busy = 1'b1;
		table_has_N_entries(1, rs_table_out);
		entry_exists_in_table(inst_in[(`SS_SIZE-1)], rs_table_out);
		issue_next_test = clear_issue_next_test();
		check_issue_next_correct(issue_next, issue_next_test);
		assert(~rs_full) else #1 exit_on_error;
		assert(free_rows_next == (`RS_SIZE-1)) else #1 exit_on_error;

		// Don't dispatch a new instruction
		@(posedge clock);

		$display("*************************************RESET *********************************");	
		reset = 1'b1;
		
		@(posedge clock);
		`DELAY;

		//Table should be empty
		table_out();
		rs_table_test = clear_rs_table_test();
		issue_next_test = clear_issue_next_test();
		assert(rs_table_out == rs_table_test) else #1 exit_on_error;
		assert(issue_next_test == issue_next) else #1 exit_on_error;
		assert(~rs_full) else #1 exit_on_error;
		assert(free_rows_next == `RS_SIZE) else #1 exit_on_error;

        $display("###########################################################################");
		$display("***********************TEST2 : Multiple issue and CAM*********************");
		$display("###########################################################################\n");
	
		@(negedge clock);
		reset = 0;
		enable = 1;

		$display("****************************************DISPATCH MULT R1(Xready) R2 R3************************************************");
		inst_in[(`SS_SIZE-1)] = EMPTY_ROW;
		inst_in[(`SS_SIZE-1)].inst.alu_func = ALU_MULQ;
		inst_in[(`SS_SIZE-1)].inst.fu_name = FU_MULT;
		inst_in[(`SS_SIZE-1)].inst.valid_inst = 1'b1;
		inst_in[(`SS_SIZE-1)].T[$clog2(`NUM_PHYS_REG)-1:0] = 3;
		inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)-1:0] = 1;
		inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)] = 1'b0;
		inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)-1:0] = 2;
		inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)] = 1'b1;
		branch_not_taken=1'b0;
		
		// table_out();
		table_has_N_entries(0, rs_table_out);

		dispatch_valid[(`SS_SIZE-1)] = 1'b1;
		@(posedge clock);
		dispatch_valid[(`SS_SIZE-1)] = 1'b0;
		@(negedge clock);
		`DELAY;

		inst_in[(`SS_SIZE-1)].busy = 1'b1;
		table_has_N_entries(1, rs_table_out);
		entry_exists_in_table(inst_in[(`SS_SIZE-1)], rs_table_out);
		issue_next_test = clear_issue_next_test();
		check_issue_next_correct(issue_next, issue_next_test);
		assert(~rs_full) else #1 exit_on_error;
		assert(free_rows_next == (`RS_SIZE-1)) else #1 exit_on_error;

		$display("****************************************DISPATCH ADD R1(Xready) R2 R4************************************************");

		inst_in[(`SS_SIZE-1)] = EMPTY_ROW;
		inst_in[(`SS_SIZE-1)].inst.valid_inst = 1'b1;
		inst_in[(`SS_SIZE-1)].T[$clog2(`NUM_PHYS_REG)-1:0] = 4;
		inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)-1:0] = 1;
		inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)] = 1'b0;
		inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)-1:0] = 2;
		inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)] = 1'b1;
		inst_1 = inst_in[(`SS_SIZE-1)];
		inst_1.busy = 1'b1;
		inst_1.T1[$clog2(`NUM_PHYS_REG)] = 1'b1;
        table_has_N_entries(1, rs_table_out);

        dispatch_valid[(`SS_SIZE-1)] = 1'b1;
    	@(posedge clock);
    	dispatch_valid[(`SS_SIZE-1)] = 1'b0;
		@(negedge clock);
		`DELAY;
		
		inst_in[(`SS_SIZE-1)].busy = 1'b1;
		table_has_N_entries(2, rs_table_out);
		entry_exists_in_table(inst_in[(`SS_SIZE-1)], rs_table_out);
		issue_next_test = clear_issue_next_test();
		check_issue_next_correct(issue_next, issue_next_test);
		assert(~rs_full) else #1 exit_on_error;
		assert(free_rows_next == (`RS_SIZE-2)) else #1 exit_on_error;

		$display("****************************************DISPATCH ADD R1(Xready) R2 R5************************************************");

		inst_in[(`SS_SIZE-1)] = EMPTY_ROW;
		inst_in[(`SS_SIZE-1)].inst.valid_inst = 1'b1;
		inst_in[(`SS_SIZE-1)].T[$clog2(`NUM_PHYS_REG)-1:0] = 5;
		inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)-1:0] = 1;
		inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)] = 1'b0;
		inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)-1:0] = 2;
		inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)] = 1'b1;
		inst_2 = inst_in[(`SS_SIZE-1)];
		inst_2.busy = 1'b1;
		inst_2.T1[$clog2(`NUM_PHYS_REG)] = 1'b1;
		table_has_N_entries(2, rs_table_out);
		
		dispatch_valid[(`SS_SIZE-1)] = 1'b1;
    	@(posedge clock);
    	dispatch_valid[(`SS_SIZE-1)] = 1'b0;
		@(negedge clock);
		`DELAY;

		inst_in[(`SS_SIZE-1)].busy = 1'b1;
		table_has_N_entries(3, rs_table_out);
		entry_exists_in_table(inst_in[(`SS_SIZE-1)], rs_table_out);
		issue_next_test = clear_issue_next_test();
		check_issue_next_correct(issue_next, issue_next_test);
		assert(~rs_full) else #1 exit_on_error;
		assert(free_rows_next == (`RS_SIZE-3)) else #1 exit_on_error;

		@(posedge clock);
		$display("****************************************Commit R1, Issue MULT R1 R2 R3, Issue ADD R1 R2 R4, Not issue Add R1 R2 R5************************************************");
		table_out();
		CAM_en[0] = 1'b1;
		CDB_in[0] = 1;

		issue_next_test = clear_issue_next_test();
		// set inst_in to mult inst
		inst_in[(`SS_SIZE-1)] = EMPTY_ROW;
		inst_in[(`SS_SIZE-1)].inst.alu_func = ALU_MULQ;
		inst_in[(`SS_SIZE-1)].inst.fu_name = FU_MULT;
		inst_in[(`SS_SIZE-1)].inst.valid_inst = 1'b1;
		inst_in[(`SS_SIZE-1)].T[$clog2(`NUM_PHYS_REG)-1:0] = 3;
		inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)-1:0] = 1;
		inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)] = 1'b1;
		inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)-1:0] = 2;
		inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)] = 1'b1;
		inst_in[(`SS_SIZE-1)].busy = 1'b1;

		issue_next_test[FU_MULT_IDX + NUM_OF_FU_TYPE[FU_MULT] - 1] = inst_in[(`SS_SIZE-1)];

		@(negedge clock);
		`DELAY;
		table_out();
		assert(issue_next_test[FU_MULT_IDX + NUM_OF_FU_TYPE[FU_MULT] - 1] == issue_next[FU_MULT_IDX + NUM_OF_FU_TYPE[FU_MULT] - 1]) else #1 exit_on_error;
		// check that just one of the alu inst was issued
		if (issue_next[FU_ALU_IDX + NUM_OF_FU_TYPE[FU_ALU] - 1] == inst_1) begin
			first = 1'b1;
		end else if (issue_next[FU_ALU_IDX + NUM_OF_FU_TYPE[FU_ALU] - 1] == inst_2) begin
			second = 1'b1;
		end else begin
			// if we exit here, it's because none of the ready
			// add instructions were issued
			exit_on_error;
		end

		assert(~rs_full) else #1 exit_on_error;
		//assert(free_rows_next == (`RS_SIZE-1)) else #1 exit_on_error;	
		if(NUM_OF_FU_TYPE[FU_ALU_IDX] == 1) begin
			@(posedge clock);
			`DELAY;
			table_out();
			CAM_en[0] = 1'b0;
			table_has_N_entries(1, rs_table_out);

			@(negedge clock);
			`DELAY;
		end

		if (first) begin
			assert(issue_next[FU_ALU_IDX + NUM_OF_FU_TYPE[FU_ALU] - 2] == inst_2) else #1 exit_on_error;
		end else if (second) begin
			if(NUM_OF_FU_TYPE[FU_ALU_IDX] == 1) begin
				assert(issue_next[FU_ALU_IDX + NUM_OF_FU_TYPE[FU_ALU] - 2] == inst_1) else #1 exit_on_error;
			end else begin
				assert(issue_next[FU_ALU_IDX + NUM_OF_FU_TYPE[FU_ALU] - 2] == inst_1) else #1 exit_on_error;
			end
		end else begin
			// if we got here, that means there is a bigger problem
			// than we know
			exit_on_error;
		end
		assert(~rs_full) else #1 exit_on_error;
		assert(free_rows_next == `RS_SIZE) else #1 exit_on_error;

		@(posedge clock);
		`DELAY;
		table_out();
		CAM_en[0] = 1'b0;
		table_has_N_entries(0, rs_table_out);

		reset = 1'b1;

		@(posedge clock);
		reset = 1'b0;

		$display("###########################################################################");
		$display("***********************TEST3 : Do not dispatch when RS is full*********************");
		$display("###########################################################################\n");
	
		$display("****************************************DISPATCH MULT R1(Xready) R2 R3 for 16 several times / ADD R1 R2 R4 should not be dispatched************************************************");

		enable = 1'b1;		
		issue_next_test = clear_issue_next_test();

		@(negedge clock);

		for(int i = 0; i < `NUM_TYPE_FU; i += 1) begin
			int count = 0;
			for(int j = 0; j < NUM_OF_FU_TYPE[i]; j += 1) begin
				inst_T = $unsigned(j);
				inst_T1 = 9;
				inst_T2 = $unsigned(`NUM_GEN_REG - i);
				$display("**************DISPATCH FU_NAME[%d] R%d R%d R%d***************", i, inst_T1, inst_T2, inst_T);
				inst_in[(`SS_SIZE-1)].inst.alu_func = ALU_ADDQ;
				inst_in[(`SS_SIZE-1)].inst.fu_name = $unsigned(i);
				inst_in[(`SS_SIZE-1)].inst.valid_inst = 1'b1;
				inst_in[(`SS_SIZE-1)].T[$clog2(`NUM_PHYS_REG)-1:0] = inst_T;
				inst_in[(`SS_SIZE-1)].T[$clog2(`NUM_PHYS_REG)] = 1'b0;
				inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)-1:0] = inst_T1;
				inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)] = 1'b0;
				inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)-1:0] = inst_T2;
				inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)] = 1'b1;
				dispatch_valid[(`SS_SIZE-1)] = 1'b1;
				
				`DELAY
				table_out();
				table_has_N_entries(count, rs_table_out);
				check_issue_next_correct(issue_next, issue_next_test);
				if(`NUM_TYPE_FU < `RS_SIZE || count < `RS_SIZE) begin
					assert(~rs_full) else #1 exit_on_error;
					assert(free_rows_next == (`RS_SIZE-count-1)) else #1 exit_on_error;
				end
				if(i == `RS_SIZE) begin
					assert(rs_full) else #1 exit_on_error;
					assert(free_rows_next == 0) else #1 exit_on_error;
				end

				@(posedge clock)
				dispatch_valid[(`SS_SIZE-1)] = 1'b0;
				@(negedge clock)
				//clear inputs
				dispatch_valid[(`SS_SIZE-1)] = 1'b0;
				inst_in[(`SS_SIZE-1)] = EMPTY_ROW;

				count += 1;
			end
			table_out();
		end

		inst_in[(`SS_SIZE-1)] = EMPTY_ROW;
		inst_in[(`SS_SIZE-1)].inst.alu_func = ALU_MULQ;
		inst_in[(`SS_SIZE-1)].inst.fu_name = FU_MULT;
		inst_in[(`SS_SIZE-1)].inst.valid_inst = 1'b1;
		inst_in[(`SS_SIZE-1)].T[$clog2(`NUM_PHYS_REG)-1:0] = 3;
		inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)-1:0] = 1;
		inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)] = 1'b0;
		inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)-1:0] = 2;
		inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)] = 1'b1;
		dispatch_valid[(`SS_SIZE-1)] = 1'b1;
		for(integer i=0; i<(`RS_SIZE-`NUM_FU_TOTAL); i=i+1) begin

			`DELAY
			table_out();
			table_has_N_entries(`NUM_FU_TOTAL+i, rs_table_out);
			check_issue_next_correct(issue_next, issue_next_test);
			assert(~rs_full) else #1 exit_on_error;
			assert(free_rows_next == (`RS_SIZE-`NUM_FU_TOTAL-i-1)) else #1 exit_on_error;

			@(negedge clock);
			// dispatch inst
		end

		table_out();
		table_has_N_entries(`RS_SIZE, rs_table_out);
		assert(rs_full) else #1 exit_on_error;
		

		check_issue_next_correct(issue_next, issue_next_test);
		assert(free_rows_next == (0)) else #1 exit_on_error;

		// since RS is full, check that dispatching another
		// instruction doesn't actually dispatch it
		@(negedge clock);		
	
		inst_in[(`SS_SIZE-1)] = EMPTY_ROW;
		inst_in[(`SS_SIZE-1)].inst.valid_inst = 1'b1;
		inst_in[(`SS_SIZE-1)].T[$clog2(`NUM_PHYS_REG)-1:0] = 4;
		inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)-1:0] = 15;
		inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)] = 1'b1;
		inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)-1:0] = 15;
		inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)] = 1'b1;
		inst_in[(`SS_SIZE-1)].busy = 1'b0;

		@(posedge clock);
		`DELAY;
		inst_in[(`SS_SIZE-1)].busy = 1'b1;
		entry_not_in_table(inst_in, rs_table_out);
		dispatch_valid[(`SS_SIZE-1)] = 1'b0;
		
		CAM_en[0] = 1'b1;
		CDB_in[0] = 9;

		@(negedge clock);
		`DELAY;

		$display("------------------------Check issue_stall ----------");
		//issue_stall = {`NUM_FU_TOTAL{1'b1}};
		for(int i = 0; i < `NUM_FU_TOTAL; i += 1) begin
			issue_stall[i] = 1'b1;
			`DELAY;
			table_out();
			assert(~issue_next[i].busy) else #1 exit_on_error;
			assert(free_rows_next == (`NUM_FU_TOTAL - 1)) else #1 exit_on_error;
			issue_stall[i] = 1'b0;
		end

		`DELAY;

		// check issue_next all valid
		for (int i = 0; i < `NUM_FU_TOTAL; i += 1) begin
			assert(issue_next[i].busy) else #1 exit_on_error;
			assert(issue_next[i].inst.valid_inst) else #1 exit_on_error;
		end
		issue_next_test = issue_next;
		table_out();
		assert(free_rows_next == (`NUM_FU_TOTAL)) else #1 exit_on_error;

		@(posedge clock);
		`DELAY;
		$display("------------------------Issue %d instructions----------", `NUM_FU_TOTAL);
		table_has_N_entries(`RS_SIZE-`NUM_FU_TOTAL, rs_table_out);
		assert(~rs_full) else #1 exit_on_error;
		// check all of the previously issued instructions are
		// no longer in the table
		for (int i = 0; i < `NUM_FU_TOTAL; i += 1) begin
			entry_not_in_table(issue_next_test[i], rs_table_out);
		end

		@(negedge clock);
		$display("------------------------Check Enable Signal----------");
		rs_table_test = rs_table_out;
		issue_next_test = issue_next;
		enable = 1'b0;
		dispatch_valid[(`SS_SIZE-1)] = 1'b1;

		@(posedge clock);
		`DELAY;
		rs_table_equal(rs_table_test, rs_table_out);
		assert(issue_next_test == issue_next) else #1 exit_on_error;

		@(posedge clock);
		`DELAY;
		rs_table_equal(rs_table_test, rs_table_out);
		assert(issue_next_test == issue_next) else #1 exit_on_error;

		@(negedge clock);
		$display("------------------------Check for dispatch invalid inst----------");
		reset = 1'b1;
		enable = 1'b1;

		@(posedge clock);
		`DELAY;
		reset = 1'b0;
		dispatch_valid[(`SS_SIZE-1)] = 1'b1;

		@(negedge clock);
		inst_in[(`SS_SIZE-1)] = EMPTY_ROW;
		inst_in[(`SS_SIZE-1)].inst.valid_inst = 1'b0;
		inst_in[(`SS_SIZE-1)].T[$clog2(`NUM_PHYS_REG)-1:0] = 4;
		inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)-1:0] = 15;
		inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)] = 1'b1;
		inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)-1:0] = 15;
		inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)] = 1'b1;
		inst_in[(`SS_SIZE-1)].busy = 1'b0;

		@(posedge clock);
		`DELAY;
		table_has_N_entries(0, rs_table_out);

		@(negedge clock);	

		reset = 1'b1;
		@(posedge clock);
		reset = 1'b0;
		enable = 1'b1;
		$display("###########################################################################");
		$display("************************* TEST4 : Test issue_stall ************************");
		$display("###########################################################################\n");

		for(int i = 0; i < `NUM_TYPE_FU; i += 1) begin
			if(NUM_OF_FU_TYPE[i] == 1) begin
				continue;
			end

			//dispatch one of type_fu if there are more than one of that fu.
			inst_in[(`SS_SIZE-1)] = EMPTY_ROW;
			inst_in[(`SS_SIZE-1)].inst.fu_name = i;
			inst_in[(`SS_SIZE-1)].inst.valid_inst = 1'b1;
			inst_in[(`SS_SIZE-1)].T[$clog2(`NUM_PHYS_REG)-1:0] = 3;
			inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)-1:0] = 1;
			inst_in[(`SS_SIZE-1)].T1[$clog2(`NUM_PHYS_REG)] = 1'b1;
			inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)-1:0] = 2;
			inst_in[(`SS_SIZE-1)].T2[$clog2(`NUM_PHYS_REG)] = 1'b1;
			branch_not_taken=1'b0;

			for(int j = 0; j < NUM_OF_FU_TYPE[i]; j += 1) begin

				table_out();
				table_has_N_entries(0, rs_table_out);

				dispatch_valid[(`SS_SIZE-1)] = 1'b1;
				@(posedge clock);
				dispatch_valid[(`SS_SIZE-1)] = 1'b0;
				//stall all issues
				issue_stall = {`NUM_FU_TOTAL{1'b1}};
				@(negedge clock);
				`DELAY;

				//check that enabling each fu will route the instruction
				issue_stall[FU_BASE_IDX[i] + NUM_OF_FU_TYPE[i] - j - 1] = 1'b0;
				`DELAY;
				table_out();
				assert(issue_next[FU_BASE_IDX[i] + NUM_OF_FU_TYPE[i] - j - 1].busy) else #1 exit_on_error;
				assert(free_rows_next == `RS_SIZE) else #1 exit_on_error;
				issue_stall[FU_BASE_IDX[i] + NUM_OF_FU_TYPE[i] - j - 1] = 1'b1;

				reset = 1'b1;
				@(posedge clock);
				`DELAY;
				reset = 1'b0;
			end
		end

		$display("LOOK HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

		@(negedge clock);
		reset = 1;
		enable = 0;
		CAM_en = 0;
		dispatch_valid = 0;
		issue_stall = 0;

		@(posedge clock);
		`DELAY;
		table_out;

		@(negedge clock);
		// dispatch halt inst
		reset = 0;
		enable = 1;
		dispatch_valid = 1;
		inst_in[0].inst.halt = 1;
		inst_in[0].inst.valid_inst = 1;
		inst_in[0].inst.cpuid = 0;
		inst_in[0].inst.illegal = 0; 
		inst_in[0].busy = 1;
		inst_in[0].inst_opcode = `PAL_HALT;
		inst_in[0].npc = 4;

		@(posedge clock);
		`DELAY;
		table_out;
		// check that halt inst exists
		for (int p = 0; p < `NUM_FU_TOTAL; ++p) begin
			// check if current issue_out index is halt
			if (issue_next[p].inst.halt == 1'b1 & issue_next[p].inst_opcode == `PAL_HALT) begin
				$display("we are good");
			end
		end

		if (`SS_SIZE == 1) begin
			$display("@@@Passed");
			$finish;
		end

		issue_stall = {`NUM_FU_TOTAL{1'b0}};
		reset = 1'b1;
		@(posedge clock);
		reset = 1'b0;
		enable = 1'b1;
		$display("###########################################################################");
		$display("***********************TEST5 : Test multiple dispatch *********************");
		$display("###########################################################################\n");
		
		for (int i = 0; i < `SS_SIZE; i += 1) begin
			$display("Dispatch %d instructions:", (i + 1));
			//clear inputs
			for(int j = 0; j < `SS_SIZE; j += 1) begin
				dispatch_valid[j] = 1'b0;
				inst_in[j] = EMPTY_ROW;
			end
			//set up instructions being dispatched
			for (int j = `SS_SIZE - 1; j >= (`SS_SIZE - 1 - i); j -= 1) begin
				inst_T = $unsigned(j);
				inst_T1 = $unsigned(`NUM_GEN_REG - i);
				inst_T2 = $unsigned(`NUM_GEN_REG - j);
				$display("**************DISPATCH MULT R%d R%d R%d***************", inst_T1, inst_T2, inst_T);
				inst_in[j].inst.alu_func = ALU_MULQ;
				inst_in[j].inst.fu_name = FU_MULT;
				inst_in[j].inst.valid_inst = 1'b1;
				inst_in[j].T[$clog2(`NUM_PHYS_REG)-1:0] = inst_T;
				inst_in[j].T[$clog2(`NUM_PHYS_REG)] = 1'b0;
				inst_in[j].T1[$clog2(`NUM_PHYS_REG)-1:0] = inst_T1;
				inst_in[j].T1[$clog2(`NUM_PHYS_REG)] = 1'b0;
				inst_in[j].T2[$clog2(`NUM_PHYS_REG)-1:0] = inst_T2;
				inst_in[j].T2[$clog2(`NUM_PHYS_REG)] = 1'b0;
				dispatch_valid[j] = 1'b1;
			end

			//check they are in table
			@(posedge clock)
			for(int j = 0; j < `SS_SIZE; j += 1) begin
				dispatch_valid[j] = 1'b0;
				inst_in[j].busy = 1'b1;
			end
			@(negedge clock)
			`DELAY
			table_out();
			table_has_N_entries(i + 1, rs_table_out);
			for(int j = `SS_SIZE - 1; j >= (`SS_SIZE - 1 - i); j -= 1) begin
				entry_exists_in_table(inst_in[j], rs_table_out);
			end
			issue_next_test = clear_issue_next_test();
			check_issue_next_correct(issue_next_test, issue_next);
			assert(~rs_full) else #1 exit_on_error;
			assert(free_rows_next == (`RS_SIZE-(i+1))) else #1 exit_on_error;

			reset = 1'b1;
			@(posedge clock)
			`DELAY
			reset = 1'b0;
			$display("\n");
		end

		for(int i = 0; i < `NUM_TYPE_FU; i += 1) begin 
			if(NUM_OF_FU_TYPE[i] > 1'b1) begin
				test_multiple_fu = 1'b1;
				test_fu = i;
			end
		end

		reset = 1'b1;
		@(posedge clock);
		reset = 1'b0;
		enable = 1'b1;
		$display("###########################################################################");
		$display("****************** TEST6 : Test multiple issue to same FU *****************");
		$display("###########################################################################\n");

		//dispatch 3 inst
		for(int j = 0; j < `SS_SIZE; j += 1) begin
			dispatch_valid[j] = 1'b0;
			inst_in[j] = EMPTY_ROW;
		end
		issue_next_test = clear_issue_next_test();

		//set up instructions being dispatched
		for(int i = 0; i < `NUM_TYPE_FU; i += 1) begin
			for(int j = 0; j < NUM_OF_FU_TYPE[i]; j += 1) begin
				inst_T = $unsigned(j);
				inst_T1 = $unsigned(`NUM_PHYS_REG - 1);
				inst_T2 = $unsigned(`NUM_GEN_REG - i);
				$display("**************DISPATCH FU_NAME[%d] R%d R%d R%d***************", i, inst_T1, inst_T2, inst_T);
				inst_in[`SS_SIZE-(j%`SS_SIZE)-1].inst.alu_func = ALU_ADDQ;
				inst_in[`SS_SIZE-(j%`SS_SIZE)-1].inst.fu_name = $unsigned(i);
				inst_in[`SS_SIZE-(j%`SS_SIZE)-1].inst.valid_inst = 1'b1;
				inst_in[`SS_SIZE-(j%`SS_SIZE)-1].T[$clog2(`NUM_PHYS_REG)-1:0] = inst_T;
				inst_in[`SS_SIZE-(j%`SS_SIZE)-1].T[$clog2(`NUM_PHYS_REG)] = 1'b0;
				inst_in[`SS_SIZE-(j%`SS_SIZE)-1].T1[$clog2(`NUM_PHYS_REG)-1:0] = inst_T1;
				inst_in[`SS_SIZE-(j%`SS_SIZE)-1].T1[$clog2(`NUM_PHYS_REG)] = 1'b0;
				inst_in[`SS_SIZE-(j%`SS_SIZE)-1].T2[$clog2(`NUM_PHYS_REG)-1:0] = inst_T2;
				inst_in[`SS_SIZE-(j%`SS_SIZE)-1].T2[$clog2(`NUM_PHYS_REG)] = 1'b1;
				dispatch_valid[`SS_SIZE-(j%`SS_SIZE)-1] = 1'b1;
				issue_next_test[FU_BASE_IDX[i] + NUM_OF_FU_TYPE[i] - j - 1] = inst_in[`SS_SIZE-(j%`SS_SIZE)-1];
				issue_next_test[FU_BASE_IDX[i] + NUM_OF_FU_TYPE[i] - j - 1].busy = 1'b1;
				issue_next_test[FU_BASE_IDX[i] + NUM_OF_FU_TYPE[i] - j - 1].T1[$clog2(`NUM_PHYS_REG)] = 1'b1;
				//dispatch instructions
				if(((j+1)%`SS_SIZE) == 0 || (j+1) == NUM_OF_FU_TYPE[i]) begin
					@(posedge clock)
					for(int k = 0; k < `SS_SIZE; k += 1) begin
						dispatch_valid[k] = 1'b0;
						inst_in[k].busy = 1'b1;
					end
					@(negedge clock)
					//clear inputs
					for(int k = 0; k < `SS_SIZE; k += 1) begin
						dispatch_valid[k] = 1'b0;
						inst_in[k] = EMPTY_ROW;
					end
				end
			end
			table_out();
		end
		@(posedge clock)
		//commit register
		CDB_in[0] = $unsigned(`NUM_PHYS_REG - 1);
		CAM_en[0] = 1'b1;

		//all instructions should issue
		@(negedge clock)
		table_out();
		table_has_N_entries(`NUM_FU_TOTAL, rs_table_out);
		for(int i = 0; i < `NUM_TYPE_FU; i += 1) begin
			check_has_func(rs_table_out, FU_NAME_VAL[i]);
		end
		check_issue_next_correct(issue_next, issue_next_test);
		assert(free_rows_next == `RS_SIZE) else #1 exit_on_error;
		assert(~rs_full) else #1 exit_on_error;
		
		@(posedge clock)
		`DELAY;
		table_out();
		table_has_N_entries(0, rs_table_out);
		assert(free_rows_next == `RS_SIZE) else #1 exit_on_error;
		assert(~rs_full) else #1 exit_on_error;

		reset = 1'b1;
		@(posedge clock);
		`DELAY;
		reset = 1'b0;
		enable = 1'b1;
		$display("###########################################################################");
		$display("****************** TEST7 : Test multiple commit *****************");
		$display("###########################################################################\n");

		for(int i = 0; i < `SS_SIZE; i += 1) begin
			inst_T = $unsigned(`NUM_GEN_REG - i);
			if(i % 2) begin
				inst_T1 = $unsigned(i);
				inst_T2 = $unsigned(`NUM_PHYS_REG - i);
			end else begin
				inst_T1 = $unsigned(`NUM_PHYS_REG - i);
				inst_T2 = $unsigned(i);
			end
			inst_in[i].inst.fu_name = i;
			inst_in[i].inst.valid_inst = 1'b1;
			inst_in[i].T[$clog2(`NUM_PHYS_REG)-1:0] = inst_T;
			inst_in[i].T[$clog2(`NUM_PHYS_REG)] = 1'b0;
			inst_in[i].T1[$clog2(`NUM_PHYS_REG)-1:0] = inst_T1;
			inst_in[i].T2[$clog2(`NUM_PHYS_REG)-1:0] = inst_T2;
			dispatch_valid[i] = 1'b1;
			if(i%2) begin
				inst_in[i].T1[$clog2(`NUM_PHYS_REG)] = 1'b0;
				inst_in[i].T2[$clog2(`NUM_PHYS_REG)] = 1'b1;
			end else begin
				inst_in[i].T1[$clog2(`NUM_PHYS_REG)] = 1'b1;
				inst_in[i].T2[$clog2(`NUM_PHYS_REG)] = 1'b0;
			end
		end

		//check they are in table
		@(posedge clock)
		`DELAY;
		for(int i = 0; i < `SS_SIZE; i += 1) begin
			dispatch_valid[i] = 1'b0;
			inst_in[i].busy = 1'b1;
		end
		@(negedge clock)
		`DELAY;
		table_out();
		table_has_N_entries(`SS_SIZE, rs_table_out);
		for(int i = `SS_SIZE - 1; i >= 0; i -= 1) begin
			entry_exists_in_table(inst_in[i], rs_table_out);
		end
		issue_next_test = clear_issue_next_test();
		check_issue_next_correct(issue_next_test, issue_next);
		assert(~rs_full) else #1 exit_on_error;
		assert(free_rows_next == (`RS_SIZE-`SS_SIZE)) else #1 exit_on_error;

		for(int i = 0; i < `SS_SIZE; i += 1) begin
			issue_next_test[FU_BASE_IDX[i]+NUM_OF_FU_TYPE[i]-1] = inst_in[i];
			issue_next_test[FU_BASE_IDX[i]+NUM_OF_FU_TYPE[i]-1].T1[$clog2(`NUM_PHYS_REG)] = 1'b1;
			issue_next_test[FU_BASE_IDX[i]+NUM_OF_FU_TYPE[i]-1].T2[$clog2(`NUM_PHYS_REG)] = 1'b1;
			CDB_in[i] = i;
			CAM_en[i] = 1'b1;
		end
		`DELAY;
		table_out();
		check_issue_next_correct(issue_next_test, issue_next);
		assert(~rs_full) else #1 exit_on_error;
		assert(free_rows_next == (`RS_SIZE)) else #1 exit_on_error;
		@(posedge clock)
		`DELAY;

		table_has_N_entries(0, rs_table_out);
		assert(~rs_full) else #1 exit_on_error;
		assert(free_rows_next == (`RS_SIZE)) else #1 exit_on_error;

		$display("@@@Passed");
		$finish;
	end
endmodule
