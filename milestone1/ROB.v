module ROB(
	input 		    	clock,
	input 		    	reset,
	input 		    	enable,
	input PHYS_REG 		T_old_in,
	input PHYS_REG		T_new_in,
	input 				mem_done_in,
	output PHYS_REG 	T_old_out,
	output PHYS_REG     T_new_out,
	output 				retire_enable,
	output				commit_enable,
	output 				full
	);

endmodule // ROB