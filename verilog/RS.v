module RS(
	input 		    	clock,
	input 		    	reset,
	input 		    	enable,
	input 		    	CAM_in,
	input  PHYS_REG 	dest_tag_in,
	input  PHYS_REG 	tag1_in,
	input  PHYS_REG 	tag2_in,
	input  OPCODE   	opcode_in,
	output OPCODE   	opcode_out,
	output PHYS_REG 	dest_tag_out,
	output PHYS_REG 	tag1_out,
	output PHYS_REG 	tag2_out,
	output [2:0] 		fu_busy_out
	);
	


endmodule // RS
	
	