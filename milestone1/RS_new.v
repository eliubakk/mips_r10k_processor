// Things that are modified : only free the RS table_busy bit, include waiting
// siganl, Issue only has 8 tables
/*
module issue_selector(
		// INPUTS
		input RS_ROW_T [(`RS_SIZE - 1):0] 					rs_table,
		input [1:0] 								LSQ_busy,

		// OUTPUTS
		//output logic [$clog2(`NUM_FU)-1:0] 					issue_cnt,
		output logic [`RS_SIZE-1:0]	issue_code
	);
	integer i;
	logic [2:0] ALU_cnt;
	logic [1:0] MULT_cnt;
	// check tag1, tag2, only check the LSQ when it is LD/STQ, 
	//
	always_comb begin
		ALU_cnt = 3'b0;
		MULT_cnt = 2'b0;


		for(i=0; i<= `RS_SIZE; i=i+1) begin
			if ((rs_table.inst.fu_name [i] == FU_LD) | (rs_table.inst.fu_name [i] == FU_ST) ) begin // For LD/Store
				if( (LSQ_busy == 2'b0) & rs_table[i].T1 [-1] & rs_table[i].T2 [-1] ) begin
					//LSQ not busy & tag match
					issue_code[i] = 1'b1;
				end else begin
					//LSQ busy or tag not match
					issue_code[i] = 1'b0;
				end 
	
			end 
			else begin // For the rest of programs
				if( rs_table[i].T1 [-1] & rs_table[i].T2 [-1] ) begin
					issue_code[i] = 1'b1;
				end else begin
					issue_code[i] = 1'b0;
				end
			end

		end

	end
	
	// TODO, use priority encoders
endmodule
*/

module max_finder(
		input RS_ROW_T [(`RS_SIZE - 1):0] 			rs_table,

		output logic [3:0] cnt_out 
	);

	cnt_out = 0;
	cnt_out = (rs_table[0].waiting_cnt > rs_table[1].waiting_cnt) ? rs_table[0].waiting_cnt : rs_table[1].waiting_cnt;

endmodule


// module partition_finder(
// 		// inputs
// 		input RS_ROW_T [(`RS_SIZE - 1):0] 			rs_table,

// 		// outputs
// 		output logic [`NUM_FU:0] partition_points,
// 		output logic [$clog2(`NUM_FU)-1:0] partition_count
// );

// 	integer i;
// 	for (i = 0; i < `RS_SIZE; i += 1) begin
// 		if (rs_table[i].issue_code) begin
// 			partition_points = {partition_points[0:partition_count]}
// 		end
// 	end

// endmodule

module next_state_rs(
	// inputs
	input RS_ROW_T [(`RS_SIZE - 1):0] 			rs_table,

	// outputs
	output RS_ROW_T [(`RS_SIZE - 1):0] 			rs_table_next  
);

	// logic [`NUM_FU:0] partition_points;
	// logic [$clog2(`NUM_FU)-1:0] partition_count;


	// integer i;
	// for (i = 0; i < `RS_SIZE; i += 1) begin
	// 	if (rs_table[i].issue_code) begin
	// 		slice = rs_table[]
	// 		rs_table_next = {};
	// 	end
	// end

	integer i;
	for (i = 0; i < `RS_SIZE; i += 1) begin
	end


	// partition_finder pf0(
	// 	// inputs
	// 	.rs_table(rs_table),

	// 	// outputs
	// 	.partition_points(partition_points),
	// 	.partition_count(partition_count)
	// );

	// rs_slicer rss0(
	// 	// inputs
	// 	.rs_table(rs_table),
	// 	.partition_points(partition_points),
	// 	.partition_count(partition_count),

	// 	// outputs
	// 	.rs_table_next(rs_table_next)
	// );

endmodule

module index_finder(
	// inputs
	input RS_ROW_T  	rs_table 	[(`RS_SIZE - 1):0],
	input 

	// outputs
	output logic [$clog2(`RS_SIZE)-1:0] insert_idx [2:0]
);

	integer i;
	for (i = 0; i < `RS_SIZE; i += 1) begin
		if (~rs_table[i].busy) begin

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
	// logic		[`RS_SIZE-1:0][3:0]	rs_waiting_cnt;  //Waitng numbers for each row
	// logic  		[`RS_SIZE-1:0] 		rs_busy_idx;	// Busy index
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
	
	assign rs_table_next.T1 [-1] = MSB_T1[2] | MSB_T1[1] | MSB_T1[0];
	assign rs_table_next.T2 [-1] = MSB_T2[2] | MSB_T2[1] | MSB_T2[0]; 

	

	always_comb begin

		// COMMIT STAGE
		// CAM broadcasts ready registers
		// if register ready high, then set ready bit to high
		// Things to add : what if the tag bit is empty?
		/*integer i,j;
		for(i=`SS_SIZE;i=0;i=i-1) begin
			if(cam_en[i]) begin
				for(j=0;j<rs_busy_cnt;j=j+1) begin
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
		end*/
		

		// ISSUE STAGE // black box
		if (enable) begin
			inst_out_next = {`NUM_FU{{$bits(RS_ROW_T}{0}}};
			// rs_table_next = {`RS_SIZE{{$bits(RS_ROW_T}{0}}};
			// don't wnat to set rs_table_next to 0 becuase CAM changes are not registered
			
	 		/*cnt_inst_out = {($clog2(`NUM_FU)-1){0}};	
			cnt_rs_next = {($clog2(`NUM_FU)-1){0}};*/ 

			integer i;
			for (i = 0; i < `RS_SIZE; i += 1) begin
				// rs_table[i]
				if (~rs_table[i].issue_code) begin
					integer j;
					for (j = 0; j < `RS_SIZE; j += 1) begin
						if (~rs_table_next[j].busy) begin
							rs_table_next[j] = rs_table[i];
						end
					end
				end
			end

			integer i;
			for(i=0;i<`RS_SIZE;i=i+1) begin
				if(issue_code[i]) begin
					inst_out_next = rs_table[i];
						
				end else begin
					rs_table_next[cnt_rs_next] = rs_table[i];
				end
				
			end
			
			/*for(integer i = `RS_SIZE -1 ; i >= 0; i = i - 1) begin
				if(issue_code[i]) begin
					inst_out_next = {inst_out_next[`RS_SIZE - 2:0], rs_table[i]};
				end else begin
					rs_table_next = {rs_table_next[`RS_SIZE - 2:0], rs_table[i]};
				end
			end*/ 
		end

		// DISPATCH STAGE
		if (enable & ~dispatch_hazard) begin

			dispatch_idx = rs_busy_cnt - issue_cnt;

			logic [$clog2(`RS_SIZE)-1:0] insert_idx [2:0];

			index_finder idx0(
				.rs_table(rs_table),
				.insert_idx(insert_idx)
			);


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



	// ISSUE STAGE

	// some module that determines row indices getting issued
	//
	issue_selector is0(
		.rs_table  (rs_table),
		.LSQ_busy  (LSQ_busy),
		
		.issue_code(issue_code),
		.issue_cnt (issue_cnt)
	);
	


	always_ff @(posedge clock)
	begin
		if (enable) begin
			inst_out <= inst_out_next;
			rs_table <= rs_table_next;
			busy_row <= rs_busy_cnt_next;
		end

	end

	// EXECUTE STAGE

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
