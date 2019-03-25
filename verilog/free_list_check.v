

module Free_List_Check(
	input clock,
	input reset,
	input write_en,
	input PHYS_REG T_old,
	input clear_en,
	input PHYS_REG T_new,

	output PHYS_REG [`FL_SIZE - 1:0] free_list_check
);

endmodule
