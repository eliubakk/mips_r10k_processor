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

	always_comb begin

		// COMMIT STAGE
		if (CDB_en) begin
			// if CDB is enabled, we want to update
			// the mapped registers
			// cam for the value and update it
			for (int i = 0; i < `NUM_GEN_REG; i += 1) begin
				// check if the bits from 6:0 match since bit
				// 7 is used to determine ready
				if (map_table[i].phys_tag[$clog2(`NUM_PHYS_REG)-1:0] == CDB_tag_in[$clog2(`NUM_PHYS_REG)-1:0]) begin
					// if tags match, then update the
					// phys_tag
					next_map_table[i].phys_tag = CDB_tag_in;
				end else begin
					// if tags don't match, leave it as is
					next_map_table[i].phys_tag = map_table[i];
				end
			end
		end else begin
			// if CDB is not enabled, then retain current
			// map_table state
			next_map_table = map_table;
		end	

		// DISPATCH STAGE
		if (enable) begin
			T1 = map_table[reg_a].phys_tag;
			T2 = map_table[reg_b].phys_tag;
			T  = map_table[reg_dest].phys_tag;
		end else if (~CDB_en) begin
			// if disabled, retain the current map_table state
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
