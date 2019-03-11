`include "sys_defs.vh"
`define DEBUG

`define DELAY #2

module testbench;
	parameter WIDTH = 16;
	parameter REQS = 3;
	logic clock;
	
	//module inputs/outputs
	logic [WIDTH-1:0] req;
	wire en;
	logic [WIDTH-1:0] gnt;
	logic [WIDTH-1:0] gnt_correct;

	wire correct = (gnt == gnt_correct);

	`DUT(ps_multiple) #(WIDTH, NUM_REQS) ps_mult(
		.req(req),
		.en(en),
		.gnt(gnt));

	always #10 clock = ~clock;

	always_ff @(negedge clock) begin
		print_gnt();
		if( !correct ) begin //CORRECT CASE
			exit_on_error( );
		end
	end

	task print_gnt;
		$display("en: %b, req: %b, gnt: %b", en, req, gnt);
	endtask

	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask


	initial begin
		en = 0;
		req = {WIDTH{1'b0}};
		gnt_correct = {WIDTH{1'b0}};

		//check gnt doesn't change when en = 0
		@(negedge clock);
		req[WIDTH-1] = 1'b1;

		//enable
		@(negedge clock);
		gnt_correct[WIDTH-1] = 1'b1;
		en = 1;

		//check all 1's
		@(negedge clock);
		req = {WIDTH{1'b1}};
		gnt_correct = {{NUM_REQS{1'b1}}, {(WIDTH-NUM_REQS){1'b0}}};

		@(negedge clock);
		$display("@@@PASSED");
		$finish;
	end

endmodule

