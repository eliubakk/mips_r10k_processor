module Free_List(
	input clock,
	input reset,
	input enable,
	input PHYS_REG T_old, // Comes from ROB during Retire Stage
	input dispatch_en, // Structural Hazard detection during Dispatch

	output [$clog2(`NUM_PHYS_REG)-1:0] num_free_entries, // Used for Dispatch Hazard
	output empty, // Used for Dispatch Hazard
	output PHYS_REG free_reg // Output for Dispatch for other modules
);
endmodule // Free_List