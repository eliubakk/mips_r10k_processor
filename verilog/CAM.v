`include "sys_defs.vh"
module CAM(enable, tag, tags_in, hits);
	parameter LENGTH=16;
	parameter WIDTH=2;
	parameter NUM_TAG=3;
	parameter TAG_SIZE=6;
	//inputs
	input [NUM_TAG-1:0] enable;
	input [NUM_TAG-1:0][TAG_SIZE-1:0] tag;
	input [LENGTH-1:0][WIDTH-1:0][TAG_SIZE-1:0] tags_in;
	//outputs
	output wor [LENGTH-1:0][WIDTH-1:0] hits;
		
	genvar i, j, k;
	for(i = 0; i < LENGTH; i = i + 1) begin
		for(j = 0; j < WIDTH; j = j + 1) begin
			for(k = 0; k < NUM_TAG; k = k + 1) begin
				assign hits[i][j] = enable[k] & (tags_in[i][j] == tag[k]);
			end
		end
	end		

endmodule