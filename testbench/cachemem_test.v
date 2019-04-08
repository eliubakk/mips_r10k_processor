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
	logic [(`NUM_SETS - 1):0] [(`NUM_WAYS - 2):0] bst_test;
	int index_to_write;
	
	// input wires

	logic clock;
	logic reset;
	logic wr1_en;
	logic [4:0] wr1_idx;
	logic [7:0] wr1_tag;
	logic [63:0] wr1_data;
	logic rd1_en;
	logic [4:0] rd1_idx;
	logic [7:0] rd1_tag;
	
	// output wires

	logic [63:0] rd1_data;
	logic rd1_valid;
	
	CACHE_SET_T [(`NUM_SETS - 1):0] sets_out;
	logic [(`NUM_SETS - 1):0] [(`NUM_WAYS - 2):0] bst_out;

	// initialize module

	`DUT(cachemem) c0(
		.clock(clock),
		.reset(reset),
		.wr1_en(wr1_en),
		.wr1_idx(wr1_idx),
		.wr1_tag(wr1_tag),
		.wr1_data(wr1_data),
		.rd1_en(rd1_en),
		.rd1_idx(rd1_idx),
		.rd1_tag(rd1_tag),

		.sets_out(sets_out),
		.bst_out(bst_out),

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

	task print_bst;
		begin
			for (int i = 0; i < `NUM_SETS; ++i) begin
				$display("bst_out[%d]: %b", i, bst_out[i]);
			end
		end
	endtask

	task print_bst_test;
		begin
			for (int i = 0; i < `NUM_SETS; ++i) begin
				$display("bst_test[%d]: %b", i, bst_test[i]);
			end
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

			print_bst;
		end
	endtask

	task display_cache_test;
		begin
			$display("------------------------------------------------Cache Test------------------------------------------");
			for (int i = 0; i < `NUM_SETS; ++i) begin
				$display("set: %d", i);
				print_set(sets_test[i]);
			end

			print_bst_test;
		end
	endtask

	task check_correct_reset;
		begin
			for (int i = 0; i < `NUM_SETS; ++i) begin
				for (int j = 0; j < `NUM_WAYS; ++j) begin
					assert(sets_out[i].cache_lines[j].valid == 0) else #1 exit_on_error;
				end
				assert(bst_out[i] == 0) else #1 exit_on_error;
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
				assert(bst_out[i] == bst_test[i]) else #1 exit_on_error;
			end
		end
	endtask

	int bst_test_depth = $clog2(`NUM_WAYS);
	int next_idx;
	int update_bst_idx;
	int acc_update = `NUM_WAYS / 2;

	task update_bst_test;
		input int set_idx;
		input int idx;
		begin
			acc_update = `NUM_WAYS / 2;
			update_bst_idx = 0;
			next_idx = acc_update;

			for (int i = 0; i < bst_test_depth; ++i) begin
				bst_test[set_idx][update_bst_idx] = ~bst_test[set_idx][update_bst_idx];
				if (next_idx > idx) begin
					update_bst_idx = (2 * update_bst_idx) + 1;
					next_idx -= acc_update / 2;
				end else begin
					update_bst_idx = (2 * update_bst_idx) + 2;
					next_idx += acc_update / 2;
				end
				acc_update /= 2;
			end
		end
	endtask

	task read_from_test;
		begin
			int found_read;
			int idx_read;
			int depth_read = $clog2(`NUM_WAYS);
			int acc_read = `NUM_WAYS;
			int next_idx_read;

			found_read = 0;
			idx_read = 0;
			next_idx_read = 0;

			for (int i = 0; i < `NUM_WAYS; ++i) begin
				if (sets_test[rd1_idx].cache_lines[i].valid && sets_test[rd1_idx].cache_lines[i].tag == rd1_tag) begin
					found_read = 1;
					idx_read = i;
					break;
				end
			end

			if (found_read) begin
				update_bst_test(rd1_idx, idx_read);
			end
		end
	endtask

	int acc_write;
	int next_idx;

	task write_to_test;
		begin

			int found_write;
			int idx_write;
			int depth_write = $clog2(`NUM_WAYS);
			acc_write  = `NUM_WAYS;

			found_write = 0;
			idx_write = 0;
			next_idx = 0;

			for (int i = 0; i < `NUM_WAYS; ++i) begin
				if (sets_test[wr1_idx].cache_lines[i].valid && sets_test[wr1_idx].cache_lines[i].tag == wr1_tag) begin
					found_write = 1;
					idx_write = i;
					break;
				end
			end

			if (!found_write) begin
				idx_write = 0;
				for (int i = 0; i < depth_write; ++i) begin
					if (bst_test[wr1_idx][next_idx] == 1) begin
						next_idx = (2 * next_idx) + 2;
						idx_write += acc_write / 2;
					end else begin
						next_idx = (2 * next_idx) + 1;
					end
					acc_write /= 2;
				end
			end

			sets_test[wr1_idx].cache_lines[idx_write].valid = 1;
			sets_test[wr1_idx].cache_lines[idx_write].data = wr1_data;
			sets_test[wr1_idx].cache_lines[idx_write].tag = wr1_tag;

			// update bst bits
			update_bst_test(wr1_idx, idx_write);
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
		rd1_en = 0;
		rd1_idx = 0;
		rd1_tag = 0;

		$display("Testing Reset...");

		@(negedge clock);
		reset = 1;
		wr1_en = 0;
		wr1_idx = 0;
		wr1_tag = 0;
		wr1_data = 0;
		rd1_en = 0;
		rd1_idx = 0;
		rd1_tag = 0;

		@(posedge clock);
		`DELAY;
		check_correct_reset;
		sets_test = sets_out;
		bst_test = bst_out;

		$display("Reset Test Passed");

		$display("Testing Single Write...");

		@(negedge clock);
		reset = 0;
		wr1_en = 1;
		wr1_idx = (`NUM_SETS - 1);
		wr1_tag = 4;
		wr1_data = 69;
		rd1_en = 0;
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
		wr1_idx = (`NUM_SETS - 1);
		wr1_tag = 5;
		wr1_data = 100;
		rd1_en = 0;
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
		rd1_en = 0;
		rd1_idx = 0;
		rd1_tag = 0;

		@(posedge clock);
		`DELAY;
		check_correct_reset;
		sets_test = sets_out;
		bst_test = bst_out;

		for (int i = 0; i < `NUM_SETS; ++i) begin
			for (int j = 0; j < `NUM_WAYS; ++j) begin
				@(negedge clock);
				reset = 0;
				wr1_en = 1;
				wr1_idx = i;
				wr1_tag = j;
				wr1_data = i*j;
				rd1_en = 0;
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
		rd1_en = 1;
		rd1_idx = (`NUM_SETS - 1);
		rd1_tag = 1;
		read_from_test;

		@(posedge clock);
		`DELAY;
		assert(rd1_data == (rd1_tag * rd1_idx)) else #1 exit_on_error;
		assert(rd1_valid == 1) else #1 exit_on_error;
		check_correct_test;

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
				rd1_en = 1;
				rd1_idx = i;
				rd1_tag = j;
				read_from_test;

				@(posedge clock);
				`DELAY;
				assert(rd1_data == i*j) else #1 exit_on_error;
				assert(rd1_valid == 1) else #1 exit_on_error;
				check_correct_test;
			end
		end

		$display("Multiple Read Passed");

		$display("Testing Single Over-Write...");

		@(negedge clock);
		reset = 0;
		wr1_en = 1;
		wr1_idx = (`NUM_SETS - 1);
		wr1_tag = 1;
		wr1_data = 999;
		rd1_en = 0;
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
		rd1_en = 0;
		rd1_idx = 0;
		rd1_tag = 0;

		@(posedge clock);
		`DELAY;
		check_correct_reset;
		sets_test = sets_out;	
		bst_test = bst_out;

		for (int i = 0; i < 3; ++i) begin
			for (int j = 0; j < `NUM_SETS; ++j) begin
				for (int k = 0; k < `NUM_WAYS; ++k) begin
					@(negedge clock);
					reset = 0;
					wr1_en = 1;
					wr1_idx = j;
					wr1_tag = k;
					wr1_data = $urandom_range(999, 0);
					rd1_en = 0;
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

		$display("Testing Single Pseudo-LRU Write...");

		@(negedge clock);
		reset = 1;
		wr1_en = 0;
		wr1_idx = 0;
		wr1_tag = 0;
		wr1_data = 0;
		rd1_en = 0;
		rd1_idx = 0;
		rd1_tag = 0;

		@(posedge clock);
		`DELAY;
		check_correct_reset;
		sets_test = sets_out;
		bst_test = bst_out;

		@(negedge clock);

		@(posedge clock);
		`DELAY;

		$display("Single Pseudo-LRU Write Passed");

		$display("@@@Passed");
		$finish;
	end


endmodule
