`include "../../sys_defs.vh"
`define DEBUG

`define DELAY #2

module testbench;
	parameter WIDTH = 16;
	parameter NUM_REQS = 3;
	logic clock;
	
	//module inputs/outputs
	logic [WIDTH-1:0] req;
	logic en;
	logic [WIDTH-1:0] gnt;
	logic [(WIDTH*NUM_REQS)-1:0] gnt_bus;
	logic [WIDTH-1:0] gnt_correct;
	logic [(WIDTH*NUM_REQS)-1:0] gnt_bus_correct;

	logic correct;

	`DUT(psel_generic) #(WIDTH, NUM_REQS) psel(
		.req(req),
		.en(en),
		.gnt_bus(gnt_bus),
		.gnt(gnt));

	always #1.5 clock = ~clock;

	always_ff @(posedge clock) begin
		set_gnt_correct();
		print_gnt();
		if( !correct ) begin //CORRECT CASE
			exit_on_error( );
		end
	end

	task print_gnt;
		$display("en: %b, req: %b, gnt: %b, gnt_correct: %b", en, req, gnt, gnt_correct);
		for (integer i = NUM_REQS; i > 0; i = i - 1) begin
			$display("gnt_bus[%d]: %b", i, gnt_bus[(i*WIDTH) - 1 -:WIDTH]);
		end
		for (integer i = NUM_REQS; i > 0; i = i - 1) begin
			$display("gnt_bus_correct[%d]: %b", i, gnt_bus_correct[(i*WIDTH) - 1 -:WIDTH]);
		end
	endtask

	task exit_on_error;
		begin
			#1;
			print_gnt();
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	task set_gnt_correct;
		integer count;
		count = 0;
		gnt_correct = {WIDTH{1'b0}};
		gnt_bus_correct = {(WIDTH*NUM_REQS){1'b0}};
		for(integer i = (WIDTH - 1); i >= 0; i = i - 1) begin
			if(en & count < NUM_REQS & req[i] == 1'b1) begin 
				gnt_correct[i] = 1'b1;
				gnt_bus_correct[WIDTH*(NUM_REQS - count) - (WIDTH-i)] = 1'b1;
				count = count + 1;
			end
		end
		correct = (gnt == gnt_correct) & (gnt_bus == gnt_bus_correct);
	endtask

	initial begin
		$display("Starting test...");
		//set starting values
		clock = 1'b0;
		en = 1'b0;
		req = {WIDTH{1'b0}};

		//check gnt doesn't change when en = 0
		@(negedge clock);
		req[WIDTH-1] = 1'b1;

		//enable
		@(negedge clock);
		en = 1'b1;

		//check all 1's
		@(negedge clock);
		req = {WIDTH{1'b1}};

		//check all 0's
		@(negedge clock);
		req = {WIDTH{1'b0}};

		//check 1, some 0's, then 1's
		@(negedge clock);
		//different test depending on WIDTH
		//if WIDTH is too small, no need to test.
		if(WIDTH > 6) begin
			req = {1'b1, {(WIDTH-6){1'b0}}, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1};
		end else if(WIDTH > 2) begin
			req = {1'b1, {(WIDTH-2){1'b0}}, 1'b1};
		end

		//check 0's, then 1's, then 0's
		@(negedge clock);
		//Again, change depending on width
		if(WIDTH > 10) begin
			req = {{(WIDTH-10){1'b0}}, 1'b1, 1'b0, 1'b1, {7{1'b0}}};
		end else if(WIDTH > 4) begin
			req = {{(WIDTH-4){1'b0}}, 1'b1, 1'b0, 1'b1, 1'b0};
		end

		//check 0's, then NUM_REQ 1's
		@(negedge clock);
		req = {{(WIDTH-NUM_REQS){1'b0}}, {NUM_REQS{1'b1}}};

		//check alternating 0's, 1's
		@(negedge clock);
		for(integer i = WIDTH; i >= 0; i = i - 1) begin
			if(i % 2) begin
				req[i] = 1'b0;
			end else begin
				req[i] = 1'b1;
			end
		end

		@(negedge clock);
		$display("@@@PASSED");
		$finish;
	end

endmodule

