// cachemem32x64

`include "../../sys_defs.vh"
`define DEBUG

module cachemem(
        input clock, reset, wr1_en, rd1_en, rd2_en,
        input  [(`NUM_SET_BITS - 1):0] wr1_idx, rd1_idx, rd2_idx,
        input  [(`NUM_TAG_BITS - 1):0] wr1_tag, rd1_tag, rd2_tag,
        input [63:0] wr1_data,
	input wr1_dirty, 

	`ifdef DEBUG
		output CACHE_SET_T [(`NUM_SETS - 1):0] sets_out,
		output logic [(`NUM_SETS - 1):0] [(`NUM_WAYS - 2):0] bst_out,
	`endif

	// victim cache outputs
	output logic victim_valid,
	output CACHE_LINE_T victim,
	output logic [(`NUM_SET_BITS - 1):0] vic_idx,

	output logic miss_valid_rd1, miss_valid_rd2,
	output logic [(`NUM_SET_BITS - 1):0] miss_idx_rd1, miss_idx_rd2,
	output logic [(`NUM_TAG_BITS - 1):0] miss_tag_rd1, miss_tag_rd2,

	output logic miss_valid_wr,
	output logic [(`NUM_SET_BITS - 1):0] miss_idx_wr,
	output logic [(`NUM_TAG_BITS - 1):0] miss_tag_wr,

        output logic [63:0] rd1_data, rd2_data,
        output logic rd1_valid, rd2_valid
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

	logic [(`NUM_WAYS - 1):0][1:0][(`NUM_TAG_BITS - 1):0] tag_table_in_read;
	logic [(`NUM_WAYS - 1):0] [(`NUM_TAG_BITS - 1):0] tag_table_in_write;
	logic [(`NUM_WAYS - 1):0][1:0][1:0] read_cam_hits_out;
	logic [(`NUM_WAYS - 1):0] tag_hits_read1, tag_hits_read2;
	logic [(`NUM_WAYS - 1):0] tag_hits_write;
	logic [(`NUM_WAYS - 1):0] tag_hits_write_found;
	logic [(`NUM_WAYS - 1):0] tag_hits_read1_found, tag_hits_read2_found;
	logic [(`NUM_WAYS - 1):0] has_invalid_write;
	logic [(`NUM_WAYS - 1):0] has_invalid_read1, has_invalid_read2;
	logic [(`NUM_WAYS - 1):0] invalid_sel;
	logic [(`NUM_WAYS - 1):0] enc_in_write;
	logic [(`NUM_WAYS - 1):0] enc_in_read1, enc_in_read2;
	logic [$clog2(`NUM_WAYS) - 1:0] tag_idx_read1, tag_idx_read2;
	logic [$clog2(`NUM_WAYS) - 1:0] tag_idx_write;
	logic [$clog2(`NUM_WAYS) - 1:0] tag_idx_write_out;
	logic [$clog2(`NUM_WAYS) - 1:0] temp_idx;

	// modules
	CAM #(
		.LENGTH(`NUM_WAYS),
		.WIDTH(2),
		.NUM_TAGS(2),
		.TAG_SIZE(`NUM_TAG_BITS))
	read_cam(
		.enable({rd1_en, rd2_en}),
		.tags({rd1_tag, rd2_tag}),
		.table_in(tag_table_in_read),
		.hits(read_cam_hits_out));

	encoder #(.WIDTH(`NUM_WAYS))
	read_enc1(
		.in(tag_hits_read1),
		.out(tag_idx_read1));

	encoder #(.WIDTH(`NUM_WAYS))
	read_enc2(
		.in(tag_hits_read2),
		.out(tag_idx_read2));

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

	assign rd1_data = (rd1_en & wr1_en & ((wr1_idx == rd1_idx) & (wr1_tag == rd1_tag))) ? wr1_data : sets[rd1_idx].cache_lines[tag_idx_read1].data;
	assign rd1_valid = (rd1_en & wr1_en & ((wr1_idx == rd1_idx) & (wr1_tag == rd1_tag))) ? 1'b1 : 
				(|tag_hits_read1) ? sets[rd1_idx].cache_lines[tag_idx_read1].valid : 0;

	assign rd2_data = (rd2_en & wr1_en & ((wr1_idx == rd2_idx) & (wr1_tag == rd2_tag))) ? wr1_data : sets[rd2_idx].cache_lines[tag_idx_read2].data;
	assign rd2_valid = (rd2_en & wr1_en & ((wr1_idx == rd2_idx) & (wr1_tag == rd2_tag))) ? 1'b1 : 
				(|tag_hits_read2) ? sets[rd2_idx].cache_lines[tag_idx_read2].valid : 0;



	assign victim_valid = wr1_en & (~|tag_hits_write_found) & sets[wr1_idx].cache_lines[tag_idx_write].valid;
	assign victim = sets[wr1_idx].cache_lines[tag_idx_write];
	assign vic_idx = wr1_idx;

	assign miss_idx_rd1 = rd1_idx;
	assign miss_tag_rd1 = rd1_tag;
	assign miss_valid_rd1 = (rd1_en) & ~(|tag_hits_read1_found);

	assign miss_idx_rd2 = rd2_idx;
	assign miss_tag_rd2 = rd2_tag;
	assign miss_valid_rd2 = (rd2_en) & ~(|tag_hits_read2_found);

	assign miss_idx_wr = wr1_idx;
	assign miss_tag_wr = wr1_tag;

	for (genvar i = 0; i < `NUM_WAYS; ++i) begin
		assign has_invalid_write[i] = ~sets[wr1_idx].cache_lines[i].valid;
		assign has_invalid_read1[i] = ~sets[rd1_idx].cache_lines[i].valid;
		assign has_invalid_read2[i] = ~sets[rd2_idx].cache_lines[i].valid;
		assign tag_table_in_read[i][1] = sets[rd1_idx].cache_lines[i].tag;
		assign tag_table_in_read[i][0] = sets[rd2_idx].cache_lines[i].tag;
		assign tag_table_in_write[i] = sets[wr1_idx].cache_lines[i].tag;
		assign tag_hits_read1[i] = read_cam_hits_out[i][1][1];
		assign tag_hits_read2[i] = read_cam_hits_out[i][0][0];
	end

	always_comb begin
		sets_next = sets;
		bst_next = bst;
		enc_in_write = tag_hits_write;
		enc_in_read1 = tag_hits_read1;
		tag_idx_write = tag_idx_write_out;
		tag_hits_write_found = tag_hits_write & ~has_invalid_write;
		tag_hits_read1_found = tag_hits_read1 & ~has_invalid_read1;
		tag_hits_read2_found = tag_hits_read2 & ~has_invalid_read2;
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
			sets_next[wr1_idx].cache_lines[tag_idx_write].dirty = wr1_dirty;
			sets_next[wr1_idx].cache_lines[tag_idx_write].data = wr1_data;
			sets_next[wr1_idx].cache_lines[tag_idx_write].valid = 1;
			sets_next[wr1_idx].cache_lines[tag_idx_write].tag = wr1_tag;
		end

		if (rd1_en) begin
			if (|tag_hits_read1_found) begin
				next_bst_idx = 0;
				acc = `NUM_WAYS / 2;
				temp_idx = `NUM_WAYS / 2;

				for (int i = 0; i < $clog2(`NUM_WAYS); ++i) begin
					bst_next[rd1_idx][next_bst_idx] = ~bst_next[rd1_idx][next_bst_idx];
					if (tag_idx_read1 >= temp_idx) begin
						next_bst_idx = (2 * next_bst_idx) + 2;
						temp_idx += (acc / 2);
					end else begin
						next_bst_idx = (2 * next_bst_idx) + 1;
						temp_idx -= (acc / 2);
					end
					acc /= 2;
				end
			end
		end

		if (rd2_en) begin
			if (|tag_hits_read2_found) begin
				next_bst_idx = 0;
				acc = `NUM_WAYS / 2;
				temp_idx = `NUM_WAYS / 2;

				for (int i = 0; i < $clog2(`NUM_WAYS); ++i) begin
					bst_next[rd2_idx][next_bst_idx] = ~bst_next[rd2_idx][next_bst_idx];
					if (tag_idx_read2 >= temp_idx) begin
						next_bst_idx = (2 * next_bst_idx) + 2;
						temp_idx += (acc / 2);
					end else begin
						next_bst_idx = (2 * next_bst_idx) + 1;
						temp_idx -= (acc / 2);
					end
					acc /= 2;
				end
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
					sets[i].cache_lines[j].dirty <= `SD 0;
				end
				bst[i] <= `SD 0;
			end
		end else begin
			sets <= `SD sets_next;
			bst <= `SD bst_next;
		end
	end


endmodule
