`define DEBUG_OUT
`define DELAY #2

`include "sys_defs.vh"

	
module testbench;
	logic clock, reset, enable;
	
	logic							if_branch;
	logic	[31:0]						if_pc_in;
	
	logic							rt_en_branch;
	logic							rt_prediction_correct;
	logic	[31:0]						rt_pc;
	logic	[31:0]						rt_calculated_pc;
	logic	[31:0]						rt_branch_index;


	logic							next_pc_valid;
	logic	[$clog2(`OBQ_SIZE):0]				next_pc_index;
	logic	[31:0]						next_pc;

	`ifdef DEBUG_OUT
	`endif

	integer i,j,k,l;	


	BP bp(
		// inputs
		.clock(clock), 
		.reset(reset), 
		.enable(enable),
		
		.if_branch(if_branch), 
		.if_pc_in(if_pc_in),
		
		.rt_en_branch(rt_en_branch),
		.rt_prediction_correct(rt_prediction_correct),
		.rt_pc(rt_pc),
		.rt_calculated_pc(rt_calculated_pc),
		.rt_branch_index(rt_branch_index),		

		// outputs 
		`ifdef DEBUG_OUT
		`endif
		.next_pc_valid(next_pc_valid),
		.next_pc_index(next_pc_index),
		.next_pc(next_pc)

	
	);


	
	always #10 clock = ~clock;



	// TASKS
	task exit_on_error;
		begin
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask


	
	initial begin
		
		$monitor("Clock: %4.0f, reset: %b, enable: %b, if_branch: %b, if_pc_in: %h. rt_en_branch: %b, rt_prediction_correct: %b, rt_pc: %h, rt_calculated_pc: %h, rt_branch_index: %b, next_pc_valid : %b, next_pc_index : %b, next_pc : %h", clock, reset, enable, if_branch, if_pc_in, rt_en_branch, rt_prediction_correct, rt_pc, rt_calculated_pc, rt_branch_index, next_pc_valid, next_pc_index, next_pc);	

		// Initial value
		clock 			= 1'b0;
		reset 			= 1'b0;
		enable 			= 1'b0;
		if_branch		= 1'b0;
		if_pc_in 			= 32'h0;
		rt_en_branch		= 1'b0;
		rt_prediction_correct	= 1'b0;
		rt_pc			= 32'h0;
		rt_calculated_pc	= 32'h0;
		rt_branch_index		= `OBQ_SIZE+1'b0; 
	
		// Reset
		@(negedge clock);
		$display("--------------------------------RESET----------------------------------"); 
		reset = 1'b1;
		enable = 1'b0;

		@(negedge clock);
		reset = 1'b0;
		enable = 1'b1;
		@(posedge clock);
		`DELAY;
		//display_table;

		$display("@@@passed");
		$finish;		
	end
	
endmodule


