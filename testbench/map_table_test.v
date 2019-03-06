`include "sys_defs.vh"

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

		$display("ALL TESTS Passed");
		$finish;
	end


endmodule
