module Arch_Map_Table(
	input	clock,
	input 	reset,
	input	enable,
	input PHYS_REG	T_new_in, // Comes from ROB during Retire

	output GEN_REG [`NUM_GEN_REG-1:0] arch_table // Arch table status
);

endmodule // Arch_Map_Table