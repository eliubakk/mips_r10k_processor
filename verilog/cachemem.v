// cachemem32x64

`include "../../sys_defs.vh"
`define DEBUG

module cache(
        input clock, reset, wr1_en,
        input  [(`NUM_SET_BITS - 1):0] wr1_idx, rd1_idx,
        input  [(`NUM_TAG_BITS - 1):0] wr1_tag, rd1_tag,
        input [63:0] wr1_data, 

	`ifdef DEBUG

		output logic [31:0] 	[63:0] 			data_out,
		output logic [31:0]  	[(`NUM_TAG_BITS - 1):0]	tags_out, 
		output logic [31:0]        			valids_out, 
	`endif

        output [63:0] rd1_data,
        output rd1_valid
        
      );

	// given addr, find set index
	// cam through the tags in that set for match
	// output data at index of match


	/*
	logic [31:0] 	[63:0] 			data;
	logic [31:0]  	[(`NUM_TAG_BITS - 1):0]	tags; 
	logic [31:0]        			valids;
	*/

	// internal data
	CACHE_SET_T [(`NUM_SETS - 1):0] sets;

	logic [(`NUM_TAG_BITS - 1):0] tag_in;
	logic [(`NUM_WAYS - 1):0] [(`NUM_TAG_BITS - 1):0] tag_table_in;
	logic [(`NUM_WAYS - 1):0] tag_hits;
	logic [(`NUM_TAG_BITS - 1):0] tag_idx;

	// assign statements
	`ifdef DEBUG
		
	`endif
	assign rd1_data = sets[rd1_idx].cache_lines[tag_idx].data;
	assign rd1_valid = sets[rd1_idx].cache_lines[tag_idx].valid;
	assign tag_in = wr1_en ? wr1_tag : rd1_tag;

	// modules

	CAM #(
		.LENGTH(`NUM_WAYS),
		.WIDTH(`NUM_TAG_BITS),
		.NUM_TAGS(1),
		.TAG_SIZE(`NUM_TAG_BITS))
	cam(
		.enable(1),
		.tags(tag_in),
		.table_in(tag_table_in),
		.hits(tag_hits));

	encoder #(.WIDTH(`NUM_TAG_BITS)) enc(
				.in(tag_hits),
				.out(tag_idx));
	
	// combinational logic
	always_comb begin
		if (wr1_en) begin
			for (int i = 0; i < `NUM_WAYS; ++i) begin
				tag_table_in[i] = sets[wr1_idx].cache_lines[i].tag;
			end
		end else begin
			for (int i = 0; i < `NUM_WAYS; ++i) begin
				tag_table_in[i] = sets[rd1_idx].cache_lines[i].tag;
			end
		end
	end

	// sequential logic
	always_ff @(posedge clock) begin
		if (reset) begin
			for (int i = 0; i < `NUM_SETS; ++i) begin
				for (int j = 0; j < `NUM_WAYS; ++j) begin
					sets[i].cache_lines[j].tag <= `SD 0;
					sets[i].cache_lines[j].valid <= `SD 0;
				end
			end
		end else if (wr1_en) begin
			sets[wr1_idx].cache_lines[tag_idx].data <= `SD wr1_data;
			sets[wr1_idx].cache_lines[tag_idx].tag <= `SD wr1_tag;
			sets[wr1_idx].cache_lines[tag_idx].valid <= `SD 1;
		end
	end

	/*
	logic [`NUM_SETS-1:0]				enable_bus;
	logic [31:0] tag_bus;
	// internal wires

	 logic [31:0] tag_hits;
	 logic [4:0] tag_idx;

	// assign statements

	assign rd1_data = data[tag_idx];
	assign rd1_valid = valids[tag_idx];
	
	`ifdef DEBUG
		assign data_out = data;
		assign tags_out = tags;
		assign valids_out = valids;
	`endif

	encoder #(
		.WIDTH(32)
	)
	enc (
		.in(tag_bus),
		.out(tag_idx)
	);


	CAM #(
		.LENGTH(32),
		.WIDTH(`NUM_TAG_BITS),
		.NUM_TAGS(1),
		.TAG_SIZE(`NUM_TAG_BITS)
	)
	cam (
		.enable(1),
		.tags(wr1_en ? wr1_tag : rd1_tag),
		.table_in(tags),
		.hits(tag_hits)
	);

	// combinational logic
	 always_comb begin
		for (int i = 0; i < 32; ++i) begin
			if (wr1_en) begin
				tag_bus[i] = tag_hits[i] & (wr1_idx*`NUM_WAYS <= i) & (i < ((wr1_idx + 1)*`NUM_WAYS));
			end else begin
				tag_bus[i] = tag_hits[i] & (rd1_idx*`NUM_WAYS <= i) & (i < ((rd1_idx + 1)*`NUM_WAYS));
			end
		end
	 end

	// sequential logic
	always_ff @(posedge clock) begin
		if (reset) begin
			valids <= `SD 31'b0;
			for (int i = 0; i < 32; ++i) begin
				tags[i] <= `SD 0;
			end
		end else if (wr1_en) begin
			valids[tag_idx] <= `SD 1;
			data[tag_idx] <= `SD wr1_data;
			tags[tag_idx] <= `SD wr1_tag;
		end
	end
	*/
endmodule
