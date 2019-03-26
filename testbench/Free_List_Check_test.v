`include "../sys_defs.vh"

`define DELAY #2
`define CLOCK_PERIOD #10

module testbench;

	// parameters

	parameter ONE = 1'b1;
	parameter ZERO = 1'b0;

	// initialize wires

	// input wires
	logic clock;
	logic enable;
	PHYS_REG [`FL_SIZE - 1:0] free_list_in;
	logic [$clog2(`FL_SIZE):0] tail_in;
	
	// output wires
	PHYS_REG [`FL_SIZE - 1:0] free_list_check;
	logic [$clog2(`FL_SIZE):0] tail_check;

	// test wires
	PHYS_REG [`FL_SIZE - 1:0] free_list_test;
	logic [$clog2(`FL_SIZE):0] tail_test;

	// initialize module

	`DUT(Free_List_Check) flc0(
		// input wires
		.clock(clock),
		.enable(enable),
		.free_list_in(free_list_in),
		.tail_in(tail_in),

		// output wires
		.free_list_check(free_list_check),
		.tail_check(tail_check)
	);

	// TASKS
	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	task set_random_free_list;
		begin
			for (int i = 0; i < `FL_SIZE; ++i) begin
				free_list_in[i] = $urandom_range(`NUM_PHYS_REG, 0);
			end
			tail_in = $urandom_range(`FL_SIZE, 0);
		end
	endtask

	// set clock change
	always `CLOCK_PERIOD clock = ~clock;

	initial begin

		// monitor wires
		$monitor("clock: %b enable: %b tail_in: %d tail_check: %d",
			clock, enable, tail_in, tail_check);

		// intial values
		clock = ZERO;
		enable = ZERO;
		tail_in = 0;

		$display("Testing Single Write...");

		@(negedge clock);
		enable = ONE;
		set_random_free_list;
		free_list_test = free_list_in;
		tail_test = tail_in;

		@(posedge clock);
		`DELAY;
		enable = ZERO;
		assert(free_list_test == free_list_check) else #1 exit_on_error;
		assert(tail_test == tail_check) else #1 exit_on_error;

		$display("Single Write Passed");

		$display("Testing Single No Write...");

		@(negedge clock);
		enable = ZERO;
		set_random_free_list;

		@(posedge clock);
		`DELAY;
		assert(free_list_test == free_list_check) else #1 exit_on_error;
		assert(tail_test == tail_check) else #1 exit_on_error;

		$display("No Single Write Passed");

		$display("Testing Multiple Random Enable...");

		for (int i = 0; i < 100; ++i) begin
			@(negedge clock);
			enable = $urandom_range(1, 0);
			set_random_free_list;
			if (enable) begin
				free_list_test = free_list_in;
				tail_test = tail_in;
			end

			@(posedge clock);
			`DELAY;
			assert(free_list_test == free_list_check) else #1 exit_on_error;
			assert(tail_test == tail_check) else #1 exit_on_error;
		end

		$display("Multiple Random Enable Passed");

		$display("ALL TESTS Passed");
		$finish;
	end


endmodule
