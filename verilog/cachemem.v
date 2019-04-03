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


	logic [31:0] 	[63:0] 			data;
	logic [31:0]  	[(`NUM_TAG_BITS - 1):0]	tags; 
	logic [31:0]        			valids;
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
		end
	end

	always_ff @(posedge clock) begin
		if (wr1_en) begin
			data[tag_idx] <= `SD wr1_data;
			tags[tag_idx] <= `SD wr1_tag;
		end
	end

endmodule
