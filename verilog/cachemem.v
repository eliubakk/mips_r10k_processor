// cachemem32x64

`include "../../sys_defs.vh"
`define DEBUG

module cachemem(
        input clock, reset, wr1_en, rd1_en,
        input  [(`NUM_SET_BITS - 1):0] wr1_idx, rd1_idx,
        input  [(`NUM_TAG_BITS - 1):0] wr1_tag, rd1_tag,
        input [63:0] wr1_data, 

	`ifdef DEBUG
		output CACHE_SET_T [(`NUM_SETS - 1):0] sets_out,
		output logic [(`NUM_SETS - 1):0] [(`NUM_WAYS - 2):0] bst_out,
	`endif

	// victim cache outputs
	output logic victim_valid,
	output CACHE_LINE_T victim,
	output logic [(`NUM_SET_BITS - 1):0] vic_idx,

	output logic miss_valid_rd,
	output logic [(`NUM_SET_BITS - 1):0] miss_idx_rd,
	output logic [(`NUM_TAG_BITS - 1):0] miss_tag_rd,

	output logic miss_valid_wr,
	output logic [(`NUM_SET_BITS - 1):0] miss_idx_wr,
	output logic [(`NUM_TAG_BITS - 1):0] miss_tag_wr,

        output logic [63:0] rd1_data,
        output logic rd1_valid 
      );

	// given addr, find set index
	// cam through the tags in that set for match
	// output data at index of match

	// internal data
	CACHE_SET_T [(`NUM_SETS - 1):0] sets;
	CACHE_SET_T [(`NUM_SETS - 1):0] sets_next;

	logic [(`NUM_SETS - 1):0] [(`NUM_WAYS - 2):0] bst; 
	logic [(`NUM_SETS - 1):0] [(`NUM_WAYS - 2):0] bst_next;

	logic [($clog2(`NUM_WAYS - 1) - 1):0] next_bst_idx;
	logic [($clog2(`NUM_WAYS) - 1):0] acc; 

	logic [(`NUM_WAYS - 1):0] [(`NUM_TAG_BITS - 1):0] tag_table_in_read;
	logic [(`NUM_WAYS - 1):0] [(`NUM_TAG_BITS - 1):0] tag_table_in_write;
	logic [(`NUM_WAYS - 1):0] tag_hits_read;
	logic [(`NUM_WAYS - 1):0] tag_hits_write;
	logic [(`NUM_WAYS - 1):0] tag_hits_write_found;
	logic [(`NUM_WAYS - 1):0] has_invalid;
	logic [(`NUM_WAYS - 1):0] invalid_sel;
	logic [(`NUM_WAYS - 1):0] enc_in_write;
	logic [$clog2(`NUM_WAYS) - 1:0] tag_idx_read;
	logic [$clog2(`NUM_WAYS) - 1:0] tag_idx_write;
	logic [$clog2(`NUM_WAYS) - 1:0] tag_idx_write_out;
	logic [$clog2(`NUM_WAYS) - 1:0] temp_idx;

	// modules
	CAM #(
		.LENGTH(`NUM_WAYS),
		.WIDTH(1),
		.NUM_TAGS(1),
		.TAG_SIZE(`NUM_TAG_BITS))
	read_cam(
		.enable(1'b1),
		.tags(rd1_tag),
		.table_in(tag_table_in_read),
		.hits(tag_hits_read));

	encoder #(.WIDTH(`NUM_WAYS))
	read_enc(
		.in(tag_hits_read),
		.out(tag_idx_read));

	psel_generic #(
			.WIDTH(`NUM_WAYS),
			.NUM_REQS(1))
	idx_psel(
		.req(has_invalid),
		.en(wr1_en),
		.gnt(invalid_sel));

	CAM #(
		.LENGTH(`NUM_WAYS),
		.WIDTH(1),
		.NUM_TAGS(1),
		.TAG_SIZE(`NUM_TAG_BITS))
	write_cam(
		.enable(wr1_en),
		.tags(wr1_tag),
		.table_in(tag_table_in_write),
		.hits(tag_hits_write));

	encoder #(.WIDTH(`NUM_WAYS)) 
	write_enc(
		.in(enc_in_write),
		.out(tag_idx_write_out));

	// assign statements
	assign sets_out = sets;
	assign bst_out = bst;
	assign rd1_data = sets[rd1_idx].cache_lines[tag_idx_read].data;
	assign rd1_valid = (|tag_hits_read) ? sets[rd1_idx].cache_lines[tag_idx_read].valid : 0;

	assign vic_valid = wr1_en & (~|tag_hits_write_found) & sets[wr1_idx].cache_lines[tag_idx_write].valid;
	assign victim = sets[wr1_idx].cache_lines[tag_idx_write];

	assign miss_idx_rd = rd1_idx;
	assign miss_tag_rd = rd1_tag;

	assign miss_idx_wr = wr1_idx;
	assign miss_tag_wr = wr1_tag;

	for (genvar i = 0; i < `NUM_WAYS; ++i) begin
		assign has_invalid[i] = ~sets[wr1_idx].cache_lines[i].valid;
		assign tag_table_in_read[i] = sets[rd1_idx].cache_lines[i].tag;
		assign tag_table_in_write[i] = sets[wr1_idx].cache_lines[i].tag;
	end

	always_comb begin
		sets_next = sets;
		bst_next = bst;
		enc_in_write = tag_hits_write;
		tag_idx_write = tag_idx_write_out;
		tag_hits_write_found = tag_hits_write & ~has_invalid;
		miss_valid_rd = 0;
		miss_valid_wr = 0;

		if (wr1_en) begin
			if (|tag_hits_write_found) begin
				enc_in_write = tag_hits_write;
				next_bst_idx = 0;
				acc = `NUM_WAYS / 2;
				temp_idx = `NUM_WAYS / 2;

				for (int i = 0; i < $clog2(`NUM_WAYS); ++i) begin
					bst_next[wr1_idx][next_bst_idx] = ~bst_next[wr1_idx][next_bst_idx];
					if (tag_idx_write >= temp_idx) begin
						next_bst_idx = (2 * next_bst_idx) + 2;
						temp_idx += (acc / 2);
					end else begin
						next_bst_idx = (2 * next_bst_idx) + 1;
						temp_idx -= (acc / 2);
					end
					acc /= 2;
				end
			end else begin
				miss_valid_wr = 1;
				// find positoin based on bst
				tag_idx_write = 0;
				next_bst_idx = 0;
				acc = `NUM_WAYS / 2;

				for (int i = 0; i < $clog2(`NUM_WAYS); ++i) begin
					bst_next[wr1_idx][next_bst_idx] = ~bst_next[wr1_idx][next_bst_idx];
					if (~bst_next[wr1_idx][next_bst_idx]) begin
						tag_idx_write += acc;
						next_bst_idx = (2 * next_bst_idx) + 2;
					end else begin
						next_bst_idx = (2 * next_bst_idx) + 1;
					end
					acc /= 2;
				end
			end
			sets_next[wr1_idx].cache_lines[tag_idx_write].data = wr1_data;
			sets_next[wr1_idx].cache_lines[tag_idx_write].valid = 1;
			sets_next[wr1_idx].cache_lines[tag_idx_write].tag = wr1_tag;
		end

		if (rd1_en) begin
			if (|tag_hits_read) begin
				next_bst_idx = 0;
				acc = `NUM_WAYS / 2;
				temp_idx = `NUM_WAYS / 2;

				for (int i = 0; i < $clog2(`NUM_WAYS); ++i) begin
					bst_next[rd1_idx][next_bst_idx] = ~bst_next[rd1_idx][next_bst_idx];
					if (tag_idx_read >= temp_idx) begin
						next_bst_idx = (2 * next_bst_idx) + 2;
						temp_idx += (acc / 2);
					end else begin
						next_bst_idx = (2 * next_bst_idx) + 1;
					end
					acc /= 2;
				end
			end else begin
				miss_valid_rd = 1;
			end
		end
	end

	always_ff @(posedge clock) begin
		if (reset) begin
			for (int i = 0; i < `NUM_SETS; ++i) begin
				for (int j = 0; j < `NUM_WAYS; ++j) begin
					sets[i].cache_lines[j].data <= `SD 0;
					sets[i].cache_lines[j].tag <= `SD 0;
					sets[i].cache_lines[j].valid <= `SD 0;
				end
				bst[i] <= `SD 0;
			end
		end else begin
			sets <= `SD sets_next;
			bst <= `SD bst_next;
		end
	end


endmodule
