module ps_single(req, en, gnt);
	parameter WIDTH=16;
	input  [WIDTH-1:0] req;
	input  			   en;
	output wand [WIDTH-1:0] gnt;

	genvar i;
	for(i = 0; i < (WIDTH - 1); i = i + 1) begin
		assign gnt[(WIDTH-1-i):0] = en ? {req[WIDTH-1-i],{(WIDTH-1-i){~req[WIDTH-1-i]}}} 
										: {(WIDTH-i){1'b0}};
	end
	assign gnt[0] = en ? req[0] : 1'b0;

endmodule

module ps(req, en, gnt);
	parameter WIDTH = 16; //number of grant lines that can be high at once.
	parameter NUM_REQS = 3; //number of req lines arbitrating over
	input [WIDTH-1:0] req;
	input en;
	output wor [WIDTH-1:0] gnt;

	wire [(WIDTH*NUM_REQS)-1:0] internal_reqs;
	wire [(WIDTH*NUM_REQS)-1:0] internal_gnts;

	genvar i;
	for(i = NUM_REQS; i > 0; i = i - 1) begin
		if (i == NUM_REQS) begin
			assign internal_reqs[(WIDTH*NUM_REQS)-1 -: WIDTH] = req[WIDTH-1:0];
		end else begin
			//mask previous grant
			assign internal_reqs[(WIDTH*i)-1 -: WIDTH] = internal_reqs[(WIDTH*(i+1))-1 -: WIDTH] &
														~internal_gnts[(WIDTH*(i+1))-1 -: WIDTH];
		end

		ps_single #(WIDTH) psel(.req(internal_reqs[(WIDTH*i)-1 -: WIDTH]), 
						 .en(en), 
						 .gnt(internal_gnts[(WIDTH*i)-1 -: WIDTH]));

		assign gnt = internal_gnts[(WIDTH*i)-1 -: WIDTH];
	end
endmodule