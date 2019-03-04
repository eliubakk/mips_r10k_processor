module Map_Table(
	input	clock,
	input 	reset,
	input	enable,
	input GEN_REG	reg_a, // Comes from Decode during Dispatch
	input GEN_REG	reg_b, // Comes from Decode during Dispatch 
	input GEN_REG 	reg_dest, // Comes from Decode during Dispatch
	input PHYS_REG	free_reg, // Comes from Free List during Dispatch
	input PHYS_REG 		CDB_tag_in, // Comes from CDB during Commit
	input				CDB_en, // Comes from CDB during Commit

	output PHYS_REG T1, // Output for Dispatch and goes to RS
	output PHYS_REG T2, // Output for Dispatch and goes to RS
	output PHYS_REG T // Output for Dispatch and goes to RS and ROB
);

endmodule // Map_Table