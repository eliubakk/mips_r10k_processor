`include "sys_defs.vh"
`define DEBUG
module Map_Table(
	input	clock,
	input 	reset,
	input	enable,
	input GEN_REG			reg_a, 		// Comes from Decode during Dispatch
	input GEN_REG			reg_b, 		// Comes from Decode during Dispatch 
	input GEN_REG 			reg_dest, 	// Comes from Decode during Dispatch
	input PHYS_REG			free_reg, 	// Comes from Free List during Dispatch
	input PHYS_REG 			CDB_tag_in, 	// Comes from CDB during Commit
	input				CDB_en, 	// Comes from CDB during Commit
	input MAP_ROW_T [`NUM_GEN_REG-1:0]	map_check_point,
	input branch_incorrect,


	`ifdef DEBUG
	output MAP_ROW_T [`NUM_GEN_REG-1:0]	map_table_out,
	`endif

	output PHYS_REG 		T1, 		// Output for Dispatch and goes to RS
	output PHYS_REG 		T2, 		// Output for Dispatch and goes to RS
	output PHYS_REG 		T 		// Output for Dispatch and goes to RS and ROB
);

	// internal data

	// map_table registers and combinational next_map_table
	MAP_ROW_T [`NUM_GEN_REG-1:0]	map_table;
	MAP_ROW_T [`NUM_GEN_REG-1:0]	next_map_table;

	`ifdef DEBUG
	assign map_table_out = map_table;
	`endif

	assign T1 = map_table[reg_a].phys_tag;
	assign T2 = map_table[reg_b].phys_tag;
	assign T = map_table[reg_dest].phys_tag;

	always_comb begin

		if (branch_incorrect) begin
			next_map_table = map_check_point;
		end else if (CDB_en & enable) begin
			// Commit Stage first
			for (int i = 0; i < `NUM_GEN_REG; ++i) begin
				if (map_table[i].phys_tag[$clog2(`NUM_PHYS_REG)-1:0] == CDB_tag_in[$clog2(`NUM_PHYS_REG)-1:0]) begin
					next_map_table[i].phys_tag = CDB_tag_in;
				end else begin
					next_map_table[i].phys_tag = map_table[i].phys_tag;
				end
			end
			// Dispatch Stage second
			next_map_table[reg_dest] = free_reg;
		end else if (CDB_en) begin
			for (int i = 0; i < `NUM_GEN_REG; ++i) begin
				if (map_table[i].phys_tag[$clog2(`NUM_PHYS_REG)-1:0] == CDB_tag_in[$clog2(`NUM_PHYS_REG)-1:0]) begin
					next_map_table[i].phys_tag = CDB_tag_in;
				end else begin
					next_map_table[i].phys_tag = map_table[i].phys_tag;
				end
			end
		end else if (enable) begin
			next_map_table = map_table;
			next_map_table[reg_dest] = free_reg;
		end else begin
			next_map_table = map_table;
		end
	end

	always_ff @(posedge clock) begin
		if (reset) begin
			// if reset, set reg_i = pr_i (i.e. reg0 = pr0, ...)
			for (int i = 0; i < `NUM_GEN_REG; i += 1) begin
				map_table[i].phys_tag 		<= i;
				map_table[i].phys_tag[$clog2(`NUM_PHYS_REG)] <= 1'b1;
			end
		end else begin
			// update the map_table's next state
			map_table 				<= next_map_table;
		end
	end

endmodule // Map_Table
