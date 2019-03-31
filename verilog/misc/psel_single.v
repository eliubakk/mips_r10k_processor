`include "../../sys_defs.vh"
module psel_single(req, en, gnt);
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
