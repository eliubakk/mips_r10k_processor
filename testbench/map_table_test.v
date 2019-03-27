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
	PHYS_REG T_old_test;


	// input wires
	logic clock;
	logic reset;
	logic enable;
	GEN_REG  [`SS_SIZE-1:0] reg_a;
	GEN_REG  [`SS_SIZE-1:0] reg_b;
	GEN_REG  [`SS_SIZE-1:0] reg_dest;
	PHYS_REG [`SS_SIZE-1:0] free_reg;
	PHYS_REG [`SS_SIZE-1:0] CDB_tag_in;
	logic 	 [`SS_SIZE-1:0] CDB_en;

	// output wires
	MAP_ROW_T [`NUM_GEN_REG-1:0]	map_table_out;
	logic [(`NUM_GEN_REG-1):0] cam_hits_out;
	PHYS_REG [`SS_SIZE-1:0] T1;
	PHYS_REG [`SS_SIZE-1:0] T2;
	PHYS_REG [`SS_SIZE-1:0] T_old;

	
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
		.cam_hits_out(cam_hits_out),
		.T1(T1),
		.T2(T2),
		.T_old(T_old)
	);


	// TASKS
	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	task table_out;

		begin
				$display("**********************************************************\n");
				$display("------------------------MAP TABLE----------------------------\n");

			for(integer i=0;i<`NUM_GEN_REG;i=i+1) begin
				$display("GEN_REG = %d,  PHYS_REG = %d, READY = %d", i, map_table_out[i].phys_tag[$clog2(`NUM_PHYS_REG)-1:0], map_table_out[i].phys_tag[$clog2(`NUM_PHYS_REG)]);
			end
				$display("**********************************************************\n");
		end
	endtask

	task cam_out;

		begin
				$display("**********************************************************\n");
				$display("------------------------CAM HITS----------------------------\n");

			for(integer i=0;i<`NUM_GEN_REG;i=i+1) begin
				$display("GEN_REG = %d, HIT = %d", i, cam_hits_out[i]);
			end
				$display("**********************************************************\n");
		end
	endtask


	// set clock change
	always `CLOCK_PERIOD clock = ~clock;

	initial begin

		// monitor wires
		$monitor("clock: %b reset: %b enable: %b \nCDB_tag_in: %d CDB_en: %d\nreg_a: %d | T1: %d T1_ready: %d \nreg_b: %d | T2: %d T2_ready: %d \nreg_dest: %d free_reg: %d | T_old: %d T_old_ready: %d\n",
					clock, reset, enable, CDB_tag_in[0][$clog2(`NUM_PHYS_REG)-1:0], CDB_en[0], reg_a[0], T1[0][$clog2(`NUM_PHYS_REG)-1:0], T1[0][$clog2(`NUM_PHYS_REG)], reg_b[0], T2[0][$clog2(`NUM_PHYS_REG)-1:0], T2[0][$clog2(`NUM_PHYS_REG)], reg_dest[0], free_reg[0], T_old[0][$clog2(`NUM_PHYS_REG)-1:0], T_old[0][$clog2(`NUM_PHYS_REG)]);

		// intial values
		clock = ZERO;
		reset = ZERO;
		enable = ZERO;
		for(int i = 0; i < `SS_SIZE; i += 1) begin
			reg_a[i] = 0;
			reg_b[i] = 0;
			reg_dest[i] = 0;
			free_reg[i] = 0;
			free_reg[i][$clog2(`NUM_PHYS_REG)] = ONE;
			CDB_tag_in[i] = 0;
			CDB_en[i] = ZERO;
		end

		table_out();

		$display("Testing Reset...");
		@(negedge clock);
		reset = ONE;

		@(posedge clock);
		`DELAY;
		table_out();
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
		reset = ZERO;

		
		// check each gen reg
		for (int i = 0; i < `NUM_GEN_REG; ++i) begin
			for (int j = 0; j < `NUM_GEN_REG; ++j) begin

				table_out();
				@(posedge clock);
				enable = ONE;
				reg_a[0] = i;
				reg_b[0] = j;

				@(negedge clock);
				`DELAY;
				assert(T1[0][$clog2(`NUM_GEN_REG)-1:0] == i) else #1 exit_on_error;
				assert(T1[0][$clog2(`NUM_PHYS_REG)] == ONE) else #1 exit_on_error;
				assert(T2[0][$clog2(`NUM_GEN_REG)-1:0] == j) else #1 exit_on_error;
				assert(T2[0][$clog2(`NUM_PHYS_REG)] == ONE) else #1 exit_on_error;

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
			free_reg[0] = i;
			reg_dest[0] = counter;

			@(posedge clock);
			`DELAY;
			enable = ZERO;
			assert(map_table_out[reg_dest[0]].phys_tag == free_reg[0]) else #1 exit_on_error;
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
			free_reg[0] = i;
			reg_dest[0] = counter;

			@(posedge clock);
			`DELAY;
			enable = ZERO;
			assert(map_table_out[reg_dest[0]].phys_tag == free_reg[0]) else #1 exit_on_error;
			++counter;

		end
		table_out();
		$display("Multiple Reg Dispatch Passed");

		$display("Testing Single Reg Commit...");

		// at this point, all the mapped registers are not ready
		// from the prev test

		// commit a register
		@(negedge clock);
		reset = ZERO;
		CDB_en[0] = ONE;
		CDB_tag_in[0] = 32;
		CDB_tag_in[0][$clog2(`NUM_PHYS_REG)] = ONE;
		`DELAY;
		cam_out();
		@(posedge clock);
		`DELAY;
		CDB_en[0] = ZERO;
		table_out();
		assert(map_table_out[0].phys_tag == CDB_tag_in[0]) else #1 exit_on_error;

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
			free_reg[0] = i;
			reg_dest[0] = counter;

			@(posedge clock);
			`DELAY;
			assert(map_table_out[reg_dest[0]].phys_tag == free_reg[0]) else #1 exit_on_error;
			++counter;

		end

		// at this point, all regs in map_table are not ready
		enable = ZERO;

		for (int i = `NUM_GEN_REG; i < `NUM_PHYS_REG; ++i) begin

			@(negedge clock);
			CDB_en[0] = ONE;
			CDB_tag_in[0] = i;
			CDB_tag_in[0][$clog2(`NUM_PHYS_REG)] = ONE;

			@(posedge clock);
			`DELAY;
			CDB_en = ZERO;
			assert(map_table_out[i - `NUM_GEN_REG].phys_tag == CDB_tag_in[0]) else #1 exit_on_error;
		end
		table_out();
		$display("Multiple Reg Commit Passed");

		$display("Testing Simultaneous Commit and Dispatch...");

		// reset
		@(negedge clock);
		reset = ONE;
		enable = ZERO;
		CDB_en[0] = ZERO;

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
			free_reg[0] = i;
			reg_dest[0] = counter;

			@(posedge clock);
			`DELAY;
			assert(map_table_out[reg_dest[0]].phys_tag == free_reg[0]) else #1 exit_on_error;
			++counter;

		end
		table_out();
		@(posedge clock);
		`DELAY;
		enable = ONE;
		reg_a[0] = 6;
		reg_b[0] = 9;
		reg_dest[0] = 4;
		T_old_test = map_table_out[reg_dest[0]].phys_tag;
		T_old_test[$clog2(`NUM_PHYS_REG)] = ONE;
		CDB_tag_in[0] = 36;
		CDB_tag_in[0][$clog2(`NUM_PHYS_REG)] = ONE;
		CDB_en[0] = ONE;
		free_reg[0] = 0;
		
		`DELAY;
		cam_out();
		assert(T1[0] == `NUM_GEN_REG + reg_a[0]) else #1 exit_on_error;
		assert(T2[0] == `NUM_GEN_REG + reg_b[0]) else #1 exit_on_error;
		assert(T_old[0] == T_old_test) else #1 exit_on_error;

		@(posedge clock);
		`DELAY;
		table_out();
		enable = ZERO;
		CDB_en[0] = ZERO;
		assert(map_table_out[reg_dest[0]].phys_tag == free_reg[0]) else #1 exit_on_error;
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
						map_table_test[j].phys_tag[$clog2(`NUM_PHYS_REG)] = ONE;
					end
				end
			end
			T_old_test =  map_table_test[test_reg_dest].phys_tag;
			if (test_enable) begin
				map_table_test[test_reg_dest].phys_tag = test_free_reg;
			end

			@(negedge clock);
			reset = ZERO;
			enable = test_enable;
			reg_a[0] = test_a;
			reg_b[0] = test_b;
			reg_dest[0] = test_reg_dest;
			free_reg[0] = test_free_reg;
			CDB_tag_in[0] = test_CDB_tag;
			CDB_en[0] = test_CDB_en;
			
			`DELAY;
			if (test_enable) begin
				assert(T1[0] == map_table_test[test_a].phys_tag) else #1 exit_on_error;
				assert(T2[0] == map_table_test[test_b].phys_tag) else #1 exit_on_error;
				assert(T_old[0] == T_old_test)
				assert(map_table_test[test_reg_dest].phys_tag == free_reg[0]) else #1 exit_on_error;
			end

			@(posedge clock);
			`DELAY;
			assert(map_table_out == map_table_test) else #1 exit_on_error;
			
			
		end

		$display("Multiple Simultaneous Commit and Dispatch");

		$display("Testing Basic Branch Incorrect...");

		@(negedge clock);
		enable = ZERO;
		CDB_en[0] = ZERO;
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


		$display("@@@Passed");
		$finish;
	end


endmodule
