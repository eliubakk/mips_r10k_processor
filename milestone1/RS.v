
module issue_selector(
		// INPUTS
		input RS_ROW_T [(`RS_SIZE - 1):0] 					rs_table,

		// OUTPUTS
		output logic [$clog2(`NUM_FU)-1:0] 					issue_cnt,
		output logic [`RS_SIZE-1:0]	issue_code
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
	input 								dispatch_hazard, // global dispatch hazard
	input 								safe_dispatch,

	input 								min_rob_fr,
	input logic [1:0]			LSQ_busy,	// 00 : not busy, 01: LQ busy, 10: SQ busy

	// OUTPUTS
	`ifdef DEBUG 
	output RS_ROW_T [(`RS_SIZE - 1):0] 	rs_table_out,
	`endif

	output [`NUM_FU - 1:0] RS_ROW_T 	inst_out, 
	output logic [`NUM_FU - 1:0]		issue,
	// output logic [$clog2(`RS_SIZE)-1:0]	busy_rows,
	output logic [$clog2(`SS_SIZE)-1:0] num_can_dispatch
	// num_can_dispatch tells decoder how many instr can be 
	// dispatched in the following cycle
	// busy_rows tells previous stage how many entries are available
	// therefore, the previous stage will only try to dispatch as 
	// many instructions as rows are available
	);
	
	//next state comb variables
	RS_ROW_T [`NUM_FU-1:0] 			inst_out_next;
	RS_ROW_T [(`RS_SIZE - 1):0]		rs_table_next;
	logic [`NUM_FU-1:0] 			issue_next;
	logic [$clog2(`RS_SIZE)-1:0] 	busy_rows_next;
	// busy_rows_next is a synchronous register that outputs 
	// how many rows are in use minus num inst issued

	logic [$clog2(`RS_SIZE)-1:0]	busy_rows_new;

	//table to store internal state
	RS_ROW_T [(`RS_SIZE - 1):0] 	rs_table;
	logic [$clog2(`RS_SIZE)-1:0]	busy_rows;
	logic [`NUM_FU-1:0] 			issue;
	logic [`RS_SIZE-1:0] issue_code;
	logic [$clog2(`SS_SIZE)-1:0] 			issue_cnt;

	assign num_can_dispatch = ((`RS_SIZE - busy_rows_next) < `SS_SIZE)? (`RS_SIZE - busy_rows_next): `SS_SIZE;  
	//////////////////////////////////////////////////
	//                                              //
	//                Dispatch-Stage                //
	//                                              //
	//////////////////////////////////////////////////

	logic [1:0] inst_in_cnt;
	//logic min = (num_can_dispatch < safe_dispatch) ? num_can_dispatch : safe_dispatch;
	always_comb begin
		if (enable & ~dispatch_hazard) begin
			rs_table_next = rs_table;
			busy_rows_next = busy_rows;
			// inst_in[2], inst_in[1], inst_in[0], inst_in_cnt
			//    0            0		   0           00
			//    1            0		   0           01
			//    1            1		   0           10
			//    1            1		   1           11
			inst_in_cnt[0] = inst_in[0].inst.valid_inst | 
							(inst_in[2].inst.valid_inst ^ inst_in[1].inst.valid_inst);
			inst_in_cnt[1] = inst_in[1].inst.valid_inst;

			// busy rows - issue count -> num_dispatch 
			num_can_dispatch = busy_rows - issue_cnt;	// Need to modify decode stage by with num_can_dispatch

			// during dispatch, if RS gets a valid instruction
			// insert instruction to end of rs_table
			// increase busy_rows to keep track of the end of rs_table array
			// as instructions get issued, we shift occupied registers up
			if (inst_in_cnt == `SS_SIZE) begin
				rs_table_next[busy_rows+:`SS_SIZE] = inst_in[2-:`SS_SIZE];
				busy_rows_next = busy_rows + `SS_SIZE;
			end else if (inst_in_cnt == `SS_SIZE - 1) begin
				rs_table_next[busy_rows+:(`SS_SIZE - 1)] = inst_in[2-:(`SS_SIZE - 1)];
				busy_rows_next = busy_rows + `SS_SIZE - 1;
			end else if (inst_in_cnt == `SS_SIZE - 2) begin
				rs_table_next[busy_rows+:(`SS_SIZE - 2)] = inst_in[2-:(`SS_SIZE - 2)];
				busy_rows_next = busy_rows + `SS_SIZE - 2;
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
	//
		issue_selector is0(
			.rs_table(rs_table),
			
			.issue_code(issue_code),
			.issue_cnt(issue_cnt)
		);
	

	always_comb begin
		if (enable) begin
			inst_out_next = {`NUM_FU{{$bits(RS_ROW_T}{0}}};
			rs_table_next = {`RS_SIZE{{$bits(RS_ROW_T}{0}}};
			busy_rows_next = busy_rows - issue_cnt;
			for(integer i = `RS_SIZE - 1; i >= 0; i -= 1) begin
				if(issue_code[i]) begin
					inst_out_next = {inst_out_next[`RS_SIZE - 2:0], rs_table[i]};
				end else begin
					rs_table_next = {rs_table_next[`RS_SIZE - 2:0], rs_table[i]};
				end
			end 
		end
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

	// COMMIT STAGE
	always_comb
	begin
		// CAM broadcasts ready registers
		// if register ready high, then set ready bit to high
		// Things to add : what if the tag bit is empty?
		integer i,j;
		for(i=`SS_SIZE;i=0;i=i-1) begin
			if(cam_en[i]) begin
				for(j=0;j<busy_rows;j=j+1) begin
					if(rs_table.T1 == CDB_in[i]) begin
						rs_table.T1 = rs_table.T1 | (1'b1 << 6); 
					end
					if(rs_table.T2 == CDB_in[i]) begin
						rs_Table.T2 = rs_table.T2 | (1'b1 << 6);
					end
				end		
			end		
		end
		
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
