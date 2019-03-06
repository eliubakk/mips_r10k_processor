`include "sys_defs.vh"

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

	// output wires
	logic [$clog2(`NUM_PHYS_REG)-1:0] num_free_entries;
	logic empty;
	PHYS_REG free_reg;

	
	// initialize module

	`DUT(Free_List) fl0(
		// inputs
		.clock(clock),
		.reset(reset),
		.enable(enable),
		.T_old(T_old),
		.dispatch_en(dispatch_en),
		// outputs
		.num_free_entries(num_free_entries),
		.empty(empty),
		.free_reg(free_reg)
	);


	// TASKS
	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask


	// set clock change
	always `CLOCK_PERIOD clock = ~clock;

	initial begin

		// monitor wires
		$monitor("clock: %b reset: %b enable: %b T_old: %d dispatch_en: %b num_free_entries: %d empty: %b free_reg: %d", 
				clock, reset, enable, T_old, dispatch_en, num_free_entries, empty, free_reg);

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
			assert(num_free_entries == (`NUM_PHYS_REG - `NUM_GEN_REG - 1)) else #1 exit_on_error;
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

		$display("ALL TESTS Passed");
		$finish;
	end


endmodule
