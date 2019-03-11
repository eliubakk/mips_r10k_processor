`include "sys_defs.vh"

module Arch_Map_Table(
	input	clock,
	input 	reset,
	input	enable,
	input PHYS_REG	T_new_in, // Comes from ROB during Retire
	input PHYS_REG	T_old_in, //What heewoo added. It is required to find which entry should I update. Comes from ROB during retire.

	output PHYS_REG [`NUM_GEN_REG-1:0] arch_table // Arch table status, what heewoo changed from GEN_REG to PHYS_REG
);

	//PHYS_REG		[`NUM_GEN_REG-1:0]	 	arch_map_table; 
	logic			[(`NUM_GEN_REG)-1:0]		retire_idx; // general register index which physical register should be updated, also useful for superscalar retire
	//logic			retire_hit;


	always_comb begin
		retire_idx = `NUM_GEN_REG'b0;
		//retire_hit = 1'b0;

		if(enable) begin
			for (integer i=0;i<`NUM_GEN_REG;i=i+1) begin
				if( arch_table[i] == T_old_in ) begin
					retire_idx[i] = 1'b1;
				end
			end
		end	

	end

	always_ff @(posedge clock) begin
		if(reset) begin
			for(integer i=0;i<`NUM_GEN_REG;i=i+1) begin
				arch_table[i] <=  i; //GEN_REG[i] = PHYS_REG[i]			
			end
		end else if (enable) begin
			for(integer i=0;i<`NUM_GEN_REG;i=i+1) begin
				if(retire_idx[i] == 1'b1) begin
					arch_table[i] <= T_new_in;
				end
			end	
		end
	
	end

endmodule // Arch_Map_Table
