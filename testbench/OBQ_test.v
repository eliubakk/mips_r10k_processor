`include "sys_defs.vh"
`define DEBUG
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
	logic write_en;
	OBQ_ROW_T bh_row;
	logic clear_en;
	logic [$clog2(`OBQ_SIZE)-1:0] index;

	// output wires
	OBQ_ROW_T [`OBQ_SIZE-1:0] obq_out;
	logic [$clog2(`OBQ_SIZE)-1:0] tail_out;
	logic bh_pred_valid;
	OBQ_ROW_T bh_pred;

	// test wires
	OBQ_ROW_T [`OBQ_SIZE-1:0] obq_test;
	logic [$clog2(`OBQ_SIZE)-1:0] tail_test;
	
	// initialize module
	`DUT(OBQ) obq0(
		// inputs
		.clock(clock),
		.reset(reset),
		.write_en(write_en),
		.bh_row(bh_row),
		.clear_en(clear_en),
		.index(index),

		// outputs
		.obq_out(obq_out),
		.tail_out(tail_out),
		.bh_pred_valid(bh_pred_valid),
		.bh_pred(bh_pred)
	);

	// TASKS
	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	task obq_equal;
		input OBQ_ROW_T [`OBQ_SIZE-1:0] obq;
		input OBQ_ROW_T [`OBQ_SIZE-1:0] test;
		input [$clog2(`OBQ_SIZE)-1:0] tail;
		input [$clog2(`OBQ_SIZE)-1:0] tail_test;
		begin
			assert(tail == tail_test) else #1 exit_on_error;
			for (int i = 0; i < tail; ++i) begin
				assert(obq[i] == test[i]) else #1 exit_on_error;
			end
		end
	endtask

	// set clock change
	always `CLOCK_PERIOD clock = ~clock;

	initial begin

		// monitor wires
		$monitor("clock: %b reset: %b write_en: %b bh_row: %b clear_en: %b index: %d bh_pred_valid: %b bh_pred: %b",
				clock, reset, write_en, bh_row, clear_en, index, bh_pred_valid, bh_pred);

		// initialize
		clock = ZERO;
		reset = ZERO;
		write_en = ZERO;
		bh_row.branch_history = 0;
		clear_en = ZERO;
		index = 0;

		$display("Testing Reset...");
		@(negedge clock);
		reset = ONE;

		for (int i = 0; i < `OBQ_SIZE; ++i) begin
			obq_test[i].branch_history = 0;
		end
		tail_test = 0;

		@(posedge clock);
		`DELAY;
		obq_equal(obq_out, obq_test, tail_out, tail_test);

		$display("Reset Test Passed");

		$display("ALL TESTS Passed");
		$finish;
	end


endmodule
