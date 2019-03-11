`include "sys_defs.vh"
`define DEBUG

`define DELAY #2

module testbench;
	logic clock, reset, enable;
	PHYS_REG 		                T_old_in; // Comes from Map Table During Dispatch
	PHYS_REG		                T_new_in; // Comes from Free List During Dispatch
	PHYS_REG 		                CDB_tag_in; // Comes from CDB during Commit
	logic			                CDB_en; // Comes from CDB during Commit
	logic			                dispatch_en; // Structural Hazard detection during Dispatch
	logic			                branch_not_taken;
    //Outputs
	PHYS_REG 	                    T_old_out; // Output for Retire Stage goes to Free List
	PHYS_REG                        T_new_out; // Output for Retire Stage goes to Arch Map
	logic 				            T_old_valid, T_new_valid;
	logic [$clog2(`ROB_SIZE) - 1:0] rob_free_entries;
    logic                           rob_full;

    `DUT(ROB) ROB0(
        //inputs
        .clock(clock),
        .reset(reset),
        .enable(enable),
        .T_old_in(T_old_in),
        .T_new_in(T_new_in),
        .CDB_tag_in(CDB_tag_in),
        .CDB_en(CDB_en),
        .dispatch_en(dispatch_en),
        .branch_not_taken(branch_not_taken),

        //outputs
        .T_old_out(T_old_out),
        .T_new_out(T_new_out),
        .T_old_valid(T_old_valid),
        .T_new_valid(T_new_valid),
        .rob_free_entries(rob_free_entries),
        .rob_full(rob_full)
    )

    always #10 clock = ~clock;

    typedef ROB_ROW_T [`ROB_SIZE] table_t;

    function table_t clear_rob_table_test;
		begin
			for (integer i = 0; i < `RS_SIZE; i += 1) begin
				// rs_table_test[i] = '{($bits(RS_ROW_T)){0} };
				clear_rob_table_test[i].T_new_out = `DUMMY_REG;
				clear_rob_table_test[i].T_old_out = `DUMMY_REG;
				clear_rob_table_test[i].busy = 1'b0;
			end
		end
	endfunction

    task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

    task print_rob_entry;
		input ROB_ROW_T rob_entry;
		begin
			$display("\tT_old_out = %7.0b", rob_entry.T_old_out);
			$display("\tT_new_out = %7.0b", rob_entry.T_new_out);
            $display("\tBusy = %b", rob_entry.busy);
		end
	endtask

    task print_rob_table;
		input ROB_ROW_T  [(`ROB_SIZE - 1):0]	rob_table;
		begin
			$display("**********************************************************\n");
			$display("------------------------ROB TABLE----------------------------\n");

			for(integer i=0;i<`ROB_SIZE;i=i+1) begin
				$display("Entry: %d", i);
				print_rob_entry(rob_table[i]);
			end
			$display("*******************************************************************\n");
		end
	endtask

    task table_out;
		begin
				$display("**********************************************************\n");
				$display("------------------------ROB TABLE----------------------------\n");

			for(integer i=0;i<`ROB_SIZE;i=i+1) begin
				$display("ROB_Row = %d,  busy = %d, T_old_out = %7.0b, T_new_out = %7.0b ", i, rob_table_out[i].busy, rob_table_out[i].T_old_out, rob_table_out[i].T_new_out);
			end
				$display("ROB full = %b, rob_free_entries = %d",rob_full, rob_free_entries);
            $display("*******************************************************************\n");
        end
    endtask

    task table_test_out;
		begin
				$display("**********************************************************\n");
				$display("------------------------ROB TABLE----------------------------\n");

			for(integer i=0;i<`ROB_SIZE;i=i+1) begin
				$display("ROB_Row = %d,  busy = %d, T_old_out = %7.0b, T_new_out = %7.0b ", i, rob_table_test[i].busy, rob_table_test[i].T_old_out, rob_table_test[i].T_new_out);
			end
				$display("ROB full = %b, rob_free_entries = %d",rob_full_test, rob_free_entries_test);			
			$display("*******************************************************************\n");
		end
	endtask

    //task entry_exists_in_table;
		////input ROB_ROW_T inst_in;
		//input ROB_ROW_T [(`ROB_SIZE - 1):0] rob_table_out;
		//begin
		//	integer i;
		//	for (i = 0; i < `ROB_SIZE; i += 1) begin
		//		if (rob_table_out[i].busy) begin
		//			//if (rs_table_out[i] == inst_in) begin
		//			return;
		//			//end
		//		end
		//	end
		//	$display("failed in entry_exists_in_table");
		//	#1 exit_on_error;
		//end
	//endtask

	//task entry_not_in_table;
	//	//input RS_ROW_T inst_in;
	//	input ROB_ROW_T [(`ROB_SIZE - 1):0] rob_table_out;
	//	begin
	//		integer i;
	//		for (i = 0; i < `ROB_SIZE; i += 1) begin
	//			if (rob_table_out[i].busy) begin
	////				if (rs_table_out[i] == inst_in) begin
		//				$display("failed in entry_not_in_table");
		//				#1 exit_on_error;
		////			end
			//	end
		//	end
		//	return;
		//end
	//endtask

	task table_has_N_entries;
		input integer count;
		input ROB_ROW_T [(`ROB_SIZE - 1):0] rob_table_out;
		begin
			integer _count = 0;
			integer i;
			_count = 0;
			for (i = 0; i < `ROB_SIZE; i += 1) begin
				if (rob_table_out[i].busy) begin
					_count += 1;
				end
			end
			assert(count == _count) else #1 exit_on_error;
		end
	endtask

	task tags_now_ready;
		input integer tag;
		input ROB_ROW_T [(`ROB_SIZE - 1):0] rob_table_out;
		begin
			integer i;
			for (i = 0; i < `ROB_SIZE; i += 1) begin
				if (rob_table_out[i].busy) begin
					if (rob_table_out[i].T_old_out[$clog2(`NUM_PHYS_REG)-1:0] == tag) begin
						assert(rob_table_out[i].T_old_out[$clog2(`NUM_PHYS_REG)]) else #1 exit_on_error;
					end
					if (rob_table_out[i].T_new_out[$clog2(`NUM_PHYS_REG)-1:0] == tag) begin
						assert(rob_table_out[i].T_new_out[$clog2(`NUM_PHYS_REG)]) else #1 exit_on_error;
					end
				end
			end
			return;
		end
	endtask

	task rob_table_equal;
		input ROB_ROW_T [(`ROB_SIZE - 1):0] rob_table;
		input ROB_ROW_T [(`ROB_SIZE - 1):0] rob_table_test;
		begin
			for (int i = 0; i < `ROB_SIZE; i += 1) begin
				assert(rob_table_test[i] === rob_table[i]) else #1 exit_on_error;
			end
		end
	endtask

	// helper variables
	logic first = 1'b0;
	logic second = 1'b0;
	ROB_ROW_T inst_1;
	ROB_ROW_T inst_2;
	
	initial begin
		
	/*	$monitor("Clock: %4.0f, reset: $b, enable:%b, CAM_en:%b, CDB_in:%h, .dispatch_valid:%b, inst_in:%h, LSQ_busy : %b, \n rs_table_out:%h", clock, reset, enable, CAM_en, CDB_in,dispatch_valid, inst_in, LSQ_busy, rs_table_out);	
 	*/
		$monitor("Clock: %4.0f, reset: %b, enable:%b, ", clock, reset, enable);	
		
		// Initial value
		clock = 1'b0;
		reset = 1'b0;
		enable = 1'b0;
		T_old_in = 7'b1111111;
		T_new_in = 7'b1111111;
		CDB_tag_in = 7'b1111111;
		CDB_en = 1'b0;
		dispatch_en = 1'b0;
		branch_not_taken = 1'b0; 

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
		T_old_in = 7'b1111111;
		T_new_in = 7'b1111111;
		CDB_tag_in = 7'b1111111;
		CDB_en = 1'b0;
		dispatch_en = 1'b1;
		branch_not_taken = 1'b0;	
		$display("****************************************DISPATCH MULT R1 R2 R3************************************************");

		// At this cycle, rob_table should be empty
		// because currently dispatched instruction is seen
		// in rob_table on the next cycle
		@(posedge clock);
		`DELAY;

		table_has_N_entries(1, rob_table_out);
		@(negedge clock);	

		$display("@@@Passed");
		$finish;
	end
	
endmodule