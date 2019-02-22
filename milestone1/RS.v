
module issue_selector(
		// INPUTS
		input RS_ROW_T [(`RS_SIZE - 1):0] 					rs_table,
		input [1:0] 										LSQ_busy,

		// OUTPUTS
		output logic [$clog2(`NUM_FU)-1:0] 					issue_cnt,
		output logic [`RS_SIZE-1:0]	issue_code
	);
	// TODO, use priority encoders
endmodule

module RS_CAM(
		input en, 
		input CDB_tag,
		input PHYS_REG T1 [`RS_SIZE:0],
		input PHYS_REG T2 [`RS_SIZE:0],

	);

endmodule

module RS(
	// INPUTS
	input 		    					clock,
	input 		    					reset,
	input 		    					enable, // enable input comes from ROB's "dispatch" output
	input  [`SS_SIZE-1:0] 	    		CAM_en,
	input   PHYS_REG		CDB_in [`SS_SIZE-1:0], // What heewoo and Morteza added
	input   RS_ROW_T		inst_in [`SS_SIZE-1:0],
	// input 								dispatch_hazard, // global dispatch hazard
	// input  [$clog2(`SS_SIZE)-1:0]		safe_dispatch,

	// input 								min_rob_fr,
	input [1:0]							LSQ_busy,	// 00 : not busy, 01: LQ busy, 10: SQ busy

	// OUTPUTS
	`ifdef DEBUG 
	output RS_ROW_T  	rs_table_out [(`RS_SIZE - 1):0],
	`endif

	output  RS_ROW_T 	inst_out [`NUM_FU - 1:0], 
	output logic [`NUM_FU - 1:0]		issue,
	output logic [$clog2(`SS_SIZE)-1:0] num_can_dispatch
	// num_can_dispatch tells decoder how many instr can be 
	// dispatched in the following cycle
	// busy_rows tells previous stage how many entries are available
	// therefore, the previous stage will only try to dispatch as 
	// many instructions as rows are available
	);
	
	//next state comb variables
	RS_ROW_T  			inst_out_next [`NUM_FU-1:0];
	RS_ROW_T 		rs_table_next [(`RS_SIZE - 1):0];
	logic [`NUM_FU-1:0] 			issue_next;
	logic [$clog2(`RS_SIZE)-1:0] 	busy_rows_next;

	//table to store internal state
	RS_ROW_T  	rs_table [(`RS_SIZE - 1):0];
	logic [$clog2(`RS_SIZE)-1:0]	busy_rows;
	logic [`NUM_FU-1:0] 			issue;
	logic [`RS_SIZE-1:0] 			issue_code;
	logic [$clog2(`SS_SIZE)-1:0] 	issue_cnt;

	// wires determined from input
	logic [1:0] inst_in_cnt;

	logic [$clog2(`RS_SIZE)-1:0] 	dispatch_idx;

	//////////////////////////////////////////////////
	//                                              //
	//                Dispatch-Stage                //
	//                                              //
	//////////////////////////////////////////////////

	// inst_in[2], inst_in[1], inst_in[0], inst_in_cnt
	//    0            0		   0           00
	//    1            0		   0           01
	//    1            1		   0           10
	//    1            1		   1           11
	assign inst_in_cnt[0] = inst_in[0].inst.valid_inst | 
						   (inst_in[2].inst.valid_inst ^ inst_in[1].inst.valid_inst);
	assign inst_in_cnt[1] = inst_in[1].inst.valid_inst;
	assign busy_rows_next = busy_rows - issue_cnt + inst_in_cnt;

	// Need to modify decode stage by with num_can_dispatch
	assign num_can_dispatch = ((`RS_SIZE - busy_rows_next) < `SS_SIZE) ? `RS_SIZE - busy_rows_next 
																       : `SS_SIZE; // busy_rows - issue_cnt;	
	always_comb begin

		// COMMIT STAGE
		// CAM broadcasts ready registers
		// if register ready high, then set ready bit to high
		// Things to add : what if the tag bit is empty?
		integer i,j;
		for(i=`SS_SIZE;i=0;i=i-1) begin
			if(cam_en[i]) begin
				for(j=0;j<busy_rows;j=j+1) begin
					// if(rs_table[i].T1 == CDB_in[i]) begin
					// 	rs_table_next.T1 <= rs_table.T1 | (1'b1 << 6); 
					// end
					rs_table_next[i].T1[-1] |= (rs_table[j].T1 == CDB_in[i]);
					rs_table_next[i].T2[-1] |= (rs_table[j].T2 == CDB_in[i]);
					// if(rs_table.T2 == CDB_in[i]) begin
					// 	rs_table_next.T2 = rs_table.T2 | (1'b1 << 6);
					// end
				end		
			end		
		end
		

		// ISSUE STAGE
		if (enable) begin
			inst_out_next = {`NUM_FU{{$bits(RS_ROW_T}{0}}};
			rs_table_next = {`RS_SIZE{{$bits(RS_ROW_T}{0}}};
			for(integer i = `RS_SIZE - 1; i >= 0; i -= 1) begin
				if(issue_code[i]) begin
					inst_out_next = {inst_out_next[`RS_SIZE - 2:0], rs_table[i]};
				end else begin
					rs_table_next = {rs_table_next[`RS_SIZE - 2:0], rs_table[i]};
				end
			end 
		end

		// DISPATCH STAGE
		if (enable & ~dispatch_hazard) begin

			dispatch_idx = busy_rows - issue_cnt;
			// during dispatch, if RS gets a valid instruction
			// insert instruction to end of rs_table
			// increase busy_rows to keep track of the end of rs_table array
			// as instructions get issued, we shift occupied registers up
			if (inst_in_cnt == `SS_SIZE) begin
				rs_table_next[dispatch_idx+:`SS_SIZE] = inst_in[2-:`SS_SIZE];
				// busy_rows_next = busy_rows + `SS_SIZE;
			end else if (inst_in_cnt == `SS_SIZE - 1) begin
				rs_table_next[dispatch_idx+:(`SS_SIZE - 1)] = inst_in[2-:(`SS_SIZE - 1)];
				// busy_rows_next = busy_rows + `SS_SIZE - 1;
			end else if (inst_in_cnt == `SS_SIZE - 2) begin
				rs_table_next[dispatch_idx+:(`SS_SIZE - 2)] = inst_in[2-:(`SS_SIZE - 2)];
				// busy_rows_next = busy_rows + `SS_SIZE - 2;
			end
		end else begin
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
	always_ff @(posedge clock) begin
		if (reset) begin
			rs_table <= {(RS_ROW_T [(`RS_SIZE - 1):0]){0}};
			busy_rows <= {([$clog2(`RS_SIZE)-1:0]){0}};
		end
		rs_table <= rs_table_next;
		busy_rows <= busy_rows_next;
	end



	// ISSUE STAGE

	// some module that determines row indices getting issued
	//
	issue_selector is0(
		.rs_table  (rs_table),
		.LSQ_busy  (LSQ_busy),
		
		.issue_code(issue_code),
		.issue_cnt (issue_cnt)
	);
	

	always_comb begin

	end

	always_ff @(posedge clock)
	begin
		if (enable) begin
			inst_out <= inst_out_next;
			rs_table <= rs_table_next;
			busy_row <= busy_rows_next;
		end

	end

	// EXECUTE STAGE
	always_comb
	begin
		// forward the issued signal and clear the RS entry
	end

	// // COMMIT STAGE
	// always_comb
	// begin

	// end
 
	// RETIRE STAGE
	// RS does nothing

	// always_ff @(posedge clock) begin
	// 	if(reset) begin
			
	// 		dest_tag_out <= 0;
	// 		tag1_out 	 <= 0;
	// 		tag2_out  	 <= 0;
	// 		issue 		 <= 0;
	// 		fu_busy_out  <= 6'b0;
	// 	else
	// 		opcode_out   <= opcode_out_next;
	// 		dest_tag_out <= dest_tag_out_next;
	// 		tag1_out 	 <= tag1_out_next;
	// 		tag2_out 	 <= tag2_out_next;
	// 		issue 		 <= issue_next;
	// 		fu_busy_out  <= fu_busy_out_next;
	// 	end
	// end
endmodule // RS
