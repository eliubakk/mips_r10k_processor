// This module is for 1 way scalar processor
// Issue width is NUM_FU
// RS_SIZE : 12
// NUM_FU : 5

`include "sys_defs.vh"
`define DEBUG
module RS_CAM(
		input				enable,
		input 				CAM_en, 
		input PHYS_REG  		CDB_tag,
		input RS_ROW_T  [`RS_SIZE-1:0] rs_table,
		output 	 logic [`RS_SIZE-1:0] T1_hit,
		output 	 logic [`RS_SIZE-1:0] T2_hit
		
	);
		
	always_comb begin
		T1_hit = {`RS_SIZE{1'b0}};
		T2_hit = {`RS_SIZE{1'b0}};	
		if(CAM_en & enable) begin
			for(integer i=0;i<`RS_SIZE;i=i+1) begin
				T1_hit[i] = (rs_table[i].T1[5:0] == CDB_tag[5:0]);
			 	T2_hit[i] = (rs_table[i].T2[5:0] == CDB_tag[5:0]);
			end		
		end else begin
			T1_hit = {`RS_SIZE{1'b0}};
			T2_hit = {`RS_SIZE{1'b0}};	
		end	
	end		

endmodule

//-----------------------------------------------------------------------------------------
module RS(
	// INPUTS
	input 		    				clock,
	input 		    				reset,
	input 		    				enable, // enable input comes from ROB's "dispatch" output
	input [`SS_SIZE-1:0] 			CAM_en,
	input PHYS_REG					CDB_in, 
	input							dispatch_valid, // FU from ROB or Free list
	input RS_ROW_T [(`SS_SIZE)-1:0]	inst_in,
	input [1:0]						LSQ_busy, // 00 : not busy, 01: LQ busy, 10: SQ busy, 11: Both of them busy
	input							branch_not_taken, // signal to mention the status of the branch
	input 
	input [31:0]  					inst_opcode;
  	input [63:0]  					npc;
	// OUTPUTS
	`ifdef DEBUG 
	output RS_ROW_T [(`RS_SIZE - 1):0]		rs_table_out,		
	`endif
	output RS_ROW_T [`NUM_FU-1:0]			issue_out, 
	output logic 	[$clog2(`NUM_FU) - 1:0]	issue_cnt,
	output wand								rs_full
	);
	
	////////////////////////////
	//	INTERNAL VARIABLES    //
	////////////////////////////

	//STATE VARIABLES 
	RS_ROW_T [(`RS_SIZE - 1):0]		rs_table, rs_table_next; 
	logic    [$clog2(`RS_SIZE):0]	rs_busy_cnt, rs_busy_cnt_next;

	//CDB CAM VARIABLES
	logic [(`RS_SIZE -1):0] MSB_T1, MSB_T2; // MSB bits for each CAM modules	

	// DISPATCH LOGIC VARIABLES
	logic [`RS_SIZE-1:0] dispatch_reqs, dispatch_gnt;

	// ISSUE LOGIC VARIABLEs
	logic [`NUM_FU-1:0][`RS_SIZE-1:0] issue_reqs, issue_gnts;


	////////////////////////////
	//	COMBINATIONAL LOGIC   //
	////////////////////////////

	//FOR TESTING
	`ifdef DEBUG 
		assign rs_table_out = rs_table;
	`endif

	//CONTROL OUTPUTS
	genvar ig,jg;
	for(ig = 0; ig < `RS_SIZE; ig = ig + 1) begin
		assign rs_full = rs_table[ig].busy;
	end

	//ISSUE LOGIC
	for(ig = 0; ig < `NUM_FU; ig = ig + 1) begin
		// psel for each FU type
		if(FU_NAME_VAL[ig] == FU_LD) begin 
			psel_generic #(`RS_SIZE, NUM_FU_TYPE[ig]) psel(
				.req(issue_reqs[ig]),
				.en(enable & ~LSQ_busy[0]),
				.gnt(issue_gnts[ig])
			);
		end else if(FU_NAME_VAL[ig] == FU_ST) begin
			psel_generic #(`RS_SIZE, NUM_FU_TYPE[ig]) psel(
				.req(issue_reqs[ig]),
				.en(enable & ~LSQ_busy[1]),
				.gnt(issue_gnts[ig])
			);
		end else begin
			psel_generic #(`RS_SIZE, NUM_FU_TYPE[ig]) psel(
				.req(issue_reqs[ig]),
				.en(enable),
				.gnt(issue_gnts[ig])
			);
		end
	end

	//DISPATCH LOGIC
	for(ig = 0; ig < `RS_SIZE; ig = ig + 1) begin
		assign dispatch_reqs[ig] = ~rs_table[ig].busy;
	end

	// psel for where dispatched instructions will go into table	
	psel_generic #(`RS_SIZE, `SS_SIZE) psel_dispatch(
		.req(dispatch_reqs),
		.en(enable & dispatch_valid),
		.gnt(dispatch_gnt)
	);

	// CAM
	// Initiate one RS_CAM modules, parallelly process CDB broadcasting & CAM
	RS_CAM rscam ( 
		.enable(enable),
		.CAM_en(CAM_en), 
		.CDB_tag(CDB_in),
		.rs_table(rs_table[`RS_SIZE-1:0]),
		.T1_hit(MSB_T1),
		.T2_hit(MSB_T2)
	);

	// Merge the MSB resultf from 3 CAMS, and update the next rs table,
	// This will be used for issue stage
	
	assign issue_cnt = | issue_gnts[0] + | issue_gnts[1] + | issue_gnts[2] + | issue_gnts[3] + | issue_gnts[4];
	//assign issue_idx = ALU_issue_gnt | LD_issue_gnt | ST_issue_gnt | MULT_issue_gnt | BR_issue_gnt;
	
	integer i, j, k;
	always_comb begin
		// COMMIT STAGE//	
		rs_table_next = rs_table;
		
		for(i=0;i<=`RS_SIZE;i=i+1) begin
			rs_table_next[i].T1[6] = MSB_T1[i] | rs_table[i].T1[6];
			rs_table_next[i].T2[6] = MSB_T2[i] | rs_table[i].T2[6];
		end 
	
		// ISSUE STAGE //
		//Initialization to prevent latch
		for(i=0; i<`NUM_FU; i=i+1) begin // Another way to do this?
			issue_out[i].inst.opa_select = ALU_OPA_IS_REGA;
			issue_out[i].inst.opb_select = ALU_OPB_IS_REGB;
			issue_out[i].inst.dest_reg = DEST_IS_REGC;
			issue_out[i].inst.alu_func = ALU_ADDQ;
			issue_out[i].inst.fu_name = FU_ALU;
			issue_out[i].inst.rd_mem = 1'b0;
			issue_out[i].inst.wr_mem = 1'b0;
			issue_out[i].inst.ldl_mem = 1'b0;
			issue_out[i].inst.stc_mem = 1'b0;
			issue_out[i].inst.cond_branch = 1'b0;
			issue_out[i].inst.uncond_branch = 1'b0;
			issue_out[i].inst.halt = 1'b0;
			issue_out[i].inst.cpuid = 1'b0;
			issue_out[i].inst.illegal = 1'b0;
			issue_out[i].inst.valid_inst = 1'b0;
			issue_out[i].T = `DUMMY_REG;
			issue_out[i].T1 = `DUMMY_REG;
			issue_out[i].T2 = `DUMMY_REG;
			issue_out[i].busy = 1'b0;
			issue_out[i].inst_opcode = `NOOP_INST;
			issue_out[i].npc = 0;
			
		end
	
		for(i = 0; i < `NUM_FU; i = i + 1) begin
			for(j = 0; j < `RS_SIZE; j = j + 1) begin 
				issue_reqs[i][j] = (rs_table_next[j].inst.fu_name == FU_NAME_VAL[i] &
										 rs_table_next[j].T1[6] & rs_table_next[j].T2[6] 
										 & rs_table_next[j].busy);
			end
		end

		// loop through each FU_TYPE psel 
		for(i = 0; i < `NUM_FU; i = i + 1) begin
			// loop through RS table
			for(j = 0; j < `RS_SIZE; j = j+1) begin
				if(issue_gnts[i][j]) begin
					// if statment for all FU of each type
					for(k = 0; k < NUM_FU_TYPE[i]; k = k + 1) begin
						if(~issue_out[FU_IDX_VAL[i] + k].busy & rs_table_next[j].busy) begin
							issue_out[FU_IDX_VAL[i] + k] = rs_table_next[j];
							issue_out[FU_IDX_VAL[i] + k].busy = 1'b1;
							rs_table_next[j].busy = 1'b0; //Free the RS table
						end
					end
				end
			end
		end

		//make into encoder?
		rs_busy_cnt_next = rs_table_next[0].busy + rs_table_next[1].busy + rs_table_next[2].busy + rs_table_next[3].busy +  rs_table_next[4].busy + rs_table_next[5].busy + rs_table_next[6].busy + rs_table_next[7].busy + rs_table_next[8].busy + rs_table_next[9].busy + rs_table_next[10].busy + rs_table_next[11].busy +  rs_table_next[12].busy + rs_table_next[13].busy + rs_table_next[14].busy + rs_table_next[15].busy; 

			
		// DISPATCH STAGE
		for(i = 0; i < `SS_SIZE; i = i + 1) begin
			if(inst_in[i].inst.valid_inst) begin
				for(j = 0; j < `RS_SIZE; j = j + 1) begin
					if(dispatch_gnt[j] & ~rs_table_next[j].busy) begin
						rs_table_next[j] = inst_in[i];
						rs_table_next[j].busy = 1'b1;
					end 
				end	
			end
		end

	end

	//////////////////////////////////////////////////
	//                                              //
	//        Update the flip flops			        //
	//                                              //
	//////////////////////////////////////////////////
	always_ff @(posedge clock) begin
		if (reset | branch_not_taken) begin
			for(i=0; i<`RS_SIZE; i=i+1) begin // Other way to do this?			
				rs_table[i].inst.opa_select <=  ALU_OPA_IS_REGA;
				rs_table[i].inst.opb_select <=  ALU_OPB_IS_REGB;
				rs_table[i].inst.dest_reg <=  DEST_IS_REGC;
				rs_table[i].inst.alu_func <=  ALU_ADDQ;
				rs_table[i].inst.fu_name <=  FU_ALU;
				rs_table[i].inst.rd_mem <=  1'b0;
				rs_table[i].inst.wr_mem <=  1'b0;
				rs_table[i].inst.ldl_mem <=  1'b0;
				rs_table[i].inst.stc_mem <=  1'b0;
				rs_table[i].inst.cond_branch <=  1'b0;
				rs_table[i].inst.uncond_branch <=  1'b0;
				rs_table[i].inst.halt <=  1'b0;
				rs_table[i].inst.cpuid <=  1'b0;
				rs_table[i].inst.illegal <=  1'b0;
				rs_table[i].inst.valid_inst <= 1'b0;
				rs_table[i].T <=  `DUMMY_REG;
				rs_table[i].T1 <= `DUMMY_REG;
				rs_table[i].T2 <=  `DUMMY_REG;
				rs_table[i].busy <=  1'b0;
				rs_table[i].inst_opcode <= `NOOP_INST;
				rs_table[i].npc <= 0;
			end
			rs_busy_cnt <=  {($clog2(`RS_SIZE)){1'b0}};
		end
		else begin
			rs_table <=  rs_table_next;
			rs_busy_cnt <=  rs_busy_cnt_next;
		end
	end

endmodule // RS