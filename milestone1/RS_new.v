// This module is for 1 way scalar processor
// Issue width is NUM_FU
// RS_SIZE : 12
// NUM_FU : 5

`include "sys_defs.vh"
`define DEBUG
module RS_CAM(
		input		enable,
		input 		CAM_en, 
		input PHYS_REG  CDB_tag,
		input RS_ROW_T  rs_table [`RS_SIZE-1:0],
		output 	 logic [`RS_SIZE-1:0] T1_hit,
		output 	 logic [`RS_SIZE-1:0] T2_hit
		
	);
		
	always_comb begin
		T1_hit = {`RS_SIZE{0}};
		T2_hit = {`RS_SIZE{0}};	
		if(CAM_en & enable) begin
			for(integer i=0;i<`RS_SIZE;i=i+1) begin
				T1_hit[i] = (rs_table[i].T1[5:0] == CDB_tag[5:0]);
			 	T2_hit[i] = (rs_table[i].T2[5:0] == CDB_tag[5:0]);
			end		
		end else begin
			T1_hit = {`RS_SIZE{0}};
			T2_hit = {`RS_SIZE{0}};	
		end	
	end		

endmodule
// Arbiter for 16bit
module PS(
			input					enable,
			input		[15 : 0]		index,
	
			output	logic 	[15 : 0]		gnt,
			output 	logic				req_up
		);

	logic [3:0] req_up_bottom;
	logic [3:0] ps_top_result;
	logic		req_up;
	PS4 ps_bottom[3:0]  (
			.enable(ps_top_result),
			.index(index),
			.gnt(gnt),
			.req_up(req_up_bottom)
	);
	PS4 ps_top (
			.enable(enable),
			.index(req_up_bottom),
			.gnt(ps_top_result),
			.req_up(req_up)
	);
			
			
endmodule

module PS4(
			input					enable,
			input		[3:0]			index,
			output	logic	[3:0]			gnt,
			output	logic				req_up
		);

	assign gnt[3] = enable & index[3];
	assign gnt[2] = enable & index[2] & !index[3];
	assign gnt[1] = enable & index[1] & !index[2] & !index[3];
	assign gnt[0] = enable & index[0] & !index[1] & !index[2] & !index[3];
	assign req_up = index[3] | index[2] | index[1] | index[0];

endmodule
//-----------------------------------------------------------------------------------------
module RS(
	// INPUTS
	input 		    					clock,
	input 		    					reset,
	input 		    					enable, // enable input comes from ROB's "dispatch" output
	input  [`SS_SIZE-1:0] 	    		CAM_en,
	input   PHYS_REG			CDB_in, 
	input					dispatch_valid,        // FU from ROB or Free list
	input   RS_ROW_T			inst_in,
	input [1:0]				LSQ_busy,	// 00 : not busy, 01: LQ busy, 10: SQ busy
	input					branch_not_taken, // signal to mention the status of the branch
	// OUTPUTS
	`ifdef DEBUG 
	output RS_ROW_T  			rs_table_out [(`RS_SIZE - 1):0],
	//output logic [`RS_SIZE-1:0]		issue_idx,			
	`endif
	
	//output	RS_ROW_T		issue_out,
	output  RS_ROW_T 			issue_next [(`NUM_FU - 1):0], 
	output logic [$clog2(`NUM_FU) - 1:0]	issue_cnt,
	output	logic				rs_full
	);
	
	//current and next state comb variables (Do not need to update the
	//entire rs_table, rs_table is on sequential logic)
	
	logic [$clog2(`RS_SIZE)-1:0] 		rs_busy_cnt_next;
	RS_ROW_T  				rs_table_next 	[(`RS_SIZE - 1):0];


	//table to store internal state
	logic [$clog2(`RS_SIZE)-1:0]		rs_busy_cnt;	// The number of busy rows
	RS_ROW_T  				rs_table 	[(`RS_SIZE - 1):0];	// RS_Table
	//logic [$clog2(`SS_SIZE)-1:0] 		issue_cnt;		// The number of instructions that we will issue
	RS_ROW_T 				issue_out	[`NUM_FU-1:0];		// The instructions that we will issue next
	logic  					dispatch_cnt;					

	// logic for CDB CAM
	
	logic [(`RS_SIZE -1):0] MSB_T1; // T1 MSB bits for each CAM modules
	logic [(`RS_SIZE -1):0] MSB_T2; // T2 MSB bits for each CAM modules

	// isue_idx for each of functional unit (before and after priority
	// encoder)
	//
	logic	[`RS_SIZE-1:0] 	issue_idx, issue_idx_next; // Issued instruction that we issued on last instruction, for remove busy bit on FU 
	
	logic	[`RS_SIZE-1:0] ALU_issue_idx, ALU_issue_gnt;
	logic	[`RS_SIZE-1:0] LD_issue_idx, LD_issue_gnt;
	logic	[`RS_SIZE-1:0] ST_issue_idx, ST_issue_gnt;
	logic	[`RS_SIZE-1:0] MULT_issue_idx, MULT_issue_gnt;
	logic	[`RS_SIZE-1:0] BR_issue_idx, BR_issue_gnt;
	// For dispatch
	logic	[`RS_SIZE-1:0] dispatch_idx, dispatch_gnt;

	//------------------------------------------------------
	//For testing
	//
	`ifdef DEBUG 
	assign  	rs_table_out = rs_table;
	`endif


	
	// Dispatch signal
	assign rs_busy_cnt_next = rs_busy_cnt - issue_cnt + (dispatch_valid) & (dispatch_cnt) & (inst_in.inst.valid_inst);
	assign rs_full = (rs_busy_cnt > (`RS_SIZE - 1)) ? 1:0;


	// Find which row in RS is used for dispatch	
	PS ps_dispatch(
		.enable(enable),
		.index({{(16-`RS_SIZE){1'b0}},dispatch_idx}),
		.gnt(dispatch_gnt),
		.req_up()
	);

	// Find which row in FU_issue_idx to issue
		PS ps_alu(
			.enable(enable),
			.index({{(16-`RS_SIZE){1'b0}},ALU_issue_idx}),
			.gnt(ALU_issue_gnt),
			.req_up()
		);
		PS ps_ld(
			.enable(enable),
			.index({{(16-`RS_SIZE){1'b0}},LD_issue_idx}),
			.gnt(LD_issue_gnt),
			.req_up()
		);
		PS ps_st(
			.enable(enable),
			.index({{(16-`RS_SIZE){1'b0}},ST_issue_idx}),
			.gnt(ST_issue_gnt),
			.req_up()
		);
		PS ps_mult(
			.enable(enable),
			.index({{(16-`RS_SIZE){1'b0}},MULT_issue_idx}),
			.gnt(MULT_issue_gnt),
			.req_up()
		);
		PS ps_br(
			.enable(enable),
			.index({{(16-`RS_SIZE){1'b0}},BR_issue_idx}),
			.gnt(BR_issue_gnt),
			.req_up()
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
	
	
	
	always_comb begin

		//checks for the branch not taken
	if (branch_not_taken) begin
		for(integer i=0; i<`RS_SIZE; i=i+1) begin 
				rs_table_next[i].inst.opa_select =  ALU_OPA_IS_REGA;
				rs_table_next[i].inst.opb_select =  ALU_OPB_IS_REGB;
				rs_table_next[i].inst.dest_reg =  DEST_IS_REGC;
				rs_table_next[i].inst.alu_func =  ALU_ADDQ;
				rs_table_next[i].inst.fu_name =  FU_ALU;
				rs_table_next[i].inst.rd_mem =  1'b0;
				rs_table_next[i].inst.wr_mem =  1'b0;
				rs_table_next[i].inst.ldl_mem =  1'b0;
				rs_table_next[i].inst.stc_mem =  1'b0;
				rs_table_next[i].inst.cond_branch =  1'b0;
				rs_table_next[i].inst.uncond_branch =  1'b0;
				rs_table_next[i].inst.halt =  1'b0;
				rs_table_next[i].inst.cpuid =  1'b0;
				rs_table_next[i].inst.illegal =  1'b0;
				rs_table_next[i].inst.valid_inst = 1'b0;
				//rs_table[i].T =  `DUMMY_REG;
				//rs_table[i].T1 = `DUMMY_REG;
				//rs_table[i].T2 =  `DUMMY_REG;
				rs_table_next[i].T =  7'b1111111;
				rs_table_next[i].T1 = 7'b1111111;
				rs_table_next[i].T2 =  7'b1111111;
				
				rs_table_next[i].busy <=  1'b0;
				
				end
		for(integer i=0; i<`NUM_FU; i=i+1) begin // Other way to do this?
			
				issue_out[i].inst.opa_select =  ALU_OPA_IS_REGA;
				issue_out[i].inst.opb_select =  ALU_OPB_IS_REGB;
				issue_out[i].inst.dest_reg =  DEST_IS_REGC;
				issue_out[i].inst.alu_func =  ALU_ADDQ;
				issue_out[i].inst.fu_name =  FU_ALU;
				issue_out[i].inst.rd_mem =  1'b0;
				issue_out[i].inst.wr_mem =  1'b0;
				issue_out[i].inst.ldl_mem =  1'b0;
				issue_out[i].inst.stc_mem =  1'b0;
				issue_out[i].inst.cond_branch =  1'b0;
				issue_out[i].inst.uncond_branch =  1'b0;
				issue_out[i].inst.halt =  1'b0;
				issue_out[i].inst.cpuid =  1'b0;
				issue_out[i].inst.illegal =  1'b0;
				issue_out[i].inst.valid_inst = 1'b0;
				issue_out[i].T =  7'b1111111;
				issue_out[i].T1 = 7'b1111111;
				issue_out[i].T2 =  7'b1111111;
				issue_out[i].busy =  1'b0;
				end


		
		issue_idx_next = {($clog2(`RS_SIZE)){0}};

	end
	else begin
			
	
		
		
		// COMMIT STAGE//	
		rs_table_next = rs_table;
		for(integer i=0;i<=`RS_SIZE;i=i+1) begin
			rs_table_next[i].T1[6] = MSB_T1[i] | rs_table[i].T1[6];
			rs_table_next[i].T2[6] = MSB_T2[i] | rs_table[i].T1[6];
		end 
	



		// ISSUE STAGE //
		//Initiaalization to prevent latch
			for(integer i=0; i<`NUM_FU; i=i+1) begin // Anothe way to do this?
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
					
			issue_out[i].T = 7'b1111111;
			issue_out[i].T1 = 7'b1111111;
			issue_out[i].T2 = 7'b1111111;
			issue_out[i].busy = 1'b0;
			end
	
		// Initialize the issue cnt and inx, gnt table	
			issue_cnt = {$clog2(`NUM_FU){0}}; 
			issue_idx_next = {`RS_SIZE{0}};
			
			ALU_issue_idx = 	{`RS_SIZE{0}};
			LD_issue_idx = 		{`RS_SIZE{0}}; 
			ST_issue_idx = 		{`RS_SIZE{0}}; 
			MULT_issue_idx = 	{`RS_SIZE{0}}; 

			BR_issue_idx = 		{`RS_SIZE{0}};
		if (enable) begin
		// Initialize issue_out table
			 
	// First of all, check the instructions, tags -> enable FU_issue_idx bits
	// ISSUE width = FU number
	// For multiple issue,
	// 0. Update the RS busy bit
	// 1 : FU_issue_idx[i] = i when row i is ready to issue (tags ready,
	// no Structural hazard)
	// 2 : FU_issue_gnt[i] by using priority encoder (only one row per
	// each FU can be issued)
	// 3 : write issue_out table, issue_cnt increase, set issue_out_busy
	// (valid issue)
	//
	//
			
			for(integer i=0;i<`RS_SIZE;i=i+1) begin
				if(issue_idx[i]) begin
					rs_table_next[i].busy = 1'b0;
						
				end 
				else begin
					rs_table_next[i].busy = rs_table[i].busy;
				end
			end
	
			for(integer i=0;i<`RS_SIZE;i=i+1) begin
				if(rs_table_next[i].T1 [6] & rs_table_next[i].T2 [6] & rs_table_next[i].busy ) begin
					case(rs_table_next[i].inst.fu_name) 
						FU_ALU : begin
								ALU_issue_idx[i] = 1'b1;
						end

						FU_LD : begin	
							if(LSQ_busy!=2'b01) begin
								LD_issue_idx[i] = 1'b1;
							end
						end

						FU_ST :  begin	
							if(LSQ_busy!=2'b10)  begin
								ST_issue_idx[i] = 1'b1;
							end
						end

						FU_MULT :  begin	
								MULT_issue_idx[i] = 1'b1;
							end
						FU_BR :  begin	
											
								BR_issue_idx[i] = 1'b1;
										
						end
						
				
					endcase

				end 
				
			end
					

		end

		// update the issue_out, rs_table_next_busy, issue_cnt by
		// using FU_index_gnt
		//
		//For ALU
		for(integer i=0; i<`RS_SIZE; i=i+1) begin
			if(ALU_issue_gnt[i] == 1) begin
				issue_out[0] = rs_table_next[i]; // issue_out[0] for ALU
				issue_out[0].busy = 1'b1;
				//rs_table_next[i].busy = 1'b0; //Free the RS table

			end			
		end

		//For LD
		for(integer i=0; i<`RS_SIZE; i=i+1) begin
			if(LD_issue_gnt[i] == 1) begin
				issue_out[1] = rs_table_next[i]; // issue_out[1] for LD
				issue_out[1].busy = 1'b1;
			//	rs_table_next[i].busy = 1'b0; //Free the RS table
			end 
		end

		//For ST
		for(integer i=0; i<`RS_SIZE; i=i+1) begin
			if(ST_issue_gnt[i] == 1) begin
				issue_out[2] = rs_table_next[i]; // issue_out[2] for ST
				issue_out[2].busy = 1'b1;
				//rs_table_next[i].busy = 1'b0; //Free the RS table
			end 
		end

		//For MULT
		for(integer i=0; i<`RS_SIZE; i=i+1) begin
			if(MULT_issue_gnt[i] == 1) begin
				issue_out[3] = rs_table_next[i]; // issue_out[3] for MULT
				issue_out[3].busy = 1'b1;
				//rs_table_next[i].busy = 1'b0; //Free the RS tableSS
			end 
		end

		// For BR
		for(integer i=0; i<`RS_SIZE; i=i+1) begin
			if(BR_issue_gnt[i] == 1) begin
				issue_out[4] = rs_table_next[i]; // issue_out[3] for MULT
				issue_out[4].busy = 1'b1;
			//	rs_table_next[i].busy = 1'b0; //Free the RS table
			end 
		end
	
		issue_cnt = | ALU_issue_gnt + | LD_issue_gnt + | ST_issue_gnt + | MULT_issue_gnt + | BR_issue_gnt;
		issue_idx_next = ALU_issue_gnt | LD_issue_gnt | ST_issue_gnt | MULT_issue_gnt | BR_issue_gnt;
		// DISPATCH STAGE
		//
		// To decide which row to dispatch
		dispatch_idx = {`RS_SIZE{0}};
		dispatch_cnt = 0;
		
		
		for(integer i=0;i<`RS_SIZE;i=i+1) begin
			dispatch_idx[i] = (~rs_table[i].busy) & inst_in.inst.valid_inst & dispatch_valid; // disppatch index is all 0 when the instruction is not valid or no structural hazard

		end
		if (enable & dispatch_valid) begin
			
			integer i;
			for(i = 0;i<`RS_SIZE;i=i+1) begin
				if(dispatch_gnt[i]) begin
					rs_table_next[i] 	= inst_in;
					rs_table_next[i].busy 	= 1'b1;
					dispatch_cnt		= 1;
					break;
				end /*else begin
					rs_table_next[i] 	= rs_table[i];
						
				end*/
					
				
			end	

		end



		


		

	end
	end

	//CHANGE

	//////////////////////////////////////////////////
	//                                              //
	//        Update the flip flops			//
	//                                              //
	//////////////////////////////////////////////////
	always_ff @(posedge clock) begin
		if (reset) begin
		//	rs_table <= {(RS_ROW_T [(`RS_SIZE - 1):0]){0}}; // Other way to do this?
			
				for(integer i=0; i<`RS_SIZE; i=i+1) begin // Other way to do this?
			
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
				//rs_table[i].T <=  `DUMMY_REG;
				//rs_table[i].T1 <= `DUMMY_REG;
				//rs_table[i].T2 <=  `DUMMY_REG;
				rs_table[i].T <=  7'b1111111;
				rs_table[i].T1 <= 7'b1111111;
				rs_table[i].T2 <=  7'b1111111;
				
				rs_table[i].busy <=  1'b0;
				
				end
				for(integer i=0; i<`NUM_FU; i=i+1) begin // Other way to do this?
			
				issue_next[i].inst.opa_select <=  ALU_OPA_IS_REGA;
				issue_next[i].inst.opb_select <=  ALU_OPB_IS_REGB;
				issue_next[i].inst.dest_reg <=  DEST_IS_REGC;
				issue_next[i].inst.alu_func <=  ALU_ADDQ;
				issue_next[i].inst.fu_name <=  FU_ALU;
				issue_next[i].inst.rd_mem <=  1'b0;
				issue_next[i].inst.wr_mem <=  1'b0;
				issue_next[i].inst.ldl_mem <=  1'b0;
				issue_next[i].inst.stc_mem <=  1'b0;
				issue_next[i].inst.cond_branch <=  1'b0;
				issue_next[i].inst.uncond_branch <=  1'b0;
				issue_next[i].inst.halt <=  1'b0;
				issue_next[i].inst.cpuid <=  1'b0;
				issue_next[i].inst.illegal <=  1'b0;
				issue_next[i].inst.valid_inst <= 1'b0;
				issue_next[i].T <=  7'b1111111;
				issue_next[i].T1 <= 7'b1111111;
				issue_next[i].T2 <=  7'b1111111;
				issue_next[i].busy <=  1'b0;
							
	
				end


			rs_busy_cnt <=  {($clog2(`RS_SIZE)){0}};
			issue_idx <= {($clog2(`RS_SIZE)){0}};

		//	rs_busy_cnt <=  0;
		end
		else begin
			rs_table <=  rs_table_next;
			rs_busy_cnt <=  rs_busy_cnt_next;
			issue_next	<= issue_out;
			issue_idx <= issue_idx_next;
		end
	end



endmodule // RS
