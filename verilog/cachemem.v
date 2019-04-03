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
	logic [`NUM_SETS-1:0] [(`NUM_TAG_BITS - 1):0] tags_bus;
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
		.WIDTH(`NUM_TAG_BITS)
	)
	enc (
		.in(tag_hits),
		.out(tag_idx)
	);

	CAM #(
		.LENGTH(`NUM_WAYS),
		.WIDTH(`NUM_TAG_BITS),
		.NUM_TAGS(1),
		.TAG_SIZE(`NUM_TAG_BITS)
	)
	cam [`NUM_SETS-1:0] (
		.enable(enable_bus),
		.tags(wr1_en? wr1_tag : rd1_tag),
		.table_in(tags_bus),
		.hits(tag_hits)
	);

	// combinational logic
	 always_comb begin
		for (int i = 0; i < `NUM_SETS; ++i) begin
			enable_bus[i] = (rd1_idx == i) | (wr1_en & wr1_idx == i);
			tags_bus[i] = tags[(i*`NUM_WAYS)+:((i + 1)*(`NUM_WAYS))];
		end
	 end

	// sequential logic
	always_ff @(posedge clock) begin
		if (reset) begin
			valids <= `SD 31'b0;
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

	/*
  assign rd1_data = data[rd1_idx];
  assign rd1_valid = valids[rd1_idx] && (tags[rd1_idx] == rd1_tag);

  always_ff @(posedge clock) begin
    if(reset)
      valids <= `SD 31'b0;
    else if(wr1_en) 
      valids[wr1_idx] <= `SD 1;
  end
  
  always_ff @(posedge clock) begin
    if(wr1_en) begin
      data[wr1_idx] <= `SD wr1_data;
      tags[wr1_idx] <= `SD wr1_tag;
    end
  end
	*/

endmodule
