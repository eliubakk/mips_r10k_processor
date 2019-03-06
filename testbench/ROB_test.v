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

    function table_t clear_rs_table_test;
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
				$display("ROB full = %b, rob_free_entries = %d",rs_full, issue_cnt);			
			$display("*******************************************************************\n");
		end
	endtask

    