`include "../../sys_defs.vh"
module Arch_Map_Table(
	input	clock,
	input 	reset,
	input [`SS_SIZE-1:0] enable,
	input PHYS_REG	[`SS_SIZE-1:0] T_new_in, // Comes from ROB during Retire
	input PHYS_REG	[`SS_SIZE-1:0] T_old_in, //What heewoo added. It is required to find which entry should I update. Comes from ROB during retire.

	output PHYS_REG [`NUM_GEN_REG-1:0] arch_map_table // Arch table status, what heewoo changed from GEN_REG to PHYS_REG
);

	PHYS_REG		[`NUM_GEN_REG-1:0]	 	arch_map_table_next; 
	logic [`SS_SIZE-1:0] enable_forwarded;
	PHYS_REG [`SS_SIZE-1:0] T_new_forwarded;
	PHYS_REG [`SS_SIZE-1:0] T_old_forwarded;
	logic			[(`NUM_GEN_REG)-1:0]		retire_idx; // general register index which physical register should be updated, also useful for superscalar retire
	//logic			retire_hit;

	//CAM VARIABLES FOR CDB
	logic [(`SS_SIZE-1):0][($clog2(`NUM_PHYS_REG)-1):0] cam_tags_in;
	logic [(`NUM_GEN_REG-1):0][($clog2(`NUM_PHYS_REG)-1):0] cam_table_in;
	logic [(`NUM_GEN_REG-1):0][(`SS_SIZE-1):0] cam_hits;

	wire T_idx0_over_idx1;
	wire T_idx1_over_idx2; 
	wire T_idx0_over_idx2;

	if(`SS_SIZE == 1) begin
		assign T_old_forwarded = T_old_in;
		assign T_new_forwarded = T_new_in;
		assign enable_forwarded = enable;
	end else if(`SS_SIZE == 3) begin
		assign T_idx0_over_idx1 = enable[0] & (T_new_in[1] == T_old_in[0]);
		assign T_idx1_over_idx2 = enable[1] & (T_new_in[2] == T_old_in[1]);
		assign T_idx0_over_idx2 = (enable[0] & (T_new_in[2] == T_old_in[0])) | (T_idx0_over_idx1 && T_idx1_over_idx2);
		assign enable_forwarded[2] = enable[2];
		assign T_old_forwarded[2] = T_old_in[2];
		assign T_new_forwarded[2] = T_idx0_over_idx2? T_new_in[0] : 
									T_idx1_over_idx2? T_new_in[1] :
													  T_new_in[2];
		assign enable_forwarded[1] = (~T_idx0_over_idx2 & T_idx1_over_idx2)? enable[0] :
									 				    (~T_idx1_over_idx2)? enable[1] : 
														 					 1'b0;
		assign T_old_forwarded[1] = (~T_idx0_over_idx2 & T_idx1_over_idx2)? T_old_in[0]:
													   (~T_idx1_over_idx2)? T_old_in[1]:
														 					`DUMMY_REG;
		assign T_new_forwarded[1] = (~T_idx0_over_idx2 & (T_idx1_over_idx2 | T_idx0_over_idx1))? T_new_in[0]:
													   						(~T_idx1_over_idx2)? T_new_in[1]:
														 										 `DUMMY_REG;
		assign enable_forwarded[0] = (~T_idx0_over_idx2 & ~T_idx0_over_idx1 & ~T_idx1_over_idx2)? enable[0] :
																			  					  1'b0;
		assign T_old_forwarded[0] = (~T_idx0_over_idx2 & ~T_idx0_over_idx1 & ~T_idx1_over_idx2)? T_old_in[0] :
																			 					 `DUMMY_REG;
		assign T_new_forwarded[0] = (~T_idx0_over_idx2 & ~T_idx0_over_idx1 & ~T_idx1_over_idx2)? T_new_in[0] :
																			 					 `DUMMY_REG;		
	end

	genvar ig;
	for(ig = 0; ig < `NUM_GEN_REG; ig += 1) begin
		assign cam_table_in[ig] = arch_map_table[ig][($clog2(`NUM_PHYS_REG)-1):0];
	end
	for(ig = 0; ig < `SS_SIZE; ig += 1) begin
		assign cam_tags_in[ig] = T_old_forwarded[ig][($clog2(`NUM_PHYS_REG)-1):0];
	end

	//Instantiate CAM module for reg
	CAM #(.LENGTH(`NUM_GEN_REG),
		  .WIDTH(1),
		  .NUM_TAGS(`SS_SIZE),
		  .TAG_SIZE($clog2(`NUM_PHYS_REG))) map_cam ( 
		.enable(enable_forwarded),
		.tags(cam_tags_in),
		.table_in(cam_table_in),
		.hits(cam_hits)
	);

	always_comb begin
		arch_map_table_next = arch_map_table;

		for (integer i = 0; i < `NUM_GEN_REG; i += 1) begin
			for(integer j = `SS_SIZE-1; j >= 0; j -= 1) begin
				if(cam_hits[i][j]) begin
					arch_map_table_next[i] = T_new_forwarded[j];
				end
			end
		end
	end

	always_ff @(posedge clock) begin
		if(reset) begin
			for(int i = 0; i < `NUM_GEN_REG; i += 1) begin
				arch_map_table[i] <=  `SD ((1'b1 << $clog2(`NUM_PHYS_REG)) | $unsigned(i)); //GEN_REG[i] = PHYS_REG[i]			
			end
		end else begin
			arch_map_table <= `SD arch_map_table_next;
		end
	end

endmodule // Arch_Map_Table
