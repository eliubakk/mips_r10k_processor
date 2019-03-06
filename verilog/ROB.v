`include "sys_defs.vh"
`define DEBUG

module ROB(
	input 		    	clock,
	input 		    	reset,
	input 		    	enable,
	input PHYS_REG 		T_old_in, // Comes from Map Table During Dispatch
	input PHYS_REG		T_new_in, // Comes from Free List During Dispatch
	input PHYS_REG 		CDB_tag_in, // Comes from CDB during Commit
	input				CDB_en, // Comes from CDB during Commit
	input				dispatch_en, // Structural Hazard detection during Dispatch
	input 				branch_not_taken,

	// OUTPUTS
	`ifdef DEBUG 
	output PHYS_REG 	T_old_out, // Output for Retire Stage goes to Free List
	output PHYS_REG     T_new_out, // Output for Retire Stage goes to Arch Map
	output 				T_old_valid, T_new_valid;
	output [$clog2(`ROB_SIZE) - 1:0] rob_free_entries,
	output							 rob_full // Used for Dispatch Hazard
	`endif
);

endmodule // ROB

logic [$clog2(`ROB_SIZE) - 1:0] tail, head;
logic [$clog2(`ROB_SIZE) - 1:0] tail_reg, head_reg;
//logic [$clog2(`ROB_SIZE) - 1:0] ROB_idx;
							
logic ROB_ROW_T [`ROB_SIZE-1:0]		ROB_table, ROB_table_reg;
logic check_loop;		// To keep a tab on the loop checking during dispatch stage
logic T_new_valid_reg, T_old_valid_reg;

/// CAM module
module ROB_CAM(
		input				enable,
		input 				CAM_en, 
		input PHYS_REG  		CDB_tag,
		input ROB_ROW_T  [`ROB_SIZE-1:0] ROB_table_reg,
		output 	 logic [`ROB_SIZE-1:0] T1_hit
		output T_new_valid, T_old_valid;
	);
		
	always_comb begin
		T1_hit = {`ROB_SIZE{1'b0}};
		if(CAM_en & enable) begin
			for(integer i=0;i<`ROB_SIZE;i=i+1) begin
				T1_hit[i] = (ROB_table_reg[i].T_new_out[5:0] == CDB_tag[5:0]);			 	
			end		
		end else begin
			T1_hit = {`ROB_SIZE{1'b0}};
			
		end	
	end		
//RETIRE STAGE

always_comb begin
	
	ROB_table= ROB_table_reg;
	T_new_valid= 1'b0;	// Intializing the valid bits after each cycle
	T_old_valid= 1'b0;
	
	if(ROB_table_reg[head].T_new_out[6]) begin			// check for the head pointer and the ready bit of dest reg to know it has commited or not
		T_new_valid= 1;
		T_old_valid= 1;
		T_old_out= ROB_table[head].T_old_out;
		T_new_out= ROB_table[head].T_new_out;
		ROB_table[head].busy= 0;
		head= head_reg + 1;

	end 	

// COMMIT STAGE

	ROB_CAM robcam ( 
		.enable(enable),
		.CAM_en(CAM_en), 
		.CDB_tag(CDB_tag_in),
		.ROB_table(ROB_table_reg[`ROB_SIZE-1:0]),
		.T1_hit(MSB_T1)		
	);

	for (integer i=0; i< `ROB_SIZE; i=i+1) begin
		ROB_table[i].T_new_out[6]= MSB_T1 | ROB_table_reg[i].T_new_out[6];
	end

rob_full = ROB_table_reg[0].busy & ROB_table_reg[1].busy & ROB_table_reg[2].busy & ROB_table_reg[3].busy & ROB_table_reg[4].busy 
			& ROB_table_reg[5].busy & ROB_table_reg[6].busy & ROB_table_reg[7].busy & ROB_table_reg[8].busy & ROB_table_reg[9].busy 
			& ROB_table_reg[10].busy & ROB_table_reg[11].busy &  ROB_table_reg[12].busy & ROB_table_reg[13].busy & ROB_table_reg[14].busy & ROB_table_reg[15].busy; 

rob_free_entries = `ROB_SIZE - (ROB_table[0].busy + ROB_table[1].busy + ROB_table[2].busy + ROB_table[3].busy +  ROB_table[4].busy + ROB_table[5].busy + ROB_table[6].busy + ROB_table[7].busy + ROB_table[8].busy + ROB_table[9].busy + ROB_table[10].busy + ROB_table[11].busy +  ROB_table[12].busy + ROB_table[13].busy + ROB_table[14].busy + ROB_table[15].busy); 

// Dispatch
check_loop = 1'b0;
	for (integer i=head; i< `ROB_SIZE; i=i+1) begin
		if (!busy) begin
			ROB_table[i].T_new_out= T_new_in;
			ROB_table[i].T_old_out= T_old_in;
			ROB_table[i].busy= 1;
			check_loop = 1'b1;
			tail= tail_reg +1;
		end
		

	end

	if(!check_loop) begin
		for(integer i=0;i< head; i=i+1) begin
			if (!busy) begin
			ROB_table[i].T_new_out= T_new_in;
			ROB_table[i].T_old_out= T_old_in;
			ROB_table[i].busy= 1;
			tail= tail_reg+1;
		end
		
		end
	end

	//UPDATE_FLIP_FLOPS

	always_ff@ (posedge clock)begin
		if (reset| branch_not_taken)
			for (integer i=0; i< `ROB_SIZE; i=i+1) begin
				ROB_table_reg[i].T_new_out <=  `SD 7'b1111111;
				ROB_table_reg[i].T_old_out <= `SD 7'b1111111;
				ROB_table_reg[i].busy <= `SD 1'b0;	
			end
			T_new_valid_reg <= `SD 1'b0;
			T_old_valid_reg <= `SD 1'b0;

		else begin
			ROB_table_reg<= ROB_table;
		end
	end
end