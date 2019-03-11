module ps(
	input  [WIDTH-1:0] req,
	input  			   en,
	output wand [WIDTH-1:0] gnt
	);
	parameter WIDTH=16;

	if(en) 
		for(integer i = 0; i < WIDTH - 1; i = i + 1) begin
			assign gnt[(WIDTH-1-i):0] = {req[WIDTH-1-i],{(WIDTH-1-i){~req[WIDTH-1-i]}}};
		end
		assign gnt[0] = req[0];
	else begin
		assign gnt[WIDTH-1:0] = {WIDTH{1'b0}};
	end

endmodule

module ps_multiple(
	input [WIDTH-1:0] req,
	input en,
	output wor [WIDTH-1:0] gnt
);
	parameter WIDTH = 16; //number of grant lines that can be high at once.
	parameter NUM_REQS = 3; //number of req lines arbitrating over

	wire [(WIDTH*NUM_REQS)-1:0] internal_reqs;
	wire [(WIDTH*NUM_REQS)-1:0] internal_gnts;

	for(integer i = NUM_REQS; i > 0; i = i - 1) begin
		if (i == NUM_REQS) begin
			assign internal_reqs[(WIDTH*NUM_REQS)-1 -: WIDTH] = req[WIDTH-1:0];
		end else begin
			//mask previous grant
			assign internal_reqs[(WIDTH*i)-1 -: WIDTH] = internal_reqs[(WIDTH*(i+1))-1 -: WIDTH] &
														~internal_gnts[(WIDTH*(i+1))-1 -: WIDTH];
		end

		ps #(WIDTH) psel(.req(internal_reqs[(WIDTH*i)-1 -: WIDTH]), 
						 .en(en), 
						 .gnt(internal_gnts[(WIDTH*i)-1 -: WIDTH]));

		assign gnt = internal_gnts[(WIDTH*i)-1 -: WIDTH];
	end
endmodule