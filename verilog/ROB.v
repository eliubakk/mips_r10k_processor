`include "../../sys_defs.vh"
`timescale 1ns/100ps
`define DEBUG

/// CAM module
module ROB_CAM(
		input				enable,
		input 				CAM_en, 
		input PHYS_REG  		CDB_tag,
		input ROB_ROW_T  [`ROB_SIZE-1:0] ROB_table,
		output 	 logic [`ROB_SIZE-1:0] T1_hit
		
	);
		
	always_comb begin
		T1_hit = {`ROB_SIZE{1'b0}};
		if(CAM_en & enable) begin
			for(integer i=0;i<`ROB_SIZE;i=i+1) begin
				T1_hit[i] = (ROB_table[i].T_new_out[5:0] == CDB_tag[5:0]);			 	
			end		
		end else begin
			T1_hit = {`ROB_SIZE{1'b0}};
			
		end	
	end		
endmodule

module ROB(
	input 		    	clock,
	input 		    	reset,
	input 		    	enable,
	input PHYS_REG 		T_old_in, // Comes from Map Table During Dispatch
	input PHYS_REG		T_new_in, // Comes from Free List During Dispatch
	input PHYS_REG 		CDB_tag_in, // Comes from CDB during Commit
	input				CAM_en, // Comes from CDB during Commit
	input				dispatch_en, // Structural Hazard detection during Dispatch
	input 				branch_not_taken,

	// OUTPUTS
	
	output PHYS_REG 	T_free, // Output for Retire Stage goes to Free List
	output PHYS_REG     T_arch, // Output for Retire Stage goes to Arch Map

	output logic		T_out_valid,
	output logic [$clog2(`ROB_SIZE):0] rob_free_entries,
	output logic							 rob_full, // Used for Dispatch Hazard
	`ifdef DEBUG 
	output  ROB_ROW_T [`ROB_SIZE:1]		ROB_table_out,
	output logic [$clog2(`ROB_SIZE):0] tail_reg, head_reg
	`endif
);



logic [$clog2(`ROB_SIZE):0] tail, head;
//logic [$clog2(`ROB_SIZE) - 1:0] tail_reg, head_reg;
//logic [$clog2(`ROB_SIZE) - 1:0] ROB_idx;

							
 ROB_ROW_T [`ROB_SIZE:1]		ROB_table;
 ROB_ROW_T [`ROB_SIZE:1]		ROB_table_reg;
logic check_loop;		// To keep a tab on the loop checking during dispatch stage
//logic T_new_valid_reg, T_old_valid_reg;
logic [(`ROB_SIZE):1] MSB_T1;


`ifdef DEBUG 
	assign  	ROB_table_out = ROB_table_reg;
	`endif

ROB_CAM robcam( 
		.enable(enable),
		.CAM_en(CAM_en), 
		.CDB_tag(CDB_tag_in),
		.ROB_table(ROB_table),
		.T1_hit(MSB_T1)		
	);



//RETIRE STAGE

always_comb begin
	
	ROB_table= ROB_table_reg;
	T_out_valid= 1'b0;	// Intializing the valid bits after each cycle
	head= head_reg;
	tail= tail_reg;
	T_free= 7'b1111111;
		T_arch= 7'b1111111;

	if((ROB_table_reg[head].busy)&(ROB_table_reg[head].T_new_out[6])) begin			// check for the head pointer and the ready bit of dest reg to know it has commited or not
		T_out_valid= 1;
		T_free= ROB_table[head].T_old_out;
		T_arch= ROB_table[head].T_new_out;
		ROB_table[head].busy= 0;
		if (head_reg==5'd16) begin
			head= 5'd1;
		end
		else begin
			head= head_reg + 1;
		end 
		

	end 	

// COMMIT STAGE

	

	for (integer i=1; i<= `ROB_SIZE; i=i+1) begin
		ROB_table[i].T_new_out[6]= MSB_T1[i] | ROB_table_reg[i].T_new_out[6];
	end

rob_full = ROB_table_reg[16].busy & ROB_table_reg[1].busy & ROB_table_reg[2].busy & ROB_table_reg[3].busy & ROB_table_reg[4].busy 
			& ROB_table_reg[5].busy & ROB_table_reg[6].busy & ROB_table_reg[7].busy & ROB_table_reg[8].busy & ROB_table_reg[9].busy 
			& ROB_table_reg[10].busy & ROB_table_reg[11].busy &  ROB_table_reg[12].busy & ROB_table_reg[13].busy & ROB_table_reg[14].busy & ROB_table_reg[15].busy; 

rob_free_entries = `ROB_SIZE - (ROB_table[16].busy + ROB_table[1].busy + ROB_table[2].busy + ROB_table[3].busy +  ROB_table[4].busy + ROB_table[5].busy + ROB_table[6].busy + ROB_table[7].busy + ROB_table[8].busy + ROB_table[9].busy + ROB_table[10].busy + ROB_table[11].busy +  ROB_table[12].busy + ROB_table[13].busy + ROB_table[14].busy + ROB_table[15].busy); 

// Dispatch
check_loop = 1'b0;
	

	if (dispatch_en) begin
		for (integer i=1; i<= `ROB_SIZE; i=i+1) begin
			if (i > head) begin
				if (!ROB_table[i].busy) begin
					ROB_table[i].T_new_out= T_new_in;
					ROB_table[i].T_old_out= T_old_in;
					ROB_table[i].busy= 1;
					check_loop = 1'b1;
					if (tail_reg == 5'd16) begin
						tail= 5'd1;
					end
					else begin
						tail= tail_reg + 1;
					end			
					break;
				end
			end 
		end

		
			if(!check_loop) begin
				for(integer i=1;i< `ROB_SIZE; i=i+1) begin
					if(i<head) begin
						if (!ROB_table[i].busy) begin
							ROB_table[i].T_new_out= T_new_in;
							ROB_table[i].T_old_out= T_old_in;
							ROB_table[i].busy= 1;
							if (tail_reg == 5'd16) begin
								tail= 5'd1;
							end
							else begin
								tail= tail_reg + 1;
							end		
							break;
						end
					end
					
				
				end
			end
		end

		if (dispatch_en) begin
		if(head==0) begin
			head= head_reg+1;
		end

	end
end

	//UPDATE_FLIP_FLOPS

always_ff @(posedge clock) begin
	if (reset | branch_not_taken) begin
		for (integer i=1; i<= `ROB_SIZE; i=i+1) begin
			ROB_table_reg[i].T_new_out <= `SD 7'b1111111;
			ROB_table_reg[i].T_old_out <=  `SD 7'b1111111;
			ROB_table_reg[i].busy <= `SD 1'b0;		
		end
		tail_reg<= `SD 0;
		head_reg<= `SD 0;
	end

	else begin
		ROB_table_reg<= `SD ROB_table;
		tail_reg<=  `SD tail;
		head_reg<=  `SD head;
			
	end
end

endmodule // ROB