`define DEBUG_OUT
`define DELAY #2

`define BH_SIZE		4
`define PC_SIZE		4



module testbench;
	logic clock, reset, enable;
	logic							if_branch;
	logic	[31:0]						pc_in;
	logic							obq_bh_pred_valid;
	logic	[`BH_SIZE-1:0]					obq_gh_in;
	logic							clear_en;

	logic							prediction_valid;
	logic	 						prediction;
	logic 	[`BH_SIZE-1:0] 					ght_out;

	`ifdef DEBUG_OUT
	logic	[2**(`BH_SIZE)-1:0]				pht_out;
	`endif

	integer i,j,k,l;	

	// for accuracy calculation
	//
	integer total_count_for, hit_count_for;
	integer total_count_random, hit_count_random;




	GSHARE gshare(
		// inputs
		.clock(clock), 
		.reset(reset), 
		.enable(enable),
		.if_branch(if_branch), 
		.pc_in(pc_in),
		.obq_bh_pred_valid(obq_bh_pred_valid),
		.obq_gh_in(obq_gh_in),
		.clear_en(clear_en),
		
		// outputs 
		`ifdef DEBUG_OUT
		.pht_out(pht_out),
		`endif	
		.ght_out(ght_out),
		.prediction_valid(prediction_valid),
		.prediction_out(prediction)
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
			$display("--------------------------GHT-----------------------------------");
			$display("GHT : %b // Prediction valid : %b, Prediction : %b", ght_out, prediction_valid, prediction);
			$display("----------------------------PHT-----------------------------");
				$display("GHT idx           PHT");
			for(k=0;k<(2**`BH_SIZE);k=k+1) begin
				$display("Idx %b : Prediction %b", k[`BH_SIZE-1:0], pht_out[k]);
			end
			$display("-------------------------------------------\n");
		end
	endtask

	/*task accuracy_check_for;
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
	endtask*/


	
	initial begin
		
		$monitor("Clock: %4.0f, reset: %b, enable: %b, pc_in: %h, obq_bh_pred_valid: %b, obq_gh_in: %h, clear_en: %b, prediction_valid : %b, prediction: %b", clock, reset, enable, pc_in, obq_bh_pred_valid, obq_gh_in, clear_en, prediction_valid, prediction);	

		// Initial value
		clock 			= 1'b0;
		reset 			= 1'b0;
		enable 			= 1'b0;
		if_branch		= 1'b0;
		pc_in 			= 32'h0;
		obq_bh_pred_valid 	= 1'b0;
		obq_gh_in		= `BH_SIZE'b0;
		clear_en		= 1'b0; 


		// Initialize random testing
		total_count_for = 0;
		hit_count_for = 0;
		total_count_random = 0;
		hit_count_random = 0;

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


		$display("------------------------------Functionality check for 4bit----------------------");
		$display("------------------------------Update the PHT and GHT when the branch is taken------------------");
		
		// Update PHT

		@(negedge clock);
		clear_en		= 1'b1;
		obq_bh_pred_valid 	= 1'b1;
		obq_gh_in		= `BH_SIZE'b1010;
		@(posedge clock);
		`DELAY;
		$display("\n GHT is updated to 1010, PHT[1010] is updated to be taken");
		display_table;
		assert( (!prediction_valid) & pht_out[`BH_SIZE'b1010] & (ght_out==`BH_SIZE'b1010) ) else #1 exit_on_error;

		@(negedge clock);
		clear_en		= 1'b1;
		obq_bh_pred_valid 	= 1'b1;
		obq_gh_in		= `BH_SIZE'b0110;
		@(posedge clock);
		`DELAY;
		$display("\n GHT is updated to 0110, PHT[0110] is updated to be taken");
		display_table;
		assert( (!prediction_valid) & pht_out[`BH_SIZE'b0110] & (ght_out==`BH_SIZE'b0110) ) else #1 exit_on_error;

		@(negedge clock);
		clear_en		= 1'b1;
		obq_bh_pred_valid 	= 1'b1;
		obq_gh_in		= `BH_SIZE'b1111;
		@(posedge clock);
		`DELAY;
		$display("\n GHT is updated to 1111, PHT[1111] is updated to be taken");
		display_table;
		assert( (!prediction_valid) & pht_out[`BH_SIZE'b1111] & (ght_out==`BH_SIZE'b1111) ) else #1 exit_on_error;

		@(negedge clock);
		clear_en		= 1'b1;
		obq_bh_pred_valid 	= 1'b1;
		obq_gh_in		= `BH_SIZE'b0001;
		@(posedge clock);
		`DELAY;
		$display("\n GHT is updated to 0001, PHT[0001] is updated to be taken");
		display_table;
		assert( (!prediction_valid) & pht_out[`BH_SIZE'b0001] & (ght_out==`BH_SIZE'b0001) ) else #1 exit_on_error;

		@(negedge clock);
		clear_en		= 1'b1;
		obq_bh_pred_valid 	= 1'b1;
		obq_gh_in		= `BH_SIZE'b0000;
		@(posedge clock);
		`DELAY;
		$display("\n GHT is updated to 0000, PHT[0000] is updated to be taken");
		display_table;
		assert( (!prediction_valid) & pht_out[`BH_SIZE'b0000] & (ght_out==`BH_SIZE'b0000) ) else #1 exit_on_error;


		// Modify already existed PHT
		@(negedge clock);
		clear_en		= 1'b1;
		obq_bh_pred_valid 	= 1'b1;
		obq_gh_in		= `BH_SIZE'b0110;
		@(posedge clock);
		`DELAY;
		$display("\n GHT is updated to 0110, PHT[0110] is updated to be not taken");
		display_table;
		assert( (!prediction_valid) & !pht_out[`BH_SIZE'b0110] & (ght_out==`BH_SIZE'b0110) ) else #1 exit_on_error;


		$display("------------------------------Prediction based on PHT------------------");
		
		// Prediction
		
		@(negedge clock);
		if_branch		= 1'b1;
		pc_in			= 32'h0;
		clear_en		= 1'b0;
		obq_bh_pred_valid 	= 1'b0;
		obq_gh_in		= `BH_SIZE'b0110;
		@(posedge clock);
		`DELAY;
		$display("\n prediction = PHT[0110] = not taken, GHT is updated to 1100, PHT[0110] should remain to be not taken");
		display_table;
		assert( (prediction_valid) & (!prediction) & !pht_out[`BH_SIZE'b0110] & (ght_out==`BH_SIZE'b1100) ) else #1 exit_on_error;

		

		// Prediction with hashing
	
		@(negedge clock);
		if_branch		= 1'b1;
		pc_in			= 32'b1100_00;
		clear_en		= 1'b0;
		obq_bh_pred_valid 	= 1'b0;
		obq_gh_in		= `BH_SIZE'b0110;
		@(posedge clock);
		`DELAY;
		$display("\n prediction = PHT[0000] = taken, GHT is updated to 1001,  PHT[0110] should remain to be not taken");
		display_table;
		assert( (prediction_valid) & (prediction) & !pht_out[`BH_SIZE'b0110] & (ght_out==`BH_SIZE'b1001) ) else #1 exit_on_error;

	

		$display("------------------------------Do not predict when there is roll back------------------");

		// Roll back and do not predict

		@(negedge clock);
		if_branch		= 1'b1;
		pc_in			= 32'b0;
		clear_en		= 1'b1;
		obq_bh_pred_valid 	= 1'b1;
		obq_gh_in		= `BH_SIZE'b1110;
		@(posedge clock);
		`DELAY;
		$display("\n prediction not valid, GHT is updated to 1110,  PHT[1110] should be taken");
		display_table;
		assert( !(prediction_valid) & pht_out[`BH_SIZE'b1110] & (ght_out==`BH_SIZE'b1110) ) else #1 exit_on_error;

		// RESET

		@(negedge clock);
		$display("--------------------------------RESET----------------------------------"); 
		reset = 1'b1;
		pc_in = 32'h0;
	
		
		@(negedge clock);
		reset = 1'b0;
/*
		// For loop check
		$display("-----------------------for loop testing (9T 1N) and check accuracy --------------------");

		for(j=0;j<100;j=j+1) begin
			for(l=0;l<9;l=l+1) begin
				@(negedge clock);
				branch_taken = 1'b1;
				pc_in = pc_in + 4;
				@(posedge clock);
				`DELAY;
				accuracy_check_for;				
			end
				@(negedge clock);
				branch_taken = 1'b0;
				pc_in = pc_in + 4;
				@(posedge clock);
				`DELAY;
				accuracy_check_for;
		end	

		display_table;

		// Random update and check
		$display("---------------------------------RANDOM testing and check accuracy------------------------");
		
		for(i=0;i<100;i=i+1) begin
			@(negedge clock);
			branch_taken = $urandom()%2;
			pc_in	     = $urandom();
			@(posedge clock);
			`DELAY;
			display_table;
			accuracy_check_random;
		end
	
		display_table;
			

		$display("-----------------------------------------------------------------");
		$display("For loop accuracy 	: %f percent for %d test", 100*hit_count_for/total_count_for,total_count_for);
		$display("Random test accuracy  : %f percent for %d test", 100*hit_count_random/total_count_random,total_count_random);

*/
		$display("@@@passed");
		$finish;		
	end
	
endmodule


