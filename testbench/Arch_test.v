`include "sys_defs.vh"
`define DEBUG

`define DELAY #2

module testbench;
	logic clock, reset, enable;
	PHYS_REG 					T_new_in;
	PHYS_REG					T_old_in;
	
	PHYS_REG		[`NUM_GEN_REG-1:0]	arch_table;

	integer					i,j,k;

	`DUT(Arch_Map_Table) AMT(
		// inputs
		.clock(clock), 
		.reset(reset),
		.enable(enable), 
		.T_new_in(T_new_in), 
		.T_old_in(T_old_in), 
		// outputs 
		.arch_table(arch_table)

	 );

	
	always #10 clock = ~clock;



	// TASKS
	task exit_on_error;
		begin
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	task display_arch_table;
		begin
			$display("-----------Archtecture Map Table-----------");
			for(k=0;k<`NUM_GEN_REG;k=k+1) begin
				$display("Reg:%d, Phys Reg : %d", k, arch_table[k]); 
			end
			$display("------------------------------------------\n");	
		end
	endtask

	
	initial begin
		
		$monitor("Clock: %4.0f, reset: %b, enable:%b, T_new_in:%d, T_old_in:%d", clock, reset, enable, T_new_in, T_old_in);	

		// Initial value
		clock = 1'b0;
		reset = 1'b0;
		enable = 1'b0;
		T_new_in = 7'b0;
		T_old_in = 7'b0;

		@(negedge clock);
		reset = 1'b1;
		
		@(posedge clock);
		`DELAY;
		$display("-----After reset");
		display_arch_table;

		$display("-----Check the Arch Map functionality-----"); // Check the CDB functionality
		
		//
		//
		@(negedge clock);
		reset = 1'b0;
		enable = 1'b1;
		T_old_in = 7'd3;
		T_new_in = 7'd3 + `NUM_GEN_REG;
		@(posedge clock);
		`DELAY;
		display_arch_table;
		assert(arch_table[3]==3+`NUM_GEN_REG) else #1 exit_on_error;
		
		// Update phys reg to phys reg + 32	
		for(i=0;i<`NUM_GEN_REG;i=i+1) begin
			@(negedge clock);
			T_old_in = i;
			T_new_in = i + `NUM_GEN_REG;
			@(posedge clock);
			`DELAY;
			display_arch_table;
			assert(arch_table[i]==i+`NUM_GEN_REG) else #1 exit_on_error;
	
		end


		$display("-----Check reset-----"); // check reset
		
		@(negedge clock);
		reset = 1'b1;
		@(posedge clock);
		`DELAY;
		for(j=0;j<`NUM_GEN_REG;j=j+1) begin
			assert(arch_table[j]==j) else #1 exit_on_error;

		end

		display_arch_table;
	
	
		$display("-----Check enable-----");// check enable	
		
		@(negedge clock);
		reset = 1'b0;
		enable = 1'b0;
		T_old_in = 7'b0000111;
		T_new_in = 7'b0100111;
		@(posedge clock);
		`DELAY;
		for(j=0;j<`NUM_GEN_REG;j=j+1) begin
			assert(arch_table[j]==j) else #1 exit_on_error;

		end

		display_arch_table;

		$display("@@@passed");
		$finish;		

		end
	
endmodule
