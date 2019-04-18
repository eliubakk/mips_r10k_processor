
`include "../../sys_defs.vh"

module victim_cache(
	// inputs
	clock,
	reset,
	rd_en,
	rd_idx,
	rd_tag,
	wr_en,
	wr_idx,
	wr_tag,

	// outputs
	line_out,
	line_valid,

	fired,
	fired_valid
);

	parameter RD_PORTS = 2;
	parameter WR_PORTS = 2;
	parameter NUM_WAYS = 4;

	// module defines
	`define NUM_SETS 32/NUM_WAYS
	`define NUM_SET_BITS $clog2(`NUM_SETS)
	`define NUM_TAG_BITS $clog2(13 - `NUM_SET_BITS)

	typedef struct packed {
		logic [63:0] data;
		logic [(`NUM_TAG_BITS - 1):0] tag;
		logic valid;
		logic dirty;
	} CACHE_LINE_T;

	// define inputs
	input clock;
	input reset;

	input [(RD_PORTS - 1):0] rd_en;
	input [(RD_PORTS - 1):0] [(`NUM_SET_BITS - 1):0] rd_idx;
	input [(RD_PORTS - 1):0] [(`NUM_TAG_BITS - 1):0] rd_tag;

	input [(WR_PORTS - 1):0] wr_en;
	input CACHE_LINE_T [(WR_PORTS - 1):0] wr_lines;

	// define outputs
	output logic [(RD_PORTS - 1):0] line_valid;
	output CACHE_LINE_T [(RD_PORTS - 1):0] line_out;

	output logic [(WR_PORTS - 1):0] fired_valid;
	output CACHE_LINE_T [(WR_PORTS - 1):0] fired;

	// internal data
	CACHE_LINE_T [3:0] lines, lines_next;
	logic [3:0] valid, valid_next;

	logic full;

	logic [(RD_PORTS - 1):0] [1:0] idx_rd;
	logic [(WR_PORTS - 1):0] [1:0] idx_wr;
	logic [1:0] wr_pos, fire_pos;

	// assign statements
	for (genvar i = 0; i < RD_PORTS; ++i) begin
		assign line_valid[i] = valid[idx_rd[i]] & rd_en[i];
		assign line_out[i] = lines[idx_rd[i]];
	end
	assign full = &line_valid;


	// combinational logic
	always_comb begin
		lines_next = lines;
		valid_next = valid;
		wr_pos = 2'b0;
		fire_pos = 2'b11;

		for (int i = 0; i < WR_PORTS; ++i) begin
			if (wr_en[i]) begin
				for (int j = 3; j >= 0; --j) begin
					lines_next[j] = lines_next[j - 1];
					valid_next[j] = valid_next[j - 1];
				end
				++wr_pos;
				--fire_pos;
			end
		end

		--wr_pos;

		for (int i = 0; i < WR_PORTS; ++i) begin
			if (wr_en[i]) begin
				lines_next[wr_pos] = wr_lines[i];
				valid_next[i] = 1'b1;
				--wr_pos;
				fired[i] = lines[fire_pos];
				fired_valid[i] = lines[fire_pos].valid;
				++fire_pos;
			end
		end
	end

	// sequential logic
	always_ff @(posedge clock) begin
		if (reset) begin
			for (int i = 0; i < 4; ++i) begin
				valid[i] <= `SD 1'b0;
			end
		end else begin
			lines <= `SD lines_next;
			valid <= `SD valid_next;
		end
	end


endmodule
