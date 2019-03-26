`include "../sys_defs.vh"
`define DEBUG

`define DELAY #2

module testbench;
	logic clock, reset, enable;
	PHYS_REG 		tag_in;
	logic			ex_valid;

	PHYS_REG		CDB_tag_out;
	logic			CDB_en_out;
	logic			busy;
	integer			i;


	`DUT(CDB) CDB1(
		// inputs
		.clock(clock), 
		.reset(reset), 
		.enable(enable), 
		.tag_in(tag_in), 
		.ex_valid(ex_valid),
		// outputs 
		.CDB_tag_out(CDB_tag_out),
		.CDB_en_out(CDB_en_out), 
		.busy(busy)

	 );

	
	always #10 clock = ~clock;



	// TASKS
	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	
	initial begin
		
		$monitor("Clock: %4.0f, reset: %b, enable:%b, tag_in:%d, ex_valid:%b, CDB_tag_out:%d, CDB_en_out:%b, busy:%b", clock, reset, enable, tag_in, ex_valid, CDB_tag_out, CDB_en_out, busy);	

		// Initial value
		clock = 1'b0;
		reset = 1'b0;
		enable = 1'b0;
		tag_in = 0;
		ex_valid = 1'b0;

		@(negedge clock);
		reset = 1'b1;

		$display("-----Check the CDB functionality-----"); // Check the CDB functionality

		
		for(i=0;i<`NUM_PHYS_REG;i=i+1) begin
			@(negedge clock);
			reset =  1'b0;
			enable = 1'b1;
			tag_in = i;
			ex_valid = 1'b1;
			@(posedge clock);
			`DELAY;
			assert(busy & CDB_en_out &(CDB_tag_out==i)) else #1 exit_on_error;
	
		end

		$display("-----Check reset-----"); // check reset
		
		@(negedge clock);
		reset = 1'b1;
		@(posedge clock);
		`DELAY;
		assert(!busy & !CDB_en_out &(CDB_tag_out==7'b0)) else #1 exit_on_error;

		$display("-----Put tag = 3 for future testing-----");

		@(negedge clock);
		reset = 1'b0;
		enable = 1'b1;
		tag_in = 7'b0000011;
		ex_valid = 1'b1;	
		@(posedge clock);
		`DELAY;
		assert(busy & CDB_en_out &(CDB_tag_out==3)) else #1 exit_on_error;



		$display("-----Check enable-----");// check enable	
		
		@(negedge clock);
		reset = 1'b0;
		tag_in = 7'b0011001;
		enable = 1'b0;
		@(posedge clock);
		`DELAY;
		assert(!busy & !CDB_en_out &(CDB_tag_out==7'd3)) else #1 exit_on_error;


		$display("-----Check output is not valid when ex_valid = 0-----"); // check ex_valid
	
		@(negedge clock);
		reset = 1'b0;
		tag_in = 7'b0000011;
		enable = 1'b1;
		ex_valid = 1'b0;
		@(posedge clock);
		`DELAY;
		assert(!busy & !CDB_en_out &(CDB_tag_out==7'd3)) else #1 exit_on_error;

		$display("-----Check output is not valid when enable = 0 and ex_valid = 0-----"); // check enable & ex_valid
	
		@(negedge clock);
		reset = 1'b0;
		tag_in = 7'b0000111;
		enable = 1'b0;
		ex_valid = 1'b0;
		@(posedge clock);
		`DELAY;
		assert(!busy & !CDB_en_out &(CDB_tag_out==7'd3)) else #1 exit_on_error;



		$display("@@@passed");
		$finish;		

		end
	
endmodule

		// Change the inputs with sys_defsvalues
		// 0. Synthesize
		// 1. integrate everything into pipeline (single scalar)
		// + check functionality + precise state & interrupt
		// 2. Superscalar for each module
		// 3. Small test programs (single scalar, super scalar)
		// 4. Automated testing
		// Future work : LSQ + branch predictor

