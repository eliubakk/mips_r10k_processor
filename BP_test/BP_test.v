`define DEBUG_OUT
`define DELAY #2

`include "sys_defs.vh"

	
module testbench;
	logic clock, reset, enable;
	
	logic							if_branch;
	logic	[31:0]						if_pc_in;
	
	logic							rt_en_branch;
	logic							rt_branch_taken;
	logic							rt_prediction_correct;
	logic	[31:0]						rt_pc;
	logic	[31:0]						rt_calculated_pc;
	logic	[31:0]						rt_branch_index;


	logic							next_pc_valid;
	logic	[$clog2(`OBQ_SIZE):0]				next_pc_index;
	logic	[31:0]						next_pc;

	`ifdef DEBUG_OUT
	//BTB
	logic 	[`BTB_ROW-1:0]					valid_out;
	logic	[`BTB_ROW-1:0]	[`TAG_SIZE-1:0]			tag_out;
	logic	[`BTB_ROW-1:0]	[`TARGET_SIZE-1:0]		target_address_out;
	//OBQ
	OBQ_ROW_T [`OBQ_SIZE-1:0] 				obq_out;
	logic [$clog2(`OBQ_SIZE):0] 				tail_out;
	//GSHARE
	logic	[2**(`BH_SIZE)-1:0]				pht_out;
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
		.rt_branch_taken(rt_branch_taken),
		.rt_prediction_correct(rt_prediction_correct),
		.rt_pc(rt_pc),
		.rt_calculated_pc(rt_calculated_pc),
		.rt_branch_index(rt_branch_index),		

		// outputs 
		`ifdef DEBUG_OUT
		//BTB
		.valid_out(valid_out),
		.tag_out(tag_out),
		.target_address_out(target_address_out),
		//OBQ
		.obq_out(obq_out),
		.tail_out(tail_out),
		//GSHARE
		.pht_out(pht_out),		

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

	task display_table;
		begin
			$display("*******************************************************************************");
			$display("*******************************************************************************");
		
			$display("FETCH_IN @@@ if_branch : %d, if_pc_in : %h", if_branch, if_pc_in);
			$display("RETIRE_IN @@@ rt_en_branch : %b, rt_branch_taken : %b, rt_prediction_correct : %b", rt_en_branch, rt_branch_taken, rt_prediction_correct);
			$display("FETCH_OUT @@@ rt_pc : %h, rt_calculated_pc : %h, rt_branch_index : %5.0b", rt_pc, rt_calculated_pc, rt_branch_index);
			$display("--------------------------BTB-----------------------------------");
			$display("index(pc[%2.0d:2]		valid		tag(pc[%2.0d,%2.0d])	target_address(pc[%2.0d,2])",$clog2(`BTB_ROW)+1, `TAG_SIZE+$clog2(`BTB_ROW)+2, $clog2(`BTB_ROW)+2, `TARGET_SIZE+1 );
			for(i=0;i<`BTB_ROW;i=i+1) begin
			$display("%d		 %1.0b		%h		%h",i,valid_out[i], tag_out[i], target_address_out[i] );
			end
			$display("*******************************************************************************");
			$display("--------------------------GSHARE PHT-----------------------------------");
				$display("GHT idx           PHT");
			for(i=0;i<(2**`BH_SIZE);i=i+1) begin
				$display("Idx %b : Prediction %b", i[`BH_SIZE-1:0], pht_out[i]);
			end
			
			$display("*******************************************************************************");
			$display("---------------------------OBQ-----------------------------------------");
			
			// From Ash	
			
			$display("*******************************************************************************");
			$display("*******************************************************************************");


		end
	endtask


	
	initial begin
		
		$monitor("Clock: %4.0f, reset: %b, enable: %b, if_branch: %b, if_pc_in: %h. rt_en_branch: %b, rt_prediction_correct: %b, rt_pc: %h, rt_calculated_pc: %h, rt_branch_index: %5.0b, next_pc_valid : %b, next_pc_index : %b, next_pc : %h", clock, reset, enable, if_branch, if_pc_in, rt_en_branch, rt_prediction_correct, rt_pc, rt_calculated_pc, rt_branch_index, next_pc_valid, next_pc_index, next_pc);	

		// Initial value
		clock 			= 1'b0;
		reset 			= 1'b0;
		enable 			= 1'b0;
		//Input from fetch
		if_branch		= 1'b0;
		if_pc_in 		= 32'h0;
		//Input from retire
		rt_en_branch		= 1'b0;
		rt_branch_taken		= 1'b0;
		rt_prediction_correct	= 1'b0;
		rt_pc			= 32'h0;
		rt_calculated_pc	= 32'h0;
		rt_branch_index		= {$clog2(`OBQ_SIZE){1'b0}}; 
	
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
		display_table;
		// assert () else #1 exit_on_error;


		// Need to do : How do we know whether the instruction is
		// branch or not before decode?

	
		// Fetch Input : branch but not in BTB, branch and in BTB, not
		// branch
		// Retire Input : branch prediction correct, branch prediction
		// incorrect

		@(negedge clock);
		$display("--------------------------------Testing when the instruction is branch but not in BTB ----------------------------------"); 
		if_branch		= 1'b1;
		if_pc_in 		= 32'h20;
		rt_en_branch		= 1'b0;
		rt_branch_taken		= 1'b0;
		rt_prediction_correct	= 1'b0;
		rt_pc			= 32'h0;
		rt_calculated_pc	= 32'h0;
		rt_branch_index		= {$clog2(`OBQ_SIZE){1'b0}};

		@(posedge clock);
		`DELAY;
		//display_table;
		// assert () else #1 exit_on_error;
		//
		@(negedge clock);
		$display("--------------------------------Update the BTB and OBQ ----------------------------------"); 
		if_branch		= 1'b0;
		if_pc_in 		= 32'h20;
		rt_en_branch		= 1'b1;
		rt_branch_taken		= 1'b1;
		rt_prediction_correct	= 1'b0;
		rt_pc			= 32'h20;
		rt_calculated_pc	= 32'h30;
		rt_branch_index		= {$clog2(`OBQ_SIZE){1'b0}};

		@(posedge clock);
		`DELAY;
		display_table;
		// assert () else #1 exit_on_error;
		//
		//
		@(negedge clock);
		$display("--------------------------------Fetch the updated PC address ----------------------------------"); 
		if_branch		= 1'b1;
		if_pc_in 		= 32'h20;
		rt_en_branch		= 1'b0;
		rt_branch_taken		= 1'b0;
		rt_prediction_correct	= 1'b0;
		rt_pc			= 32'h20;
		rt_calculated_pc	= 32'h30;
		rt_branch_index		= {$clog2(`OBQ_SIZE){1'b0}};

		@(posedge clock);
		`DELAY;
		//display_table;
		// assert () else #1 exit_on_error;


		


		$display("@@@passed");
		$finish;		
	end

	
	
endmodule


