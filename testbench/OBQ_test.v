`include "sys_defs.vh"
`define DEBUG
`define DELAY #2
`define CLOCK_PERIOD #10
`define NUM_RAND_ITER 20

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
	logic [$clog2(`OBQ_SIZE):0] index;
	logic shift_en;
	logic [$clog2(`OBQ_SIZE):0] shift_index;

	// output wires
	OBQ_ROW_T [`OBQ_SIZE-1:0] obq_out;
	logic [$clog2(`OBQ_SIZE):0] tail_out;
	logic [$clog2(`OBQ_SIZE):0] row_tag;
	logic bh_pred_valid;
	OBQ_ROW_T bh_pred;

	// test wires
	OBQ_ROW_T [`OBQ_SIZE-1:0] obq_test;
	logic [$clog2(`OBQ_SIZE):0] tail_test;
	logic [$clog2(`OBQ_SIZE):0] row_tag_test;
	
	// initialize module
	`DUT(OBQ) obq0(
		// inputs
		.clock(clock),
		.reset(reset),
		.write_en(write_en),
		.bh_row(bh_row),
		.clear_en(clear_en),
		.index(index),
		.shift_en(shift_en),
		.shift_index(shift_index),

		// outputs
		.obq_out(obq_out),
		.tail_out(tail_out),
		.row_tag(row_tag),
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
		input [$clog2(`OBQ_SIZE):0] tail;
		input [$clog2(`OBQ_SIZE):0] tail_test;
		begin
			$display("in obq_equal");
			assert(tail == tail_test) else #1 exit_on_error;
			for (int i = 0; i < tail; ++i) begin
				assert(obq[i] == test[i]) else #1 exit_on_error;
			end
		end
	endtask

	task print_obq;
		input OBQ_ROW_T [`OBQ_SIZE-1:0] obq;
		begin
			for (int i = 0; i < `OBQ_SIZE; ++i) begin
				$display("i = %d bht: %b", i, obq[i].branch_history);
			end
		end
	endtask

	task insert_into_test;
		input OBQ_ROW_T row;
		begin
			if (tail_test < `OBQ_SIZE) begin
				obq_test[tail_test] = row;
				row_tag_test = tail_test;
				++tail_test;
			end
		end
	endtask

	task clear_from_test;
		input int idx;
		begin
			$display("clearing index: %d", idx);
			if (idx < tail_test) begin
				tail_test = idx;
				obq_test[idx - 1].branch_history[`BH_SIZE - 1] = ~obq_test[idx - 1].branch_history[`BH_SIZE - 1];
			end
		end
	endtask

	task shift_test;
		input int idx;
		begin
			if (idx < tail_test) begin
				int count;
				count = 0;
				for (int i = idx + 1; i < `OBQ_SIZE; ++i) begin
					obq_test[count] = obq_test[i];
					++count;
				end
				tail_test -= idx + 1;
			end
		end
	endtask

	// set clock change
	always `CLOCK_PERIOD clock = ~clock;

	initial begin

		// monitor wires
		$monitor("clock: %b reset: %b write_en: %b bh_row: %b clear_en: %b index: %d shift_en: %b shift_index: %d bh_pred_valid: %b bh_pred: %b",
				clock, reset, write_en, bh_row, clear_en, index, shift_en, shift_index, bh_pred_valid, bh_pred);

		// initialize
		clock = ZERO;
		reset = ZERO;
		write_en = ZERO;
		bh_row.branch_history = 0;
		clear_en = ZERO;
		index = 0;
		shift_en = ZERO;
		shift_index = 0;
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

		$display("Testing Single Write...");

		@(negedge clock);
		reset = ZERO;
		bh_row.branch_history = `BH_SIZE'b1010101011;
		write_en = ONE;
		insert_into_test(bh_row);

		@(posedge clock);
		`DELAY;
		assert(bh_pred_valid == ONE) else #1 exit_on_error;
		assert(bh_pred == bh_row) else #1 exit_on_error;
		assert(row_tag == row_tag_test) else #1 exit_on_error;
		obq_equal(obq_out, obq_test, tail_out, tail_test);

		$display("Single Write Passed");

		$display("Testing Multiple Write...");

		for (int i = 1; i < 5; ++i) begin
			@(negedge clock);
			reset = ZERO;
			bh_row.branch_history = $urandom_range(2**10,0);
			write_en = ONE;
			insert_into_test(bh_row);

			@(posedge clock);
			`DELAY;
			assert(bh_pred_valid == ONE) else #1 exit_on_error;
			assert(bh_pred == bh_row) else #1 exit_on_error;
			assert(row_tag == row_tag_test) else #1 exit_on_error;
			obq_equal(obq_out, obq_test, tail_out, tail_test);
		end

		$display("Multiple Write Passed");

		$display("Testing Single Clear...");
		@(negedge clock);
		write_en = ZERO;
		clear_en = ONE;
		index = 4; // clear the last entry
		clear_from_test(index);

		@(posedge clock);
		`DELAY;
		assert(bh_pred_valid == ONE) else #1 exit_on_error;
		assert(bh_pred == obq_test[3]) else #1 exit_on_error;
		obq_equal(obq_out, obq_test, tail_out, tail_test);

		$display("Single Clear Passed");

		$display("Testing Multiple Clear...");

		@(negedge clock);
		clear_en = ONE;
		index = 1;
		clear_from_test(index);

		@(posedge clock);
		`DELAY;
		assert(bh_pred_valid == ONE) else #1 exit_on_error;
		assert(bh_pred == obq_test[0]) else #1 exit_on_error;
		obq_equal(obq_out, obq_test, tail_out, tail_test);

		$display("Multiple Clear Passed");

		$display("Testing Clear All...");

		// reset
		@(negedge clock);
		reset = ONE;
		write_en = ZERO;
		clear_en = ZERO;
		tail_test = 0;

		// insert
		for (int i = 0; i < `OBQ_SIZE; ++i) begin
			@(negedge clock);
			reset = ZERO;
			bh_row.branch_history = $urandom_range(2**10, 0);
			write_en = ONE;
			insert_into_test(bh_row);

			@(posedge clock);
			`DELAY;
			assert(bh_pred_valid == ONE) else #1 exit_on_error;
			assert(bh_pred == bh_row) else #1 exit_on_error;
			assert(row_tag == row_tag_test) else #1 exit_on_error;
			obq_equal(obq_out, obq_test, tail_out, tail_test);
		end

		// clear
		@(negedge clock);
		write_en = ZERO;
		clear_en = ONE;
		index = 0;
		clear_from_test(index);

		@(posedge clock);
		`DELAY;
		assert(bh_pred_valid == ZERO) else #1 exit_on_error;
		obq_equal(obq_out, obq_test, tail_out, tail_test);
		assert(tail_out == 0) else #1 exit_on_error;

		$display("Clear All Passed");

		$display("Testing Multiple Write and Multiple Clear...");

		// reset
		@(negedge clock);
		reset = ONE;
		write_en = ZERO;
		clear_en = ZERO;

		@(posedge clock);
		`DELAY;
		obq_test = obq_out;
		tail_test = tail_out;

		// random iterations
		for (int i = 0; i < `NUM_RAND_ITER; ++i) begin
			@(negedge clock);
			reset = ZERO;
			write_en = $urandom_range(1, 0);
			clear_en = $urandom_range(1, 0);
			bh_row.branch_history = $urandom_range(2**10 - 1, 0);
			index = $urandom_range(2**4 - 1, 0);
			if (clear_en) begin
				clear_from_test(index);
			end
			if (write_en) begin
				insert_into_test(bh_row);
			end

			@(posedge clock);
			`DELAY;
			assert(bh_pred_valid == (tail_test > 0)) else #1 exit_on_error;
			obq_equal(obq_out, obq_test, tail_out, tail_test);
			if (write_en) begin
				assert(row_tag == row_tag_test) else #1 exit_on_error;
			end
		end

		$display("Multiple Write and Multiple Clear Passed");

		$display("Testing Single Shift...");

		@(negedge clock);
		reset = ONE;
		write_en = ZERO;
		clear_en = ZERO;

		@(posedge clock);
		`DELAY;
		obq_test = obq_out;
		tail_test = tail_out;

		// insert random stuff
		for (int i = 0; i < 6; ++i) begin
			@(negedge clock);
			reset = ZERO;
			write_en = ONE;
			bh_row.branch_history = $urandom_range(2**10 - 1, 0);
			insert_into_test(bh_row);

			@(posedge clock);
			`DELAY;
			assert(bh_pred_valid == (tail_test > 0)) else #1 exit_on_error;
			obq_equal(obq_out, obq_test, tail_out, tail_test);
			assert(row_tag == row_tag_test) else #1 exit_on_error;
		end

		@(negedge clock);
		write_en = ZERO;
		shift_en = ONE;
		shift_index = 0;
		shift_test(shift_index);

		@(posedge clock);
		`DELAY;
		assert(bh_pred_valid == ONE) else #1 exit_on_error;
		obq_equal(obq_out, obq_test, tail_out, tail_test);

		$display("Single Shift Passed");

		$display("Testing Multiple Shift...");

		@(negedge clock);
		write_en = ZERO;
		shift_en = ONE;
		shift_index = 4;
		shift_test(shift_index);

		@(posedge clock);
		`DELAY;
		assert(bh_pred_valid == ZERO) else #1 exit_on_error;
		obq_equal(obq_out, obq_test, tail_out, tail_test);

		$display("Multiple Shift Passed");

		$display("Testing Multiple Write and Multiple Shift...");

		@(negedge clock);
		shift_en = ZERO;
		reset = ONE;

		@(posedge clock);
		`DELAY;
		obq_test = obq_out;
		tail_test = tail_out;

		for (int i = 0; i < `NUM_RAND_ITER; ++i) begin
			@(negedge clock);
			reset = ZERO;
			write_en = $urandom_range(1, 0);
			shift_en = $urandom_range(1, 0);
			bh_row.branch_history = $urandom_range(2**10 - 1, 0);
			shift_index = $urandom_range(2**4 - 1, 0);
			if (shift_en) begin
				shift_test(shift_index);
			end
			if (write_en) begin
				insert_into_test(bh_row);
			end

			@(posedge clock);
			`DELAY;
			assert(bh_pred_valid == (tail_out > 0)) else #1 exit_on_error;
			obq_equal(obq_out, obq_test, tail_out, tail_test);
			if (write_en) begin
				assert(row_tag == row_tag_test) else #1 exit_on_error;
			end
		end

		$display("Multiple Write and Multiple Shift Passed");

		$display("Testing Multiple Clear and Multiple Shift...");

		@(negedge clock);
		shift_en = ZERO;
		write_en = ZERO;
		reset = ONE;

		@(posedge clock);
		`DELAY;
		obq_test = obq_out;
		tail_test = tail_out;

		for (int i = 0; i < `NUM_RAND_ITER; ++i) begin
			@(negedge clock);
			if (i % 10 == 0) begin
				for (int j = 0; j < 10; ++j) begin
					@(negedge clock);
					reset = ZERO;
					write_en = ONE;
					shift_en = ZERO;
					clear_en = ZERO;
					bh_row.branch_history = $urandom_range(2**10 - 1, 0);
					insert_into_test(bh_row);

					@(posedge clock);
					`DELAY;
					assert(bh_pred_valid == (tail_out > 0)) else #1 exit_on_error;
					obq_equal(obq_out, obq_test, tail_out, tail_test);
					assert(row_tag == row_tag_test) else #1 exit_on_error;
				end
			end else begin
				reset = ZERO;
				write_en = ZERO;
				clear_en = $urandom_range(1, 0);
				shift_en = $urandom_range(1, 0);
				index = $urandom_range(2**4 - 1, 0);

				if (shift_en & clear_en) begin
					shift_index = $urandom_range(index, 0);
				end else begin
					shift_index = $urandom_range(2**4 - 1, 0);
				end

				if (clear_en) begin
					clear_from_test(index);
				end

				if (shift_en) begin
					shift_test(shift_index);
				end
	
				@(posedge clock);
				`DELAY;
				$display("tail_out: %d tail_test: %d", tail_out, tail_test);
				print_obq(obq_out);
				print_obq(obq_test);
				assert(bh_pred_valid == (tail_out > 0)) else #1 exit_on_error;
				obq_equal(obq_out, obq_test, tail_out, tail_test);
			end

		end		

		$display("Multiple Clear and Multiple Shift Passed");
		$display("Testing Multiple Write, Clear, and Shift...");
		
		@(negedge clock);
		shift_en = ZERO;
		write_en = ZERO;
		clear_en = ZERO;
		reset = ONE;

		@(posedge clock);
		`DELAY;
		obq_test = obq_out;
		tail_test = tail_out;

		for (int i = 0; i < `NUM_RAND_ITER; ++i) begin
			@(negedge clock);
			// $display("after negedge");
			reset = ZERO;
			// $display("shift_en starts at: %b", shift_en);
			write_en = $urandom_range(1, 0);
			shift_en = $urandom_range(1, 0);
			// $display("shift_en is now: %b", shift_en);
			clear_en = $urandom_range(1, 0);
			bh_row.branch_history = $urandom_range(2**10 - 1, 0);
			index = $urandom_range(2**4 - 1, 0);
			// $display("got some random vals");
			if (shift_en & clear_en) begin
				shift_index = $urandom_range(index, 0);
			end else begin
				shift_index = $urandom_range(2**4 - 1, 0);
			end

			// $display("before clear");
			// print_obq(obq_test);	
			if (clear_en) begin
				clear_from_test(index);
			end
			// $display("after clear");
			// print_obq(obq_test);
			// $display("shift_en: %b", shift_en);
			if (shift_en) begin
				shift_test(shift_index);
			end
			// $display("after shift");
			// print_obq(obq_test);

			if (write_en) begin
				insert_into_test(bh_row);
			end
			$display("end negedge");
			// print_obq(obq_out);
			// print_obq(obq_test);

			@(posedge clock);
			$display("clocky");
			`DELAY;
			$display("here");
			assert(bh_pred_valid == (tail_out > 0)) else #1 exit_on_error;
			$display("tail_out: %d tail_test: %d", tail_out, tail_test);
			print_obq(obq_out);
			print_obq(obq_test);
			obq_equal(obq_out, obq_test, tail_out, tail_test);
			$display("after equal?");
			if (write_en) begin
				assert(row_tag == row_tag_test) else #1 exit_on_error;
			end
			$display("i = %d", i);
		end

		$display("Multiple Write, Clear, and Shift Passed");

		$display("ALL TESTS Passed");
		$finish;
	end


endmodule
