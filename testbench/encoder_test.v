`include "sys_defs.vh"
`define DEBUG

`define DELAY #2

module testbench;
	parameter WIDTH = 16;
	logic clock;
	
	//module inputs/outputs
	logic [WIDTH-1:0] in;
	logic [$clog2(WIDTH)-1:0] out, out_correct;
	logic valid, valid_correct;

	logic correct;

	`DUT(encoder) #(WIDTH) encoder0(
		.in(in),
		.out(out),
		.valid(valid));

	always #1 clock = ~clock;

	always_ff @(posedge clock) begin
		set_out_correct();
		print_out();
		if( !correct ) begin //CORRECT CASE
			exit_on_error( );
		end
	end

	task print_out;
		$display("in: %b, out: %b, valid: %b, out_correct: %b, valid_correct:%b", in, out, valid, out_correct, valid_correct);
	endtask

	task exit_on_error;
		begin
			#1;
			print_out();
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	task set_out_correct;
		integer count;
		count = 0;
		out_correct = {WIDTH{1'b0}};
		valid_correct = 0;
		for(integer i = (WIDTH - 1); i >= 0; i = i - 1) begin
			if(in[i]) begin 
				if(count == 0) begin
					out_correct = i;
					valid_correct = 1'b1;
					count = count + 1;
				end else begin
					valid_correct = 1'b0;
				end
			end
		end
		correct = valid_correct? (out == out_correct) & valid : ~valid;
	endtask

	initial begin
		$display("Starting test...");
		//set starting values
		clock = 1'b0;

		//check all 0's
		in = {WIDTH{1'b0}};
		@(negedge clock);

		//check all 1's
		@(negedge clock);
		in = {WIDTH{1'b1}};

		//check alternating 1's
		@(negedge clock);
		for(integer i = WIDTH; i >= 0; i = i - 1) begin
			if(i % 2) begin
				in[i] = 1'b0;
			end else begin
				in[i] = 1'b1;
			end
		end

		//check 2 1's
		@(negedge clock);
		in = {1'b0, 1'b1, 1'b1, {(WIDTH - 3){1'b0}}};

		//check each one-hot value
		for(integer i = 0; i < WIDTH; i = i + 1) begin
			@(negedge clock);
			in = {WIDTH{1'b0}};
			in[i] = 1'b1;
		end

		@(negedge clock);
		$display("@@@PASSED");
		$finish;
	end

endmodule

