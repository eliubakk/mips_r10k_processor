module RS(
	input 		    		clock,
	input 		    		reset,
	input 		    		enable,
	input 		    		CAM_in,
	input  PHYS_REG			CDB_in, // What heewoo and Morteza added
	input  DECODED_INST		inst_in,
	input  FU_IDX			fu_idx,
	input  PHYS_REG 		dest_tag_in,
	input  PHYS_REG 		tag1_in,
	input  PHYS_REG 		tag2_in,

	output OPCODE   		inst_out,
	output PHYS_REG 		dest_tag_out,
	output PHYS_REG 		tag1_out,
	output PHYS_REG 		tag2_out,
	output 					issue,
	output logic [(`NUM_FU - 1):0] 		fu_busy_out
	);
	
	//next state comb variables
	PHYS_REG 	dest_tag_out_next, tag1_out_next, tag2_out_next;
	wire 		issue_next;
	logic [(`NUM_FU - 1):0] fu_busy_out_next;

	//table to store internal state
	RS_ROW_T [(`NUM_FU - 1):0] inst_buffer;

	//stage before dispatch
	//	check for busy signal

	//after dispatch
	//	update busy, opcode, T, T1, T2
	//  
 

	always_ff @(posedge clock) begin
		if(reset) begin
			
			dest_tag_out <= 0;
			tag1_out 	 <= 0;
			tag2_out  	 <= 0;
			issue 		 <= 0;
			fu_busy_out  <= 6'b0;
		else
			opcode_out   <= opcode_out_next;
			dest_tag_out <= dest_tag_out_next;
			tag1_out 	 <= tag1_out_next;
			tag2_out 	 <= tag2_out_next;
			issue 		 <= issue_next;
			fu_busy_out  <= fu_busy_out_next;
		end
	end
endmodule // RS
