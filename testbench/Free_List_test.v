`include "../../sys_defs.vh"

`define DELAY #2
`define CLOCK_PERIOD #10

module testbench;

	// parameters

	parameter ONE = 1'b1;
	parameter ZERO = 1'b0;

	// initialize wires

	// input wires
	logic clock;
	logic reset;
	logic enable;
	PHYS_REG T_old;
	logic dispatch_en;

	logic branch_incorrect = ZERO;
	PHYS_REG [`NUM_PHYS_REG-1:0] free_check_point;
	logic [$clog2(`NUM_PHYS_REG):0] tail_check_point;

	// output wires
	logic [$clog2(`NUM_PHYS_REG):0] num_free_entries;
	logic empty;
	PHYS_REG free_reg;
	PHYS_REG last_free_reg;

	PHYS_REG [`NUM_PHYS_REG-1:0] free_list_out;
	logic [$clog2(`NUM_PHYS_REG):0] tail_out;


	
	// initialize module

	`DUT(Free_List) fl0(
		// inputs
		.clock(clock),
		.reset(reset),
		.enable(enable),
		.T_old(T_old),

		.branch_incorrect(branch_incorrect),
		.free_check_point(free_check_point),
		.tail_check_point(tail_check_point),

		.dispatch_en(dispatch_en),
		// outputs
		.num_free_entries(num_free_entries),
		.empty(empty),
		.free_reg(free_reg),

		.free_list_out(free_list_out),
		.tail_out(tail_out)
	);


	// TASKS
	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask


	task print_free_list;
		input	PHYS_REG [`NUM_PHYS_REG-1:0] list;
		begin
			for (int i = 0; i < `NUM_PHYS_REG; ++i) begin
				$display("i = %d tag: %d", i, list[i]);
			end	
		end
	endtask

	task check_free_list;
		input	PHYS_REG [`NUM_PHYS_REG-1:0] first;
		input 	[$clog2(`NUM_PHYS_REG):0] first_tail;
		input	PHYS_REG [`NUM_PHYS_REG-1:0] second;
		input 	[$clog2(`NUM_PHYS_REG):0] second_tail;
		begin
			assert (first_tail == second_tail) else #1 exit_on_error;
			for (int i = 0; i < first_tail; ++i) begin
				assert(first[i] == second[i]) else #1 exit_on_error;
			end
		end
	endtask

	task check_not_ready;
		input PHYS_REG r;
		begin
			assert(r[$clog2(`NUM_PHYS_REG)] == 1'b0) else #1 exit_on_error;
		end
	endtask


	// set clock change
	always `CLOCK_PERIOD clock = ~clock;

	initial begin

		// monitor wires
		$monitor("clock: %b reset: %b enable: %b T_old: %d dispatch_en: %b num_free_entries: %d empty: %b free_reg: %d branch_incorrect: %b", 
				clock, reset, enable, T_old, dispatch_en, num_free_entries, empty, free_reg, branch_incorrect);

		// intial values
		clock = ZERO;
		reset = ZERO;
		enable = ZERO;
		T_old =  0;
		dispatch_en = ZERO;

		$display("Testing Reset...");
		@(negedge clock);
		reset = ONE;

		@(posedge clock);
		`DELAY;
		assert(num_free_entries == (`NUM_PHYS_REG - `NUM_GEN_REG)) else #1 exit_on_error;
		assert(!empty) else #1 exit_on_error;

		$display("Reset Test Passed");

		$display("Testing Retire One Register...");
		for (int i = 0; i < (`NUM_PHYS_REG - `NUM_GEN_REG); ++i) begin
			// reset
			@(negedge clock);
			reset = ONE;

			@(posedge clock);
			`DELAY;
			reset = ZERO;

			// retire
			@(negedge clock);
			T_old = i;
			enable = ONE;
			dispatch_en = ZERO;
			reset = ZERO;

			@(posedge clock);
			`DELAY;
			assert(num_free_entries == (`NUM_PHYS_REG - `NUM_GEN_REG + 1)) else #1 exit_on_error;
			assert(!empty) else #1 exit_on_error;
			enable = ZERO;

			// reset
			@(negedge clock);
			reset = ONE;

			@(posedge clock);
			`DELAY;
			reset = ZERO;
		end

		$display("Retire One Register Passed");

		$display("Testing Dispatch One Register...");

		// reset
		@(negedge clock);
		reset = ONE;

		@(posedge clock);
		`DELAY;
		reset = ZERO;

		// dispatch
		@(negedge clock);
		enable = ZERO;
		dispatch_en = ONE;
		reset = ZERO;
		last_free_reg = free_reg;

		@(posedge clock);
		`DELAY;
		assert(num_free_entries == (`NUM_PHYS_REG - `NUM_GEN_REG - 1)) else #1 exit_on_error;
		assert(!empty) else #1 exit_on_error;
		assert(last_free_reg != free_reg) else #1 exit_on_error;
		dispatch_en = ZERO;

		// reset
		@(negedge clock);
		reset = ONE;

		@(posedge clock);
		`DELAY;
		reset = ZERO;

		$display("Dispatch One Register Passed");

		$display("Testing Multiple Register Retire...");

		// reset
		@(negedge clock);
		reset = ONE;

		@(posedge clock);
		`DELAY;
		reset = ZERO;

		// retire multiple
		for (int i = 0; i < `NUM_GEN_REG; ++i) begin
			@(negedge clock);
			T_old = i;
			enable = ONE;
			dispatch_en = ZERO;
			reset = ZERO;
			last_free_reg = free_reg;

			@(posedge clock);
			`DELAY;
			enable = ZERO;
			assert(num_free_entries == (`NUM_PHYS_REG - `NUM_GEN_REG + 1 + i)) else #1 exit_on_error;
			assert(!empty) else #1 exit_on_error;
			assert(last_free_reg == free_reg) else #1 exit_on_error;
		end

		$display("Multiple Register Retire Passed");

		$display("Testing Register Retire Past PhysReg Size...");
		// retire a register
		@(negedge clock);
		T_old = 6;
		enable = ONE;
		dispatch_en = ZERO;
		reset = ZERO;
		last_free_reg = free_reg;

		@(posedge clock);
		`DELAY;
		enable = ZERO;
		assert(num_free_entries == `NUM_PHYS_REG) else #1 exit_on_error;
		assert(!empty) else #1 exit_on_error;
		assert(last_free_reg == free_reg) else #1 exit_on_error;

		$display("Register Retire Past PhysReg Size Passed");

		$display("Testing Dispatch All Free Register...");

		for (int i = 0; i < `NUM_PHYS_REG; ++i) begin
			// dispatch register
			@(negedge clock);
			enable = ZERO;
			dispatch_en = ONE;
			reset = ZERO;
			last_free_reg = free_reg;

			@(posedge clock);
			`DELAY;
			dispatch_en = ZERO;
			assert(num_free_entries == `NUM_PHYS_REG - 1 - i) else #1 exit_on_error;
			if (i == `NUM_PHYS_REG - 1) begin
				assert(empty) else #1 exit_on_error;
			end else begin
				assert(!empty) else #1 exit_on_error;
				assert(last_free_reg != free_reg) else #1 exit_on_error;
			end
		end

		$display("Dispatch All Free Register Passed");

		$display("Testing Dispatch Past Empty Free List...");

		// dispatch register
		@(negedge clock);
		enable = ZERO;
		dispatch_en = ONE;
		reset = ZERO;

		@(posedge clock);
		`DELAY;
		dispatch_en = ZERO;
		assert(num_free_entries == 0) else #1 exit_on_error;
		assert(empty) else #1 exit_on_error;

		$display("Dispatch Past Empty Free List Passed");


		$display("Testing Basic Branch Incorrect...");

		// retire a few registers
		// retire reg 5, 7, 9, 14

		@(negedge clock);
		enable = ONE;
		T_old = 5;

		@(posedge clock);
		`DELAY;
		assert(num_free_entries == 1) else #1 exit_on_error;
		assert(!empty) else #1 exit_on_error;
		assert(free_reg == 5) else #1 exit_on_error;	

		@(negedge clock);
		enable = ONE;
		T_old = 7;

		@(posedge clock);
		`DELAY;
		assert(num_free_entries == 2) else #1 exit_on_error;
		assert(!empty) else #1 exit_on_error;
		assert(free_reg == 5) else #1 exit_on_error;	


		@(negedge clock);
		enable = ONE;
		T_old = 9;

		@(posedge clock);
		`DELAY;
		assert(num_free_entries == 3) else #1 exit_on_error;
		assert(!empty) else #1 exit_on_error;
		assert(free_reg == 5) else #1 exit_on_error;	


		@(negedge clock);
		enable = ONE;
		T_old = 14;

		@(posedge clock);
		`DELAY;
		assert(num_free_entries == 4) else #1 exit_on_error;
		assert(!empty) else #1 exit_on_error;
		assert(free_reg == 5) else #1 exit_on_error;	
		enable = ZERO;

		// update the checkpoint free list
		free_check_point[0] = 8;
		free_check_point[1] = 9;
		free_check_point[2] = 12;
		tail_check_point = 3;

		// set branch_incorrect to high
		@(negedge clock);
		branch_incorrect = ONE;

		@(posedge clock);
		`DELAY;
		assert(num_free_entries == 3) else #1 exit_on_error;
		assert(!empty) else #1 exit_on_error;
		assert(free_reg == 8) else #1 exit_on_error;

		check_free_list(free_list_out, tail_out, free_check_point, tail_check_point);
		
		$display("Basic Branch Incorrect Passed");

		$display("Testing Multiple Branch Incorrect...");

		branch_incorrect = ZERO;

		for (int i = 0; i < `NUM_PHYS_REG; ++i) begin
			@(negedge clock);
			for (int j = 0; j < i; ++j) begin
				free_check_point[j] = $urandom_range(63, 0);
			end
			tail_check_point = i;
			branch_incorrect = ONE;

			@(posedge clock);
			`DELAY;
			branch_incorrect = ZERO;
			check_free_list(free_list_out, tail_out, free_check_point, tail_check_point);
		end

		$display("Multiple Branch Incorrect Passed");

		$display("Testing Dispatch Not Ready...");

		@(negedge clock);
		reset = 1;

		@(posedge clock);
		`DELAY;
		reset = 0;
		// free list should be reset

		while (!empty) begin
			@(negedge clock);
			dispatch_en = 1;

			@(posedge clock);
			check_not_ready(free_reg);
			`DELAY;
			
		end

		// now that free reg is empty, lets start retiring ready regs
		for (int i = 0; i < `NUM_PHYS_REG; ++i) begin
			@(negedge clock);
			dispatch_en = 0;
			enable = 1;
			T_old = i;
			T_old[$clog2(`NUM_PHYS_REG)] = 1'b1;

			@(posedge clock);
			`DELAY;
			assert(num_free_entries == (i + 1)) else #1 exit_on_error;
			assert(empty == 0) else #1 exit_on_error;
		end

		// now similar while loop to check for not ready
		while (!empty) begin
			@(negedge clock);
			enable = 0;
			dispatch_en = 1;

			@(posedge clock);
			check_not_ready(free_reg);
			`DELAY;
		end

		$display("Dispatch Not Ready Passed");

		$display("ALL TESTS Passed");
		$finish;
	end


endmodule
