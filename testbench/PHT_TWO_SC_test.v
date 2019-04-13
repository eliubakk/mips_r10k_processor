`define DEBUG

`include "../../sys_defs.vh"

`define DELAY #2
module testbench;
	logic clock, reset, enable;
	logic			if_branch;
	logic 	[31:0]		if_pc_in;
	logic			rt_branch;
	logic	[31:0]		rt_pc_in;
	logic			rt_branch_taken;	


	logic	 		if_prediction;
	logic			if_prediction_valid;
	`ifdef DEBUG
	logic 	[`PHT_ROW-1:0][1:0] 	pht_out;
	`endif

	integer i,j,k,l;	


	PHT_TWO_SC pht_0(
		// inputs
		.clock(clock), 
		.reset(reset), 
		.enable(enable), 
		.if_branch(if_branch),
		.if_pc_in(if_pc_in),
		.rt_branch(rt_branch),
		.rt_pc_in(rt_pc_in),
		.rt_branch_taken(rt_branch_taken),
		
		// outputs 
		`ifdef DEBUG
		.pht_out(pht_out),
		`endif	
	
		.if_prediction(if_prediction),
		.if_prediction_valid(if_prediction_valid)
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

	task display_pht;
		begin
			
			$display("\n----------Display PHT--------------------");
			$display(" Fetch : if_branch %d, if_pc_in : %h", if_branch, if_pc_in);
			$display(" Fetch prediction valid : %b, Fetch prediction : %b", if_prediction_valid, if_prediction);
			$display(" Retire : rt_branch %d, rt_pc_in : %h", rt_branch, rt_pc_in);
			$display(" 	    rt_branch_taken %d", rt_branch_taken);
			$display("\n----------Prediction History Table--------");
			for(j=0;j<`PHT_ROW;j=j+1) begin
				$display("Idx %1.0d : Prediction %2.0b", j, pht_out[j][1:0]);	
			end
			$display("-------------------------------------------\n");
		end
	endtask

	task reset_test;
		begin
			assert((!if_prediction_valid) && (!if_prediction)) else #1 exit_on_error;
			for(i=0;i<`PHT_ROW;++i) begin
				assert( pht_out[i] == 2'b0 ) else #1 exit_on_error;
			end
		end
	endtask
	
	initial begin
		
		$monitor("Clock: %4.0f, reset: %b, enable: %b",clock, reset, enable);	

		// Initial value
		clock = 1'b0;
		reset = 1'b0;
		enable = 1'b0;

		if_branch = 1'b0;	
		if_pc_in = 32'h0;
		rt_branch = 1'b0;
		rt_pc_in = 32'h0;
		rt_branch_taken = 1'b0;	
		
		// Reset
		
		$display("\n RESET test"); 
		@(negedge clock);
		reset = 1'b1;

		@(posedge clock);
		`DELAY;
		display_pht;
	  	reset_test;	

		$display("@@@ RESET test passed\n ");


		
		// Retirement test
		//
		$display("\n Retire test");
		@(negedge clock);
		reset = 1'b0;
		enable =1'b1;
	
		rt_branch = 1'b1;
		rt_pc_in = 4*(3+`PHT_ROW*5);
		rt_branch_taken = 1'b1;

		@(posedge clock);
		`DELAY
		assert ( (!if_prediction) && (!if_prediction_valid) ) else #1 exit_on_error;
		assert( pht_out[3] == 2'b01 ) else #1 exit_on_error;


		@(negedge clock);
		@(posedge clock);
		`DELAY
		assert ( (!if_prediction) && (!if_prediction_valid) ) else #1 exit_on_error;
		assert( pht_out[3] == 2'b10 ) else #1 exit_on_error;


		@(negedge clock);
		@(posedge clock);
		`DELAY;
		display_pht;
		
		assert ( (!if_prediction) && (!if_prediction_valid) ) else #1 exit_on_error;
		assert( pht_out[3] == 2'b11 ) else #1 exit_on_error;

		@(negedge clock);
		@(posedge clock);
		`DELAY;
		display_pht;
		
		assert ( (!if_prediction) && (!if_prediction_valid) ) else #1 exit_on_error;
		assert( pht_out[3] == 2'b11 ) else #1 exit_on_error;


				

		$display("@@@ Retire test passed\n");

		

		$display("\n Fetch test");

		@(negedge clock);
		reset = 1'b0;
		enable =1'b1;
	
		if_branch = 1'b1;
		if_pc_in = 12;

		rt_branch = 1'b0;
		rt_pc_in = 16;
		rt_branch_taken = 1'b1;

		@(posedge clock);
		`DELAY
		display_pht;
		assert ( (if_prediction) && (if_prediction_valid) ) else #1 exit_on_error;
		assert( pht_out[3] == 2'b11 ) else #1 exit_on_error;
		assert( pht_out[4] == 2'b00 ) else #1 exit_on_error;

		@(negedge clock);
		reset = 1'b0;
		enable =1'b1;
	
		if_branch = 1'b1;
		if_pc_in = 20;


		@(posedge clock);
		`DELAY
		display_pht;
		assert ( (!if_prediction) && (if_prediction_valid) ) else #1 exit_on_error;
		assert( pht_out[5] == 2'b00 ) else #1 exit_on_error;
		assert( pht_out[4] == 2'b00 ) else #1 exit_on_error;



		$display("@@@ Fetch test passed\n");
		
/*
		//Update each row to weakly not-taken
		//
		$display("------------------------Every row to weakly not taken-------------------------------");
		for(i=0;i<`PHT_ROW;i=i+1) begin
			@(negedge clock);
			if_branch = 1'b0;
			rt_branch = 1'b1;
			rt_pc_in = 4*i;
			rt_cond_branch = 1'b1;
			rt_branch_taken = 1'b1;
			@(posedge clock);
			`SD;
			display_pht;
			reset_test;	

		end


		//Update each row to weakly taken
		//
		//

		$display("-------------------------Every row to weakly taken-------------------------------");		


		for(i=0;i<`PHT_ROW;i=i+1) begin
			@(negedge clock);
			rt_pc_in = 4*i;
			rt_cond_branch	= 1'b1;
			rt_branch_taken = 1'b1;
			@(posedge clock);
			`SD;
			display_pht;
			assert(!if_prediction_valid & (pht_out[i]==2'b10)) else #1 exit_on_error;		
			

		end


		$display("--------------------------prediction to be taken---------------------------------");

			@(negedge clock);
			if_branch = 1'b1;
			if_cond_branch = 1'b1;
			if_pc_in = 4;
			rt_branch = 1'b0;
			@(posedge clock);
			`SD
			display_pht;
			assert(if_prediction_valid & if_prediction & (pht_out[1]==2'b10)) else #1 exit_on_error;


		//Update each row to strongly taken

		$display("------------------------Every row to strongly taken--------------------------");

		for(i=0;i<`PHT_ROW;i=i+1) begin
			@(negedge clock);
			if_branch = 1'b0;
			rt_branch = 1'b1;
			rt_cond_branch = 1'b1;
			rt_branch_taken = 1'b1;
			rt_pc_in = 4*i;
			@(posedge clock);
			`SD;
			display_pht;
			assert(!if_prediction_valid & (pht_out[i]==2'b11)) else #1 exit_on_error;		
			

		end*/
		$display("@@@passed");
		$finish;		

		end
	
endmodule


