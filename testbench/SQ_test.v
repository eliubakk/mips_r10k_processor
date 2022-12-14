`include "../../sys_defs.vh"
`define DEBUG
`define DELAY #2
`define CLOCK_PERIOD #10
`define NUM_RAND_ITER 500
`define index_t ($clog2(`SQ_SIZE) - 1)

module testbench;

	// parameters

	parameter ONE = 1'b1;
	parameter ZERO = 1'b0;

	// initialize wires

	// input wires
	logic clock;
	logic reset;

	// read signals
	logic rd_en; // load queue wants to read data at an address in SQ
	logic [31:0] addr_rd; // the address the load queue wants to read
	logic [($clog2(`SQ_SIZE) - 1):0] ld_pos; // the tail of the sq at the time the load was dispatched

	// dispatch signals
	logic dispatch_en; // 1 when a store is getting dispatched
	logic  [31:0] dispatch_addr; // addr of the store
	logic dispatch_addr_ready; // if the store address is ready (direct store vs indirect store)
	logic [63:0] dispatch_data; // data to store 
	logic dispatch_data_ready; // if the data of store is ready (direct store vs indirect store)
	
	// execute signals
	logic ex_en; // 1 when a store is being executed
	logic [($clog2(`SQ_SIZE) - 1):0] ex_index; // the index/tag of the store that is being executed
	logic [31:0] ex_addr; // the address calculated during execute
	logic ex_addr_en; // 1 if want to use ex_addr for the address (direct vs indirect store)
	logic [63:0] ex_data; // the data calculated during execute
	logic ex_data_en; // 1 if want to use ex_data for the data (direct vs indirect store)

	// retire signals
	logic rt_en; // 1 when a store is at retire
	// input [`index_t:0] rt_index, // the index/tag of the store that is being retired

	// output wires
	// read outputs
	logic [63:0] data_rd; // the data that is being read by the load
	logic rd_valid; // whether the data that is being read is ready

	// general outputs
	logic [($clog2(`SQ_SIZE) - 1):0] tail_out; // the index of the store being dispatched
	logic full;

	// test variables
	logic [($clog2(`SQ_SIZE) - 1):0] tail_test;
	logic [($clog2(`SQ_SIZE) - 1):0] head_test;

	logic [`SQ_SIZE - 1:0] [31:0] addr_test;
	logic [`SQ_SIZE - 1:0] addr_ready_test;
	logic [`SQ_SIZE - 1:0] [63:0] data_test;
	logic [`SQ_SIZE - 1:0] data_ready_test;
	
	logic [`SQ_SIZE - 1:0] [31:0] addr_out;
	logic [`SQ_SIZE - 1:0] addr_ready_out;
	logic [`SQ_SIZE - 1:0] [63:0] data_out;
	logic [`SQ_SIZE - 1:0] data_ready_out;
	logic [`index_t:0] head_out;
	logic [`index_t:0] tail_out;
	// initialize module

	`DUT(SQ) sq0(
		// inputs
		.clock(clock),
		.reset(reset),
		.rd_en(rd_en),
		.addr_rd(addr_rd),
		.ld_pos(ld_pos),
		.dispatch_en(dispatch_en),
		.dispatch_addr(dispatch_addr),
		.dispatch_addr_ready(dispatch_addr_ready),
		.dispatch_data(dispatch_data),
		.dispatch_data_ready(dispatch_data_ready),
		.ex_en(ex_en),
		.ex_index(ex_index),
		.ex_addr(ex_addr),
		.ex_addr_en(ex_addr_en),
		.ex_data(ex_data),
		.ex_data_en(ex_data_en),
		.rt_en(rt_en),

		// outputs
		.addr_out(addr_out),
		.addr_ready_out(addr_ready_out),
		.data_out(data_out),
		.data_ready_out(data_ready_out),
		.head_out(head_out),
		.data_rd(data_rd),
		.rd_valid(rd_valid),
		.tail_out(tail_out),
		.full(full)
	);

	// TASKS
	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	task print_sq;
		begin
			$display("---------------------------------------------------------------SQ--------------------------------------------------");
			$display("head: %d tail: %d", head_out, tail_out);
			$display("addr and addr_ready:");
			for (int i = 0; i < `SQ_SIZE; ++i) begin
				$display("\taddr[%d] = %d ready[%d] = %b", i, addr_out[i], i, addr_ready_out[i]);
			end
			$display("data and data ready:");
			for (int i = 0; i < `SQ_SIZE; ++i) begin
				$display("\tdata[%d] = %d ready[%d] = %b", i, data_out[i], i, data_ready_out[i]);
			end
		end
	endtask

	task check_correct_reset;
		begin
			assert(rd_valid == 0) else #1 exit_on_error;
			assert(tail_out == 0) else #1 exit_on_error;
			assert(full == 0) else #1 exit_on_error;

			for (int i = 0; i < `SQ_SIZE; ++i) begin
				assert(addr_out[i] == 0) else #1 exit_on_error;
				assert(data_out[i] == 0) else #1 exit_on_error;
				assert(addr_ready_out[i] == 0) else #1 exit_on_error;
				assert(data_ready_out[i] == 0) else #1 exit_on_error;
			end

			assert(head_out == 0) else #1 exit_on_error;
			assert(tail_out == 0) else #1 exit_on_error;
		end
	endtask

	task check_dispatch_in;
		begin
			if (dispatch_addr_ready) begin
				assert(addr_out[tail_test] == dispatch_addr) else #1 exit_on_error;
			end
			assert(addr_ready_out[tail_test] == dispatch_addr_ready) else #1 exit_on_error;
			if (dispatch_data_ready) begin
				assert(data_out[tail_test] == dispatch_data) else #1 exit_on_error;
			end
			assert(data_ready_out[tail_test] == dispatch_data_ready) else #1 exit_on_error;
		end
	endtask

	task check_ex_in;
		begin
			if (ex_addr_en) begin
				assert(addr_out[ex_index] == ex_addr) else #1 exit_on_error;
			end
			assert(addr_ready_out[ex_index] == 1) else #1 exit_on_error;
			if (ex_data_en) begin
				assert(data_out[ex_index] == ex_data) else #1 exit_on_error;
			end
			assert(data_ready_out[ex_index] == 1) else #1 exit_on_error;
		end
	endtask

	task copy_test;
		begin
			addr_test = addr_out;
			addr_ready_test = addr_ready_out;
			data_test = data_out;
			data_ready_test = data_ready_out;
			tail_test = tail_out;
		end
	endtask

	// set clock change
	always `CLOCK_PERIOD clock = ~clock;

	initial begin

		// monitor wires
		$monitor("clock: %b reset: %b rd_en: %b addr_rd: %d ld_pos: %d dispatch_en: %b dispatch_addr: %d dispatch_addr_ready: %b dispatch_data: %d dispatch_data_ready: %b ex_en: %b ex_index: %d ex_addr: %d ex_addr_en: %b ex_data: %d ex_data_en: %b rt_en: %b data_rd: %d rd_valid: %b tail_out: %d full: %b", 
			clock, reset, rd_en, addr_rd, ld_pos, dispatch_en, dispatch_addr, dispatch_addr_ready, dispatch_data, dispatch_data_ready, ex_en, ex_index, ex_addr, ex_addr_en, ex_data, ex_data_en, rt_en, data_rd, rd_valid, tail_out, full);

		// intial values
		clock = ZERO;
		reset = ZERO;
		rd_en = 0;
		addr_rd = 0;
		ld_pos = 0;
		dispatch_en = 0;
		dispatch_addr = 0;
		dispatch_addr_ready = 0;
		dispatch_data = 0;
		dispatch_data_ready = 0;
		ex_en = 0;
		ex_index = 0;
		ex_addr = 0;
		ex_addr_en = 0;
		ex_data = 0;
		ex_data_en = 0;
		rt_en = 0;
		
		$display("Testing Reset...");
		@(negedge clock);
		reset = ONE;

		@(posedge clock);
		`DELAY;
		check_correct_reset;
		copy_test;

		$display("Reset Test Passed");

		$display("Testing Read Empty...");
		@(negedge clock);
		reset = ZERO;
		rd_en = 1;
		addr_rd = 0;
		ld_pos = 0;
		dispatch_en = 0;
		dispatch_addr = 0;
		dispatch_addr_ready = 0;
		dispatch_data = 0;
		dispatch_data_ready = 0;
		ex_en = 0;
		ex_index = 0;
		ex_addr = 0;
		ex_addr_en = 0;
		ex_data = 0;
		ex_data_en = 0;
		rt_en = 0;

		@(posedge clock);
		`DELAY;
		assert(rd_valid == 0) else #1 exit_on_error;

		$display("Read Empty Passed");

		$display("Testing Single Dispatch...");
		@(negedge clock);
		reset = ZERO;
		rd_en = 0;
		addr_rd = 0;
		ld_pos = 0;
		dispatch_en = 1;
		dispatch_addr = 10;
		dispatch_addr_ready = 1;
		dispatch_data = 0;
		dispatch_data_ready = 0;
		ex_en = 0;
		ex_index = 0;
		ex_addr = 0;
		ex_addr_en = 0;
		ex_data = 0;
		ex_data_en = 0;
		rt_en = 0;

		tail_test = tail_out;

		@(posedge clock);
		`DELAY;
		assert(rd_valid == 0) else #1 exit_on_error;
		assert(tail_out == 1) else #1 exit_on_error;
		assert(full == 0) else #1 exit_on_error;
		check_dispatch_in;

		$display("Single Dispatch Passed");

		$display("Testing Single Execute...");
		@(negedge clock);
		reset = ZERO;
		rd_en = 0;
		addr_rd = 0;
		ld_pos = 0;
		dispatch_en = 0;
		dispatch_addr = 0;
		dispatch_addr_ready = 0;
		dispatch_data = 0;
		dispatch_data_ready = 0;
		ex_en = 1;
		ex_index = 0;
		ex_addr = 0;
		ex_addr_en = 0;
		ex_data = 12;
		ex_data_en = 1;
		rt_en = 0;

		@(posedge clock);
		`DELAY;
		assert(rd_valid == 0) else #1 exit_on_error;
		assert(tail_out == 1) else #1 exit_on_error;
		assert(full == 0) else #1 exit_on_error;
		check_ex_in;

		$display("Single Execute Passed");

		$display("Testing Single Retire...");

		@(negedge clock);
		reset = ZERO;
		rd_en = 0;
		addr_rd = 0;
		ld_pos = 0;
		dispatch_en = 0;
		dispatch_addr = 0;
		dispatch_addr_ready = 0;
		dispatch_data = 0;
		dispatch_data_ready = 0;
		ex_en = 0;
		ex_index = 0;
		ex_addr = 0;
		ex_addr_en = 0;
		ex_data = 0;
		ex_data_en = 0;
		rt_en = 1;

		@(posedge clock);
		`DELAY;
		assert(tail_out == 1) else #1 exit_on_error;
		assert(head_out == 1) else #1 exit_on_error;
		assert(addr_ready_out[0] == 0) else #1 exit_on_error;
		assert(data_ready_out[0] == 0) else #1 exit_on_error;

		$display("Single Retire Passed");

		$display("Testing Multiple Dispatch...");

		// reset SQ
		@(negedge clock);
		reset = 1;
		rd_en = 0;
		addr_rd = 0;
		ld_pos = 0;
		dispatch_en = 0;
		dispatch_addr = 0;
		dispatch_addr_ready = 0;
		dispatch_data = 0;
		dispatch_data_ready = 0;
		ex_en = 0;
		ex_index = 0;
		ex_addr = 0;
		ex_addr_en = 0;
		ex_data = 0;
		ex_data_en = 0;
		rt_en = 0;

		@(posedge clock);
		`DELAY;
		check_correct_reset;

		for (int i = 0; i < (`SQ_SIZE - 1); ++i) begin
		
			@(negedge clock);
			reset = 0;
			rd_en = 0;
			addr_rd = 0;
			ld_pos = 0;
			dispatch_en = 1;
			dispatch_addr = $urandom_range(2**32 - 1, 0);
			dispatch_addr_ready = $urandom_range(1, 0);
			dispatch_data = $urandom_range(2**64 - 1, 0);
			dispatch_data_ready = $urandom_range(1, 0);
			ex_en = 0;
			ex_index = 0;
			ex_addr = 0;
			ex_addr_en = 0;
			ex_data = 0;
			ex_data_en = 0;
			rt_en = 0;

			tail_test = tail_out;

			@(posedge clock);
			`DELAY;
			check_dispatch_in;
			assert(tail_out == tail_test + 1) else #1 exit_on_error;

		end
		assert(full == 1) else #1 exit_on_error;

		$display("Multiple Dispatch Passed");

		$display("Testing Multiple Execute...");

		for (int i = 0; i < (`SQ_SIZE - 1); ++i) begin
			@(negedge clock);
			reset = 0;
			rd_en = 0;
			addr_rd = 0;
			ld_pos = 0;
			dispatch_en = 0;
			dispatch_addr = 0;
			dispatch_addr_ready = 0;
			dispatch_data = 0;
			dispatch_data_ready = 0;
			ex_en = 1;
			ex_index = i;
			ex_addr = $urandom_range(2**32 - 1, 0);
			ex_addr_en = ~addr_ready_out[i];
			ex_data = $urandom_range(2**64 - 1, 0);
			ex_data_en = ~data_ready_out[i];
			rt_en = 0;

			@(posedge clock);
			`DELAY;
			check_ex_in;
			assert(full == 1) else #1 exit_on_error;
		end
		$display("Multiple Execute Passed");

		$display("Testing Multiple Retire...");
		copy_test;
		for (int i = 0; i < (`SQ_SIZE - 1); ++i) begin
			@(negedge clock);
			reset = 0;
			rd_en = 0;
			addr_rd = 0;
			ld_pos = 0;
			dispatch_en = 0;
			dispatch_addr = 0;
			dispatch_addr_ready = 0;
			dispatch_data = 0;
			dispatch_data_ready = 0;
			ex_en = 0;
			ex_index = 0;
			ex_addr = 0;
			ex_addr_en = 0;
			ex_data = 0;
			ex_data_en = 0;
			rt_en = 1;

			@(posedge clock);
			`DELAY;
			assert(head_out == i + 1) else #1 exit_on_error;
			assert(tail_test == tail_out) else #1 exit_on_error;
			assert(full == 0) else #1 exit_on_error;			
		end

		$display("Multiple Retire Passed");

		$display("ALL TESTS Passed");
		$finish;
	end


endmodule
