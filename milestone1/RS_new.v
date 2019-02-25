// This module is for 1 way scalar processor
// Issue width is 1 for simplicity
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

	// OUTPUTS
	`ifdef DEBUG 
	output RS_ROW_T  	rs_table_out [(`RS_SIZE - 1):0],
	`endif
	
	output	RS_ROW_T	issue_next,
	//output  RS_ROW_T 	issue_next [(`NUM_FU - 1):0], 
	//output logic [`NUM_FU - 1:0]		issue_cnt,
	output	logic				rs_full
	);
	
	//current and next state comb variables (Do not need to update the
	//entire rs_table, rs_table is on sequential logic)
	
	logic [$clog2(`RS_SIZE)-1:0] 		rs_busy_cnt_next;
	RS_ROW_T  				rs_table_next 	[(`RS_SIZE - 1):0];


	//table to store internal state
	logic [$clog2(`RS_SIZE)-1:0]		rs_busy_cnt;	// The number of busy rows
	RS_ROW_T  				rs_table 	[(`RS_SIZE - 1):0];	// RS_Table
	logic [$clog2(`SS_SIZE)-1:0] 		issue_cnt;		// The number of instructions that we will issue
	//RS_ROW_T 				issue_next	[`NUM_FU-1:0];		// The instructions that we will issue next
	logic	[(`RS_SIZE)-1:0] 		issue_idx;
	logic  [($clog2(`RS_SIZE))-1:0]		dispatch_cnt;					

	// logic for CDB CAM
	
	logic [(`RS_SIZE -1):0] MSB_T1; // T1 MSB bits for each CAM modules
	logic [(`RS_SIZE -1):0] MSB_T2; // T2 MSB bits for each CAM modules

	// For dispatch
	logic	[`RS_SIZE-1:0] dispatch_idx, dispatch_gnt;

	
	// Dispatch signal
	assign rs_busy_cnt_next = rs_busy_cnt - issue_cnt + (dispatch_valid) & (dispatch_cnt) & (inst_in.inst.valid_inst);
	assign rs_full = (rs_busy_cnt > (`RS_SIZE - 1)) ? 1:0;



	
	PS ps_dispatch(
		.enable(enable),
		.index({{(16-`RS_SIZE){0}},dispatch_idx}),
		.gnt(dispatch_gnt),
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

			
		rs_table_next = rs_table;
		for(integer i=0;i<=`RS_SIZE;i=i+1) begin
			rs_table_next[i].T1[6] = MSB_T1[i] | rs_table[i].T1[6];
			rs_table_next[i].T2[6] = MSB_T2[i] | rs_table[i].T1[6];
		end 
	


		// ISSUE STAGE // 
		if (enable) begin
			issue_next.inst.opa_select = 0;
			issue_next.inst.opa_select = 0;
			issue_next.inst.opb_select = 0;
			issue_next.inst.dest_reg = 0;
			issue_next.inst.alu_func = 0;
			issue_next.inst.fu_name = 0;
			issue_next.inst.rd_mem = 0;
			issue_next.inst.wr_mem = 0;
			issue_next.inst.ldl_mem = 0;
			issue_next.inst.stc_mem = 0;
			issue_next.inst.cond_branch = 0;
			issue_next.inst.uncond_branch = 0;
			issue_next.inst.halt = 0;
			issue_next.inst.cpuid = 0;
			issue_next.inst.illegal = 0;
			issue_next.inst.valid_inst = 0;
					
			issue_next.T = 0;
			issue_next.T1 = 0;
			issue_next.T2 = 0;
			issue_next.busy = 0;
			
			issue_cnt = {$clog2(`NUM_FU){0}}; 
			issue_idx = {`RS_SIZE{0}};
	 	
	// First of all, check the instructions, tags -> enable issue_idx bits
	// Just issue one instructions per one cycle
			for(integer i=0;i<`RS_SIZE;i=i+1) begin
				if(rs_table_next[i].T1 [6] & rs_table_next[i].T2 [6] & rs_table_next[i].busy ) begin
					case(rs_table_next[i].inst.fu_name) 
						FU_ALU : begin
								if(!issue_next.busy) begin	
									issue_next = rs_table[i];
									issue_cnt = issue_cnt + 1;
									issue_idx[i] = 1'b1;
									rs_table_next[i].busy = 0;
									end								
						end

						FU_LD : begin	
							if(LSQ_busy!=2'b01) begin
								if(!issue_next.busy) begin	
									issue_next = rs_table[i]; //LD
									issue_cnt = issue_cnt + 1;
									issue_idx[i] = 1'b1;
									rs_table_next[i].busy = 0;
								end 
							end
						end

						FU_ST :  begin	
							if(LSQ_busy!=2'b10)  begin
								if(!issue_next.busy) begin	
									issue_next = rs_table[i]; //ST
									issue_cnt = issue_cnt + 1;
									issue_idx[i] = 1'b1;
									rs_table_next[i].busy = 0;
								end 	
							end
						end

						FU_MULT :  begin	
								if(!issue_next.busy) begin	
									issue_next = rs_table[i]; //MULT1
									issue_cnt = issue_cnt + 1;
									issue_idx[i] = 1'b1;
									rs_table_next[i].busy = 0;
								end 
						end
						FU_BR :  begin	
								if(!issue_next.busy) begin	
									issue_next = rs_table[i]; //BR
									issue_cnt = issue_cnt + 1;
									issue_idx[i] = 1'b1;
									rs_table_next[i].busy = 0;
								end 			
						end

				
					endcase
				end
				break;
			end
					

		end
		// For multi issue
		// 1. Select the issued logic by using Priority encoder
		// 2. Update the issue table, and disable the busy bit in
		// rs_table_next
		/*PS ps_alu(
			.enable(enable),
			.index(),
			.gnt(),
			.req_up()
		);

		PS ps_ld(
			.enable(enable),
			.index(),
			.gnt(),
			.req_up()
		);


		PS ps_st(
			.enable(enable),
			.index(),
			.gnt(),
			.req_up()
		);


		PS ps_mult(
			.enable(enable),
			.index(),
			.gnt(),
			.req_up()
		);


		PS ps_br(
			.enable(enable),
			.index(),
			.gnt(),
			.req_up()
		);
*/

	/*
  Redeclaration of ANSI ports not allowed for 'dispatch_valid', this will be 
  an error in a future release

			integer j,k;
			for(j=0;j<=`RS_SIZE;j=j+1) begin
				for(k=0;k<=`NUM_FU;k=k+1) begin
					if(rs_table[j].busy & issue_idx[j] & issue_next[k].busy) begin
						rs_table_next[j].busy = 0;
					end
				end	
			end
*/


		// DISPATCH STAGE
		//
		// To decide which row to dispatch
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
				end
				break;
			end	

		end

		
	// Incresae the waiting index of rs_table_next
	
	

	end

	//////////////////////////////////////////////////
	//                                              //
	//        Update the flip flops			//
	//                                              //
	//////////////////////////////////////////////////
	always_ff @(posedge clock) begin
		if (reset) begin
			for(integer i=0; i<`RS_SIZE; i=i+1) begin
			//rs_table <= {(RS_ROW_T [(`RS_SIZE - 1):0]){0}};
			/*rs_table.inst.opa_select <= 0;
			rs_table.inst.opb_select <= 0;
			rs_table.inst.dest_reg <= 0;
			rs_table.inst.alu_func <= 0;
			rs_table.inst.fu_name <= 0;
			rs_table.inst.rd_mem <= 0;
			rs_table.inst.wr_mem <= 0;
			rs_table.inst.ldl_mem <= 0;
			rs_table.inst.stc_mem <= 0;
			rs_table.inst.cond_branch <= 0;
			rs_table.inst.uncond_branch <= 0;
			rs_table.inst.halt <= 0;
			rs_table.inst.cpuid <= 0;
			rs_table.inst.illegal <= 0;
			rs_table.inst.valid_inst <= 0;*/
			rs_table[i].T <= 0;
			rs_table[i].T1 <= 0;
			rs_table[i].T2 <= 0;
			rs_table[i].busy <= 0;
			end


			//rs_busy_cnt <= {([$clog2(`RS_SIZE)-1:0]){0}};
			rs_busy_cnt <= 0;
		end
		rs_table <= rs_table_next;
		rs_busy_cnt <= rs_busy_cnt_next;
	end



endmodule // RS
