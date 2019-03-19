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



	// set clock change
	always `CLOCK_PERIOD clock = ~clock;

	initial begin

		// monitor wires
		$monitor("clock: %b reset: %b enable: %b T_old: %d dispatch_en: %b num_free_entries: %d empty: %b free_reg: %d branch_incorrect: %b", 
				clock, reset, enable, T_old, dispatch_en, num_free_entries, empty, free_reg, branch_incorrect);

		// initialize

		$display("ALL TESTS Passed");
		$finish;
	end


endmodule
