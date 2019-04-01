`include "../../sys_defs.vh"
`define DEBUG

`define DELAY #2

module testbench;
	logic clock, reset, enable;
	PHYS_REG [`SS_SIZE-1:0] T_old_in; // Comes from Map Table During Dispatch
	PHYS_REG [`SS_SIZE-1:0] T_new_in; // Comes from Free List During Dispatch
	PHYS_REG [`SS_SIZE-1:0] CDB_tag_in; // Comes from CDB during Commit
	logic	 [`SS_SIZE-1:0] CAM_en; // Comes from CDB during Commit
	logic 	 [`SS_SIZE-1:0] dispatch_en; // Structural Hazard detection during Dispatch
	logic	 branch_not_taken;
    //Outputs
    ROB_ROW_T [`SS_SIZE-1:0] retire_out, retire_test;
	//PHYS_REG [`SS_SIZE-1:0] T_free_out, T_free_test; // Output for Retire Stage goes to Free List
	//PHYS_REG [`SS_SIZE-1:0] T_arch_out, T_arch_test; // Output for Retire Stage goes to Arch Map
	//logic 	 [`SS_SIZE-1:0] T_out_valid, T_out_valid_test;
	logic [$clog2(`ROB_SIZE):0] free_rows_next_out, free_rows_next_test;
    logic 						full_out, full_test;

    logic [$clog2(`ROB_SIZE):0] tail_out, head_out;
    logic [$clog2(`ROB_SIZE):0] tail_next_out, head_next_out;
    ROB_ROW_T [`ROB_SIZE-1:0] ROB_table_out, ROB_table_test;
   	logic [`ROB_SIZE-1:0] ready_to_retire_out;
	logic [`SS_SIZE-1:0][$clog2(`ROB_SIZE):0] retire_idx_out;
	logic [`SS_SIZE-1:0] retire_idx_valid_out;
	logic [`SS_SIZE-1:0][$clog2(`ROB_SIZE):0] dispatch_idx_out;


    `DUT(ROB) ROB0(
        //inputs
        .clock(clock),
        .reset(reset),
        .enable(enable),
        .T_old_in(T_old_in),
        .T_new_in(T_new_in),
        .CDB_tag_in(CDB_tag_in),
        .CAM_en(CAM_en),
        .dispatch_en(dispatch_en),
        .branch_not_taken(branch_not_taken),

        //outputs
        .retire_out(retire_out),
        .free_rows_next(free_rows_next_out),
        .full(full_out),
        .tail_out(tail_out),
        .head_out(head_out),
        .tail_next_out(tail_next_out),
        .head_next_out(head_next_out),
        .ROB_table_out(ROB_table_out),
        .ready_to_retire_out(ready_to_retire_out),
        .retire_idx_out(retire_idx_out),
        .retire_idx_valid_out(retire_idx_valid_out),
        .dispatch_idx_out(dispatch_idx_out)
    );

    always #10 clock = ~clock;

    typedef ROB_ROW_T [`ROB_SIZE-1:0] table_t;

    function table_t clear_rob_table_test;
		begin
			for (integer i = 0; i < `ROB_SIZE; i += 1) begin
				clear_rob_table_test[i].T_new = `DUMMY_REG;
				clear_rob_table_test[i].T_old = `DUMMY_REG;
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

    task table_out;
		begin
			$display("**********************************************************\n");
			$display("--------------------- ROB TABLE --------------------------\n");
			$display("head = %d, tail = %d", head_out, tail_out);
			for(integer i = `ROB_SIZE-1; i >= 0; i -= 1) begin
				$display("Row = %d, busy = %d, T_old = %7.0b, T_new = %7.0b", i, ROB_table_out[i].busy, ROB_table_out[i].T_old, ROB_table_out[i].T_new);
			end
				$display("ROB full = %b, free_rows_next = %d", full_out, free_rows_next_out);
				$display("ready_to_retire_out: %d", ready_to_retire_out[`ROB_SIZE-1]);
			for(int i = `SS_SIZE-1; i >= 0; i -= 1) begin
				$display("retire_idx_out[%d]: %d", i, retire_idx_out[i]);
				$display("retire_idx_valid_out[%d]: %d", i, retire_idx_valid_out[i]);
				$display("dispatch_idx_out[%d]: %d", i, dispatch_idx_out[i]);
			end
			$display("head_next_out: %d", head_next_out);
			$display("tail_next_out: %d", tail_next_out);
            $display("**********************************************************\n");

            $display("**********************************************************\n");
			$display("----------------------- retire_out ----------------------------\n");
			for(integer i = `SS_SIZE-1; i >= 0; i -= 1) begin
				$display("Row: %d, T_old: %7.0b, T_new: %7.0b, busy: %b", i, retire_out[i].T_old, retire_out[i].T_new, retire_out[i].busy);
			end
			$display("**********************************************************\n");
        end
    endtask

    task table_test_out;
		begin
				$display("**********************************************************\n");
				$display("------------------------ ROB TABLE TEST ----------------------------\n");

			for(integer i = `ROB_SIZE-1; i >= 0;i -= 1) begin
				$display("ROB_Row = %d, busy = %d, T_old = %7.0b, T_new = %7.0b", i, ROB_table_test[i].busy, ROB_table_test[i].T_old, ROB_table_test[i].T_new);
			end
				$display("ROB full = %b, free_rows_next = %d", full_test, free_rows_next_test);			
			$display("*******************************************************************\n");

			$display("**********************************************************\n");
			$display("----------------------- retire_test ----------------------------\n");
			for(integer i = `SS_SIZE-1; i >= 0; i -= 1) begin
				$display("Row: %d, T_old: %7.0b, T_new: %7.0b, busy: %b", i, retire_test[i].T_old, retire_test[i].T_new, retire_test[i].busy);
			end
			$display("**********************************************************\n");
		end
	endtask

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
					if (rob_table_out[i].T_new[$clog2(`NUM_PHYS_REG)-1:0] == tag) begin
						assert(rob_table_out[i].T_new[$clog2(`NUM_PHYS_REG)]) else #1 exit_on_error;
					end
				end
			end
			return;
		end
	endtask

	task check_correct;
		begin
			for (int i = 0; i < `ROB_SIZE; i += 1) begin
				assert(ROB_table_test[i].busy === ROB_table_out[i].busy) else #1 exit_on_error;
				if(ROB_table_test[i].busy) begin
					assert(ROB_table_test[i] === ROB_table_out[i]) else #1 exit_on_error;
				end
			end
			assert(full_out == full_test) else #1 exit_on_error;
			assert(free_rows_next_out == free_rows_next_test) else #1 exit_on_error;
			for(int i = 0; i < `SS_SIZE; i += 1) begin
				assert(retire_out[i].busy === retire_test[i].busy) else #1 exit_on_error;
				if(retire_test[i].busy) begin
					assert(retire_out[i].T_old === retire_test[i].T_old) else #1 exit_on_error;
					assert(retire_out[i].T_new === retire_test[i].T_new) else #1 exit_on_error;
				end
			end
		end
	endtask

	// helper variables
	logic first = 1'b0;
	logic second = 1'b0;
	ROB_ROW_T inst_1;
	ROB_ROW_T inst_2;
	int T_new_counter = `NUM_GEN_REG;
	int retire_idx_counter;
	int dispatch_idx_counter;
	bit looped = 0;
	
	initial begin
		$monitor("Clock: %4.0f, reset: %b, enable:%b, ", clock, reset, enable);	
		
		// Initial value
		clock = 1'b0;
		reset = 1'b0;
		enable = 1'b0;
		T_old_in = {`SS_SIZE{`DUMMY_REG}};
		T_new_in = {`SS_SIZE{`DUMMY_REG}};
		CDB_tag_in = {`SS_SIZE{`DUMMY_REG}};
		CAM_en = {`SS_SIZE{1'b0}};
		dispatch_en = {`SS_SIZE{1'b0}};
		branch_not_taken = 1'b0; 

		//test variables
		ROB_table_test = clear_rob_table_test();
		full_test = 1'b0;
		free_rows_next_test = 16;
		for(int i = 0; i < `SS_SIZE; i += 1) begin
			retire_test[i].T_new = `DUMMY_REG;
			retire_test[i].T_old = `DUMMY_REG;
			retire_test[i].busy = 1'b0;
		end

		//reset
		@(negedge clock);
		reset = 1;
		@(negedge clock);
		table_out();
		check_correct();

		reset = 0;
		@(posedge clock);
		`DELAY
		table_out();
		$display("###########################################################################");
		$display("************** TEST 1 : Dispatch and retire one instruction ***************");
		$display("###########################################################################\n"); 

		$display("*********************** DISPATCH ADDQ R1 R2 R3 ****************************");
		enable = 1;
		T_old_in[`SS_SIZE-1] = 3;
		T_old_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_new_in[`SS_SIZE-1] = T_new_counter;
		dispatch_en[`SS_SIZE-1] = 1'b1;

		//update test variables
		free_rows_next_test -= 1;

		@(negedge clock);
		table_out();
		check_correct();

		@(posedge clock);
		`DELAY;
		dispatch_en[`SS_SIZE-1] = 1'b0;
		`DELAY;
		ROB_table_test[`ROB_SIZE-1].T_new = T_new_in[`SS_SIZE-1];
		ROB_table_test[`ROB_SIZE-1].T_old = T_old_in[`SS_SIZE-1];
		ROB_table_test[`ROB_SIZE-1].busy = 1'b1;
		table_out();
		check_correct();

		//commit T_new
		CDB_tag_in[`SS_SIZE-1] = T_new_counter;
		CAM_en[`SS_SIZE-1] = 1'b1;

		@(negedge clock);
		retire_test[`SS_SIZE-1] = ROB_table_test[`ROB_SIZE-1];
		retire_test[`SS_SIZE-1].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
		free_rows_next_test += 1;
		table_out();
		check_correct();

		@(posedge clock);
		`DELAY;
		CAM_en[`SS_SIZE-1] = 1'b0;
		ROB_table_test[`ROB_SIZE-1].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
		ROB_table_test[`ROB_SIZE-1].busy = 1'b0;
		retire_test[`SS_SIZE-1].busy = 1'b0;
		table_out();
		check_correct();

		$display("###########################################################################");
		$display("***** TEST 2 : Dispatch five instructions, then retire. Tests ENABLE ******");
		$display("###########################################################################\n"); 

		for(int i = 0; i < 5; i += 1) begin
			$display("*********************** DISPATCH ADDQ R1 R2 R%d ****************************", i);
			enable = 1'b0;
			T_old_in[`SS_SIZE-1] = i;
			T_old_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)] = 1'b1;
			T_new_in[`SS_SIZE-1] = T_new_counter;
			T_new_counter += 1;
			dispatch_en[`SS_SIZE-1] = 1'b1;

			@(negedge clock);
			table_out();
			check_correct();

			@(posedge clock);
			`DELAY;
			enable = 1'b1;
			//update test variables
			free_rows_next_test -= 1;

			@(negedge clock);
			table_out();
			check_correct();

			@(posedge clock);
			`DELAY;
			dispatch_en[`SS_SIZE-1] = 1'b0;
			`DELAY;
			ROB_table_test[`ROB_SIZE-(i + 1)].T_new = T_new_in[`SS_SIZE-1];
			ROB_table_test[`ROB_SIZE-(i + 1)].T_old = T_old_in[`SS_SIZE-1];
			ROB_table_test[`ROB_SIZE-(i + 1)].busy = 1'b1;
			table_out();
			check_correct();
		end
		T_new_counter -= 5;
		for(int i = 0; i < 5; i += 1) begin
			//commit T_new
			enable = 1'b0;
			CDB_tag_in[`SS_SIZE-1] = T_new_counter;
			T_new_counter += 1;
			CAM_en[`SS_SIZE-1] = 1'b1;

			@(posedge clock);
			`DELAY;
			CAM_en[`SS_SIZE-1] = 1'b0;
			ROB_table_test[`ROB_SIZE-(i + 1)].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
			table_out();
			check_correct();

			enable = 1'b1;
			@(negedge clock);
			retire_test[`SS_SIZE-1] = ROB_table_test[`ROB_SIZE-(i + 1)];
			free_rows_next_test += 1;
			table_out();
			check_correct();

			@(posedge clock);
			`DELAY;
			ROB_table_test[`ROB_SIZE-(i + 1)].busy = 1'b0;
			retire_test[`SS_SIZE-1].busy = 1'b0;
			table_out();
			check_correct();
		end

		$display("###########################################################################");
		$display("****** TEST 3 : Dispatch instructions until tail loops, then retire *******");
		$display("###########################################################################\n"); 
		T_new_counter -= 5;
		for(int i = 4; i <= `ROB_SIZE; i += 1) begin
			$display("*********************** DISPATCH ADDQ R1 R2 R%d ****************************", i + 1);
			T_old_in[`SS_SIZE-1] = i + 1;
			T_old_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)] = 1'b1;
			T_new_in[`SS_SIZE-1] = T_new_counter;
			T_new_counter += 1;
			dispatch_en[`SS_SIZE-1] = 1'b1;

			//update test variables
			free_rows_next_test -= 1;

			@(negedge clock);
			table_out();
			check_correct();

			@(posedge clock);
			`DELAY;
			dispatch_en[`SS_SIZE-1] = 1'b0;
			`DELAY;
			ROB_table_test[`ROB_SIZE-((i%`ROB_SIZE) + 1)].T_new = T_new_in[`SS_SIZE-1];
			ROB_table_test[`ROB_SIZE-((i%`ROB_SIZE) + 1)].T_old = T_old_in[`SS_SIZE-1];
			ROB_table_test[`ROB_SIZE-((i%`ROB_SIZE) + 1)].busy = 1'b1;
			table_out();
			check_correct();
		end

		T_new_counter -= (`ROB_SIZE - 3);
		for(int i = 4; i <= `ROB_SIZE; i += 1) begin
			//commit T_new
			CDB_tag_in[`SS_SIZE-1] = T_new_counter;
			T_new_counter += 1;
			CAM_en[`SS_SIZE-1] = 1'b1;

			@(negedge clock);
			retire_test[`SS_SIZE-1] = ROB_table_test[`ROB_SIZE-((i%`ROB_SIZE) + 1)];
			retire_test[`SS_SIZE-1].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
			free_rows_next_test += 1;
			table_out();
			check_correct();

			@(posedge clock);
			`DELAY;
			CAM_en[`SS_SIZE-1] = 1'b0;
			ROB_table_test[`ROB_SIZE-((i%`ROB_SIZE) + 1)].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
			ROB_table_test[`ROB_SIZE-((i%`ROB_SIZE) + 1)].busy = 1'b0;
			retire_test[`SS_SIZE-1].busy = 1'b0;
			table_out();
			check_correct();
		end
		T_new_counter -= (`ROB_SIZE - 3);

		$display("###########################################################################");
		$display("****** TEST 4 : Dispatch instruction, then dispatch and retire x 5 ********");
		$display("###########################################################################\n"); 

		$display("*********************** DISPATCH ADDQ R1 R2 R0 ****************************");
		T_old_in[`SS_SIZE-1] = 0;
		T_old_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_new_in[`SS_SIZE-1] = T_new_counter;
		dispatch_en[`SS_SIZE-1] = 1'b1;

		//update test variables
		free_rows_next_test -= 1;

		@(negedge clock);
		table_out();
		check_correct();

		@(posedge clock);
		`DELAY;
		dispatch_en[`SS_SIZE-1] = 1'b0;
		`DELAY;
		ROB_table_test[`ROB_SIZE-1].T_new = T_new_in[`SS_SIZE-1];
		ROB_table_test[`ROB_SIZE-1].T_old = T_old_in[`SS_SIZE-1];
		ROB_table_test[`ROB_SIZE-1].busy = 1'b1;
		table_out();
		check_correct();

		for(int i = 1; i <= 5; i += 1) begin
			//commit T_new
			CDB_tag_in[`SS_SIZE-1] = T_new_counter;
			T_new_counter += 1;
			CAM_en[`SS_SIZE-1] = 1'b1;
			if(i < 5) begin
				$display("*********************** DISPATCH ADDQ R1 R2 R%d ****************************", i);
				T_old_in[`SS_SIZE-1] = i;
				T_old_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)] = 1'b1;
				T_new_in[`SS_SIZE-1] = T_new_counter;
				dispatch_en[`SS_SIZE-1] = 1'b1;
			end
			@(negedge clock);
			retire_test[`SS_SIZE-1] = ROB_table_test[`ROB_SIZE-1];
			retire_test[`SS_SIZE-1].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
			if(i == 5) begin
				free_rows_next_test += 1;
			end
			table_out();
			check_correct();	

			@(posedge clock);
			`DELAY;
			CAM_en[`SS_SIZE-1] = 1'b0;
			dispatch_en[`SS_SIZE-1] = 1'b0;
			`DELAY;
			ROB_table_test[`ROB_SIZE-1].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
			ROB_table_test[`ROB_SIZE-1].busy = 1'b0;
			retire_test[`SS_SIZE-1].busy = 1'b0;
			if(i < 5) begin
				ROB_table_test[`ROB_SIZE-1].T_new = T_new_in[`SS_SIZE-1];
				ROB_table_test[`ROB_SIZE-1].T_old = T_old_in[`SS_SIZE-1];
				ROB_table_test[`ROB_SIZE-1].busy = 1'b1;
			end
			table_out();
			check_correct();	
		end
		T_new_counter -= 5;
		$display("###########################################################################");
		$display("***** TEST 5 : Fill the Rob, retire until head at top, then fill again ****");
		$display("###########################################################################\n"); 

		//run test 2 again to get head and tail to `ROB_SIZE - 1 - 4
		for(int i = 0; i < 5; i += 1) begin
			$display("*********************** DISPATCH ADDQ R1 R2 R%d ****************************", i);
			T_old_in[`SS_SIZE-1] = i;
			T_old_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)] = 1'b1;
			T_new_in[`SS_SIZE-1] = T_new_counter;
			T_new_counter += 1;
			dispatch_en[`SS_SIZE-1] = 1'b1;

			//update test variables
			free_rows_next_test -= 1;

			@(negedge clock);
			check_correct();

			@(posedge clock);
			`DELAY;
			dispatch_en[`SS_SIZE-1] = 1'b0;
			`DELAY;
			ROB_table_test[`ROB_SIZE-(i + 1)].T_new = T_new_in[`SS_SIZE-1];
			ROB_table_test[`ROB_SIZE-(i + 1)].T_old = T_old_in[`SS_SIZE-1];
			ROB_table_test[`ROB_SIZE-(i + 1)].busy = 1'b1;
			check_correct();
		end
		T_new_counter -= 5;
		for(int i = 0; i < 5; i += 1) begin
			//commit T_new
			CDB_tag_in[`SS_SIZE-1] = T_new_counter;
			T_new_counter += 1;
			CAM_en[`SS_SIZE-1] = 1'b1;

			@(negedge clock);
			retire_test[`SS_SIZE-1] = ROB_table_test[`ROB_SIZE-(i + 1)];
			retire_test[`SS_SIZE-1].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
			free_rows_next_test += 1;
			check_correct();

			@(posedge clock);
			`DELAY;
			CAM_en[`SS_SIZE-1] = 1'b0;
			ROB_table_test[`ROB_SIZE-(i + 1)].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
			ROB_table_test[`ROB_SIZE-(i + 1)].busy = 1'b0;
			retire_test[`SS_SIZE-1].busy = 1'b0;
			check_correct();
		end
		table_out();

		T_new_counter -= 1;
		for(int i = 4; i < (`ROB_SIZE + 4); i += 1) begin
			$display("*********************** DISPATCH ADDQ R1 R2 R%d ****************************", i + 1);
			T_old_in[`SS_SIZE-1] = i + 1;
			T_old_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)] = 1'b1;
			T_new_in[`SS_SIZE-1] = T_new_counter;
			T_new_counter += 1;
			dispatch_en[`SS_SIZE-1] = 1'b1;

			//update test variables
			free_rows_next_test -= 1;

			@(negedge clock);
			table_out();
			check_correct();

			@(posedge clock);
			`DELAY;
			dispatch_en[`SS_SIZE-1] = 1'b0;
			`DELAY;
			ROB_table_test[`ROB_SIZE-((i%`ROB_SIZE) + 1)].T_new = T_new_in[`SS_SIZE-1];
			ROB_table_test[`ROB_SIZE-((i%`ROB_SIZE) + 1)].T_old = T_old_in[`SS_SIZE-1];
			ROB_table_test[`ROB_SIZE-((i%`ROB_SIZE) + 1)].busy = 1'b1;
			if(i == (`ROB_SIZE + 3)) begin
				full_test = 1'b1;
			end
			table_out();
			check_correct();
			if(i == (`ROB_SIZE - 1)) begin
				T_new_counter -= `ROB_SIZE;
			end
		end

		for(int i = 4; i < `ROB_SIZE; i += 1) begin
			//commit T_new
			CDB_tag_in[`SS_SIZE-1] = T_new_counter;
			T_new_counter += 1;
			CAM_en[`SS_SIZE-1] = 1'b1;

			@(negedge clock);
			retire_test[`SS_SIZE-1] = ROB_table_test[`ROB_SIZE-((i%`ROB_SIZE) + 1)];
			retire_test[`SS_SIZE-1].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
			free_rows_next_test += 1;
			table_out();
			check_correct();

			@(posedge clock);
			`DELAY;
			CAM_en[`SS_SIZE-1] = 1'b0;
			ROB_table_test[`ROB_SIZE-((i%`ROB_SIZE) + 1)].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
			ROB_table_test[`ROB_SIZE-((i%`ROB_SIZE) + 1)].busy = 1'b0;
			retire_test[`SS_SIZE-1].busy = 1'b0;
			if(i == 4) begin
				full_test = 1'b0;
			end
			table_out();
			check_correct();
		end

		T_new_counter -= (`ROB_SIZE - 4);
		for(int i = 4; i < `ROB_SIZE; i += 1) begin
			$display("*********************** DISPATCH ADDQ R1 R2 R%d ****************************", i + 1);
			T_old_in[`SS_SIZE-1] = i + 1;
			T_old_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)] = 1'b1;
			T_new_in[`SS_SIZE-1] = T_new_counter;
			T_new_counter += 1;
			dispatch_en[`SS_SIZE-1] = 1'b1;

			//update test variables
			free_rows_next_test -= 1;

			@(negedge clock);
			table_out();
			check_correct();

			@(posedge clock);
			`DELAY;
			dispatch_en[`SS_SIZE-1] = 1'b0;
			`DELAY;
			ROB_table_test[`ROB_SIZE-(i + 1)].T_new = T_new_in[`SS_SIZE-1];
			ROB_table_test[`ROB_SIZE-(i + 1)].T_old = T_old_in[`SS_SIZE-1];
			ROB_table_test[`ROB_SIZE-(i + 1)].busy = 1'b1;
			if(i == (`ROB_SIZE - 1)) begin
				full_test = 1'b1;
			end
			table_out();
			check_correct();
		end

		$display("###########################################################################");
		$display("**** TEST 6 : When ROB is full, retire head and dispatch the same cycle ***");
		$display("###########################################################################\n"); 

		T_new_counter -= `ROB_SIZE;
		for(int i = 0; i < `ROB_SIZE; i += 1) begin
			//commit T_new
			CDB_tag_in[`SS_SIZE-1] = T_new_counter;
			T_new_counter += 1;
			CAM_en[`SS_SIZE-1] = 1'b1;
			$display("*********************** DISPATCH ADDQ R1 R2 R%d ****************************", i);
			T_old_in[`SS_SIZE-1] = i;
			T_old_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)] = 1'b1;
			T_new_in[`SS_SIZE-1] = `ROB_SIZE + 1 + i;
			dispatch_en[`SS_SIZE-1] = 1'b1;
			@(negedge clock);
			retire_test[`SS_SIZE-1] = ROB_table_test[`ROB_SIZE-(i + 1)];
			retire_test[`SS_SIZE-1].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
			table_out();
			check_correct();

			@(posedge clock);
			`DELAY;
			CAM_en[`SS_SIZE-1] = 1'b0;
			dispatch_en[`SS_SIZE-1] = 1'b0;
			`DELAY;
			retire_test[`SS_SIZE-1].busy = 1'b0;
			ROB_table_test[`ROB_SIZE-(i+1)].T_new = T_new_in[`SS_SIZE-1];
			ROB_table_test[`ROB_SIZE-(i+1)].T_old = T_old_in[`SS_SIZE-1];
			ROB_table_test[`ROB_SIZE-(i+1)].busy = 1'b1;
			table_out();
			check_correct();	
		end

		$display("###########################################################################");
		$display("********** TEST 7 : Commit not at head, should not retire. RESET **********");
		$display("###########################################################################\n"); 

		for(int i = `ROB_SIZE - 6; i >= 0; i -= 2) begin
			//commit T_new
			CDB_tag_in[`SS_SIZE-1] = `ROB_SIZE + 1 + i;
			CAM_en[`SS_SIZE-1] = 1'b1;

			@(negedge clock);
			if(i == 0) begin
				retire_test[`SS_SIZE-1] = ROB_table_test[`ROB_SIZE-(i + 1)];
				retire_test[`SS_SIZE-1].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
				free_rows_next_test += 1;
			end
			table_out();
			check_correct();

			@(posedge clock);
			`DELAY;
			CAM_en[`SS_SIZE-1] = 1'b0;
			ROB_table_test[`ROB_SIZE-(i + 1)].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
			if(i == 0) begin
				ROB_table_test[`ROB_SIZE-(i + 1)].busy = 1'b0;
				retire_test[`SS_SIZE-1].busy = 1'b0;
				full_test = 1'b0;
			end
			table_out();
			check_correct();
		end
		if(`SS_SIZE == 1) begin
			retire_idx_counter = `ROB_SIZE - 2;
			retire_test[`SS_SIZE-1] = ROB_table_test[retire_idx_counter];
			retire_test[`SS_SIZE-1].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
			free_rows_next_test += 1;
			for(int i = 1; i < 10; i += 2) begin
				//commit T_new
				CDB_tag_in[`SS_SIZE-1] = `ROB_SIZE + 1 + i;
				CAM_en[`SS_SIZE-1] = 1'b1;

				@(negedge clock);
				table_out();
				check_correct();

				@(posedge clock);
				`DELAY;
				CAM_en[`SS_SIZE-1] = 1'b0;
				ROB_table_test[`ROB_SIZE-(i + 1)].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
				ROB_table_test[retire_idx_counter].busy = 1'b0;
				retire_test[`SS_SIZE-1].busy = 1'b0;
				retire_idx_counter -= 1;
				retire_test[`SS_SIZE-1] = ROB_table_test[retire_idx_counter];
				retire_test[`SS_SIZE-1].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
				free_rows_next_test += 1;
				table_out();
				check_correct();
			end
		end

		//reset
		reset = 1'b1;
		@(posedge clock);
		`DELAY;
		reset = 1'b0;
		ROB_table_test = clear_rob_table_test();
		full_test = 1'b0;
		free_rows_next_test = 16;
		for(int i = 0; i < `SS_SIZE; i += 1) begin
			retire_test[i].T_new = `DUMMY_REG;
			retire_test[i].T_old = `DUMMY_REG;
			retire_test[i].busy = 1'b0;
		end

		table_out();
		check_correct();

		$display("###########################################################################");
		$display("******************** TEST 8 : Test branch_not_taken ***********************");
		$display("###########################################################################\n"); 
		T_new_counter = `NUM_GEN_REG;
		for(int i = 0; i < 5; i += 1) begin
			$display("*********************** DISPATCH ADDQ R1 R2 R%d ****************************", i);
			T_old_in[`SS_SIZE-1] = i;
			T_old_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)] = 1'b1;
			T_new_in[`SS_SIZE-1] = T_new_counter;
			T_new_counter += 1;
			dispatch_en[`SS_SIZE-1] = 1'b1;

			//update test variables
			free_rows_next_test -= 1;

			@(negedge clock);
			check_correct();

			@(posedge clock);
			`DELAY;
			dispatch_en[`SS_SIZE-1] = 1'b0;
			`DELAY;
			ROB_table_test[`ROB_SIZE-(i + 1)].T_new = T_new_in[`SS_SIZE-1];
			ROB_table_test[`ROB_SIZE-(i + 1)].T_old = T_old_in[`SS_SIZE-1];
			ROB_table_test[`ROB_SIZE-(i + 1)].busy = 1'b1;
			check_correct();
		end

		//branch mispredicted
		branch_not_taken = 1'b1;
		@(posedge clock);
		`DELAY;
		branch_not_taken = 1'b0;
		ROB_table_test = clear_rob_table_test();
		full_test = 1'b0;
		free_rows_next_test = 16;
		for(int i = 0; i < `SS_SIZE; i += 1) begin
			retire_test[i].T_new = `DUMMY_REG;
			retire_test[i].T_old = `DUMMY_REG;
			retire_test[i].busy = 1'b0;
		end

		if(`SS_SIZE == 1) begin
			$display("@@@Passed");
			$finish;
		end

		$display("###########################################################################");
		$display("************ TEST 9 : Test Superscalar dispatch, commit, retire ***********");
		$display("###########################################################################\n"); 
		T_new_counter = `NUM_GEN_REG;
		dispatch_idx_counter = `ROB_SIZE-1;
		//Dispatch 1, 2, ..., `SS_SIZE
		for(int i = 0; i < `SS_SIZE; i += 1) begin
			for(int j = 0; j < `SS_SIZE; j += 1) begin
				if(j > i) begin
					continue;
				end
				$display("*********************** DISPATCH ADDQ R1 R2 R%d ****************************", i);
				T_old_in[`SS_SIZE-1-j] = `ROB_SIZE-1-(dispatch_idx_counter-j);
				T_old_in[`SS_SIZE-1-j][$clog2(`NUM_PHYS_REG)] = 1'b1;
				T_new_in[`SS_SIZE-1-j] = T_new_counter;
				T_new_counter += 1;
				dispatch_en[`SS_SIZE-1-j] = 1'b1;

				//update test variables
				free_rows_next_test -= 1;
			end
			@(negedge clock);
			table_out();
			check_correct();

			@(posedge clock);
			`DELAY;
			for(int j = 0; j < `SS_SIZE; j += 1) begin
				if(j > i) begin
					continue;
				end
				dispatch_en[`SS_SIZE-1-j] = 1'b0;
				ROB_table_test[dispatch_idx_counter].T_new = T_new_in[`SS_SIZE-1-j];
				ROB_table_test[dispatch_idx_counter].T_old = T_old_in[`SS_SIZE-1-j];
				ROB_table_test[dispatch_idx_counter].busy = 1'b1;
				dispatch_idx_counter -= 1;
			end
			`DELAY;
			table_out();
			check_correct();
		end
		T_new_counter = `NUM_GEN_REG;
		retire_idx_counter = `ROB_SIZE-1;
		//Commit `SS_SIZE, `SS_SIZE-1, ..., 1
		for(int i = 0; i < `SS_SIZE; i += 1) begin
			for(int j = 0; j < `SS_SIZE; j += 1) begin
				if(j > `SS_SIZE-1-i) begin
					continue;
				end
				//commit T_new
				CDB_tag_in[`SS_SIZE-1-j] = T_new_counter;
				T_new_counter += 1;
				CAM_en[`SS_SIZE-1-j] = 1'b1;
			end

			@(negedge clock);
			for(int j = 0; j < `SS_SIZE; j += 1) begin
				if(j > `SS_SIZE-1-i) begin
					continue;
				end
				retire_test[`SS_SIZE-1-j] = ROB_table_test[retire_idx_counter-j];
				retire_test[`SS_SIZE-1-j].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
				free_rows_next_test += 1;
			end
			table_out();
			check_correct();

			@(posedge clock);
			`DELAY;
			for(int j = 0; j < `SS_SIZE; j += 1) begin
				if(j > `SS_SIZE-1-i) begin
					continue;
				end
				CAM_en[`SS_SIZE-1-j] = 1'b0;
				ROB_table_test[retire_idx_counter].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
				ROB_table_test[retire_idx_counter].busy = 1'b0;
				retire_test[`SS_SIZE-1-j].busy = 1'b0;
				retire_idx_counter -= 1;
			end
			table_out();
			check_correct();
		end

		$display("###########################################################################");
		$display("***** TEST 10 : Test Superscalar dispatch, retire when tail/head loop *****");
		$display("###########################################################################\n"); 
		T_new_counter = `NUM_GEN_REG;
		dispatch_idx_counter += 1;
		retire_idx_counter += 1;
		//Dispatch `SS_SIZE until tail loops
		for(int i = 0; ~looped; i += 1) begin
			for(int j = 0; j < `SS_SIZE; j += 1) begin
				$display("*********************** DISPATCH ADDQ R1 R2 R%d ****************************", i);
				T_old_in[`SS_SIZE-1-j] = (i*`SS_SIZE) + j;
				T_old_in[`SS_SIZE-1-j][$clog2(`NUM_PHYS_REG)] = 1'b1;
				T_new_in[`SS_SIZE-1-j] = T_new_counter;
				T_new_counter += 1;
				dispatch_en[`SS_SIZE-1-j] = 1'b1;

				//update test variables
				free_rows_next_test -= 1;
			end
			@(negedge clock);
			table_out();
			check_correct();

			@(posedge clock);
			`DELAY;
			for(int j = 0; j < `SS_SIZE; j += 1) begin
				dispatch_en[`SS_SIZE-1-j] = 1'b0;
				ROB_table_test[dispatch_idx_counter].T_new = T_new_in[`SS_SIZE-1-j];
				ROB_table_test[dispatch_idx_counter].T_old = T_old_in[`SS_SIZE-1-j];
				ROB_table_test[dispatch_idx_counter].busy = 1'b1;
				if(dispatch_idx_counter == 0) begin
					dispatch_idx_counter = `ROB_SIZE - 1;
					looped = 1;
				end else begin
					dispatch_idx_counter -= 1;
				end
			end
			`DELAY;
			table_out();
			table_test_out();
			check_correct();
		end
		T_new_counter = `NUM_GEN_REG;
		looped = 0;
		//Commit `SS_SIZE, `SS_SIZE-1, ..., 1
		for(int i = 0; ~looped; i += 1) begin
			for(int j = 0; j < `SS_SIZE; j += 1) begin
				//commit T_new
				CDB_tag_in[`SS_SIZE-1-j] = T_new_counter;
				T_new_counter += 1;
				CAM_en[`SS_SIZE-1-j] = 1'b1;
			end

			@(negedge clock);
			for(int j = 0; j < `SS_SIZE; j += 1) begin
				retire_test[`SS_SIZE-1-j] = (retire_idx_counter >= j)? ROB_table_test[retire_idx_counter-j] :
																	   ROB_table_test[`ROB_SIZE-(j-retire_idx_counter)];
				retire_test[`SS_SIZE-1-j].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
				free_rows_next_test += 1;
			end
			table_out();
			check_correct();

			@(posedge clock);
			`DELAY;
			for(int j = 0; j < `SS_SIZE; j += 1) begin
				CAM_en[`SS_SIZE-1-j] = 1'b0;
				ROB_table_test[retire_idx_counter].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
				ROB_table_test[retire_idx_counter].busy = 1'b0;
				retire_test[`SS_SIZE-1-j].busy = 1'b0;
				if(retire_idx_counter == 0) begin 
					retire_idx_counter = `ROB_SIZE - 1;
					looped = 1;
				end else begin
					retire_idx_counter -= 1;
				end
			end
			table_out();
			check_correct();
		end

		$display("###########################################################################");
		$display("*** TEST 11 : Test Superscalar dispatch/retire with 1, 2, ..., `SS_SIZE ***");
		$display("###########################################################################\n"); 
		T_new_counter = `NUM_GEN_REG;
		dispatch_idx_counter = `ROB_SIZE-1;
		retire_idx_counter = `ROB_SIZE-1;
		looped = 0;
		for(int i = 1; ~looped; i = (i%(`SS_SIZE-1)+1)) begin
			//Dispatch 1, 2, ..., `SS_SIZE
			for(int j = 0; j < `SS_SIZE; j += 1) begin
				if(j > i) begin
					continue;
				end
				$display("*********************** DISPATCH ADDQ R1 R2 R%d ****************************", i);
				T_old_in[`SS_SIZE-1-j] = `ROB_SIZE-1-(dispatch_idx_counter-j);
				T_old_in[`SS_SIZE-1-j][$clog2(`NUM_PHYS_REG)] = 1'b1;
				T_new_in[`SS_SIZE-1-j] = (T_new_counter+j);
				dispatch_en[`SS_SIZE-1-j] = 1'b1;

				//update test variables
				free_rows_next_test -= 1;
			end
			@(negedge clock);
			table_out();
			check_correct();

			@(posedge clock);
			`DELAY;
			for(int j = 0; j < `SS_SIZE; j += 1) begin
				if(j > i) begin
					continue;
				end
				dispatch_en[`SS_SIZE-1-j] = 1'b0;
				ROB_table_test[dispatch_idx_counter].T_new = T_new_in[`SS_SIZE-1-j];
				ROB_table_test[dispatch_idx_counter].T_old = T_old_in[`SS_SIZE-1-j];
				ROB_table_test[dispatch_idx_counter].busy = 1'b1;
				if(j < i) begin 
					if(dispatch_idx_counter == 0) begin
						dispatch_idx_counter = `ROB_SIZE - 1;
						looped = 1;
					end else begin
						dispatch_idx_counter -= 1;
					end
				end
			end
			`DELAY;
			table_out();
			check_correct();

			//Commit 1, 2, ..., `SS_SIZE
			for(int j = 0; j < `SS_SIZE; j += 1) begin
				if(j > i) begin
					continue;
				end
				//commit T_new
				CDB_tag_in[`SS_SIZE-1-j] = T_new_counter;
				T_new_counter += 1;
				CAM_en[`SS_SIZE-1-j] = 1'b1;
			end

			@(negedge clock);
			for(int j = 0; j < `SS_SIZE; j += 1) begin
				if(j > i) begin
					continue;
				end
				if(retire_idx_counter >= j) begin
					retire_test[`SS_SIZE-1-j] = ROB_table_test[retire_idx_counter-j];
				end else begin
					retire_test[`SS_SIZE-1-j] = ROB_table_test[`ROB_SIZE-(j - retire_idx_counter)];
				end
				retire_test[`SS_SIZE-1-j].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
				free_rows_next_test += 1;
			end
			table_out();
			table_test_out();
			check_correct();

			@(posedge clock);
			`DELAY;
			for(int j = 0; j < `SS_SIZE; j += 1) begin
				if(j > i) begin
					continue;
				end
				CAM_en[`SS_SIZE-1-j] = 1'b0;
				ROB_table_test[retire_idx_counter].T_new[$clog2(`NUM_PHYS_REG)] = 1'b1;
				ROB_table_test[retire_idx_counter].busy = 1'b0;
				retire_test[`SS_SIZE-1-j].busy = 1'b0;
				if(j < i) begin
					if(retire_idx_counter == 0) begin 
						retire_idx_counter = `ROB_SIZE - 1;
						looped = 1;
					end else begin
						retire_idx_counter -= 1;
					end
				end
			end
			table_out();
			check_correct();
		end

		$display("@@@Passed");
		$finish;
	end
	
endmodule