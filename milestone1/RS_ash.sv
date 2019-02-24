// Things that are modified : only free the RS table_busy bit, include waiting
// siganl, Issue only has 8 tables

module alu_issue_finder(
	// inputs
	input RS_ROW_T [(`RS_SIZE - 1):0] 			rs_table,
	input TAG_UPDATE_T [`RS_SIZE-1:0]			tags_updated,

	// outputs
	output logic [`RS_SIZE-1:0] 				issue_code,
	output logic [1:0]							alu_cnt,
);

	issue_code = {(`RS_SIZE){0}};
	alu_cnt = 3'b0;
	integer i;
	for (i = 0; i < `RS_SIZE; i += 1) begin
		if (tags_updated.T1 & tags_updated.T2) begin
			if ((rs_table[i].inst.FU_NAME == FU_ALU) & (alu_cnt == 0)) begin
				issue_code[i] = 1;
				alu_cnt = 2'd1;
			end else if ((rs_table[i].inst.FU_NAME == FU_ALU) & (alu_cnt == 3'd1)) begin
				issue_code[i] = 1;
				alu_cnt = 2'd2;
			end else if (rs_table[i].inst.FU_NAME == FU_ALU) begin
				issue_code[i] = 1;
				alu_cnt = 2'd3;
				break;
			end else begin
				issue_code[i] = 0;
			end
		end else begin
			issue_code[i] = 0;
		end
	end
endmodule


module mult_issue_finder(
	// inputs
	input RS_ROW_T [(`RS_SIZE - 1):0] 			rs_table,
	input TAG_UPDATE_T [`RS_SIZE-1:0]			tags_updated,

	// outputs
	output logic [`RS_SIZE-1:0] 				issue_code,
	output logic [1:0]							mult_cnt,
);

	issue_code = {(`RS_SIZE){0}};
	mult_cnt = 2'b0;
	integer i;
	for (i = 0; i < `RS_SIZE; i += 1) begin
		if (tags_updated.T1 & tags_updated.T2) begin
			if ((rs_table[i].inst.FU_NAME == FU_MULT) & (mult_cnt == 0)) begin
				issue_code[i] = 1;
				mult_cnt = 2'd1;
			end else if (rs_table[i].inst.FU_NAME == FU_MULT) begin
				issue_code[i] = 1;
				mult_cnt = 2'd2;
				break;
			end else begin
				issue_code[i] = 0;
			end
		end else begin
			issue_code[i] = 0;
		end
	end
endmodule


module ld_issue_finder(
	// inputs
	input RS_ROW_T [(`RS_SIZE - 1):0] 			rs_table,
	input 		 								LSQ_busy,
	input TAG_UPDATE_T [`RS_SIZE-1:0]			tags_updated,

	// outputs
	output logic [`RS_SIZE-1:0] 				issue_code,
	output logic 								ld_cnt,
);

	issue_code = {(`RS_SIZE){0}};
	ld_cnt = 1'b0;
	integer i;
	for (i = 0; i < `RS_SIZE; i += 1) begin
		if (tags_updated.T1 & tags_updated.T2) begin
			if ((rs_table[i].inst.FU_NAME == FU_LD) & (ld_cnt == 0) & ~LSQ_busy) begin
				issue_code[i] = 1;
				ld_cnt = 1'd1;
				break;
			end else begin
				issue_code[i] = 0;
			end
		end else begin
			issue_code[i] = 0;
		end
	end
endmodule


module st_issue_finder(
	// inputs
	input RS_ROW_T [(`RS_SIZE - 1):0] 			rs_table,
	input 		 								LSQ_busy,
	input TAG_UPDATE_T [`RS_SIZE-1:0]			tags_updated,

	// outputs
	output logic [`RS_SIZE-1:0] 				issue_code,
	output logic 								ld_cnt,
);

	issue_code = {(`RS_SIZE){0}};
	ld_cnt = 1'b0;
	integer i;
	for (i = 0; i < `RS_SIZE; i += 1) begin
		if (tags_updated.T1 & tags_updated.T2) begin
			if ((rs_table[i].inst.FU_NAME == FU_LD) & (ld_cnt == 0) & ~LSQ_busy) begin
				issue_code[i] = 1;
				ld_cnt = 1'd1;
				break;
			end else begin
				issue_code[i] = 0;
			end
		end else begin
			issue_code[i] = 0;
		end
	end
endmodule


module br_issue_finder(
	// inputs
	input RS_ROW_T [(`RS_SIZE - 1):0] 			rs_table,
	input TAG_UPDATE_T [`RS_SIZE-1:0]			tags_updated,

	// outputs
	output logic [`RS_SIZE-1:0] 				issue_code,
	output logic 								br_cnt,
);

	issue_code = {(`RS_SIZE){0}};
	br_cnt = 1'b0;
	integer i;
	for (i = 0; i < `RS_SIZE; i += 1) begin
		if (tags_updated.T1 & tags_updated.T2) begin
			if ((rs_table[i].inst.FU_NAME == FU_BR) & (br_cnt == 0)) begin
				issue_code[i] = 1;
				br_cnt = 1'd1;
				break;
			end else begin
				issue_code[i] = 0;
			end
		end else begin
			issue_code[i] = 0;
		end
	end
endmodule


module issue_selector(
		// INPUTS
		input RS_ROW_T [(`RS_SIZE - 1):0] 					rs_table,
		input TAG_UPDATE_T [`RS_SIZE-1:0]					tags_updated,
		input [1:0] 										LSQ_busy,

		// OUTPUTS
		output logic [$clog2(`NUM_FU)-1:0] 					issue_cnt,
		output logic [`RS_SIZE-1:0]	issue_code
	);
	integer i;
	logic [2:0] ALU_cnt; // combinational count of issued alu instructions
	logic [1:0] MULT_cnt; // combinational count of issue mult instructions
	logic 		LD_cnt; // combinational count of issue ld instructions
	logic 		ST_cnt; // combinational count of issue st instructions
	logic 		BR_cnt; // combinational count of issue br instructions

	// check tag1, tag2, only check the LSQ when it is LD/STQ, 
	logic [`RS_SIZE-1:0]	issue_code_alu;
	logic [`RS_SIZE-1:0]	issue_code_mult;
	logic [`RS_SIZE-1:0]	issue_code_ld;
	logic [`RS_SIZE-1:0]	issue_code_st;
	logic [`RS_SIZE-1:0]	issue_code_br;

	// determine which alu instructions get issued and count
	alu_issue_finder aif0(
		.rs_table  (rs_table),
		.tags_updated(tags_updated),
		.issue_code(issue_code_alu),
		.alu_cnt   (ALU_cnt)
	);

	// determine which mult instructions get issued and count
	mult_issue_finder mif0(
		.rs_table  (rs_table),
		.tags_updated(tags_updated),
		.issue_code(issue_code_mult),
		.mult_cnt  (MULT_cnt)
	);

	// determine which ld instructions get issued and count
	ld_issue_finder lif0(
		.rs_table(rs_table),
		.tags_updated(tags_updated),
		.issue_code(issue_code_ld),
		.ld_cnt(LD_cnt)
	);

	// determine which st instructions get issued and count
	st_issue_finder sif0(
		.rs_table(rs_table),
		.tags_updated(tags_updated),
		.issue_code(issue_code_st),
		.ld_cnt(ST_cnt)
	);

	br_issue_finder bif0(
		.rs_table  (rs_table),
		.tags_updated(tags_updated),
		.issue_code(issue_code_br),
		.br_cnt    (BR_cnt)
	);

	// determine which br instructions get issued and count
	always_comb begin
		issue_code = issue_code_alu  | 
					 issue_code_mult | 
					 issue_code_ld   | 
					 issue_code_st   | 
					 issue_code_br;
		issue_cnt = ALU_cnt + MULT_cnt + LD_cnt + ST_cnt + BR_cnt;
	end	
