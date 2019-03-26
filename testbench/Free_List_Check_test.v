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

		$display("ALL TESTS Passed");
		$finish;
	end


endmodule
