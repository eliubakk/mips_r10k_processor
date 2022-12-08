`include "../../sys_defs.vh"

`define DEBUG

`define DELAY #2

module testbench;
	logic clock, reset;
	logic [`SS_SIZE-1:0] 	enable;
	PHYS_REG [`SS_SIZE-1:0] T_new_in;
	PHYS_REG [`SS_SIZE-1:0] T_old_in;
	
	PHYS_REG [`NUM_GEN_REG-1:0]	arch_map_table;

	integer i,j,k;

	`DUT(Arch_Map_Table) AMT(
		// inputs
		.clock(clock), 
		.reset(reset),
		.enable(enable), 
		.T_new_in(T_new_in), 
		.T_old_in(T_old_in), 
		// outputs 
		.arch_map_table(arch_map_table)

	 );

	
	always #10 clock = ~clock;



	// TASKS
	task exit_on_error;
		begin
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	task display_arch_map_table;
		begin
			$display("-----------Archtecture Map Table-----------");
			for(k = 0; k < `NUM_GEN_REG; k += 1) begin
				$display("Reg:%d, Phys Reg : %d", k, arch_map_table[k][$clog2(`NUM_PHYS_REG)-1:0]); 
			end
			$display("------------------------------------------\n");	
		end
	endtask

	
	initial begin
		if(`SS_SIZE == 1) begin
			$monitor("Clock: %4.0f, reset: %b, enable:%b, T_new_in:%d, T_old_in:%d", clock, reset, enable, T_new_in[0][$clog2(`NUM_PHYS_REG)-1:0], T_old_in[0][$clog2(`NUM_PHYS_REG)-1:0]);	
		end else begin
			$monitor("Clock: %4.0f, reset: %b, enable:%b\nT_new_in[2]:%d, T_old_in[2]:%d\nT_new_in[1]:%d, T_old_in[1]:%d\nT_new_in[0]:%d, T_old_in[0]:%d", clock, reset, enable, 
									T_new_in[2][$clog2(`NUM_PHYS_REG)-1:0], T_old_in[2][$clog2(`NUM_PHYS_REG)-1:0], 
									T_new_in[1][$clog2(`NUM_PHYS_REG)-1:0], T_old_in[1][$clog2(`NUM_PHYS_REG)-1:0], 
									T_new_in[0][$clog2(`NUM_PHYS_REG)-1:0], T_old_in[0][$clog2(`NUM_PHYS_REG)-1:0]);	
		end
		// Initial value
		clock = 1'b0;
		reset = 1'b0;
		enable = {`SS_SIZE{1'b0}};
		T_new_in = {`SS_SIZE{`DUMMY_REG}};
		T_old_in = {`SS_SIZE{`DUMMY_REG}};

		@(negedge clock);
		reset = 1'b1;
		
		@(posedge clock);
		`DELAY;
		$display("-----After reset");
		display_arch_map_table;

		$display("-----Check the Arch Map functionality-----"); // Check the CDB functionality
		
		@(negedge clock);
		reset = 1'b0;
		enable[`SS_SIZE-1] = 1'b1;
		T_old_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)-1:0] = 3;
		T_old_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_new_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)-1:0] = (3 + `NUM_GEN_REG);
		T_new_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)] = 1'b1;
		@(posedge clock);
		`DELAY;
		display_arch_map_table;
		assert(arch_map_table[3] == ((1'b1 << $clog2(`NUM_PHYS_REG)) | (3 + `NUM_GEN_REG))) else #1 exit_on_error;
		
		// Update phys reg to phys reg + 32	
		for(i = 0; i < `NUM_GEN_REG; i += 1) begin
			@(negedge clock);
			T_old_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)-1:0] = i;
			T_old_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)] = 1'b1;
			T_new_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)-1:0] = (i + `NUM_GEN_REG);
			T_new_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)] = 1'b1;
			@(posedge clock);
			`DELAY;
			display_arch_map_table;
			assert(arch_map_table[i] == ((1'b1 << $clog2(`NUM_PHYS_REG)) | (i + `NUM_GEN_REG))) else #1 exit_on_error;
	
		end

		$display("-----Check reset-----"); // check reset
		
		@(negedge clock);
		reset = 1'b1;
		@(posedge clock);
		`DELAY;
		enable = {`SS_SIZE{1'b0}};
		reset = 1'b0;
		for(i = 0; i < `NUM_GEN_REG; i += 1) begin
			assert(arch_map_table[i] == ((1'b1 << $clog2(`NUM_PHYS_REG)) | i)) else #1 exit_on_error;

		end

		display_arch_map_table;
	
	
		$display("-----Check enable-----");// check enable	
		
		@(negedge clock);
		reset = 1'b0;
		enable[`SS_SIZE-1] = 1'b0;
		T_old_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)-1:0] = 7;
		T_old_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_new_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)-1:0] = (7 + `NUM_GEN_REG);
		T_new_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)] = 1'b1;
		@(posedge clock);
		`DELAY;
		for(i = 0; i < `NUM_GEN_REG; i += 1) begin
			assert(arch_map_table[i] == ((1'b1 << $clog2(`NUM_PHYS_REG)) | i)) else #1 exit_on_error;
		end

		display_arch_map_table;

		// random numbers
		$display("-----Random number check"); // check for random numbers

		for(i = 0; i < `NUM_GEN_REG; i += 1) begin
			@(negedge clock);
			enable[`SS_SIZE-1] = 1'b1;
			T_old_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)-1:0] = i;
			T_old_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)] = 1'b1;
			T_new_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)-1:0] = $urandom()%`NUM_GEN_REG + `NUM_GEN_REG;
			T_new_in[`SS_SIZE-1][$clog2(`NUM_PHYS_REG)] = 1'b1;
			@(posedge clock);
			`DELAY;
			display_arch_map_table;
			assert(arch_map_table[i] == T_new_in[`SS_SIZE-1]) else #1 exit_on_error;
		end

		if(`SS_SIZE == 1) begin
			$display("@@@passed");
			$finish;	
		end	

		$display("------Test superscalar------");
		
		@(negedge clock);
		reset = 1'b1;
		@(posedge clock);
		`DELAY;
		enable = {`SS_SIZE{1'b0}};
		reset = 1'b0;

		//Three instructions with no dependencies
		for(i = `SS_SIZE-1; i >= 0; i -= 1) begin
			enable[i] = 1'b1;
			T_old_in[i][$clog2(`NUM_PHYS_REG)-1:0] = (`SS_SIZE - 1 - i);
			T_old_in[i][$clog2(`NUM_PHYS_REG)] = 1'b1;
			T_new_in[i][$clog2(`NUM_PHYS_REG)-1:0] = ((`SS_SIZE - 1 - i) + `NUM_GEN_REG);
			T_new_in[i][$clog2(`NUM_PHYS_REG)] = 1'b1;
		end
		@(posedge clock);
		`DELAY;
		enable = {`SS_SIZE{1'b0}};
		display_arch_map_table;
		for(i = 0; i < `SS_SIZE; i += 1) begin
			assert(arch_map_table[`SS_SIZE - 1 - i] == T_new_in[i]) else #1 exit_on_error;
		end

		//Three instructions dependency between 2 and 1
		enable = {`SS_SIZE{1'b1}};
		T_old_in[2][$clog2(`NUM_PHYS_REG)-1:0] = 3;
		T_old_in[2][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_new_in[2][$clog2(`NUM_PHYS_REG)-1:0] = (3 + `NUM_GEN_REG);
		T_new_in[2][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_old_in[1][$clog2(`NUM_PHYS_REG)-1:0] = (3 + `NUM_GEN_REG);
		T_old_in[1][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_new_in[1][$clog2(`NUM_PHYS_REG)-1:0] = (4 + `NUM_GEN_REG);
		T_new_in[1][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_old_in[0][$clog2(`NUM_PHYS_REG)-1:0] = 4;
		T_old_in[0][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_new_in[0][$clog2(`NUM_PHYS_REG)-1:0] = (5 + `NUM_GEN_REG);
		T_new_in[0][$clog2(`NUM_PHYS_REG)] = 1'b1;
		@(posedge clock);
		`DELAY;
		enable = {`SS_SIZE{1'b0}};
		display_arch_map_table;
		assert(arch_map_table[3] == T_new_in[1]) else #1 exit_on_error;
		assert(arch_map_table[4] == T_new_in[0]) else #1 exit_on_error;

		//Three instructions dependency between 2 and 0
		enable = {`SS_SIZE{1'b1}};
		T_old_in[2][$clog2(`NUM_PHYS_REG)-1:0] = 5;
		T_old_in[2][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_new_in[2][$clog2(`NUM_PHYS_REG)-1:0] = (6 + `NUM_GEN_REG);
		T_new_in[2][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_old_in[1][$clog2(`NUM_PHYS_REG)-1:0] = 6;
		T_old_in[1][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_new_in[1][$clog2(`NUM_PHYS_REG)-1:0] = (8 + `NUM_GEN_REG);
		T_new_in[1][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_old_in[0][$clog2(`NUM_PHYS_REG)-1:0] = (6 + `NUM_GEN_REG);
		T_old_in[0][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_new_in[0][$clog2(`NUM_PHYS_REG)-1:0] = (7 + `NUM_GEN_REG);
		T_new_in[0][$clog2(`NUM_PHYS_REG)] = 1'b1;
		@(posedge clock);
		`DELAY;
		enable = {`SS_SIZE{1'b0}};
		display_arch_map_table;
		assert(arch_map_table[5] == T_new_in[0]) else #1 exit_on_error;
		assert(arch_map_table[6] == T_new_in[1]) else #1 exit_on_error;

		//Three instructions dependency between 1 and 0
		enable = {`SS_SIZE{1'b1}};
		T_old_in[2][$clog2(`NUM_PHYS_REG)-1:0] = 7;
		T_old_in[2][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_new_in[2][$clog2(`NUM_PHYS_REG)-1:0] = (9 + `NUM_GEN_REG);
		T_new_in[2][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_old_in[1][$clog2(`NUM_PHYS_REG)-1:0] = 8;
		T_old_in[1][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_new_in[1][$clog2(`NUM_PHYS_REG)-1:0] = (10 + `NUM_GEN_REG);
		T_new_in[1][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_old_in[0][$clog2(`NUM_PHYS_REG)-1:0] = (10 + `NUM_GEN_REG);
		T_old_in[0][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_new_in[0][$clog2(`NUM_PHYS_REG)-1:0] = (11 + `NUM_GEN_REG);
		T_new_in[0][$clog2(`NUM_PHYS_REG)] = 1'b1;
		@(posedge clock);
		`DELAY;
		enable = {`SS_SIZE{1'b0}};
		display_arch_map_table;
		assert(arch_map_table[7] == T_new_in[2]) else #1 exit_on_error;
		assert(arch_map_table[8] == T_new_in[0]) else #1 exit_on_error;

		//Three instructions dependency between (2 and 1) and (1 and 0)
		enable = {`SS_SIZE{1'b1}};
		T_old_in[2][$clog2(`NUM_PHYS_REG)-1:0] = 9;
		T_old_in[2][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_new_in[2][$clog2(`NUM_PHYS_REG)-1:0] = (12 + `NUM_GEN_REG);
		T_new_in[2][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_old_in[1][$clog2(`NUM_PHYS_REG)-1:0] = (12 + `NUM_GEN_REG);
		T_old_in[1][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_new_in[1][$clog2(`NUM_PHYS_REG)-1:0] = (13 + `NUM_GEN_REG);
		T_new_in[1][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_old_in[0][$clog2(`NUM_PHYS_REG)-1:0] = (13 + `NUM_GEN_REG);
		T_old_in[0][$clog2(`NUM_PHYS_REG)] = 1'b1;
		T_new_in[0][$clog2(`NUM_PHYS_REG)-1:0] = (14 + `NUM_GEN_REG);
		T_new_in[0][$clog2(`NUM_PHYS_REG)] = 1'b1;
		@(posedge clock);
		`DELAY;
		enable = {`SS_SIZE{1'b0}};
		display_arch_map_table;
		assert(arch_map_table[9] == T_new_in[0]) else #1 exit_on_error;
		
		$display("@@@passed");
		$finish;
		end	
endmodule
