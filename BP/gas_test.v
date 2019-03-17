`define DEBUG_OUT
`define DELAY #2

`define GHT_BIT		4
`define PHT_PC_BIT	2



module testbench;
	logic clock, reset, enable;
	logic 							branch_taken;
	logic	[32:0]						pc_in;
	
	logic	 						prediction;
	`ifdef DEBUG_OUT
	logic 	[`GHT_BIT-1:0] 					ght_out;
	logic	[2**(`GHT_BIT)-1:0][2**(`PHT_PC_BIT)-1:0]	pht_out;
	`endif

	integer i,j,k,l;	

	// for accuracy calculation
	//
	integer total_count_for, hit_count_for;
	integer total_count_random, hit_count_random;




	GAS gas(
		// inputs
		.clock(clock), 
		.reset(reset), 
		.enable(enable), 
		.branch_taken(branch_taken),
		.pc_in(pc_in),
		
		// outputs 
		`ifdef DEBUG_OUT
		.ght_out(ght_out),
		.pht_out(pht_out),
		`endif	
	
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
			$display("GHT : %b", ght_out);
			$display("----------------------------PHT per PC-----------------------------");
				$display("GHT idx           per-PC PHT");
			for(k=0;k<(2**`GHT_BIT);k=k+1) begin
				$display("Idx %b : Prediction %b", k[`GHT_BIT-1:0], pht_out[k]);
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
		display_table;

		$display("------------------------------Functionality check----------------------");
		// Functionality check - Fix PC and check the update of
		// prediction, GHT, and PHT
		@(negedge clock);
		branch_taken = 1'b1;
		pc_in = 0;
		@(posedge clock);
		`DELAY;
		$display("\n predict not taken, PHT[0000][0] is updated to 1, GHT is updated to 0001");
		display_table;
		assert( (!prediction) & pht_out[0][0] & (ght_out==1) ) else #1 exit_on_error;


		@(negedge clock);
		branch_taken = 1'b1;
		pc_in = 0;
		@(posedge clock);
		`DELAY;
		$display("\n predict not taken, PHT[0001][0] is updated to 1, GHT is updated to 0011");
		display_table;
		assert( (!prediction) & pht_out[1][0] & (ght_out==`GHT_BIT'b11) ) else #1 exit_on_error;

		@(negedge clock);
		branch_taken = 1'b1;
		pc_in = 0;
		@(posedge clock);
		`DELAY;
		$display("\n predict not taken, PHT[0011][0] is updated to 1, GHT is updated to 0111");
		display_table;
		assert( (!prediction) & pht_out[3][0] & (ght_out==`GHT_BIT'b111) ) else #1 exit_on_error;

		@(negedge clock);
		branch_taken = 1'b1;
		pc_in = 0;
		@(posedge clock);
		`DELAY;
		$display("\n predict not taken, PHT[0111][0] is updated to 1, GHT is updated to 1111");
		display_table;
		assert( (!prediction) & pht_out[7][0] & (ght_out==`GHT_BIT'b1111) ) else #1 exit_on_error;

		@(negedge clock);
		branch_taken = 1'b1;
		pc_in = 0;
		@(posedge clock);
		`DELAY;
		$display("\n predict not taken, PHT[1111][0] is updated to 1, GHT is updated to 1111");
		display_table;
		assert( (!prediction) & pht_out[15][0] & (ght_out==`GHT_BIT'b1111) ) else #1 exit_on_error;

		@(negedge clock);
		branch_taken = 1'b0;
		pc_in = 0;
		@(posedge clock);
		`DELAY;
		$display("\n predict taken, PHT[1111][0] is updated to 0, GHT is updated to 1110");
		display_table;
		$display(" %d, %d, %d", prediction, pht_out[15][0], ght_out);

		assert( (prediction) & !pht_out[15][0] & (ght_out==`GHT_BIT'b1110) ) else #1 exit_on_error;


		// Change the pc value




		

		// Pick some value

		
		// For loop check
	/*	$display("-----------------------for loop testing (9T 1N) and check accuracy --------------------");

		for(j=0;j<100;j=j+1) begin
			for(l=0;l<9;l=l+1) begin
				@(negedge clock);
				branch_taken = 1'b1;
				pc_in = pc_in + 4;
				@(posedge clock);
				`DELAY;
				display_table;
				accuracy_check_for;				
			end
				@(negedge clock);
				branch_taken = 1'b0;
				pc_in = pc_in + 4;
				@(posedge clock);
				`DELAY;
				display_table;
				accuracy_check_for;
		end	
*/


		// Random update and check
		/*$display("---------------------------------RANDOM testing and check accuracy------------------------");
		
		for(i=0;i<10;i=i+1) begin
			@(negedge clock);
			branch_taken = $urandom()%2;
			pc_in	     = $urandom();
			@(posedge clock);
			`DELAY;
			display_table;
			accuracy_check_random;
		end*/
	
		// RESET	
		$display("------------------------------RESET----------------------------------");
		@(negedge clock);
		reset = 1'b1;
		pc_in = 0;
		@(negedge clock);
		reset = 1'b0;
		enable = 1'b1;

			

		$display("-----------------------------------------------------------------");
		$display("For loop accuracy 	: %f percent for %d test", 100*hit_count_for/total_count_for,total_count_for);
		$display("Random test accuracy  : %f percent for %d test", 100*hit_count_random/total_count_random,total_count_random);

		$display("@@@passed");
		$finish;		
	end
	
endmodule


