`include "../../sys_defs.vh"

`define DELAY #2
`define CLOCK_PERIOD #10
`define DEBUG

module testbench;

	// parameters

	parameter ONE = 1'b1;
	parameter ZERO = 1'b0;

	// initialize wires

	CACHE_SET_T [(`NUM_SETS - 1):0] sets_test;

	int index_to_write;
	
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
	
	CACHE_SET_T [(`NUM_SETS - 1):0] sets_out;

	// initialize module

	`DUT(cachemem) c0(
		.clock(clock),
		.reset(reset),
		.wr1_en(wr1_en),
		.wr1_idx(wr1_idx),
		.wr1_tag(wr1_tag),
		.wr1_data(wr1_data),
		.rd1_idx(rd1_idx),
		.rd1_tag(rd1_tag),

		.sets_out(sets_out),
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

	task print_set;
		input CACHE_SET_T set_in;
		begin
			for (int i = 0; i < `NUM_WAYS; ++i) begin
				$display("\tdata[%d] = %d tag[%d] = %d valid[%d] = %b", i, set_in.cache_lines[i].data, i, set_in.cache_lines[i].tag, i, set_in.cache_lines[i].valid);
			end
		end
	endtask

	task display_cache;
		begin
			$display("------------------------------------------------Cache-----------------------------------------------");
			for (int i = 0; i < `NUM_SETS; ++i) begin
				$display("set: %d", i);
				print_set(sets_out[i]);
			end
		end
	endtask

	task display_cache_test;
		begin
			$display("------------------------------------------------Cache Test------------------------------------------");
			for (int i = 0; i < `NUM_SETS; ++i) begin
				$display("set: %d", i);
				print_set(sets_test[i]);
			end
		end
	endtask

	task check_correct_reset;
		begin
			for (int i = 0; i < `NUM_SETS; ++i) begin
				for (int j = 0; j < `NUM_WAYS; ++j) begin
					assert(sets_out[i].cache_lines[j].valid == 0) else #1 exit_on_error;
				end
			end
		end
	endtask

	task check_block_in_set;
		input CACHE_LINE_T line;
		input CACHE_SET_T set;
		begin
			int found;
			found = 0;
			for (int i = 0; i < `NUM_WAYS; ++i) begin
				if (set.cache_lines[i].valid) begin
					if (line.tag == set.cache_lines[i].tag) begin
						assert(line.data == set.cache_lines[i].data) else #1 exit_on_error;
					found = 1;
					end
				end
			end
			assert(found == 1) else #1 exit_on_error;
		end 
	endtask

	task check_equal_set;
		input CACHE_SET_T set_1;
		input CACHE_SET_T set_2;
		begin
			// check same number valid
			int count_1, count_2;
			count_1 = 0;
			count_2 = 0;

			for (int i = 0; i < `NUM_WAYS; ++i) begin
				if (set_1.cache_lines[i].valid) begin
					++count_1;
				end
				if (set_2.cache_lines[i].valid) begin
					++count_2;
				end
			end

			assert(count_1 == count_2) else #1 exit_on_error;

			// check set_1 is a subset of set_2
			for (int i = 0; i < `NUM_WAYS; ++i) begin
				if (set_1.cache_lines[i].valid) begin
					check_block_in_set(set_1.cache_lines[i], set_2);
				end
			end

			// check set_2 is a subset of set_1
			for (int i = 0; i < `NUM_WAYS; ++i) begin
				if (set_2.cache_lines[i].valid) begin
					check_block_in_set(set_2.cache_lines[i], set_1);
				end
			end
		end
	endtask

	task check_correct_test;
		begin
			for (int i = 0; i < `NUM_SETS; ++i) begin
				check_equal_set(sets_out[i], sets_test[i]);
			end
		end
	endtask

	task write_to_test;
		begin

			int num_valid;
			int found;
			found = 0;
			num_valid = 0;

			index_to_write = 0;

			for (int i = 0; i < `NUM_WAYS; ++i) begin
				if (sets_test[wr1_idx].cache_lines[i].valid && sets_test[wr1_idx].cache_lines[i].tag == wr1_tag) begin
					index_to_write = i;
					break;
				end else if (sets_test[wr1_idx].cache_lines[i].valid) begin
					++num_valid;
				end else begin
					index_to_write = i;
				end
			end

			if (num_valid == `NUM_WAYS) begin
				// eviction logic
			end else begin
				sets_test[wr1_idx].cache_lines[index_to_write].valid = 1;
				sets_test[wr1_idx].cache_lines[index_to_write].data = wr1_data;
				sets_test[wr1_idx].cache_lines[index_to_write].tag = wr1_tag;
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
		sets_test = sets_out;

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
		sets_test = sets_out;
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
				`DELAY
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

		$display("Testing Single Over-Write...");

		@(negedge clock);
		reset = 0;
		wr1_en = 1;
		wr1_idx = 2;
		wr1_tag = 1;
		wr1_data = 999;
		rd1_idx = 0;
		rd1_tag = 0;
		write_to_test;

		@(posedge clock);
		`DELAY;
		check_correct_test;

		$display("Single Over-Write Passed");

		$display("Testing Multiple Over-Write...");

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
		sets_test = sets_out;	

		for (int i = 0; i < 3; ++i) begin
			for (int j = 0; j < `NUM_SETS; ++j) begin
				for (int k = 0; k < `NUM_WAYS; ++k) begin
					@(negedge clock);
					reset = 0;
					wr1_en = 1;
					wr1_idx = j;
					wr1_tag = k;
					wr1_data = $urandom_range(999, 0);
					rd1_idx = 0;
					rd1_tag = 0;
					write_to_test;

					@(posedge clock);
					`DELAY;
					check_correct_test;
				end
			end
		end

		$display("Multiple Over-Write Passed");

		$display("@@@Passed");
		$finish;
	end


endmodule
