`define DEBUG_OUT

`define DELAY #2

module testbench;
	logic clock, reset, enable;
	logic 		branch_taken;
	
	logic 		prediction;
	logic [1:0] 	state_out;

	


	TWO_BIT_SC tbs(
		// inputs
		.clock(clock), 
		.reset(reset), 
		.enable(enable), 
		.branch_taken(branch_taken),
		
		// outputs 
		`ifdef DEBUG_OUT
		.state_out(state_out),
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

	// Testing begins
	
	initial begin
		
		$monitor("Clock: %4.0f, reset: %b, enable: %b, branch_taken: %b, prediction: %b, state_out: %b ", clock, reset, enable, branch_taken, prediction, state_out);	

		// Initial value
		clock = 1'b0;
		reset = 1'b0;
		enable = 1'b0;
		branch_taken = 1'b0;

		// Reset
		@(negedge clock);
		$display("-----RESET-----"); 
		reset = 1'b1;

		// Start testing
		@(negedge clock);
		$display("-----START TESTING-----"); 
		reset = 1'b0;
		enable = 1'b1;
		branch_taken = 1'b0;
		@(posedge clock);
		`DELAY;
		assert(!prediction & (state_out==2'b00)) else #1 exit_on_error;

		@(negedge clock);
		branch_taken = 1'b1;
		@(posedge clock);
		`DELAY;
		assert(!prediction & (state_out==2'b01)) else #1 exit_on_error;

		@(negedge clock);
		branch_taken = 1'b1;
		@(posedge clock);
		`DELAY;
		assert(prediction & (state_out==2'b10)) else #1 exit_on_error;

		@(negedge clock);
		branch_taken = 1'b1;
		@(posedge clock);
		`DELAY;
		assert(prediction & (state_out==2'b11)) else #1 exit_on_error;

		@(negedge clock);
		branch_taken = 1'b1;
		@(posedge clock);
		`DELAY;
		assert(prediction & (state_out==2'b11)) else #1 exit_on_error;

		@(negedge clock);
		branch_taken = 1'b0;
		@(posedge clock);
		`DELAY;
		assert(prediction & (state_out==2'b10)) else #1 exit_on_error;

		@(negedge clock);
		branch_taken = 1'b0;
		@(posedge clock);
		`DELAY;
		assert(!prediction & (state_out==2'b01)) else #1 exit_on_error;

		@(negedge clock);
		branch_taken = 1'b0;
		@(posedge clock);
		`DELAY;
		assert(!prediction & (state_out==2'b00)) else #1 exit_on_error;

		// Enable test

		@(negedge clock);
		$display("-----Enable test-----"); 
		enable = 1'b0;
		branch_taken = 1'b1;
		@(posedge clock);
		`DELAY;
		assert(!prediction & (state_out==2'b00)) else #1 exit_on_error;


		// Oscillation test

		@(negedge clock);
		$display("-----Oscillation test-----"); 
		enable = 1'b1;
		branch_taken = 1'b1;
		@(posedge clock);
		`DELAY;
		assert(!prediction & (state_out==2'b01)) else #1 exit_on_error;


		for(integer i=0;i<10;i=i+1) begin
			@(negedge clock);
			branch_taken = 1'b1;
			@(posedge clock);
			`DELAY;
			assert(prediction & (state_out==2'b10)) else #1 exit_on_error;

			@(negedge clock);
			branch_taken = 1'b0;
			@(posedge clock);
			`DELAY;
			assert(!prediction & (state_out==2'b01)) else #1 exit_on_error;

		end

		// Test enable


		$display("@@@passed");
		$finish;		

		end
	
endmodule