endmodule


module next_state_rs(
	// inputs
	input RS_ROW_T [(`RS_SIZE - 1):0] 			rs_table,
	input [`RS_SIZE-1:0] 						issue_code,
	input TAG_UPDATE_T [`RS_SIZE-1:0]			tags_updated,

	// outputs
	output RS_ROW_T [(`RS_SIZE - 1):0] 			rs_table_next  
);

	integer i, j;
	for (i = 0; i < `RS_SIZE; i += 1) begin
		if (~issue_code[i]) begin
			for (j = 0; j <= i; j += 1) begin
				if (~rs_table_next[j].busy) begin
					rs_table_next[j] = rs_table[i];
					rs_table_next[j].T1[-1] = tags_updated[i].T1;
					rs_table_next[j].T2[-1] = tags_updated[i].T2;
					break;
				end
			end
		end
	end

endmodule


module RS_CAM(
		input 		CAM_en, 
		input PHYS_REG  CDB_tag,
		input PHYS_REG T1 [`RS_SIZE-1:0],
		input PHYS_REG T2 [`RS_SIZE-1:0],
		output 	  [`RS_SIZE-1:0] T1_hit,
		output 	  [`RS_SIZE-1:0] T2_hit,
		
	);
		
	always_comb
	begin
		integer i;
		T1_hit = {`RS_SIZE{0}};
		T2_hit = {`RS_SIZE{0}};	
		if(CAM_en) begin
			for(i=0;i<`RS_SIZE;i=i+1) begin
				T1_hit[i] |= (T1[i] == CDB_tag);
			 	T2_hit[i] |= (T2[i] == CDB_tag);
			end		
		end
	end		

		

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

	input [1:0]								min_rob_fr,
	input [1:0]						LSQ_busy,	// 00 : not busy, 01: LQ busy, 10: SQ busy

	// OUTPUTS
	`ifdef DEBUG 
	output RS_ROW_T  	rs_table_out [(`RS_SIZE - 1):0],
	`endif

	output  RS_ROW_T 	inst_out [`NUM_FU - 1:0], 
	output logic [`NUM_FU - 1:0]		issue,
	output logic [$clog2(`SS_SIZE)-1:0] num_can_dispatch,
	output logic [1:0]					inst_decode
	// num_can_dispatch tells decoder how many instr can be 
	// dispatched in the following cycle
	// rs_busy_cnt tells previous stage how many entries are available
	// therefore, the previous stage will only try to dispatch as 
	// many instructions as rows are available
	);
	
	//current and next state comb variables (Do not need to update the
	//entire rs_table, rs_table is on sequential logic)

	// logic		[`RS_SIZE-1:0][3:0]	rs_waiting_cnt_next;
	// logic  		[`RS_SIZE-1:0] 		rs_busy_idx_next;
	logic [$clog2(`RS_SIZE)-1:0] 		rs_busy_cnt_next;
	RS_ROW_T  	rs_table_next 	[(`RS_SIZE - 1):0];


	//table to store internal state
	logic [$clog2(`RS_SIZE)-1:0]		rs_busy_cnt;	// The number of busy rows
	RS_ROW_T  	rs_table 	[(`RS_SIZE - 1):0];	// RS_Table
	logic [$clog2(`SS_SIZE)-1:0] 	issue_cnt;		// The number of instructions that we will issue
	RS_ROW_T 	issue_next	[`NUM_FU-1:0];		// The instructions that we will issue next

	// wires determined from input
	logic [1:0] inst_in_cnt;

	logic [$clog2(`RS_SIZE)-1:0] 	dispatch_idx;

	// logic for CDB CAM
	
	logic [`RS_SIZE -1:0] MSB_T1 [`SS_SIZE-1:0]; // T1 MSB bits for each CAM modules
	logic [`RS_SIZE -1:0] MSB_T2 [`SS_SIZE-1:0]; // T2 MSB bits for each CAM modules


	//////////////////////////////////////////////////
	//                                              //
	//                Commit-Stage                  //
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
	assign rs_busy_cnt_next = rs_busy_cnt - issue_cnt + inst_in_cnt;

	// Need to modify decode stage by with num_can_dispatch
	assign num_can_dispatch = ((`RS_SIZE - rs_busy_cnt_next) < `SS_SIZE) ? `RS_SIZE - rs_busy_cnt_next : `SS_SIZE; // rs_busy_cnt - issue_cnt;
	assign inst_decode = (num_can_dispatch < min_rob_fr) ? num_can_dispatch : min_rob_fr;	
	// CAM
	// Initiate three RS_CAM modules, parallelly process CDB broadcasting & CAM
	RS_CAM rscam [`SS_SIZE-1:0] ( 
		.CAM_en(CAM_en[`SS_SIZE-1:0]), 
		.CDB_tag(CDB_in[`SS_SIZE-1:0]),
		.T1({3{rs_table.T1}}),
		.T2({3{rs_table.T2}}),
		.T1_hit(MSB_T1[`SS_SIZE-1:0]),
		.T2_hit(MSB_T2[`SS_SIZE-1:0])
	);

	// Merge the MSB resultf from 3 CAMS, and update the next rs table,
	// This will be used for issue stage
	
	TAG_UPDATE_T [`RS_SIZE-1:0]			tags_updated;
	assign tags_updated.T1 = MSB_T1[2] | MSB_T1[1] | MSB_T1[0];
	assign tags_updated.T2 = MSB_T2[2] | MSB_T2[1] | MSB_T2[0];

	always_comb begin

		// ISSUE STAGE // black box
		if (enable) begin
			inst_out_next = {`NUM_FU{{$bits(RS_ROW_T}{0}}};
			rs_table_next = {`RS_SIZE{{$bits(RS_ROW_T}{0}}};


			issue_selector is0(
				.rs_table(rs_table),
				.tags_updated(tags_updated),
				.LSQ_busy  (LSQ_busy),

				.issue_cnt(issue_cnt),
				.issue_code(issue_code)
			);

			next_state_rs nsrs0(
				.rs_table(rs_table),
				.issue_code(issue_code),
				.tags_updated(tags_updated),

				.rs_table_next(rs_table_next)  
			);


		end

		// DISPATCH STAGE
		if (enable & ~dispatch_hazard) begin

			dispatch_idx = rs_busy_cnt - issue_cnt;

			// during dispatch, if RS gets a valid instruction
			// insert instruction to end of rs_table
			// increase rs_busy_cnt to keep track of the end of rs_table array
			// as instructions get issued, we shift occupied registers up
			if (inst_in_cnt == `SS_SIZE) begin
				rs_table_next[dispatch_idx+:`SS_SIZE] = inst_in[2-:`SS_SIZE];
				// rs_busy_cnt_next = rs_busy_cnt + `SS_SIZE;
			end else if (inst_in_cnt == `SS_SIZE - 1) begin
				rs_table_next[dispatch_idx+:(`SS_SIZE - 1)] = inst_in[2-:(`SS_SIZE - 1)];
				// rs_busy_cnt_next = rs_busy_cnt + `SS_SIZE - 1;
			end else if (inst_in_cnt == `SS_SIZE - 2) begin
				rs_table_next[dispatch_idx+:(`SS_SIZE - 2)] = inst_in[2-:(`SS_SIZE - 2)];
				// rs_busy_cnt_next = rs_busy_cnt + `SS_SIZE - 2;
			end
		end else begin
			// even if RS is disabled, output the previous output for RS READ
			rs_table_next = rs_table;
			rs_busy_cnt_next = rs_busy_cnt;
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
			rs_busy_cnt <= {([$clog2(`RS_SIZE)-1:0]){0}};
		end
		rs_table <= rs_table_next;
		rs_busy_cnt <= rs_busy_cnt_next;
	end

	always_ff @(posedge clock)
	begin
		if (enable) begin
			inst_out <= inst_out_next;
			rs_table <= rs_table_next;
			busy_row <= rs_busy_cnt_next;
		end

	end
endmodule // RS
