
module issue_selector(
		// INPUTS
		input RS_ROW_T [(`RS_SIZE - 1):0] 					rs_table,

		// OUTPUTS
		output logic [$clog2(`SS_SIZE)-1:0] 				issue_cnt,
		output logic [`SS_SIZE-1:0] [$clog2(`RS_SIZE)-1:0]	issue_idx
	);
	// TODO, use priority encoders
endmodule


module RS(
	// INPUTS
	input 		    					clock,
	input 		    					reset,
	input 		    					enable, // enable input comes from ROB's "dispatch" output
	input  [`SS_SIZE-1:0] 	    		CAM_en,
	input  [`SS_SIZE-1:0] PHYS_REG		CDB_in, // What heewoo and Morteza added
	input  [`SS_SIZE-1:0] RS_ROW_T		inst_in,

	// OUTPUTS
	`ifdef DEBUG 
	output RS_ROW_T [(`RS_SIZE - 1):0] 	rs_table_out,
	`endif

	output [`NUM_FU - 1:0] RS_ROW_T 	inst_out, 
	output logic [`NUM_FU - 1:0]		issue,
	output logic [$clog2(`RS_SIZE)-1:0]	busy_rows
	);
	
	//next state comb variables
	RS_ROW_T [`NUM_FU-1:0] 			inst_out_next;
	RS_ROW_T [(`RS_SIZE - 1):0]		rs_table_next;
	logic [`NUM_FU-1:0] 			issue_next;
	logic [$clog2(`RS_SIZE)-1:0] 	busy_rows_next;

	//table to store internal state
	RS_ROW_T [(`RS_SIZE - 1):0] 	rs_table;
	logic [$clog2(`RS_SIZE)-1:0]	busy_rows;
	logic [`NUM_FU-1:0] 			issue;
	logic [`SS_SIZE-1:0] [$clog2(`RS_SIZE)-1:0] issue_idx;
	logic [$clog2(`SS_SIZE)-1:0] 			issue_cnt;

	//////////////////////////////////////////////////
	//                                              //
	//                Dispatch-Stage                //
	//                                              //
	//////////////////////////////////////////////////

	logic [1:0] inst_in_cnt;

	always_comb
	begin
		if (enable & (busy_rows < `RS_SIZE))
		begin
			if (inst_in[2])
			inst_in_cnt = inst_in[2].inst.valid_inst + inst_in[1].inst.valid_inst + inst_in[0].inst.valid_inst;
			// during dispatch, if RS gets a valid instruction
			// insert instruction to end of rs_table
			// increase busy_rows to keep track of the end of rs_table array
			// as instructions get issued, we shift occupied registers up
			if (inst_in_cnt == 3) begin 

			if (inst_in[2].inst.valid_inst) begin
				rs_table_next[busy_rows] = inst_in[2];
				busy_rows_next = busy_rows + 1;
			end
			if (inst_in[1].inst.valid_inst) begin
				rs_table_next[busy_rows] = inst_in[1];
				busy_rows_next = busy_rows + 1;				
			end
			if (inst_in[0].inst.valid_inst) begin
				rs_table_next[busy_rows] = inst_in[0];
				busy_rows_next = busy_rows + 1;				
			end
		end
		else
		begin
			// even if RS is disabled, output the previous output for RS READ
			rs_table_next = rs_table;
			busy_rows_next = busy_rows;
		end
	end

	//////////////////////////////////////////////////
	//                                              //
	//         Dispatch Pipeline Registers          //
	//                                              //
	//////////////////////////////////////////////////
	always_ff
	begin
		if (reset)
		begin
			rs_table <= {(RS_ROW_T [(`RS_SIZE - 1):0]){0}};
			busy_rows <= {([$clog2(`RS_SIZE)-1:0]){0}};
		end
		rs_table <= rs_table_next;
		busy_rows <= busy_rows_next;
	end



	// ISSUE STAGE

	// some module that determines row indices getting issued
	issue_selector is0(
		.rs_table(rs_table),
		.issue_idx(issue_idx),
		.issue_cnt(issue_cnt)

	);


	always_comb begin
		if (enable) begin
			inst_out_next = {rs_table[issue_idx[2]], 
							 rs_table[issue_idx[1]], 
							 rs_table[issue_idx[0]]}; 
			case (issue_cnt) begin
				0: begin
					rs_table_next = rs_table;
				end
				1: begin
					if (issue_idx[0] == 0) begin
						rs_table_next = {rs_table[`RS_SIZE:1], {($bits(RS_ROW_T)){0}}};
					end else begin
					end
					rs_table_next = {rs_table[0+:issue_idx[0]+1], rs_table[issue_cnt[0]+1:`RS_SIZE]}
				end
				2: begin
				end
				default:
					// not implemented
			endcase // issue_cnt
		end
	end

	always_ff @(posedge clock)
	begin
		if (enable) begin
			inst_out <= inst_out_next;
		end

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
