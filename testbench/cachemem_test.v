`include "../../sys_defs.vh"

`define DELAY #2
`define CLOCK_PERIOD #10
`define DEBUG

module testbench;

	// parameters

	parameter ONE = 1'b1;
	parameter ZERO = 1'b0;

	// initialize wires

	logic [31:0] [63:0] data_test;
	logic [31:0] [7:0] tags_test;
	logic [31:0] valids_test;

	// input wires

	logic clock;
	logic reset;
	logic wr1_en;
	logic [4:0] wr1_idx;
	logic [7:0] wr1_tag;
	logic [63:0] wr1_data;
	logic [4:0] rd1_idx;
	logic [7:0] rd1_tag;
	
	// output wires

	logic [63:0] rd1_data;
	logic rd1_valid;
	
	logic [31:0] 	[63:0] 			data_out;
	logic [31:0]  	[(`NUM_TAG_BITS - 1):0]	tags_out; 
	logic [31:0]        			valids_out;
	
	// initialize module

	`DUT(cache) c0(
		.clock(clock),
		.reset(reset),
		.wr1_en(wr1_en),
		.wr1_idx(wr1_idx),
		.wr1_tag(wr1_tag),
		.wr1_data(wr1_data),
		.rd1_idx(rd1_idx),
		.rd1_tag(rd1_tag),

		.data_out(data_out),
		.tags_out(tags_out),
		.valids_out(valids_out),

		.rd1_data(rd1_data),
		.rd1_valid(rd1_valid)
	);

	// TASKS
	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	task display_cache;
		begin
			$display("------------------------------------------------Cache-----------------------------------------------");
			for (int i = 0; i < 32; ++i) begin
				$display("data[%d] = %d tags[%d] = %d valids[%d] = %b", i, data_out[i], i, tags_out[i], i, valids_out[i]);
			end
		end
	endtask

	task check_correct_reset;
		begin
			for (int i = 0; i < 32; ++i) begin
				assert(valids_out[i] == 0) else #1 exit_on_error;
			end
		end
	endtask

	// set clock change
	always `CLOCK_PERIOD clock = ~clock;

	initial begin

		// monitor wires
		$monitor("clock: %b reset: %b wr1_en: %b wr1_idx: %d wr1_tag: %d wr1_data: %d rd1_idx: %d rd1_tag: %d rd1_data: %d rd1_valid: %b", clock, reset, wr1_en, wr1_idx, wr1_tag, wr1_data, rd1_idx, rd1_tag, rd1_data, rd1_valid);
		
		// intial values
		clock = 0;
		reset = 0;
		wr1_en = 0;
		wr1_idx = 0;
		wr1_tag = 0;
		wr1_data = 0;
		rd1_idx = 0;
		rd1_tag = 0;

		$display("Testing Reset...");

		@(negedge clock);
		reset = 1;
		wr1_en = 0;
		wr1_idx = 0;
		wr1_tag = 0;
		wr1_data = 0;
		rd1_idx = 0;
		rd1_tag = 0;

		@(posedge clock);
		`DELAY;
		// display_cache;
		check_correct_reset;

		$display("Reset Test Passed");

		$display("Testing Single Write...");

		@(negedge clock);
		reset = 0;
		wr1_en = 1;
		wr1_idx = 3;
		wr1_tag = 4;
		wr1_data = 69;
		rd1_idx = 0;
		rd1_tag = 0;

		@(posedge clock);
		`DELAY;
		display_cache;
		assert(data_out[6] == wr1_data) else #1 exit_on_error;
		assert(tags_out[6] == wr1_tag) else #1 exit_on_error;
		assert(valids_out[6] == 1) else #1 exit_on_error;

		$display("Single Write Passed");

		$display("Testing Single Write to Same Set...");

		@(negedge clock);
		reset = 0;
		wr1_en = 1;
		wr1_idx = 3;
		wr1_tag = 5;
		wr1_data = 100;
		rd1_idx = 0;
		rd1_tag = 0;

		@(posedge clock);
		`DELAY;
		assert(data_out[7] == wr1_data) else #1 exit_on_error;
		assert(tags_out[7] == wr1_tag) else #1 exit_on_error;
		assert(valids_out[7] == 1) else #1 exit_on_error;

		$display("Single Write to Same Set Passed");

		$display("Testing Multiple Writes...");

		@(negedge clock);
		reset = 1;
		wr1_en = 0;
		wr1_idx = 0;
		wr1_tag = 0;
		wr1_data = 0;
		rd1_idx = 0;
		rd1_tag = 0;

		@(posedge clock);
		`DELAY;
		check_correct_reset;

		for (int i = 0; i < `NUM_SETS; ++i) begin
			for (int j = 0; j < `NUM_WAYS; ++j) begin
				@(negedge clock);
				reset = 0;
				wr1_en = 1;
				wr1_idx = i;
				wr1_tag = j;
				wr1_data = i*j;
				rd1_idx = 0;
				rd1_tag = 0;

				@(posedge clock);
				`DELAY;
				assert(data_out[(`NUM_WAYS * i) + j] == i*j) else #1 exit_on_error;
				assert(tags_out[(`NUM_WAYS * i) + j] == j) else #1 exit_on_error;
				assert(valids_out[(`NUM_WAYS * i) + j] == 1) else #1 exit_on_error;
			end
		end

		$display("Multiple Writes Passed");

		$display("@@@Passed");
		$finish;
	end


endmodule
