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

        output logic [63:0] rd1_data,
        output logic rd1_valid
        
      );

	// given addr, find set index
	// cam through the tags in that set for match
	// output data at index of match

	// internal data
	CACHE_SET_T [(`NUM_SETS - 1):0] sets;

	logic [(`NUM_TAG_BITS - 1):0] tag_in;
	logic [(`NUM_WAYS - 1):0] [(`NUM_TAG_BITS - 1):0] tag_table_in;
	logic [(`NUM_WAYS - 1):0] tag_hits;
	logic [(`NUM_WAYS - 1):0] enc_in;
	logic full;
	logic found;
	logic [(`NUM_TAG_BITS - 1):0] tag_idx;

	logic [(`NUM_WAYS - 1):0] req_in;
	logic p_en;
	logic [(`NUM_WAYS - 1):0] gnt_out;
	

	// assign statements
	`ifdef DEBUG
	for (genvar ig = 0; ig < `NUM_SETS; ++ig) begin
		for (genvar jg = 0; jg < `NUM_WAYS; ++jg) begin
			assign data_out[(`NUM_WAYS * ig) + jg] = sets[ig].cache_lines[jg].data;
			assign tags_out[(`NUM_WAYS * ig) + jg] = sets[ig].cache_lines[jg].tag;
			assign valids_out[(`NUM_WAYS * ig) + jg] = sets[ig].cache_lines[jg].valid;
		end
	end	
	`endif
	assign rd1_data = sets[rd1_idx].cache_lines[tag_idx].data;
	assign rd1_valid = sets[rd1_idx].cache_lines[tag_idx].valid;
	assign tag_in = wr1_en ? wr1_tag : rd1_tag;
	assign p_en = wr1_en & ~(|tag_hits) & ~full;

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

	psel_generic #(
		.WIDTH(`NUM_WAYS),
		.NUM_REQS(1))
	psel(
		.req(req_in),
		.en(p_en),
		.gnt(gnt_out));

	encoder #(.WIDTH(`NUM_WAYS)) enc(
				.in(enc_in),
				.out(tag_idx));
	
	// combinational logic
	always_comb begin
		if (wr1_en) begin
			full = 1;
			for (int i = 0; i < `NUM_WAYS; ++i) begin
				full &= sets[wr1_idx].cache_lines[i].valid;
				tag_table_in[i] = sets[wr1_idx].cache_lines[i].tag;
			end
			if (|tag_hits == 1) begin
				// if the tag was found
				enc_in = tag_hits;
			end else if (full) begin
				
			end else begin
				// insert into first available position
				for (int i = 0; i < `NUM_WAYS; ++i) begin
					req_in[`NUM_WAYS - i - 1] = ~sets[wr1_idx].cache_lines[i].valid;
				end
				for (int i = 0; i < `NUM_WAYS; ++i) begin
					enc_in[`NUM_WAYS - i - 1] = gnt_out[i];
				end
			end
		end else begin
			enc_in = tag_hits;
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

endmodule
