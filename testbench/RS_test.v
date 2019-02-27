`include "sys_defs.vh"
`define DEBUG

`define DELAY #2

module testbench;
	logic clock, reset, enable;
	logic    		CAM_en;
	PHYS_REG 		CDB_in;
	logic			dispatch_valid;
	RS_ROW_T		inst_in;
	logic	 [1:0]		LSQ_busy;
	logic 					branch_not_taken;
	

	RS_ROW_T   	 [(`RS_SIZE - 1):0] 	rs_table_out;
	RS_ROW_T 	 [(`NUM_FU -1 ):0] issue_next  ; 
	logic				rs_full;
	logic [$clog2(`NUM_FU) - 1:0]	issue_cnt;
	RS_ROW_T   	[(`RS_SIZE - 1):0] 	rs_table_test ;
	RS_ROW_T 	[(`NUM_FU -1 ):0]	issue_next_test   ; 

	
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
		.branch_not_taken(branch_not_taken),

		// outputs
		.rs_table_out(rs_table_out), 
		.issue_out(issue_next), 
		.issue_cnt(issue_cnt), 
		.rs_full(rs_full)
	 );

	
	always #10 clock = ~clock;

	// need to update this

	typedef RS_ROW_T [`RS_SIZE] table_t;

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
				clear_rs_table_test[i].inst.rd_mem = 1'b0;
				clear_rs_table_test[i].inst.wr_mem = 1'b0;
				clear_rs_table_test[i].inst.ldl_mem = 1'b0;
				clear_rs_table_test[i].inst.stc_mem = 1'b0;
				clear_rs_table_test[i].inst.cond_branch = 1'b0;
				clear_rs_table_test[i].inst.uncond_branch = 1'b0;
				clear_rs_table_test[i].inst.halt = 1'b0;
				clear_rs_table_test[i].inst.cpuid = 1'b0;
				clear_rs_table_test[i].inst.illegal = 1'b0;
				clear_rs_table_test[i].inst.valid_inst = 1'b0;
				clear_rs_table_test[i].T = `DUMMY_REG;
				clear_rs_table_test[i].T1 = `DUMMY_REG;
				clear_rs_table_test[i].T2 = `DUMMY_REG;
				// $display("dummy reg: %b", `DUMMY_REG);
				clear_rs_table_test[i].busy = 1'b0;
			end
		end
	endfunction

	typedef RS_ROW_T [`NUM_FU] issue_t;

	function issue_t clear_issue_next_test;
	begin
		for (integer i = 0; i < `NUM_FU; i += 1) begin
			clear_issue_next_test[i].inst.opa_select = ALU_OPA_IS_REGA;
			clear_issue_next_test[i].inst.opb_select = ALU_OPB_IS_REGB;
			clear_issue_next_test[i].inst.dest_reg = DEST_IS_REGC;
			clear_issue_next_test[i].inst.alu_func = ALU_ADDQ;
			clear_issue_next_test[i].inst.fu_name = FU_ALU;
			clear_issue_next_test[i].inst.rd_mem = 1'b0;
			clear_issue_next_test[i].inst.wr_mem = 1'b0;
			clear_issue_next_test[i].inst.ldl_mem = 1'b0;
			clear_issue_next_test[i].inst.stc_mem = 1'b0;
			clear_issue_next_test[i].inst.cond_branch = 1'b0;
			clear_issue_next_test[i].inst.uncond_branch = 1'b0;
			clear_issue_next_test[i].inst.halt = 1'b0;
			clear_issue_next_test[i].inst.cpuid = 1'b0;
			clear_issue_next_test[i].inst.illegal = 1'b0;
			clear_issue_next_test[i].inst.valid_inst = 1'b0;
			clear_issue_next_test[i].T = `DUMMY_REG;
			clear_issue_next_test[i].T1 = `DUMMY_REG;
			clear_issue_next_test[i].T2 = `DUMMY_REG;
			clear_issue_next_test[i].busy = 1'b0;
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

	task print_rs_entry;
		input RS_ROW_T rs_entry;
		begin
			$display("\tBusy = %b", rs_entry.busy);
			$display("\tFU_Name = %d", rs_entry.inst.fu_name);
			$display("\tT = %7.0b", rs_entry.T);
			$display("\tT1 = %7.0b", rs_entry.T1);
			$display("\tT2 = %7.0b", rs_entry.T2);
		end
	endtask

	task print_rs_table;
		input RS_ROW_T  [(`RS_SIZE - 1):0]	rs_table;
		begin
			$display("**********************************************************\n");
			$display("------------------------RS TABLE----------------------------\n");

			for(integer i=0;i<`RS_SIZE;i=i+1) begin
				$display("Entry: %d", i);
				print_rs_entry(rs_table[i]);
			end
			$display("*******************************************************************\n");

		end
	endtask

	task print_issue_table;
		input RS_ROW_T [`NUM_FU-1:0] issue_table;
		begin
			$display("**********************************************************\n");
			$display("------------------------ISSUE TABLE----------------------------\n");

			for(integer i=0;i<`NUM_FU;i=i+1) begin
				$display("Entry: %d", i);
				print_rs_entry(issue_table[i]);
			end
			$display("*******************************************************************\n");

		end
	endtask

	task table_out;
		begin
				$display("**********************************************************\n");
				$display("------------------------RS TABLE----------------------------\n");

			for(integer i=0;i<`RS_SIZE;i=i+1) begin
				$display("RS_Row = %d,  busy = %d, Function = %d, T = %7.0b T1 = %7.0b, T2 = %7.0b ", i, rs_table_out[i].busy, rs_table_out[i].inst.fu_name,rs_table_out[i].T, rs_table_out[i].T1, rs_table_out[i].T2);
			end
				$display("RS full = %b, issue_cnt = %d",rs_full, issue_cnt);
				$display("-----------------------Issue table-----------------------------------\n");
			for(integer i=0;i<`NUM_FU;i=i+1) begin
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
			// $display("checking for inst_in...");
			// print_rs_entry(inst_in);
			for (i = 0; i < `RS_SIZE; i += 1) begin
				// $display("At entry %d", i);
				// print_rs_entry(rs_table_out[i]);
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
		input RS_ROW_T [(`NUM_FU -1 ):0] issue_next;
		input RS_ROW_T [(`NUM_FU -1 ):0] issue_next_test;
		begin
			for (int i = 0; i < `NUM_FU; i += 1) begin
				if (issue_next[i] != issue_next_test[i]) begin
					$display("failed at check_issue_next_correct");
					exit_on_error;
				end
			end
			return;
		end
	endtask

	// helper variables
	logic first = 1'b0;
	logic second = 1'b0;
	RS_ROW_T inst_1;
	RS_ROW_T inst_2;
	
	initial begin
		
	/*	$monitor("Clock: %4.0f, reset: $b, enable:%b, CAM_en:%b, CDB_in:%h, .dispatch_valid:%b, inst_in:%h, LSQ_busy : %b, \n rs_table_out:%h", clock, reset, enable, CAM_en, CDB_in,dispatch_valid, inst_in, LSQ_busy, rs_table_out);	
 	*/
		$monitor("Clock: %4.0f, reset: %b, enable:%b, ", clock, reset, enable);	

		// Initial value
		clock = 1'b0;
		reset = 1'b0;
		enable = 1'b0;
		CAM_en = 1'b0;
		CDB_in = {($clog2(`NUM_PHYS_REG) - 1){1'b0}};
		dispatch_valid = 1'b0;
		LSQ_busy = 2'b0;	
		branch_not_taken = 1'b0;

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
		$display("****************************************DISPATCH MULT R1 R2 R3************************************************");

		// At this cycle, rs_table should be empty
		// because currently dispatched instruction is seen
		// in rs_table on the next cycle

		inst_in.inst.opa_select = ALU_OPA_IS_REGA;
		inst_in.inst.opb_select = ALU_OPB_IS_REGB;
		inst_in.inst.dest_reg = DEST_IS_REGC;
		inst_in.inst.alu_func = ALU_MULQ;
		inst_in.inst.fu_name = FU_MULT;
		inst_in.inst.rd_mem = 1'b0;
		inst_in.inst.wr_mem = 1'b0;
		inst_in.inst.ldl_mem = 1'b0;
		inst_in.inst.stc_mem = 1'b0;
		inst_in.inst.cond_branch = 1'b0;
		inst_in.inst.uncond_branch = 1'b0;
		inst_in.inst.halt = 1'b0;
		inst_in.inst.cpuid = 1'b0;
		inst_in.inst.illegal = 1'b0;
		inst_in.inst.valid_inst = 1'b1;
		inst_in.T = 7'd3;
		inst_in.T1 = 7'b1000001;
		inst_in.T2 = 7'b1000010;
		inst_in.busy = 1'b0;
		branch_not_taken=1'b0;

		@(posedge clock);
		`DELAY;

		table_has_N_entries(1, rs_table_out);
		inst_in.busy = 1'b1;
		entry_exists_in_table(inst_in, rs_table_out);

		inst_in.busy = 1'b1;
		issue_next_test = clear_issue_next_test();
		issue_next_test[3] = inst_in;
		check_issue_next_correct(issue_next_test, issue_next);

		@(negedge clock);

		// At this cycle, rs_table should have the previously dispatched
		// instruction. 
		// The previously dispatched instruction should be issued

		dispatch_valid = 0;

		$display("**********************************************DISPATCH BR R1 R2 R4, Issue MULT R1 R2 R3****************************");	
		inst_in.inst.opa_select = ALU_OPA_IS_REGA;
		inst_in.inst.opb_select = ALU_OPB_IS_REGB;
		inst_in.inst.dest_reg = DEST_IS_REGC;
		inst_in.inst.alu_func = ALU_ADDQ;
		inst_in.inst.fu_name = FU_BR; // Branch
		inst_in.inst.rd_mem = 1'b0;
		inst_in.inst.wr_mem = 1'b0;
		inst_in.inst.ldl_mem = 1'b0;
		inst_in.inst.stc_mem = 1'b0;
		inst_in.inst.cond_branch = 1'b0;
		inst_in.inst.uncond_branch = 1'b0;
		inst_in.inst.halt = 1'b0;
		inst_in.inst.cpuid = 1'b0;
		inst_in.inst.illegal = 1'b0;
		inst_in.inst.valid_inst = 1'b1;
		inst_in.T = 7'd4;
		inst_in.T1 = 7'b1000001;
		inst_in.T2 = 7'b1000010;
		inst_in.busy = 1'b0;

		// The previously dispatched instruction should be the next
		// issued instruction. 

		dispatch_valid = 1;

		@(posedge clock);
		`DELAY;

		dispatch_valid = 1'b0;
		inst_in.busy = 1'b1;
		table_has_N_entries(1, rs_table_out);
		entry_exists_in_table(inst_in, rs_table_out);
		issue_next_test = clear_issue_next_test();
		issue_next_test[4] = inst_in;
		check_issue_next_correct(issue_next, issue_next_test);

		@(negedge clock);

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
		dispatch_valid = 1'b1;
		inst_in.inst.opa_select = ALU_OPA_IS_MEM_DISP;
		inst_in.inst.opb_select = ALU_OPB_IS_REGB;
		inst_in.inst.dest_reg = DEST_IS_REGA;
		inst_in.inst.alu_func = ALU_ADDQ;
		inst_in.inst.fu_name = FU_LD;
		inst_in.inst.rd_mem = 1'b1;
		inst_in.inst.wr_mem = 1'b0;
		inst_in.inst.ldl_mem = 1'b1;
		inst_in.inst.stc_mem = 1'b0;
		inst_in.inst.cond_branch = 1'b0;
		inst_in.inst.uncond_branch = 1'b0;
		inst_in.inst.halt = 1'b0;
		inst_in.inst.cpuid = 1'b0;
		inst_in.inst.illegal = 1'b0;
		inst_in.inst.valid_inst = 1'b1;
		inst_in.T = 7'd5;
		inst_in.T1 = 7'b1111111;
		inst_in.T2 = 7'b1000001;
		inst_in.busy = 1'b0;
		branch_not_taken= 1'b1;

		@(posedge clock);
		`DELAY;

		// Because branch is not taken, the dispatched instruction
		// should not be in the rs_table. 
		dispatch_valid = 1'b0;
		table_has_N_entries(0, rs_table_out);
		inst_in.busy = 1'b1;
		entry_not_in_table(inst_in, rs_table_out);

		@(negedge clock);

		// At this cycle, dispatch this next instruction. 
		// Nothing should be issued for the next cycle since 
		// rs_table has been cleared in the previous cycle. 

		$display("*******************************************DISPATCH ST R1 DISP R6, ISSUE LD R1 DISP R5, EXECUTE BR R1 R2 R4************************");	
		inst_in.inst.opa_select = ALU_OPA_IS_MEM_DISP;
		inst_in.inst.opb_select = ALU_OPB_IS_REGB;
		inst_in.inst.dest_reg = DEST_IS_REGA;
		inst_in.inst.alu_func = ALU_ADDQ;
		inst_in.inst.fu_name = FU_ST;
		inst_in.inst.rd_mem = 1'b0;
		inst_in.inst.wr_mem = 1'b1;
		inst_in.inst.ldl_mem = 1'b0;
		inst_in.inst.stc_mem = 1'b1;
		inst_in.inst.cond_branch = 1'b0;
		inst_in.inst.uncond_branch = 1'b0;
		inst_in.inst.halt = 1'b0;
		inst_in.inst.cpuid = 1'b0;
		inst_in.inst.illegal = 1'b0;
		inst_in.inst.valid_inst = 1'b1;
		inst_in.T = 7'b1111111;
		inst_in.T1 = 7'b0000001;
		inst_in.T2 = 7'b0000110;
		inst_in.busy = 1'b0;
		branch_not_taken= 1'b0;
		dispatch_valid = 1'b1;

		@(posedge clock);
		`DELAY;

		// ST should not be issued because both tags are not ready.
		inst_in.busy = 1'b1;
		table_has_N_entries(1, rs_table_out);
		entry_exists_in_table(inst_in, rs_table_out);
		issue_next_test = clear_issue_next_test();
		check_issue_next_correct(issue_next, issue_next_test);

		@(negedge clock);

		$display("*************************************RESET *********************************");	
		reset = 1'b1;
		
		@(posedge clock);
		`DELAY;

		rs_table_test = clear_rs_table_test();
		issue_next_test = clear_issue_next_test();
		assert(rs_table_out == rs_table_test) else #1 exit_on_error;
		assert(issue_next_test == issue_next) else #1 exit_on_error;

        $display("###########################################################################");
		$display("***********************TEST2 : Multiple issue and CAM*********************");
		$display("###########################################################################\n");
	
		@(negedge clock);
		reset = 0;
		enable = 1;
		dispatch_valid = 1;
		LSQ_busy = 0;
		branch_not_taken = 0;		
		$display("****************************************DISPATCH MULT R1(Xready) R2 R3************************************************");

			inst_in.inst.opa_select = ALU_OPA_IS_REGA;
			inst_in.inst.opb_select = ALU_OPB_IS_REGB;
			inst_in.inst.dest_reg = DEST_IS_REGC;
			inst_in.inst.alu_func = ALU_MULQ;
			inst_in.inst.fu_name = FU_MULT;
			inst_in.inst.rd_mem = 1'b0;
			inst_in.inst.wr_mem = 1'b0;
			inst_in.inst.ldl_mem = 1'b0;
			inst_in.inst.stc_mem = 1'b0;
			inst_in.inst.cond_branch = 1'b0;
			inst_in.inst.uncond_branch = 1'b0;
			inst_in.inst.halt = 1'b0;
			inst_in.inst.cpuid = 1'b0;
			inst_in.inst.illegal = 1'b0;
			inst_in.inst.valid_inst = 1'b1;
			inst_in.T = 7'd3;
			inst_in.T1 = 7'b0000001;
			inst_in.T2 = 7'b1000010;
			inst_in.busy = 1'b0;
			branch_not_taken=1'b0;
		
		// table_out();
		table_has_N_entries(0, rs_table_out);

		@(posedge clock);
		`DELAY;

		inst_in.busy = 1'b1;
		table_has_N_entries(1, rs_table_out);
		entry_exists_in_table(inst_in, rs_table_out);
		issue_next_test = clear_issue_next_test();
		check_issue_next_correct(issue_next, issue_next_test);


		@(negedge clock);

		reset = 0;
		enable = 1;
		dispatch_valid = 1;
		LSQ_busy = 0;
		branch_not_taken = 0;

		$display("****************************************DISPATCH ADD R1(Xready) R2 R4************************************************");

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
		inst_in.inst.valid_inst = 1'b1;
		inst_in.T = 7'd4;
		inst_in.T1 = 7'b0000001;
		inst_in.T2 = 7'b1000010;
		inst_in.busy = 1'b0;
		branch_not_taken=1'b0;
        table_has_N_entries(1, rs_table_out);

		
		// table_out();
		@(posedge clock);
		`DELAY;
		
		inst_in.busy = 1'b1;
		table_has_N_entries(2, rs_table_out);
		entry_exists_in_table(inst_in, rs_table_out);
		issue_next_test = clear_issue_next_test();
		check_issue_next_correct(issue_next, issue_next_test);
		reset = 0;
		enable = 1;
		dispatch_valid = 1;
		LSQ_busy = 0;
		branch_not_taken = 0;

		$display("****************************************DISPATCH ADD R1(Xready) R2 R5************************************************");

		@(negedge clock);

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
		inst_in.inst.valid_inst = 1'b1;
		inst_in.T = 7'd5;
		inst_in.T1 = 7'b0000001;
		inst_in.T2 = 7'b1000010;
		inst_in.busy = 1'b0;
		branch_not_taken=1'b0;
		
		// table_out();

		table_has_N_entries(2, rs_table_out);
		@(posedge clock);
		`DELAY;

		inst_in.busy = 1'b1;
		table_has_N_entries(3, rs_table_out);
		entry_exists_in_table(inst_in, rs_table_out);
		issue_next_test = clear_issue_next_test();
		check_issue_next_correct(issue_next, issue_next_test);

		@(negedge clock);
		reset = 0;
		enable = 1;
		dispatch_valid = 0;
		LSQ_busy = 0;
		branch_not_taken = 0;

		$display("****************************************Commit R1, Issue MULT R1 R2 R3, Issue ADD R1 R2 R4, Not issue Add R1 R2 R5************************************************");

		CAM_en = 1;
		CDB_in = 7'b0000001;

		$display("after cam");
		table_out();

		issue_next_test = clear_issue_next_test();
		// set inst_in to mult inst
		inst_in.inst.opa_select = ALU_OPA_IS_REGA;
		inst_in.inst.opb_select = ALU_OPB_IS_REGB;
		inst_in.inst.dest_reg = DEST_IS_REGC;
		inst_in.inst.alu_func = ALU_MULQ;
		inst_in.inst.fu_name = FU_MULT;
		inst_in.inst.rd_mem = 1'b0;
		inst_in.inst.wr_mem = 1'b0;
		inst_in.inst.ldl_mem = 1'b0;
		inst_in.inst.stc_mem = 1'b0;
		inst_in.inst.cond_branch = 1'b0;
		inst_in.inst.uncond_branch = 1'b0;
		inst_in.inst.halt = 1'b0;
		inst_in.inst.cpuid = 1'b0;
		inst_in.inst.illegal = 1'b0;
		inst_in.inst.valid_inst = 1'b1;
		inst_in.T = 7'd3;
		inst_in.T1 = 7'b1000001;
		inst_in.T2 = 7'b1000010;
		inst_in.busy = 1'b1;

		// set the mult

		@(posedge clock);
		`DELAY;
		
		issue_next_test[3] = inst_in;
		assert(issue_next_test[3] == issue_next[3]) else #1 exit_on_error;

		first = 1'b0;
		second = 1'b0;

		inst_1.inst.opa_select = ALU_OPA_IS_REGA;
		inst_1.inst.opb_select = ALU_OPB_IS_REGB;
		inst_1.inst.dest_reg = DEST_IS_REGC;
		inst_1.inst.alu_func = ALU_ADDQ;
		inst_1.inst.fu_name = FU_ALU;
		inst_1.inst.rd_mem = 1'b0;
		inst_1.inst.wr_mem = 1'b0;
		inst_1.inst.ldl_mem = 1'b0;
		inst_1.inst.stc_mem = 1'b0;
		inst_1.inst.cond_branch = 1'b0;
		inst_1.inst.uncond_branch = 1'b0;
		inst_1.inst.halt = 1'b0;
		inst_1.inst.cpuid = 1'b0;
		inst_1.inst.illegal = 1'b0;
		inst_1.inst.valid_inst = 1'b1;
		inst_1.T = 7'd4;
		inst_1.T1 = 7'b1000001;
		inst_1.T2 = 7'b1000010;
		inst_1.busy = 1'b1;


		inst_2.inst.opa_select = ALU_OPA_IS_REGA;
		inst_2.inst.opb_select = ALU_OPB_IS_REGB;
		inst_2.inst.dest_reg = DEST_IS_REGC;
		inst_2.inst.alu_func = ALU_ADDQ;
		inst_2.inst.fu_name = FU_ALU;
		inst_2.inst.rd_mem = 1'b0;
		inst_2.inst.wr_mem = 1'b0;
		inst_2.inst.ldl_mem = 1'b0;
		inst_2.inst.stc_mem = 1'b0;
		inst_2.inst.cond_branch = 1'b0;
		inst_2.inst.uncond_branch = 1'b0;
		inst_2.inst.halt = 1'b0;
		inst_2.inst.cpuid = 1'b0;
		inst_2.inst.illegal = 1'b0;
		inst_2.inst.valid_inst = 1'b1;
		inst_2.T = 7'd5;
		inst_2.T1 = 7'b1000001;
		inst_2.T2 = 7'b1000010;
		inst_2.busy = 1'b1;

		// check that just one of the alu inst was issued
		if (issue_next[0] == inst_1) begin
			first = 1'b1;
		end else if (issue_next[0] == inst_2) begin
			second = 1'b1;
		end else begin
			// if we exit here, it's because none of the ready
			// add instructions were issued
			$display("issue_next[0]");
			print_rs_entry(issue_next[0]);
			print_rs_entry(inst_1);
			print_rs_entry(inst_2);
			$display("here?");
			exit_on_error;
		end

		// check that the mult inst was issued
		$display("start");
		assert(issue_next[3] == inst_in) else #1 exit_on_error;
		$display("second");
		table_has_N_entries(3, rs_table_out);

		@(negedge clock);
		inst_in.busy = 1'b1;
		$display("third");
		table_has_N_entries(1, rs_table_out);
		$display("fourth");
		if (first) begin
			assert(issue_next[0] == inst_2) else #1 exit_on_error;
			$display("fifth");
		end else if (second) begin
			assert(issue_next[0] == inst_1) else #1 exit_on_error;
			$display("sixth");
		end else begin
			// if we got here, that means there is a bigger problem
			// than we know
			$display("uh oh");
			exit_on_error;
		end

		@(negedge clock);
		table_has_N_entries(0, rs_table_out);


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



	// Test for Reset
	// reset = 0;
	// enable = 0;
	// CAM_en = 0;
	// CDB_in = `DUMMY_REG;
	// // inst_in.inst.opa_select = ALU_OPA_IS_REGA;
	// // inst_in.inst.opb_select = ALU_OPB_IS_REGB;
	// // inst_in.inst.dest_reg = DEST_IS_REGC;
	// // inst_in.inst.alu_func = ALU_ADDQ;
	// // inst_in.inst.fu_name = FU_ALU;
	// // inst_in.inst.rd_mem = 0;
	// inst_in.inst = '{ALU_OPA_IS_REGA, ALU_OPB_IS_REGB, DEST_IS_REGC, ALU_ADDQ, FU_ALU, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}; 
	// inst_in.T = {1, 6'd3};
	// inst_in.T1 = {1, 6'd2};
	// inst_in.T2 = {1, 6'd1};
	// inst_in.busy = 1;
	// dispatch_valid = 1;
	// LSQ_busy = 2'b00;


	// @(negedge clock);
	// // Nothing issued since it is reset
	// $display("-------RESET------\n");
	// reset = 1;
	// rs_table_test = clear_rs_table_test();
	// issue_next_test = clear_issue_next_test();

	// // print_rs_table(rs_table_out);
	// // print_rs_table(rs_table_test);
	// assert( rs_table_out == rs_table_test ) else #1 exit_on_error;
	// assert( issue_next == issue_next_test ) else #1 exit_on_error;
	// assert( !issue_cnt) else #1 exit_on_error;
	// assert( !rs_full ) else #1 exit_on_error;
	// $display("Reset 1 passed");
	
	// @(negedge clock);
	// reset = 0;
	// //RS is empty since it is reset
	// assert( rs_table_out == rs_table_test ) else #1 exit_on_error;
	// assert( issue_next == issue_next_test ) else #1 exit_on_error;
	// assert( !issue_cnt) else #1 exit_on_error;
	// assert( !rs_full ) else #1 exit_on_error;
	// $display("Reset 2 passed");

	// @(negedge clock);
	// $display("-------Dispatch One Instruction------\n");
	// // dispatch add p2 p1 p3
	// enable = 1;
	// CAM_en = 0;
	// dispatch_valid = 1;
	// inst_in.inst = '{ALU_OPA_IS_REGA, ALU_OPB_IS_REGB, DEST_IS_REGC, ALU_ADDQ, FU_ALU, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}; 
	// inst_in.T = {1, 6'd3};
	// inst_in.T1 = {1, 6'd2};
	// inst_in.T2 = {1, 6'd1};
	// inst_in.busy = 1;
	// LSQ_busy = 2'b00;
	// assert( issue_next == issue_next_test ) else #1 exit_on_error;
	// assert( !issue_cnt) else #1 exit_on_error;
	// assert( !rs_full ) else #1 exit_on_error;


	// @(negedge clock);
	// entry_exists_in_table(inst_in, rs_table_out);
	// table_has_N_entries(1, rs_table_out);
	// $display("Dispatch 1 instruction passed");

	// $display("-------Issue One Instruction------\n");
	// // issue add p2 p1 p3
	// dispatch_valid = 0;
	// for (int i = 0; i < `NUM_FU; i += 1) begin
	// 	print_rs_entry(issue_next[i]);
	// end
	// $display("here");
	// print_rs_entry(inst_in);
	// assert( issue_next[0] == inst_in ) else #1 exit_on_error;
	// assert( issue_next[`NUM_FU-1:1] == issue_next_test[`NUM_FU-1:1] );
	// assert( issue_cnt == 1) else #1 exit_on_error;
	// assert( !rs_full ) else #1 exit_on_error;

	// @(negedge clock);

	// entry_not_in_table(inst_in, rs_table_out);
	// table_has_N_entries(0, rs_table_out);

	// $display("Issue 1 instruction passed");

	// assert( issue_cnt == 0) else #1 exit_on_error;
	// assert( !rs_full ) else #1 exit_on_error;

	// @(negedge clock);
	// $display("-------Commit One Instruction------\n");
	// // commit add p2 p1 p3
	// CAM_en = 1;
	// CDB_in = {1, 6'd3};

	// @(negedge clock);

	// tags_now_ready(3, rs_table_out);
	// table_has_N_entries(0, rs_table_out);
	// assert( issue_next == issue_next_test ) else #1 exit_on_error;
	// assert( !issue_cnt) else #1 exit_on_error;
	// assert( !rs_full ) else #1 exit_on_error;
	// $display("Commit 1 Instruction passed");

	// $display("-------Issue Multiple Instructions------\n");
	// // dispatch mult p2 p3 p4
	// enable = 1;
	// dispatch_valid = 1;
	// inst_in.inst = '{ALU_OPA_IS_REGA, ALU_OPB_IS_REGB, DEST_IS_REGC, ALU_MULQ, FU_MULT, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}; 
	// inst_in.T = {1, 6'd4};
	// inst_in.T1 = {1, 6'd2};
	// inst_in.T2 = {1, 6'd3};
	// inst_in.busy = 1;

	// assert( issue_next == issue_next_test ) else #1 exit_on_error;
	// assert( !issue_cnt) else #1 exit_on_error;

	// @(negedge clock);

	// entry_exists_in_table(inst_in, rs_table_out);
	// table_has_N_entries(1, rs_table_out);

	// assert( !rs_full ) else #1 exit_on_error;

	// // check for issue for mult
	// // entry_not_in_table(inst_in, rs_table_out);
	// // table_has_N_entries(0, rs_table_out);
	// assert( issue_next[0] == inst_in ) else #1 exit_on_error;
	// assert( issue_next[`NUM_FU-1:1] == issue_next_test[`NUM_FU-1:1] );
	// assert( issue_cnt == 1) else #1 exit_on_error;
	// assert( !rs_full ) else #1 exit_on_error;
	// // dispatch add p4 p5 p6 and
	// dispatch_valid = 1;
	// inst_in.inst = '{ALU_OPA_IS_REGA, ALU_OPB_IS_REGB, DEST_IS_REGC, ALU_ADDQ, FU_ALU, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}; 
	// inst_in.T = {1, 6'd6};
	// inst_in.T1 = {0, 6'd4};
	// inst_in.T2 = {1, 6'd5};
	// inst_in.busy = 1;	

	// assert( issue_next == issue_next_test ) else #1 exit_on_error;
	// assert( !issue_cnt) else #1 exit_on_error;
	// assert( !rs_full ) else #1 exit_on_error;

	// @(negedge clock);
	// entry_exists_in_table(inst_in, rs_table_out);
	// table_has_N_entries(1, rs_table_out);
	// // check nothing is issued
	// assert( issue_next == issue_next_test ) else #1 exit_on_error;
	// assert( !issue_cnt) else #1 exit_on_error;
	// assert( !rs_full ) else #1 exit_on_error;
	// // dispatch add p4 p4 p7
	// dispatch_valid = 1;
	// inst_in.inst = '{ALU_OPA_IS_REGA, ALU_OPB_IS_REGB, DEST_IS_REGC, ALU_ADDQ, FU_ALU, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}; 
	// inst_in.T = {1, 6'd7};
	// inst_in.T1 = {0, 6'd4};
	// inst_in.T2 = {0, 6'd4};
	// inst_in.busy = 1;	

	// assert( issue_next == issue_next_test ) else #1 exit_on_error;
	// assert( !issue_cnt) else #1 exit_on_error;
	// assert( !rs_full ) else #1 exit_on_error;

	// @(negedge clock);
	// entry_exists_in_table(inst_in, rs_table_out);
	// table_has_N_entries(2, rs_table_out);
	// dispatch_valid = 0;
	// // table_has_N_entries(2, rs_table_out);
	// assert( issue_next == issue_next_test ) else #1 exit_on_error;
	// assert( !issue_cnt) else #1 exit_on_error;
	// assert( !rs_full ) else #1 exit_on_error;
	// @(negedge clock);
	// table_has_N_entries(2, rs_table_out);
	// assert( issue_next == issue_next_test ) else #1 exit_on_error;
	// assert( !issue_cnt) else #1 exit_on_error;
	// assert( !rs_full ) else #1 exit_on_error;
	// @(negedge clock);
	// table_has_N_entries(2, rs_table_out);
	// assert( issue_next == issue_next_test ) else #1 exit_on_error;
	// assert( !issue_cnt) else #1 exit_on_error;
	// assert( !rs_full ) else #1 exit_on_error;

	// @(negedge clock);
	// // commit mult p2 p3 p4
	// CAM_en = 1;
	// CDB_in = {1, 6'd4};
	// inst_in.inst = '{ALU_OPA_IS_REGA, ALU_OPB_IS_REGB, DEST_IS_REGC, ALU_ADDQ, FU_ALU, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}; 
	// inst_in.T = {1, 6'd6};
	// inst_in.T1 = {0, 6'd4};
	// inst_in.T2 = {1, 6'd5};
	// issue_next_test[0] = inst_in;
	// inst_in.inst = '{ALU_OPA_IS_REGA, ALU_OPB_IS_REGB, DEST_IS_REGC, ALU_ADDQ, FU_ALU, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}; 
	// inst_in.T = {1, 6'd7};
	// inst_in.T1 = {0, 6'd4};
	// inst_in.T2 = {0, 6'd4};
	// inst_in.busy = 1;	
	// issue_next_test[1] = inst_in;

	// check_issue_next_correct(issue_next, issue_next_test);


	// @(negedge clock);
	// tags_now_ready(4, rs_table_out);

	// // check for 2 issued instructions
	// table_has_N_entries(0, rs_table_out);

	// assert( issue_next == issue_next_test ) else #1 exit_on_error;
	// assert( issue_cnt == 2) else #1 exit_on_error;
	// assert( !rs_full ) else #1 exit_on_error;
	// // clear issue_next_test
	// issue_next_test = clear_issue_next_test();

	// $finish;

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
