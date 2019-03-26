`include "../sys_defs.vh"
`timescale 1ns/100ps

module Free_List_Check(
	input clock,
// 	input reset,
/*
	input write_en,
	input PHYS_REG T_old,
	input clear_en,
	input PHYS_REG T_new,
*/
	input enable,
	input PHYS_REG [`FL_SIZE - 1:0] free_list_in,
	input [$clog2(`FL_SIZE):0] tail_in,

	output PHYS_REG [`FL_SIZE - 1:0] free_list_check,
	output [$clog2(`FL_SIZE):0] tail_check
);

	// internal data

	PHYS_REG [`FL_SIZE - 1:0] free_list;
	PHYS_REG [`FL_SIZE - 1:0] free_list_next;

	logic [$clog2(`FL_SIZE):0] tail;
	logic [$clog2(`FL_SIZE):0] tail_next;

	// assign 
	assign free_list_check = free_list;
	assign tail_check = tail;

	always_comb begin
		if (enable) begin
			free_list_next = free_list_in;
			tail_next = tail_in;
		end else begin
			free_list_next = free_list;
			tail_next = tail;
		end
		/*
		free_list_next = free_list;
		tail_next = tail;

		if (write_en & clear_en) begin
		end else if (write_en) begin
		end else if (clear_en) begin
		end
		*/
	end

	always_ff @(posedge clock) begin
		if (enable) begin
			free_list <= free_list_next;
			tail <= tail_next;
		end
		/*
		if (reset) begin
			for (int i = 0; i < `NUM_GEN_REG; ++i) begin
				free_list[i] <= {0, `NUM_GEN_REG + i};
			end
			tail <= `NUM_GEN_REG;
		end else begin
			free_list <= free_list_next;
			tail <= tail_next;
		end
		*/
	end

endmodule
