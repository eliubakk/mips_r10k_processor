module CDB (
	input clock,    // Clock
	input reset,  // Asynchronous reset active low
	input enable, // Clock Enable

	input PHYS_REG tag_in,	// Comes from FU, during commit
	input			ex_valid, // Comes from FU, during commit

	output PHYS_REG CDB_tag_out, // Output for commit, goes to modules
	output 			CDB_en_out,  // Output for commit, goes to modules
	output busy
);

endmodule