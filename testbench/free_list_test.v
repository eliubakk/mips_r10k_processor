`include "sys_defs.vh"

`define DELAY #2
`define CLOCK_PERIOD #10

module testbench;
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

	Free_list(
		.clock(clock),
		.reset(reset),
		.enable(enable),
		.T_old(T_old),
		.dispatch_en(dispatch_en);
		.num_free_entries(num_free_entries),
		.empty(empty),
		.free_reg(free_reg)
	);

	// set clock change
	always `CLOCK_PERIOD clock = ~clock;

	initial begin

		// monitor wires
		$monitor();

	end


endmodule
