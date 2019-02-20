module RS(
	input 		    					clock,
	input 		    					reset,
	input 		    					enable, // enable input comes from ROB's "dispatch" output
	input 		    					CAM_en,
	input  PHYS_REG						CDB_in, // What heewoo and Morteza added
	input RS_ROW_T 						inst_in,
	`ifdef DEBUG 
	output RS_ROW_T [(`RS_SIZE - 1):0] 	rs_table_out,
	output logic 	[`RS_SIZE - 1: 0] 	busy_reg_out,
	`endif
	output [`NUM_FU - 1:0] RS_ROW_T 	inst_out, 
	output logic [`NUM_FU-1:0]			issue,
	output logic [$clog2(`RS_SIZE)-1:0]	busy_rows
	);
	
	//next state comb variables
	PHYS_REG 	dest_tag_out_next, tag1_out_next, tag2_out_next;
	wire 		issue_next;
	logic [(`NUM_FU - 1):0] fu_busy_out_next;

	//table to store internal state
	RS_ROW_T [(`RS_SIZE - 1):0] 	inst_buffer;
	logic 	[`RS_SIZE - 1: 0] 	busy_reg;
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
