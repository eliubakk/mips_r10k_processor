module RS_CAM(
		input		enable,
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
		if(CAM_en & enable) begin
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
	input   PHYS_REG		CDB_in [`SS_SIZE-1:0], 
	input				dispatch_valid,        // dispatch is not valid when the instruction is not valid, or there is structural hazard
	input   RS_ROW_T		inst_in [`SS_SIZE-1:0],
	//input 								dispatch_hazard, // global dispatch hazard
	// input  [$clog2(`SS_SIZE)-1:0]		safe_dispatch,

	//input [1:0]						min_rob_fr,
	input [1:0]						LSQ_busy,	// 00 : not busy, 01: LQ busy, 10: SQ busy

	// OUTPUTS
	`ifdef DEBUG 
	output RS_ROW_T  	rs_table_out [(`RS_SIZE - 1):0],
	`endif

	output  RS_ROW_T 	issue_next [(`NUM_FU - 1):0], 
	output logic [`NUM_FU - 1:0]		issue_cnt,
	output	logic				rs_full
	//output logic [$clog2(`SS_SIZE)-1:0] num_can_dispatch,
	//output logic [1:0]	inst_decode
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
	RS_ROW_T  				rs_table_next 	[(`RS_SIZE - 1):0];


	//table to store internal state
	// logic		[`RS_SIZE-1:0][3:0]	rs_waiting_cnt;  //Waitng numbers for each row
	// logic  		[`RS_SIZE-1:0] 		rs_busy_idx;	// Busy index
	logic [$clog2(`RS_SIZE)-1:0]		rs_busy_cnt;	// The number of busy rows
	RS_ROW_T  				rs_table 	[(`RS_SIZE - 1):0];	// RS_Table
	logic [$clog2(`SS_SIZE)-1:0] 		issue_cnt;		// The number of instructions that we will issue
	RS_ROW_T 				issue_next	[`NUM_FU-1:0];		// The instructions that we will issue next
	logic	[`RS_SIZE-1:0] 			issue_idx;
	logic  [$clog2('RS_SIZE)-1:0]		dispatch_cnt;

	// wires determined from input
/*	logic [1:0] inst_in_cnt;

	logic [$clog2(`RS_SIZE)-1:0] 	dispatch_idx;*/

	// logic for CDB CAM
	
	logic [`RS_SIZE -1:0] MSB_T1 [`SS_SIZE-1:0]; // T1 MSB bits for each CAM modules
	logic [`RS_SIZE -1:0] MSB_T2 [`SS_SIZE-1:0]; // T2 MSB bits for each CAM modules

	// counter for issue logic
/*	logic [$clog2(`NUM_FU) -1 :0] cnt_inst_out;
	logic [$clog2(`NUM_FU) -1 :0] cnt_rs_next;*/


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
/*	assign inst_in_cnt[0] = inst_in[0].inst.valid_inst | 
						   (inst_in[2].inst.valid_inst ^ inst_in[1].inst.valid_inst);
	assign inst_in_cnt[1] = inst_in[1].inst.valid_inst;*/
	assign dispatch_cnt = (inst_in[2].inst.valid_inst + inst_in[1].inst.valid_inst + inst_in[0].inst.valid_inst)
	assign rs_busy_cnt_next = rs_busy_cnt - issue_cnt + 3*(dispatch_valid)*(dispatch_cnt);
	assign rs_full = (rs_busy_cnt > (`RS_SIZE - 3)) ? 1:0;
	// Need to modify decode stage by with num_can_dispatch
	//assign num_can_dispatch = ((`RS_SIZE - rs_busy_cnt_next) < `SS_SIZE) ? `RS_SIZE - rs_busy_cnt_next : `SS_SIZE; // rs_busy_cnt - issue_cnt;
	//assign inst_decode = (num_can_dispatch < min_rob_fr) ? num_can_dispatch : min_rob_fr;	
	// CAM
	// Initiate three RS_CAM modules, parallelly process CDB broadcasting & CAM
	RS_CAM rscam [`SS_SIZE-1:0] ( 
		.enable(enable),
		.CAM_en(CAM_en[`SS_SIZE-1:0]), 
		.CDB_tag(CDB_in[`SS_SIZE-1:0]),
		.T1({3{rs_table.T1}}),
		.T2({3{rs_table.T2}}),
		.T1_hit(MSB_T1[`SS_SIZE-1:0]),
		.T2_hit(MSB_T2[`SS_SIZE-1:0])
	);

	// Merge the MSB resultf from 3 CAMS, and update the next rs table,
	// This will be used for issue stage
	
	assign rs_table_next.T1 [-1] = MSB_T1[2] | MSB_T1[1] | MSB_T1[0];
	assign rs_table_next.T2 [-1] = MSB_T2[2] | MSB_T2[1] | MSB_T2[0]; 

	

	always_comb begin

				
		rs_table_next = rs_table;
		// ISSUE STAGE // 
		if (enable) begin
			issue_next = {(RS_ROW_T [(`NUM_FU - 1):0]){0}};
			issue_cnt = {$clog2(`NUM_FU){0}}; 
			issue_idx = {`RS_SIZE{0}};
	 		/*cnt_inst_out = {($clog2(`NUM_FU)-1){0}};	
			cnt_rs_next = {($clog2(`NUM_FU)-1){0}};*/ 
			integer i;

	// First of all, check the instructions, tags -> enable issue_idx bits
			// For 3 ALU // move to issue_next, increase
			// issue_cnt, busy bit reset, 
			// starting from older instructions,
			// issue only 3 instructions
			for(i=0;i<`RS_SIZE;i=i+1) begin
				if(rs_table[i].T1 [-1] & rs_table[i].T2 [-1] & rs_table[i].busy ) begin
					case(rs_table[i].inst.fu_name) begin
						FU_ALU : begin
								if(!issue_next[0].busy) begin	
									issue_next[0] = rs_table[i]; //ALU1
									issue_cnt = issue_cnt + 1;
									issue_idx[i] = 1'b1;
								//	rs_table_next[i].busy = 0;
								end else if (issue_next[0].busy & (!issue_next[1].busy))begin
									if(rs_table[i].waiting_cnt >= issue_next[0].waiting_cnt) begin
									// When the instruction is older than the instruction in ALU1
										issue_next[1] = issue_next[0]; //Younger instruction goes to ALU2
										issue_next[0] = rs_table[i]; //Older instruction goes to ALU1
										issue_cnt = issue_cnt + 1;
										issue_idx[i] = 1'b1;
									//	rs_table_next[i].busy = 0;
									end else
										issue_next[1] = rs_table[i]; //ALU2
										issue_cnt = issue_cnt + 1;
										issue_idx[i] = 1'b1;
									//	rs_table_next[i].busy = 0;

									end

									

								end else if (issue_next[0].busy & issue_next[1].busy & (!issue_next[2].busy)) begin
									if(rs_table[i].waiting_cnt >= issue_next[0].waiting_cnt) begin
									
										issue_next[2] = issue_next[1];	
										issue_next[1] = issue_next[0];
										issue_next[0] = rs_table[i]; //ALU3
										issue_cnt = issue_cnt + 1;
										issue_idx[i] = 1'b1;
									//	rs_table_next[i].busy = 0;

									end else if ((rs_table[i].waiting_cnt >= issue_next[1].waiting_cnt) & (rs_table[i].waiting_cnt < issue_next[0].waiting_cnt)) begin
									
										issue_next[2] = issue_next[1];
										issue_next[1] = rs_table[i]; //ALU3
										issue_cnt = issue_cnt + 1;
										issue_idx[i] = 1'b1;
									//	rs_table_next[i].busy = 0;

									end else begin
									
										issue_next[2] = rs_table[i]; //ALU3
										issue_cnt = issue_cnt + 1;
										issue_idx[i] = 1'b1;
									//	rs_table_next[i].busy = 0;

									end


									
								end else if (issue_next[0].busy & issue_next[1].busy & issue_next[2].busy) begin
									if(rs_table[i].waiting_cnt >= issue_next[0].waiting_cnt) begin
										
										issue_next[2] = issue_next[1];	
										issue_next[1] = issue_next[0];
										issue_next[0] = rs_table[i]; //ALU3
										issue_idx[i] = 1'b1;
									//	rs_table_next[i].busy = 0;

									end else if ((rs_table[i].waiting_cnt >= issue_next[1].waiting_cnt) & (rs_table[i].waiting_cnt < issue_next[0].waiting_cnt)) begin
										issue_next[1] = issue_next[0];
										issue_next[0] = rs_table[i]; //ALU3
										issue_idx[i] = 1'b1;
									//	rs_table_next[i].busy = 0;
									end else if ((rs_table[i].waiting_cnt >= issue_next[2].waiting_cnt) & (rs_table[i].waiting_cnt < issue_next[1].waiting_cnt)) begin
										issue_next[2] = rs_table[i]; //ALU3
										issue_idx[i] = 1'b1;
									//	rs_table_next[i].busy = 0;

									end 

										
								end
										
						end

						FU_LD : begin	
							if(LSQ_busy!=2'b01) begin
									if(!issue_next[3].busy) begin	
										issue_next[3] = rs_table[i]; //LD
										issue_cnt = issue_cnt + 1;
										issue_idx[i] = 1'b1;
										//rs_table_next[i].busy = 0;
									end else if (issue_next[3].busy) begin
										if(rs_table[i].waiting_cnt >= issue_next[3].waiting_cnt) begin
											issue_next[3] = rs_table[i]; //LD
											issue_idx[i] = 1'b1;
										end
									end
							end
						end

						FU_ST :  begin	
							if(LSQ_busy!=2'b10)  begin
									if(!issue_next[4].busy) begin	
										issue_next[4] = rs_table[i]; //ST
										issue_cnt = issue_cnt + 1;
										issue_idx[i] = 1'b1;
										//rs_table_next[i].busy = 0;
									end else if (issue_next[4].busy) begin
										if(rs_table[i].waiting_cnt >= issue_next[4].waiting_cnt) begin
											issue_next[4] = rs_table[i]; //LD
											issue_idx[i] = 1'b1;
										end
									end

	
							end
						end

						FU_MULT :  begin	
								if(!issue_next[5].busy) begin	
									issue_next[5] = rs_table[i]; //MULT1
									issue_cnt = issue_cnt + 1;
									issue_idx[i] = 1'b1;
									//rs_table_next[i].busy = 0;
								end else if (issue_next[5].busy & (!issue_next[6].busy) ) begin
									if(rs_table[i].waiting_cnt >= issue_next[5].waiting_cnt) begin
										issue_next[6] = issue_next[5];
										issue_next[5] = rs_table[i]; 
										issue_cnt = issue_cnt + 1;
										issue_idx[i] = 1'b1;
									end else begin
										issue_next[6] = rs_table[i]; //MULT2
										issue_cnt = issue_cnt + 1;
										issue_idx[i] = 1'b1;
										//rs_table_next[i].busy = 0;
									end
								end else if (issue_next[5].busy & issue_next[6].busy) begin
									if(rs_table[i].waiting_cnt >= issue_next[5].waiting_cnt) begin
										issue_next[6] = issue_next[5];
										issue_next[5] = rs_table[i]; 
										issue_idx[i] = 1'b1;
										
									end else if((rs_table[i].waiting_cnt >= issue_next[6].waiting_cnt) & rs_table[i].waiting_cnt < issue_next[5].waiting_cnt) begin
										issue_next[6] = rs_table[i];
										issue_idx[i] = 1'b1;
									end
								end
						end
						FU_BR :  begin	
								if(!issue_next[7].busy) begin	
									issue_next[7] = rs_table[i]; //BR
									issue_cnt = issue_cnt + 1;
									issue_idx[i] = 1'b1;
									//rs_table_next[i].busy = 0;
								end else if (issue_next[7].busy) begin
									if(rs_table[i].waiting_cnt >= issue_next[7].waiting_cnt) begin
										issue_next[7] = rs_table[i]; //LD
										issue_idx[i] = 1'b1;
									end
								end
			
						end

				
					endcase
				end
			end
					

		end
		//update rs_table_next.busy to 0 when the insturuction is
		//issued

			integer j,k;
			for(j=0;j<=`RS_SIZE;j=j+1) begin
				for(k=0;k<=`NUM_FU;k=k+1) begin
					if(rs_table[j].busy & issue_idx[j] & issue_next[k].busy) begin
						rs_table_next[j].busy = 0;
					end
				end	
			end


		// DISPATCH STAGE
		if (enable & dispatch_valid) begin
			integer i;
			for(i = 2;i<`RS_SIZE;i=i+1) begin
			for(j = 1;j<i;j=j+1) begin
			for(k = 0;k<j;k=k+1) begin
				if(rs_table[i].busy==0 && rs_table[j].busy==0 && rs_table[k].busy == 0) begin
					rs_table_next[i] = inst_in[2];
					rs_table_next[i].busy = inst_in[2].inst.valid_inst;
					rs_table_next[i].waiting_cnt = 4'b0;

					rs_table_next[j] = inst_in[1];
					rs_table_next[j].busy = inst_in[1].inst.valid_inst;
					rs_table_next[j].waiting_cnt = 4'b0; 

					rs_table_next[k] = inst_in[0];
					rs_table_next[k].busy = inst_in[0].inst.valid_inst;
					rs_table_next[k].waiting_cnt = 4'b0;  
				end
				else begin
					rs_table_next[i] = rs_table[i];
					rs_table_next[j] = rs_table[j]; 
					rs_table_next[k] = rs_table[k];
				end
			end
			end
			end	

		end

		
	// Incresae the waiting index of rs_table_next
	
		for( integer i=0 ; i<`RS_SIZE ; i=i+1) begin
			if(rs_table_next.waiting_cnt[i] !=4'b1111 ) begin
				rs_table_next.waiting_cnt[i] = rs_table_next.waiting_cnt[i] + 1;
			end
		end


	end

	//////////////////////////////////////////////////
	//                                              //
	//        Update the flip flops			//
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



endmodule // RS
