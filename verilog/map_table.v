`include "../../sys_defs.vh"
`timescale 1ns/100ps
`define DEBUG
module Map_Table(
	input	clock,
	input 	reset,
	input	enable,
	input GEN_REG	[`SS_SIZE-1:0]	reg_a, 		// Comes from Decode during Dispatch
	input GEN_REG	[`SS_SIZE-1:0]  reg_b, 		// Comes from Decode during Dispatch 
	input GEN_REG 	[`SS_SIZE-1:0]  reg_dest, 	// Comes from Decode during Dispatch
	input PHYS_REG	[`SS_SIZE-1:0]  free_reg, 	// Comes from Free List during Dispatch
	input PHYS_REG 	[`SS_SIZE-1:0]  CDB_tag_in, // Comes from CDB during Commit
	input			[`SS_SIZE-1:0]	CDB_en, 	// Comes from CDB during Commit
	input MAP_ROW_T [`NUM_GEN_REG-1:0]	map_check_point,
	input branch_incorrect,


	`ifdef DEBUG
	output MAP_ROW_T [`NUM_GEN_REG-1:0]	map_table_out,
	output logic [(`NUM_GEN_REG-1):0] cam_hits_out,
	`endif

	output PHYS_REG [`SS_SIZE-1:0]	T1, 		// Output for Dispatch and goes to RS
	output PHYS_REG [`SS_SIZE-1:0]	T2, 		// Output for Dispatch and goes to RS
	output PHYS_REG [`SS_SIZE-1:0]	T_old 		// Output for Dispatch and goes to ROB
);

	// internal data

	// map_table registers and combinational next_map_table
	MAP_ROW_T [`NUM_GEN_REG-1:0]	map_table;
	MAP_ROW_T [`NUM_GEN_REG-1:0]	next_map_table;

	//CAM VARIABLES FOR CDB
	logic [(`SS_SIZE-1):0][($clog2(`NUM_PHYS_REG)-1):0] cam_tag_in;
	logic [(`NUM_GEN_REG-1):0][($clog2(`NUM_PHYS_REG)-1):0] cam_tags_in;
	logic [(`NUM_GEN_REG-1):0] cam_hits;

	`ifdef DEBUG
	assign map_table_out = map_table;
	assign cam_hits_out = cam_hits;
	`endif

	genvar ig;
	for(ig = 0; ig < `SS_SIZE; ig += 1) begin
		assign T1[ig][($clog2(`NUM_PHYS_REG)-1):0] = map_table[reg_a[ig]].phys_tag[($clog2(`NUM_PHYS_REG)-1):0];
		assign T1[ig][$clog2(`NUM_PHYS_REG)] = map_table[reg_a[ig]].phys_tag[$clog2(`NUM_PHYS_REG)] | cam_hits[reg_a[ig]];
		assign T2[ig][($clog2(`NUM_PHYS_REG)-1):0] = map_table[reg_b[ig]].phys_tag[($clog2(`NUM_PHYS_REG)-1):0];
		assign T2[ig][$clog2(`NUM_PHYS_REG)] = map_table[reg_b[ig]].phys_tag[$clog2(`NUM_PHYS_REG)] | cam_hits[reg_b[ig]];
		assign T_old[ig][($clog2(`NUM_PHYS_REG)-1):0] = map_table[reg_dest[ig]].phys_tag[($clog2(`NUM_PHYS_REG)-1):0];
		assign T_old[ig][$clog2(`NUM_PHYS_REG)] = map_table[reg_dest[ig]].phys_tag[$clog2(`NUM_PHYS_REG)] | cam_hits[reg_dest[ig]];
	end

	for(ig = 0; ig < `NUM_GEN_REG; ig += 1) begin
		assign cam_tags_in[ig] = map_table[ig].phys_tag[($clog2(`NUM_PHYS_REG)-1):0];
	end
	for(ig = 0; ig < `SS_SIZE; ig += 1) begin
		assign cam_tag_in[ig] = CDB_tag_in[ig][($clog2(`NUM_PHYS_REG)-1):0];
	end
	
	//Instantiate CAM module for reg
	CAM #(.LENGTH(`NUM_GEN_REG),
		  .WIDTH(1),
		  .NUM_TAG (`SS_SIZE),
		  .TAG_SIZE($clog2(`NUM_PHYS_REG))) map_cam ( 
		.enable(CDB_en),
		.tag(cam_tag_in),
		.tags_in(cam_tags_in),
		.hits(cam_hits)
	);

	always_comb begin
		next_map_table = branch_incorrect? map_check_point : map_table;
		if(~branch_incorrect) begin
			// Commit Stage first
			for (int i = 0; i < `NUM_GEN_REG; i += 1) begin
				next_map_table[i].phys_tag[$clog2(`NUM_PHYS_REG)] |= cam_hits[i];
			end
		end
		if (enable && ~branch_incorrect) begin
			// Dispatch Stage second
			next_map_table[reg_dest] = free_reg;
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
			map_table <= next_map_table;
		end
	end

endmodule // Map_Table
