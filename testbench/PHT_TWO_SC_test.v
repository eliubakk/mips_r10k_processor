`define DEBUG

`define PHT_ROW 8
`include "../../sys_defs.vh"

module testbench;
	logic clock, reset, enable;
	logic			if_branch;
	logic 	[31:0]		if_pc_in;
	logic			if_cond_branch;
	logic			if_direct_branch;
	logic			if_return_branch;
	logic			rt_branch;
	logic	[31:0]		rt_pc_in;
	logic			rt_cond_branch;
	logic			rt_direct_branch;
	logic			rt_return_branch;
	logic			rt_branch_taken;	


	logic	 		if_prediction;
	logic			if_prediction_valid;
	`ifdef DEBUG
	logic 	[`PHT_ROW-1:0][1:0] 	pht_out;
	`endif

	integer i,j,k,l;	

	// for accuracy calculation
	//
	//integer total_count_for, hit_count_for;
	//integer total_count_random, hit_count_random;




	PHT_TWO_SC pht_0(
		// inputs
		.clock(clock), 
		.reset(reset), 
		.enable(enable), 
		.if_branch(if_branch),
		.if_pc_in(if_pc_in),
		.if_cond_branch(if_cond_branch),
		.if_direct_branch(if_direct_branch),
		.if_return_branch(if_return_branch),
		.rt_branch(rt_branch),
		.rt_pc_in(rt_pc_in),
		.rt_cond_branch(rt_cond_branch),
		.rt_direct_branch(rt_direct_branch),
		.rt_return_branch(rt_return_branch),
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
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	task display_pht;
		begin
			$display("\n----------Prediction History Table--------");
			for(j=0;j<`PHT_ROW;j=j+1) begin
				$display("Idx %1.0d : Prediction %b", j, pht_out[j][1:0]);	
			end
			$display("-------------------------------------------\n");
		end
	endtask

/*	task accuracy_check_for;
		begin
			total_count_for = total_count_for + 1;
			if(prediction == branch_taken) begin
				hit_count_for	=  hit_count_for + 1 ;	
			end 
		end
	endtask

	task accuracy_check_random;
		begin
			total_count_random = total_count_random + 1;
			if(prediction == branch_taken) begin
				hit_count_random	= hit_count_random + 1;	
			end 
		end
	endtask
*/




	
	initial begin
		
		$monitor("Clock: %4.0f, reset: %b, enable: %b, if_branch: %b, if_pc_in: %d, if_prediction: %b, if_prediction_valid: %b, rt_branch: %b, rt_pc_in: %d, rt_branch_taken: %b",clock, reset, enable, if_branch, if_pc_in, if_prediction, if_prediction_valid, rt_branch, rt_pc_in, rt_branch_taken);	

		// Initial value
		clock = 1'b0;
		reset = 1'b0;
		enable = 1'b0;

		if_branch = 1'b0;	
		if_pc_in = 32'h0;
		if_cond_branch = 1'b0;;
		if_direct_branch = 1'b0;
		if_return_branch = 1'b0;
		rt_branch = 1'b0;
		rt_pc_in = 32'h0;
		rt_cond_branch = 1'b0;;
		rt_direct_branch = 1'b0;
		rt_return_branch = 1'b0;
		rt_branch_taken = 1'b0;	
		
		// Reset
		@(negedge clock);
		$display("--------------------------------RESET----------------------------------"); 
		reset = 1'b1;
		enable = 1'b0;

		@(negedge clock);
		reset = 1'b0;
		enable = 1'b1;
		@(posedge clock);
		`SD;
		display_pht;

		

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
			assert(!if_prediction_valid & (pht_out[i]==2'b01)) else #1 exit_on_error;		
			

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
			

		end
		

		// Random testing and prediction accuracy
		// PC is random, Taken and not taken are random
/*		

		$display("------------------------------RESET----------------------------------");
		@(negedge clock);
		reset = 1'b1;
		pc_in = 0;
		@(negedge clock);
		reset = 1'b0;
		enable = 1'b1;



		$display("-----------------------for loop testing (9T 1N)--------------------");

		for(k=0;k<100;k=k+1) begin
			for(l=0;l<9;l=l+1) begin
				@(negedge clock);
				branch_taken = 1'b1;
				pc_in = pc_in + 4;
				@(posedge clock);
				`SD;
				display_pht;
				accuracy_check_for;				
			end
				@(negedge clock);
				branch_taken = 1'b0;
				pc_in = pc_in + 4;
				@(posedge clock);
				`SD;
				display_pht;
				accuracy_check_for;


		end	

	


		$display("------------------------RANDOM testing and check accuracy----------------");
			for(k=0;k<1000;k=k+1) begin
				@(negedge clock);
				branch_taken = $urandom()%2;
				pc_in	     = $urandom();
				@(posedge clock);
				`SD;
				display_pht;
				accuracy_check_random;
			end				
				
		

		$display("-----------------------------------------------------------------");
		$display("For loop accuracy 	: %f percent", 100*hit_count_for/total_count_for);
		$display("Random test accuracy  : %f percent", 100*hit_count_random/total_count_random);
*/
		$display("@@@passed");
		$finish;		

		end
	
endmodule


