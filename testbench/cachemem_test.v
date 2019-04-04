`include "../../sys_defs.vh"

`define DELAY #2
`define CLOCK_PERIOD #10
`define DEBUG

module testbench;

	// parameters

	parameter ONE = 1'b1;
	parameter ZERO = 1'b0;

	// initialize wires

	logic [31:0] 	[63:0] 			data_test;
	logic [31:0]  	[(`NUM_TAG_BITS - 1):0]	tags_test; 
	logic [31:0]        			valids_test;
	logic 					full_test;
	int					index_test;

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

	task display_cache_test;
		begin
			$display("------------------------------------------------Cache Test------------------------------------------");
			for (int i = 0; i < 32; ++i) begin
				$display("data[%d] = %d tags[%d] = %d valids[%d] = %b", i, data_test[i], i, tags_test[i], i, valids_test[i]);
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

	task check_correct_test;
		begin
			for (int i = 0; i < 32; ++i) begin
				assert(valids_out[i] == valids_test[i]) else #1 exit_on_error;
				if (valids_out[i]) begin
					assert(data_out[i] == data_test[i]) else #1 exit_on_error;
					assert(tags_out[i] == tags_test[i]) else #1 exit_on_error;
				end
			end
		end
	endtask

	task write_to_test;
		begin
			assert(wr1_en == 1) else #1 exit_on_error;
			// first check for empty spot
			full_test = 1;
			for (int i = 0; i < `NUM_WAYS; ++i) begin
				full_test &= valids_test[(`NUM_WAYS * wr1_idx) + i];
			end
			// insert into empty spot if available
			// otherwise write to pseudo lru
			if (~full_test) begin

				for (int i = 0; i < `NUM_WAYS; ++i) begin
					if (!valids_test[(`NUM_WAYS * wr1_idx) + i]) begin
						index_test = i;
						break;
					end
				end

				$display("index_test: %d", index_test);
				data_test[(`NUM_WAYS * wr1_idx) + index_test] = wr1_data;
				tags_test[(`NUM_WAYS * wr1_idx) + index_test] = wr1_tag;
				valids_test[(`NUM_WAYS * wr1_idx) + index_test] = 1;
			end else begin
				// eviction logic
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
		check_correct_reset;
		data_test = data_out;
		tags_test = tags_out;
		valids_test = valids_out;

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
		write_to_test;

		@(posedge clock);
		`DELAY;

		// assert(data_out[6] == wr1_data) else #1 exit_on_error;
		// assert(tags_out[6] == wr1_tag) else #1 exit_on_error;
		// assert(valids_out[6] == 1) else #1 exit_on_error;
		check_correct_test;

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
		write_to_test;

		@(posedge clock);
		`DELAY;

		//assert(data_out[7] == wr1_data) else #1 exit_on_error;
		//assert(tags_out[7] == wr1_tag) else #1 exit_on_error;
		//assert(valids_out[7] == 1) else #1 exit_on_error;
		check_correct_test;

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
		data_test = data_out;
		tags_test = tags_out;
		valids_test = valids_out;

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
				write_to_test;

				@(posedge clock);
				$display("wr1_en: %b", wr1_en);
				$display("tag_hits: %b", c0.tag_hits);
				$display("full: %b", c0.full);
				$display("p_en: %b", c0.p_en);
				$display("req_in: %b", c0.req_in);
				$display("gnt_out: %b", c0.gnt_out);
				`DELAY
				display_cache;
				display_cache_test;
				// assert(data_out[(`NUM_WAYS * i) + j] == i*j) else #1 exit_on_error;
				// assert(tags_out[(`NUM_WAYS * i) + j] == j) else #1 exit_on_error;
				// assert(valids_out[(`NUM_WAYS * i) + j] == 1) else #1 exit_on_error;
				check_correct_test;
			end
		end

		$display("Multiple Writes Passed");

		$display("Testing Single Read...");

		@(negedge clock);
		reset = 0;
		wr1_en = 0;
		wr1_idx = 0;
		wr1_tag = 0;
		wr1_data = 0;
		rd1_idx = 2;
		rd1_tag = 1;

		@(posedge clock);
		`DELAY;
		assert(rd1_data == 2) else #1 exit_on_error;
		assert(rd1_valid == 1) else #1 exit_on_error;

		$display("Single Read Passed");

		$display("Testing Multiple Read...");

		for (int i = 0; i < `NUM_SETS; ++i) begin
			for (int j = 0; j < `NUM_WAYS; ++j) begin
				@(negedge clock);
				reset = 0;
				wr1_en = 0;
				wr1_idx = 0;
				wr1_tag = 0;
				wr1_data = 0;
				rd1_idx = i;
				rd1_tag = j;

				@(posedge clock);
				`DELAY;
				assert(rd1_data == i*j) else #1 exit_on_error;
				assert(rd1_valid == 1) else #1 exit_on_error;
			end
		end

		$display("Multiple Read Passed");

		$display("@@@Passed");
		$finish;
	end


endmodule
