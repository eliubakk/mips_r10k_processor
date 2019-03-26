`include "../../sys_defs.vh"

`define DELAY #2
`define CLOCK_PERIOD #10
`define DEBUG

module testbench;

	// parameters

	parameter ONE = 1'b1;
	parameter ZERO = 1'b0;

	// initialize wires

	MAP_ROW_T [`NUM_GEN_REG-1:0]	map_table_test;
	PHYS_REG test_tag;
	int counter = 0;
	MAP_ROW_T [`NUM_GEN_REG-1:0]	map_check_point;
	logic branch_incorrect = ZERO;

	int test_a;
	int test_b;
	int test_reg_dest;
	int test_free_reg;
	int test_CDB_tag;
	logic test_CDB_en;
	logic test_enable;


	// input wires
	logic clock;
	logic reset;
	logic enable;
	GEN_REG reg_a;
	GEN_REG reg_b;
	GEN_REG reg_dest;
	PHYS_REG free_reg;
	PHYS_REG CDB_tag_in;
	logic CDB_en;

	// output wires
	MAP_ROW_T [`NUM_GEN_REG-1:0]	map_table_out;
	PHYS_REG T1;
	PHYS_REG T2;
	PHYS_REG T;

	
	// initialize module

	`DUT(Map_Table) mt0(
		// inputs
		.clock(clock),
		.reset(reset),
		.enable(enable),
		.reg_a(reg_a),
		.reg_b(reg_b),
		.reg_dest(reg_dest),
		.free_reg(free_reg),
		.CDB_tag_in(CDB_tag_in),
		.CDB_en(CDB_en),
		.branch_incorrect(branch_incorrect),
		.map_check_point(map_check_point),
		// outputs
		.map_table_out(map_table_out),
		.T1(T1),
		.T2(T2),
		.T(T)
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
		$monitor("clock: %b reset: %b enable: %b reg_a: %d reg_b: %d reg_dest: %d free_reg: %d CDB_tag_in: %d CDB_en: %d T1: %d T2: %d T: %d",
					clock, reset, enable, reg_a, reg_b, reg_dest, free_reg, CDB_tag_in, CDB_en, T1, T2, T);

		// intial values
		clock = ZERO;
		reset = ZERO;
		enable = ZERO;
		reg_a = 0;
		reg_b = 0;
		reg_dest = 0;
		free_reg = 0;
		CDB_tag_in = 0;
		CDB_en = ZERO;

		$display("Testing Reset...");
		@(negedge clock);
		reset = ONE;

		@(posedge clock);
		`DELAY;
		// check that at reset, all mappings of gen purp reg are
		// to their equivalent phys reg
		for (int i = 0; i < `NUM_GEN_REG; ++i) begin
			assert(map_table_out[i].phys_tag[$clog2(`NUM_PHYS_REG)-1:0] == i) else #1 exit_on_error;
			assert(map_table_out[i].phys_tag[$clog2(`NUM_PHYS_REG)] == ONE) else #1 exit_on_error;
		end

		$display("Reset Test Passed");

		$display("Testing Get Mapped Registers...");

		// reset
		@(negedge clock);
		reset = ONE;

		// check each gen reg
		for (int i = 0; i < `NUM_GEN_REG; ++i) begin
			for (int j = 0; j < `NUM_GEN_REG; ++j) begin


				@(negedge clock);
				enable = ONE;
				reg_a = i;
				reg_b = j;

				@(posedge clock);
				`DELAY;
				assert(T1[$clog2(`NUM_GEN_REG)-1:0] == i) else #1 exit_on_error;
				assert(T1[$clog2(`NUM_PHYS_REG)] == ONE) else #1 exit_on_error;
				assert(T2[$clog2(`NUM_GEN_REG)-1:0] == j) else #1 exit_on_error;
				assert(T2[$clog2(`NUM_PHYS_REG)] == ONE) else #1 exit_on_error;

			end
		end

		// reset
		@(negedge clock);
		reset = ONE;
		enable = ZERO;

		$display("Get Mapped Registers Passed");

		map_table_test = map_table_out;

		$display("Testing Single Reg Dispatch...");

		// reset
		@(negedge clock);
		reset = ZERO;
		enable = ZERO;

		for (int i = `NUM_GEN_REG; i < `NUM_PHYS_REG; ++i) begin

			// reset
			@(negedge clock);
			reset = ZERO;
			enable = ZERO;

			// map new registers in map_table
			// the newly mapped registers are marked as not ready
			@(negedge clock);
			enable = ONE;
			free_reg = i;
			reg_dest = counter;

			@(posedge clock);
			`DELAY;
			enable = ZERO;
			assert(map_table_out[reg_dest].phys_tag == free_reg) else #1 exit_on_error;
			++counter;

			// reset
			@(negedge clock);
			reset = ZERO;
			enable = ZERO;

		end

		$display("Single Reg Dispatch Passed");

		$display("Testing Multiple Reg Dispatch...");

		counter = 0;
		// reset
		@(negedge clock);
		reset = ZERO;
		enable = ZERO;

		for (int i = `NUM_GEN_REG; i < `NUM_PHYS_REG; ++i) begin

			// map new registers in map_table
			// the newly mapped registers are marked as not ready
			@(negedge clock);
			enable = ONE;
			free_reg = i;
			reg_dest = counter;

			@(posedge clock);
			`DELAY;
			enable = ZERO;
			assert(map_table_out[reg_dest].phys_tag == free_reg) else #1 exit_on_error;
			++counter;

		end

		$display("Multiple Reg Dispatch Passed");

		$display("Testing Single Reg Commit...");

		// at this point, all the mapped registers are not ready
		// from the prev test

		// commit a register
		@(negedge clock);
		reset = ZERO;
		CDB_en = ONE;
		CDB_tag_in = 32;
		CDB_tag_in[$clog2(`NUM_PHYS_REG)] = ONE;

		@(posedge clock);
		`DELAY;
		CDB_en = ZERO;
		assert(map_table_out[0].phys_tag == CDB_tag_in) else #1 exit_on_error;

		$display("Single Reg Commit Passed");

		$display("Testing Multiple Reg Commit...");

		// set up map_table so ready bits are 0

		counter = 0;
		// reset
		@(negedge clock);
		reset = ZERO;
		enable = ZERO;

		for (int i = `NUM_GEN_REG; i < `NUM_PHYS_REG; ++i) begin

			// map new registers in map_table
			// the newly mapped registers are marked as not ready
			@(negedge clock);
			enable = ONE;
			free_reg = i;
			reg_dest = counter;

			@(posedge clock);
			`DELAY;
			assert(map_table_out[reg_dest].phys_tag == free_reg) else #1 exit_on_error;
			++counter;

		end

		// at this point, all regs in map_table are not ready
		enable = ZERO;

		for (int i = `NUM_GEN_REG; i < `NUM_PHYS_REG; ++i) begin

			@(negedge clock);
			CDB_en = ONE;
			CDB_tag_in = i;
			CDB_tag_in[$clog2(`NUM_PHYS_REG)] = ONE;

			@(posedge clock);
			`DELAY;
			CDB_en = ZERO;
			assert(map_table_out[i - `NUM_GEN_REG].phys_tag == CDB_tag_in) else #1 exit_on_error;
		end

		$display("Multiple Reg Commit Passed");

		$display("Testing Simultaneous Commit and Dispatch...");

		// reset
		@(negedge clock);
		reset = ZERO;
		enable = ZERO;
		CDB_en = ZERO;

		counter = 0;
		// reset
		@(negedge clock);
		reset = ZERO;
		enable = ZERO;

		for (int i = `NUM_GEN_REG; i < `NUM_PHYS_REG; ++i) begin

			// map new registers in map_table
			// the newly mapped registers are marked as not ready
			@(negedge clock);
			enable = ONE;
			free_reg = i;
			reg_dest = counter;

			@(posedge clock);
			`DELAY;
			assert(map_table_out[reg_dest].phys_tag == free_reg) else #1 exit_on_error;
			++counter;

		end

		@(negedge clock);
		enable = ONE;
		CDB_en = ONE;
		reg_a = 6;
		reg_b = 9;
		reg_dest = 4;
		CDB_tag_in = 36;
		CDB_tag_in[$clog2(`NUM_PHYS_REG)] = ONE;
		free_reg = 0;

		@(posedge clock);
		`DELAY;
		enable = ZERO;
		CDB_en = ZERO;
		assert(map_table_out[reg_dest].phys_tag == free_reg) else #1 exit_on_error;
		assert(T1 == `NUM_GEN_REG + reg_a) else #1 exit_on_error;
		assert(T2 == `NUM_GEN_REG + reg_b) else #1 exit_on_error;
		assert(T == free_reg) else #1 exit_on_error;

		$display("Simultaneous Commit and Dispatch Passed");

		$display("Testing Multiple Simultaneous Commit and Dispatch...");


		for (int i = 0; i < 50; ++i) begin
			test_a = $urandom_range(31, 0);
			test_b = $urandom_range(31, 0);
			test_reg_dest = $urandom_range(31, 0);
			test_free_reg = $urandom_range(63, 0);
			test_CDB_tag = $urandom_range(63, 0);
			test_CDB_en = $urandom_range(1, 0);
			test_enable = $urandom_range(1, 0);
			map_table_test = map_table_out;

			if (test_CDB_en) begin
				for (int j = 0; j < `NUM_GEN_REG; ++j) begin
					if (map_table_test[j].phys_tag[$clog2(`NUM_PHYS_REG)-1:0] == test_CDB_tag[$clog2(`NUM_PHYS_REG)-1:0]) begin
						map_table_test[j].phys_tag = test_CDB_tag;
					end
				end
			end

			if (test_enable) begin
				map_table_test[test_reg_dest].phys_tag = test_free_reg;
			end

			@(negedge clock);
			reset = ZERO;
			enable = test_enable;
			reg_a = test_a;
			reg_b = test_b;
			reg_dest = test_reg_dest;
			free_reg = test_free_reg;
			CDB_tag_in = test_CDB_tag;
			CDB_en = test_CDB_en;

			@(posedge clock);
			`DELAY;
			assert(map_table_out == map_table_test) else #1 exit_on_error;
			if (test_enable) begin
				assert(T1 == map_table_test[test_a].phys_tag) else #1 exit_on_error;
				assert(T2 == map_table_test[test_b].phys_tag) else #1 exit_on_error;
				assert(T == map_table_test[test_reg_dest].phys_tag) else #1 exit_on_error;
			end
			
		end

		$display("Multiple Simultaneous Commit and Dispatch");

		$display("Testing Basic Branch Incorrect...");

		@(negedge clock);
		enable = ZERO;
		CDB_en = ZERO;
		for (int i = 0; i < `NUM_GEN_REG; ++i) begin
			map_check_point[i].phys_tag = i + 4;
		end

		@(negedge clock);
		branch_incorrect = ONE;

		@(posedge clock);
		`DELAY;
		assert(map_table_out == map_check_point) else #1 exit_on_error;

		$display("Basic Branch Incorrect Passed");

		$display("Testing Multiple Branch Incorrect...");

		branch_incorrect = ZERO;

		for (int i = 0; i < 10; ++i) begin
			@(negedge clock);
			for (int j = 0; j < `NUM_GEN_REG; ++j) begin
				map_check_point[j] = $urandom_range(`NUM_PHYS_REG - 1, 0);
			end
			branch_incorrect = ONE;

			@(posedge clock);
			`DELAY;
			branch_incorrect = ZERO;
			assert(map_table_out == map_check_point) else #1 exit_on_error;
		end

		$display("Multiple Branch Incorrect Passed");


		$display("ALL TESTS Passed");
		$finish;
	end


endmodule
