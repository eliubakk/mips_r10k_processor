`include "../../sys_defs.vh"
module CAM(enable, tags, table_in, hits);
	parameter LENGTH=16; //number of rows in table_in
	parameter WIDTH=2; //number of columns in table_in 
	parameter NUM_TAGS=3; //number of tags we are looking for
	parameter TAG_SIZE=6; //length of each tag/table entry
	//inputs
	input [NUM_TAGS-1:0] enable;
	input [NUM_TAGS-1:0][TAG_SIZE-1:0] tags; //Value we are looking for in table
	input [LENGTH-1:0][WIDTH-1:0][TAG_SIZE-1:0] table_in; //table we are looking through
	//outputs
	output logic [LENGTH-1:0][WIDTH-1:0][NUM_TAGS-1:0] hits;
		
	genvar i, j, k;
	for(i = 0; i < LENGTH; i = i + 1) begin
		for(j = 0; j < WIDTH; j = j + 1) begin
			for(k = 0; k < NUM_TAGS; k = k + 1) begin
				assign hits[i][j][k] = enable[k] & (table_in[i][j] == tags[k]);
			end
		end
	end		

endmodule
