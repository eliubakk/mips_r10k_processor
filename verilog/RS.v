module RS(
	input 		    		clock,
	input 		    		reset,
	input 		    		enable, // enable input comes from ROB's "dispatch" output
	input 		    		CAM_in,
	input  DECODED_INST		inst_in,
	input  FU_IDX			fu_idx,
	input  PHYS_REG 		dest_tag_in,
	input  PHYS_REG 		tag1_in,
	input  PHYS_REG 		tag2_in,

	output [`NUM_FU-1:0] OPCODE   		inst_out,
	output [`NUM_FU-1:0] PHYS_REG 		dest_tag_out,
	output [`NUM_FU-1:0] PHYS_REG 		tag1_out,
	output [`NUM_FU-1:0] PHYS_REG 		tag2_out,
	output logic [`NUM_FU-1:0]			issue,
	output logic [(`NUM_FU - 1):0] 		fu_busy_out
	);
	
	//next state comb variables
	PHYS_REG 	dest_tag_out_next, tag1_out_next, tag2_out_next;
	wire 		issue_next;
	logic [(`NUM_FU - 1):0] fu_busy_out_next;

	//table to store internal state
	RS_ROW_T [(`NUM_FU - 1):0] inst_buffer;

	// DISPATCH STAGE
	always_comb
	begin
		if (enable)
		begin
			// this implies input instruction is being dispatched by ROB
			// insert into inst_buffer if space is available
			// assume some module that outputs which RS unit is free
		end
		else
		begin
			// even if RS is disabled, output the previous output for RS READ
		end
	end
	//stage before dispatch
	//	check for busy signal

	//after dispatch
	//	update busy, opcode, T, T1, T2
	//  



	// ISSUE STAGE
	always_comb
	begin
		if (enable)
		begin
		end
		// check for tags in inst_buffer if both tags are available
		// if so, set to instruction output
		// otherwise do nothing
	end

	// EXECUTE STAGE
	always_comb
	begin
		// forward the issued signal and clear the RS entry
	end

	// COMMIT STAGE
	always_comb
	begin
		// CAM broadcasts ready registers
		// if register ready high, then set ready bit to high
	end
 
	// RETIRE STAGE
	// RS does nothing

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
