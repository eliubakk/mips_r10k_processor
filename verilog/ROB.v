module ROB(
	input 		    	clock,
	input 		    	reset,
	input 		    	enable,
	input PHYS_REG 		T_old_in, // Comes from Map Table During Dispatch
	input PHYS_REG		T_new_in, // Comes from Free List During Dispatch
	input PHYS_REG 		CDB_tag_in, // Comes from CDB during Commit
	input				CDB_en, // Comes from CDB during Commit
	input				dispatch_en, // Structural Hazard detection during Dispatch

	output PHYS_REG 	T_old_out, // Output for Retire Stage goes to Free List
	output PHYS_REG     T_new_out, // Output for Retire Stage goes to Arch Map
	output [$clog2(`ROB_SIZE) - 1:0] rob_free_entries // Used for Dispatch Hazard
);

endmodule // ROB