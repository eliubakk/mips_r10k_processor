`define DEBUG_OUT
`define DELAY #2
`define PHT_ROW 8

module testbench;
	logic clock, reset, enable;
	logic 				branch_taken;
	logic	[32:0]			pc_in;
	
	logic	 			prediction;
	`ifdef DEBUG_OUT
	logic 	[`PHT_ROW-1:0][1:0] 	pht_out;
	`endif

	integer i,j,k,l;	

	// for accuracy calculation
	//
	integer total_count_for, hit_count_for;
	integer total_count_random, hit_count_random;




	PHT_TWO_SC pht_tsc(
		// inputs
		.clock(clock), 
		.reset(reset), 
		.enable(enable), 
		.branch_taken(branch_taken),
		.pc_in(pc_in),
		
		// outputs 
		`ifdef DEBUG_OUT
		.pht_out(pht_out),
		`endif	
	
		.prediction(prediction)
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

	task accuracy_check_for;
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





	
	initial begin
		
		$monitor("Clock: %4.0f, reset: %b, enable: %b, branch_taken: %b, pc_in: %h, prediction: %b", clock, reset, enable, branch_taken, pc_in, prediction);	

		// Initial value
		clock = 1'b0;
		reset = 1'b0;
		enable = 1'b0;
		branch_taken = 1'b0;
		pc_in = 32'h0;

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
		display_pht;

		

		//Update each row to weakly not-taken
		//
		$display("------------------------Every row to weakly not taken-------------------------------");
		for(i=0;i<`PHT_ROW;i=i+1) begin
			@(negedge clock);
			branch_taken = 1'b1;
			pc_in = 4*i;
			@(posedge clock);
			`DELAY;
			display_pht;
			assert(!prediction & (pht_out[i]==2'b01)) else #1 exit_on_error;		
			

		end


		//Update each row to weakly taken
		//
		//

		$display("-------------------------Every row to weakly taken-------------------------------");		


		for(i=0;i<`PHT_ROW;i=i+1) begin
			@(negedge clock);
			branch_taken = 1'b1;
			pc_in = 4*i;
			@(posedge clock);
			`DELAY;
			display_pht;
			assert(prediction & (pht_out[i]==2'b10)) else #1 exit_on_error;		
			

		end


		//Update each row to strongly taken

		$display("------------------------Every row to strongly taken--------------------------");

		for(i=0;i<`PHT_ROW;i=i+1) begin
			@(negedge clock);
			branch_taken = 1'b1;
			pc_in = 4*i;
			@(posedge clock);
			`DELAY;
			display_pht;
			assert(prediction & (pht_out[i]==2'b11)) else #1 exit_on_error;		
			

		end
		

		// Random testing and prediction accuracy
		// PC is random, Taken and not taken are random
		

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
				`DELAY;
				display_pht;
				accuracy_check_for;				
			end
				@(negedge clock);
				branch_taken = 1'b0;
				pc_in = pc_in + 4;
				@(posedge clock);
				`DELAY;
				display_pht;
				accuracy_check_for;


		end	

	


		$display("------------------------RANDOM testing and check accuracy----------------");
			for(k=0;k<1000;k=k+1) begin
				@(negedge clock);
				branch_taken = $urandom()%2;
				pc_in	     = $urandom();
				pc_in = pc_in + 4;
				@(posedge clock);
				`DELAY;
				display_pht;
				accuracy_check_random;
			end				
				
		

		$display("-----------------------------------------------------------------");
		$display("For loop accuracy 	: %f percent", 100*hit_count_for/total_count_for);
		$display("Random test accuracy  : %f percent", 100*hit_count_random/total_count_random);

		$display("@@@passed");
		$finish;		

		end
	
endmodule


