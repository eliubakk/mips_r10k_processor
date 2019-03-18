module CAM(enable, tag, in_tags, hits);
	parameter WIDTH=2;
	parameter LENGTH=16;
	parameter TAG_SIZE=6;
	//inputs
	input 				 enable;
	input [TAG_SIZE-1:0] tag;
	input [LENGTH-1:0][WIDTH-1:0][TAG_SIZE-1:0] in_tags;
	//outputs
	output logic [LENGTH-1:0][WIDTH-1:0] hits;
		
	genvar i, j;
	for(i = 0; i < LENGTH; i = i + 1) begin
		for(j = 0; j < WIDTH; j = j + 1) begin
			assign hits[i][j] = enable & (in_tags[i][j] == tag);
		end
	end		

endmodule