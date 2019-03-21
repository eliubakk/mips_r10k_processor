// This module is for 1 way scalar processor
// Issue width is NUM_FU
// RS_SIZE : 12
// NUM_FU : 5

`include "../sys_defs.vh"
`define DEBUG

//-----------------------------------------------------------------------------------------
module RS(
	// INPUTS
	input 		    				clock,
	input 		    				reset,
	input 		    				enable, // enable input comes from ROB's "dispatch" output
	input [(`SS_SIZE-1):0] 			CAM_en,
	input PHYS_REG [(`SS_SIZE-1):0]	CDB_in, 
	input							dispatch_valid, // FU from ROB or Free list
	input RS_ROW_T [(`SS_SIZE-1):0]	inst_in,
	input							branch_not_taken, // signal to mention the status of the branch
	
	// OUTPUTS
	`ifdef DEBUG 
	output RS_ROW_T [(`RS_SIZE-1):0]		rs_table_out,		
	`endif
	output RS_ROW_T [(`NUM_FU_TOTAL-1):0]			issue_out, 
	output logic 	[($clog2(`NUM_FU_TOTAL)-1):0]	issue_cnt,
	output wand								rs_full
	);
	
	////////////////////////////
	//	INTERNAL VARIABLES    //
	////////////////////////////

	//STATE VARIABLES 
	RS_ROW_T [(`RS_SIZE-1):0]		rs_table, rs_table_next; 
	logic    [$clog2(`RS_SIZE):0]	rs_busy_cnt, rs_busy_cnt_next;

	//CAM VARIABLES
	logic [(`SS_SIZE-1):0][($clog2(`NUM_PHYS_REG)-1):0] cam_tag_in;
	logic [(`RS_SIZE-1):0][1:0][($clog2(`NUM_PHYS_REG)-1):0] cam_tags_in;
	logic [(`RS_SIZE-1):0][1:0] cam_hits;	

	// DISPATCH LOGIC VARIABLES
	logic [(`RS_SIZE-1):0] dispatch_reqs, dispatch_gnt;
	logic [((`SS_SIZE*`RS_SIZE)-1):0] dispatch_gnt_bus;
	logic [(`SS_SIZE-1):0][$clog2(`RS_SIZE)-1:0] dispatch_idx;
	logic [(`SS_SIZE-1):0] dispatch_idx_valid;

	// ISSUE LOGIC VARIABLEs
	logic [(`NUM_TYPE_FU-1):0][(`RS_SIZE-1):0] issue_reqs, issue_gnts;
	logic [((`NUM_FU_TOTAL*`RS_SIZE)-1):0] issue_gnt_bus;
	logic [(`NUM_FU_TOTAL-1):0][$clog2(`RS_SIZE)-1:0] issue_idx;
	logic [(`NUM_FU_TOTAL-1):0] issue_idx_valid;


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
	for(ig = 0; ig < `NUM_TYPE_FU; ig = ig + 1) begin
		//localparam curr_idx = NUM_OF_FU_TYPE[ig-:(ig+1)].sum() - 1;
		//issue table end index of FU type (non-inclusive) 
		localparam unsigned end_idx = FU_BASE_IDX[ig]+NUM_OF_FU_TYPE[ig];
		// psel for each FU type
		psel_generic #(.WIDTH(`RS_SIZE), .NUM_REQS(NUM_OF_FU_TYPE[ig])) psel(
			.req(issue_reqs[ig]),
			.en(enable),
			.gnt_bus(issue_gnt_bus[((end_idx)*`RS_SIZE-1)-:(`RS_SIZE*NUM_OF_FU_TYPE[ig])]),
			.gnt(issue_gnts[ig])
		);
		for(jg = 0; jg < NUM_OF_FU_TYPE[ig]; jg = jg + 1) begin
			encoder #(.WIDTH(`RS_SIZE)) encode_issue(
				.in(issue_gnt_bus[((end_idx-jg)*`RS_SIZE-1)-:`RS_SIZE]),
				.out(issue_idx[end_idx-jg-1]),
				.valid(issue_idx_valid[end_idx-jg-1])
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
		.gnt_bus(dispatch_gnt_bus),
		.gnt(dispatch_gnt)
	);

	for(ig = 0; ig < `SS_SIZE; ig = ig + 1) begin
		encoder #(.WIDTH(`RS_SIZE)) encode_dispatch(
			.in(dispatch_gnt_bus[((ig+1)*`RS_SIZE-1)-:`RS_SIZE]),
			.out(dispatch_idx[ig]),
			.valid(dispatch_idx_valid[ig])
		);
	end

	//CAM LOGIC
	for(ig = 0; ig < `RS_SIZE; ig = ig + 1) begin
		assign cam_tags_in[ig][0] = rs_table[ig].T1[($clog2(`NUM_PHYS_REG)-1):0];
		assign cam_tags_in[ig][1] = rs_table[ig].T2[($clog2(`NUM_PHYS_REG)-1):0];
	end
	for(ig = 0; ig < `SS_SIZE; ig = ig + 1) begin
		assign cam_tag_in[ig] = CDB_in[ig][($clog2(`NUM_PHYS_REG)-1):0];
	end
	// Instantiate CAM module for CBD
	CAM #(.LENGTH(`RS_SIZE),
		  .WIDTH(2),
		  .NUM_TAG (`SS_SIZE),
		  .TAG_SIZE($clog2(`NUM_PHYS_REG))) rscam ( 
		.enable({`SS_SIZE{enable}} & CAM_en),
		.tag(cam_tag_in),
		.tags_in(cam_tags_in),
		.hits(cam_hits)
	);
	
	assign issue_cnt = | issue_gnts[0] + | issue_gnts[1] + | issue_gnts[2] + | issue_gnts[3] + | issue_gnts[4];
	//assign issue_idx = ALU_issue_gnt | LD_issue_gnt | ST_issue_gnt | MULT_issue_gnt | BR_issue_gnt;
	
	integer i, j, k;
	always_comb begin
		// COMMIT STAGE//	
		rs_table_next = rs_table;
		
		for(i=0;i<=`RS_SIZE;i=i+1) begin
			rs_table_next[i].T1[6] = cam_hits[i][0] | rs_table[i].T1[6];
			rs_table_next[i].T2[6] = cam_hits[i][1] | rs_table[i].T2[6];
		end 
	
		// ISSUE STAGE //
		//Initialization to prevent latch
		for(i=0; i<`NUM_FU_TOTAL; i=i+1) begin // Another way to do this?
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
	
		for(i = 0; i < `NUM_TYPE_FU; i = i + 1) begin
			for(j = 0; j < `RS_SIZE; j = j + 1) begin 
				issue_reqs[i][j] = (rs_table[j].inst.fu_name == FU_NAME_VAL[i] &
									(rs_table[j].T1[6] | cam_hits[j][0]) &
									(rs_table[j].T2[6] | cam_hits[j][1]) & 
									rs_table[j].busy);
			end
		end

		// loop through each FU encoder
		for(i = 0; i < `NUM_FU_TOTAL; i = i + 1) begin
			// loop through each of each type
			//for(j = 0; j < NUM_OF_FU_TYPE[i]; j = j + 1) begin
			if(issue_idx_valid[i]) begin
				issue_out[i] = rs_table[issue_idx[i]];
				issue_out[i].T1[6] = 1'b1;
				issue_out[i].T2[6] = 1'b1;
				rs_table_next[issue_idx[i]].busy = 1'b0;
			end
			//end
		end

		//make into encoder?
		rs_busy_cnt_next = rs_table_next[0].busy + rs_table_next[1].busy + rs_table_next[2].busy + rs_table_next[3].busy +  rs_table_next[4].busy + rs_table_next[5].busy + rs_table_next[6].busy + rs_table_next[7].busy + rs_table_next[8].busy + rs_table_next[9].busy + rs_table_next[10].busy + rs_table_next[11].busy +  rs_table_next[12].busy + rs_table_next[13].busy + rs_table_next[14].busy + rs_table_next[15].busy; 

			
		// DISPATCH STAGE
		for(i = 0; i < `SS_SIZE; i = i + 1) begin
			if(inst_in[i].inst.valid_inst & dispatch_idx_valid[i]) begin
				rs_table_next[dispatch_idx[i]] = inst_in[i];
				rs_table_next[dispatch_idx[i]].busy = 1'b1;
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