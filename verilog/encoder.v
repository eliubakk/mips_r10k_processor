`include "sys_defs.vh"

module encoder(in, out, valid);
	parameter WIDTH = 16; //number of bits in.
	input [WIDTH-1:0] in;
	output wor [$clog2(WIDTH)-1:0] out;
	output valid;

	//make sure one and only one bit is set
	assign valid = ~(in == {WIDTH{1'b0}}) & ((in & (in - 1)) == {WIDTH{1'b0}});

	genvar i, j, k;
	for(i = 0; i < $clog2(WIDTH); i = i + 1) begin
		for(j = 2 ** i; j < WIDTH; j = j + (2 ** (i+1))) begin
			for(k = j; k < (j + (2**i)); k = k + 1) begin
				assign out[i] = in[k];
			end
		end
	end
endmodule