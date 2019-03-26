`include "../sys_defs.vh"
`define DEBUG
`define DELAY #2
`define CLOCK_PERIOD #10
`define NUM_RAND_ITER 500

module testbench;

	// parameters

	parameter ONE = 1'b1;
	parameter ZERO = 1'b0;

	// initialize wires

	// input wires
	logic clock;
	logic reset;
	logic write_en;
	logic clear_en;
	logic [31:0] current_pc;

	// output wires
	logic [`RAS_SIZE - 1:0] [31:0] stack_out;
	logic [$clog2(`RAS_SIZE) - 1:0] head_out;
	logic [$clog2(`RAS_SIZE) - 1:0] tail_out;
	
	logic [31:0] next_pc;
	logic valid_out;


	// test variables
	logic [`RAS_SIZE - 1:0] [31:0] stack_test;
	logic [$clog2(`RAS_SIZE) - 1:0] head_test;
	logic [$clog2(`RAS_SIZE) - 1:0] tail_test;
	logic [$clog2(`RAS_SIZE) - 1:0] index_test;
	
	// initialize module
	`DUT(RAS) ras0(
		// inputs
		.clock(clock),
		.reset(reset),
		.write_en(write_en),
		.clear_en(clear_en),
		.current_pc(current_pc),

		// outputs
		.stack_out(stack_out),
		.head_out(head_out),
		.tail_out(tail_out),

		.next_pc(next_pc),
		.valid_out(valid_out)
	);

	// TASKS
	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	task check_correct_reset;
		begin
			assert(head_out == 0) else #1 exit_on_error;
			assert(tail_out == 0) else #1 exit_on_error;
			for (int i = 0; i < `RAS_SIZE; ++i) begin
				assert(stack_out[i] === 0) else #1 exit_on_error;
			end
			assert(valid_out === ZERO) else #1 exit_on_error;
		end
	endtask

	task push_into_test;
		begin
			stack_test[tail_test] = current_pc + 4;
			tail_test++;
			if (tail_test == head_test) begin
				head_test++;
			end
		end
	endtask

	task pop_from_test;
		begin
			if (head_test != tail_test) begin
				tail_test--;
			end
		end
	endtask

	task matches_test;
		begin
			assert(head_out == head_test) else #1 exit_on_error;
			assert(tail_out == tail_test) else #1 exit_on_error;
			for (index_test = head_out; index_test != tail_out; ++index_test) begin
				assert(stack_out[index_test] == stack_test[index_test]) else #1 exit_on_error;
			end
		end
	endtask

	task print_stack_out;
		begin
			$display("STACK OUT");
			$display("head_out: %d tail_out: %d", head_out, tail_out);
			for (int i = 0; i < `RAS_SIZE; ++i) begin
				$display("stack_out[%d] = %d", i, stack_out[i]);
			end
		end
	endtask

	task print_stack_test;
		begin
			$display("STACK TEST");
			$display("head_test: %d tail_test: %d", head_test, tail_test);
			for (int i = 0; i < `RAS_SIZE; ++i) begin
				$display("stack_test[%d] = %d", i, stack_test[i]);
			end
		end
	endtask

	// set clock change
	always `CLOCK_PERIOD clock = ~clock;

	initial begin

		// monitor wires
		$monitor("clock: %b reset: %b write_en: %b clear_en: %b current_pc: %d next_pc: %d valid_out: %b",
			clock, reset, write_en, clear_en, current_pc, next_pc, valid_out);

		// intial values
		clock = ZERO;
		reset = ZERO;
		write_en = ZERO;
		clear_en = ZERO;
		current_pc = 0;
		
		$display("Testing Reset...");
		@(negedge clock);
		reset = ONE;

		@(posedge clock);
		`DELAY;
		print_stack_out;
		print_stack_test;
		check_correct_reset;
		stack_test = stack_out;
		head_test = head_out;
		tail_test = tail_out;

		$display("Reset Test Passed");

		$display("Testing Single Push...");

		@(negedge clock);
		reset = ZERO;
		write_en = ONE;
		current_pc = 100;
		push_into_test;

		@(posedge clock);
		`DELAY;
		matches_test;

		$display("Single Push Passed");

		$display("Testing Multiple Push (No Wrap Around)...");

		// reset
		@(negedge clock);
		reset = ONE;
		write_en = ZERO;

		@(posedge clock);
		`DELAY;
		check_correct_reset;
		stack_test = stack_out;
		head_test = head_out;
		tail_test = tail_out;

		// push till full
		for (int i = 0; i < `RAS_SIZE; ++i) begin
			@(negedge clock);
			reset = ZERO;
			write_en = ONE;
			current_pc = $urandom_range(2**32 - 1, 0);
			push_into_test;

			@(posedge clock);
			`DELAY;
			matches_test;
		end

		$display("Multiple Push (No Wrap Around) Passed");

		$display("Testing Single Push (Wrap Around)...");

		// currently have full RAS
		@(negedge clock);
		write_en = ONE;
		current_pc = $urandom_range(2**32 - 1, 0);
		push_into_test;

		@(posedge clock);
		`DELAY;
		assert(stack_out[0] == current_pc + 4) else #1 exit_on_error;
		assert(head_out == 2) else #1 exit_on_error;
		assert(tail_out == 1) else #1 exit_on_error;
		matches_test;

		$display("Single Push (Wrap Around) Passed");

		$display("Testing Single Pop (No Wrap Around)...");

		// reset
		@(negedge clock);
		reset = ONE;
		write_en = ZERO;

		@(posedge clock);
		`DELAY;
		check_correct_reset;
		stack_test = stack_out;
		head_test = head_out;
		tail_test = tail_out;

		// push 1
		@(negedge clock);
		reset = ZERO;
		clear_en = ZERO;
		write_en = ONE;
		current_pc = $urandom_range(2**32 - 1, 0);
		push_into_test;

		@(posedge clock);
		`DELAY;
		matches_test;

		// pop 1
		@(negedge clock);
		write_en = ZERO;
		clear_en = ONE;
		pop_from_test;

		@(posedge clock);
		`DELAY;
		assert(valid_out == ZERO) else #1 exit_on_error;
		matches_test;

		$display("Single Pop (No Wrap Around) Passed");

		$display("Testing Multiple Pop (No Wrap Around)...");

		// reset
		@(negedge clock);
		reset = ONE;
		clear_en = ZERO;

		@(posedge clock);
		`DELAY;
		check_correct_reset;
		stack_test = stack_out;
		head_test = head_out;
		tail_test = tail_out;

		// push till full
		for (int i = 0; i < `RAS_SIZE; ++i) begin
			@(negedge clock);
			reset = ZERO;
			write_en = ONE;
			current_pc = $urandom_range(2**32 - 1, 0);
			push_into_test;

			@(posedge clock);
			`DELAY;
			assert(valid_out == ONE) else #1 exit_on_error;
			matches_test;
		end

		// clear till empty
		for (int i = 0; i < `RAS_SIZE; ++i) begin
			@(negedge clock);
			write_en = ZERO;
			clear_en = ONE;
			pop_from_test;

			@(posedge clock);
			`DELAY;
			matches_test;
		end
		assert(valid_out == ZERO) else #1 exit_on_error;

		$display("Multiple Pop (No Wrap Around) Passed");

		$display("Testing Pop If Empty...");

		@(negedge clock);
		clear_en = ONE;
		
		@(posedge clock);
		`DELAY;
		assert(valid_out == ZERO) else #1 exit_on_error;
		matches_test;

		$display("Pop If Empty Passed");

		$display("Testing Multiple Pop (with Wrap Around)...");

		// reset
		@(negedge clock);
		clear_en = ZERO;
		reset = ONE;

		@(posedge clock);
		`DELAY;
		check_correct_reset;
		stack_test = stack_out;
		head_test = head_out;
		tail_test = tail_out;

		// push with wrap around
		for (int i = 0; i < 3*`RAS_SIZE; ++i) begin
			@(negedge clock);
			write_en = ONE;
			reset = ZERO;
			current_pc = $urandom_range(2**32 - 1, 0);
			push_into_test;

			@(posedge clock);
			`DELAY;
			matches_test;
		end

		// pop all
		while (!valid_out) begin
			@(negedge clock);
			write_en = ZERO;
			clear_en = ONE;
			pop_from_test;

			@(posedge clock);
			`DELAY;
			matches_test;
		end

		$display("Multiple Pop (with Wrap Around) Passed");

		$display("Testing Multiple Simultaneous Push and Pop...");

		// reset
		@(negedge clock);
		clear_en = ZERO;
		reset = ONE;

		@(posedge clock);
		`DELAY;
		check_correct_reset;
		stack_test = stack_out;
		head_test = head_out;
		tail_test = tail_out;

		for (int i = 0; i < `NUM_RAND_ITER; ++i) begin
			@(negedge clock);
			reset = ZERO;
			write_en = $urandom_range(1, 0);
			clear_en = $urandom_range(1, 0);
			current_pc = $urandom_range(2**32 - 1, 0);
			if (write_en & clear_en) begin
				stack_test[tail_test - 1] = current_pc + 4;
			end else begin	
				if (write_en) begin
					push_into_test;
				end
				if (clear_en) begin
					pop_from_test;
				end
			end

			@(posedge clock);
			`DELAY;
			matches_test;
		end

		$display("Multiple Simultaneous Push and Pop Passed");

		$display("ALL TESTS Passed");
		$finish;
	end


endmodule
