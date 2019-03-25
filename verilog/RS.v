// MODULARIZED SUPER-SCALAR RS

`include "../sys_defs.vh"
`define DEBUG

//-----------------------------------------------------------------------------------------
module RS(
	// INPUTS
	input 		    				clock,
	input 		    				reset,
	input 		    				enable, // enable input comes from ROB's "dispatch" output
	input 		   [(`SS_SIZE-1):0] CAM_en,
	input PHYS_REG [(`SS_SIZE-1):0]	CDB_in, 
	input		   [(`SS_SIZE-1):0]	dispatch_valid, // FU from ROB or Free list
	input 		   [(`NUM_FU_TOTAL-1):0] issue_stall, // Don't issue to functional unit
	input RS_ROW_T [(`SS_SIZE-1):0]	inst_in,
	input							branch_not_taken, // signal to mention the status of the branch
	
	// OUTPUTS
	`ifdef DEBUG 
	output RS_ROW_T [(`RS_SIZE-1):0]		rs_table_out,
	output RS_ROW_T [(`RS_SIZE-1):0]		rs_table_next_out,	
	`endif
	output RS_ROW_T [(`NUM_FU_TOTAL-1):0]	issue_out,
	output logic 	[$clog2(`RS_SIZE):0]	free_rows_next,
	output wand	rs_full
	);
	
	////////////////////////////
	//	INTERNAL VARIABLES    //
	////////////////////////////

	//STATE VARIABLES 
	RS_ROW_T [(`RS_SIZE-1):0]		rs_table, rs_table_next;

	//CAM VARIABLES
	logic [(`SS_SIZE-1):0][($clog2(`NUM_PHYS_REG)-1):0] cam_tag_in;
	logic [(`RS_SIZE-1):0][1:0][($clog2(`NUM_PHYS_REG)-1):0] cam_tags_in;
	logic [(`RS_SIZE-1):0][1:0] cam_hits;	

	// DISPATCH LOGIC VARIABLES
	logic [(`RS_SIZE-1):0] dispatch_reqs, dispatch_gnt;
	logic [((`SS_SIZE*`RS_SIZE)-1):0] dispatch_gnt_bus;
	logic [(`SS_SIZE-1):0][$clog2(`RS_SIZE)-1:0] dispatch_idx;
	logic [(`SS_SIZE-1):0] dispatch_idx_valid;

	// ISSUE LOGIC VARIABLES
	logic [(`NUM_TYPE_FU-1):0][(`RS_SIZE-1):0] issue_reqs, issue_gnts;
	logic [((`NUM_FU_TOTAL*`RS_SIZE)-1):0] issue_gnt_bus;
	logic [(`NUM_FU_TOTAL-1):0][$clog2(`RS_SIZE)-1:0] issue_idx;
	logic [(`NUM_FU_TOTAL-1):0] issue_idx_valid;
	logic [(`NUM_FU_TOTAL-1):0][$clog2(`RS_SIZE)-1:0] issue_idx_shifted;
	logic [(`NUM_FU_TOTAL-1):0] issue_idx_valid_shifted;

	// FREE_ROWS_NEXT LOGIC VARIABLES
	wire [0:(`MAX_RS_SIZE-1)] busy_bits; 


	////////////////////////////
	//	COMBINATIONAL LOGIC   //
	////////////////////////////

	//FOR TESTING
	`ifdef DEBUG 
		assign rs_table_out = rs_table;
		assign rs_table_next_out = rs_table_next;
	`endif

	//CONTROL OUTPUTS
	genvar ig,jg;
	for(ig = 0; ig < `RS_SIZE; ig = ig + 1) begin
		assign rs_full = rs_table[ig].busy;
	end

	// FREE_ROWS_NEXT LOGIC
	for(ig = 0; ig < `MAX_RS_SIZE; ig += 4) begin
		for(jg = ig; jg < ig + 4; jg += 1) begin
			if(jg >= `RS_SIZE) begin
				assign busy_bits[jg] = 1'b0;
			end else begin
				assign busy_bits[jg] = ~rs_table_next[jg].busy;
			end
		end
	end

	//ISSUE LOGIC
	for(ig = 0; ig < `NUM_TYPE_FU; ig = ig + 1) begin
		for(jg = 0; jg < `RS_SIZE; jg = jg + 1) begin 
			assign issue_reqs[ig][jg] = (rs_table[jg].inst.fu_name == FU_NAME_VAL[ig] &
										(rs_table[jg].T1[$clog2(`NUM_PHYS_REG)] | cam_hits[jg][0]) &
										(rs_table[jg].T2[$clog2(`NUM_PHYS_REG)] | cam_hits[jg][1]) & 
										rs_table[jg].busy);
		end
	end

	for(ig = 0; ig < `NUM_TYPE_FU; ig += 1) begin
		localparam unsigned end_idx = FU_BASE_IDX[ig]+NUM_OF_FU_TYPE[ig]-1;
		for(jg = end_idx; (jg >= FU_BASE_IDX[ig]) && (jg <= end_idx); jg -= 1) begin
			if(jg == (end_idx)) begin
				assign issue_idx_shifted[jg] = issue_stall[jg]? 0 : issue_idx[jg];
				assign issue_idx_valid_shifted[jg] = issue_stall[jg]? 0 : issue_idx_valid[jg];
			end else begin
				assign issue_idx_shifted[jg] = issue_stall[jg]? 0 : 
									issue_idx[jg + BIT_COUNT_LUT[issue_stall[end_idx:jg+1]]];
				assign issue_idx_valid_shifted[jg] = issue_stall[jg]? 0 : 
									issue_idx_valid[jg + BIT_COUNT_LUT[issue_stall[end_idx:jg+1]]];
			end
		end
	end

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
			// encode gnt into RS index
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
		.en(enable),
		.gnt_bus(dispatch_gnt_bus),
		.gnt(dispatch_gnt)
	);

	for(ig = 0; ig < `SS_SIZE; ig = ig + 1) begin
		// encode gnt into RS index
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

	//Instantiate CAM module for CBD
	CAM #(.LENGTH(`RS_SIZE),
		  .WIDTH(2),
		  .NUM_TAG (`SS_SIZE),
		  .TAG_SIZE($clog2(`NUM_PHYS_REG))) rscam ( 
		.enable({`SS_SIZE{enable}} & CAM_en),
		.tag(cam_tag_in),
		.tags_in(cam_tags_in),
		.hits(cam_hits)
	);
	
	integer i;
	always_comb begin
		//DEFAULT STATE
		free_rows_next = 0;
		rs_table_next = rs_table;
		for(i = 0; i < `NUM_FU_TOTAL; i = i + 1) begin
			issue_out[i] = EMPTY_ROW;
		end
		
		//COMMIT STAGE
		for(i = 0; i < `RS_SIZE; i = i + 1) begin
			rs_table_next[i].T1[$clog2(`NUM_PHYS_REG)] = cam_hits[i][0] | rs_table[i].T1[$clog2(`NUM_PHYS_REG)];
			rs_table_next[i].T2[$clog2(`NUM_PHYS_REG)] = cam_hits[i][1] | rs_table[i].T2[$clog2(`NUM_PHYS_REG)];
		end 		

		//ISSUE STAGE
		for(i = 0; i < `NUM_FU_TOTAL; i = i + 1) begin
			if(issue_idx_valid_shifted[i]) begin
				issue_out[i] = rs_table[issue_idx_shifted[i]];
				issue_out[i].T1[$clog2(`NUM_PHYS_REG)] = 1'b1;
				issue_out[i].T2[$clog2(`NUM_PHYS_REG)] = 1'b1;
				rs_table_next[issue_idx_shifted[i]].busy = 1'b0;
			end
		end
			
		//DISPATCH STAGE
		for(i = 0; i < `SS_SIZE; i = i + 1) begin
			if(dispatch_valid[i] & inst_in[i].inst.valid_inst & dispatch_idx_valid[i]) begin
				rs_table_next[dispatch_idx[i]] = inst_in[i];
				rs_table_next[dispatch_idx[i]].busy = 1'b1;
			end 
		end

		//DISPATCH CONTROL SIGNAL
		//	number of rows that can be dispatched into next cycle
		//for(i = 0; i < `RS_SIZE; i = i + 1) begin
		//	free_rows_next += ~rs_table_next[i].busy;
		//end
		free_rows_next = BIT_COUNT_LUT[busy_bits[0:3]] + BIT_COUNT_LUT[busy_bits[4:7]] + BIT_COUNT_LUT[busy_bits[8:11]] + BIT_COUNT_LUT[busy_bits[12:15]];

	end

	//////////////////////////////////////////////////
	//                                              //
	//        Update the flip flops			        //
	//                                              //
	//////////////////////////////////////////////////
	always_ff @(posedge clock) begin
		if (reset | branch_not_taken) begin
			for(i=0; i<`RS_SIZE; i=i+1) begin // Other way to do this?
				rs_table[i] <= EMPTY_ROW;
			end
		end
		else begin
			rs_table  <= rs_table_next;
		end
	end

endmodule // RS