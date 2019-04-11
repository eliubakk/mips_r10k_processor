`include "../../sys_defs.vh"

module inst_cache(
	input clock,
	input reset,

	input [3:0] Imem2proc_response,
	input [63:0] mem2proc_data,
	input [3:0] mem2proc_tag,

	input [63:0] proc2Icache_addr,

	output logic [1:0] proc2Imem_command,
	output logic [63:0] proc2Imem_addr,

	output logic [63:0] Icache_data_out, // value is memory[proc2Icache_addr]
	output logic Icache_valid_out // when this is high
);

	// internal data
	logic miss_valid_rd;
 	logic [(`NUM_SET_BITS - 1):0] miss_idx_rd;
 	logic [(`NUM_TAG_BITS - 1):0] miss_tag_rd;
  	logic miss_valid_wr;
  	logic [(`NUM_SET_BITS - 1):0] miss_idx_wr;
  	logic [(`NUM_TAG_BITS - 1):0] miss_tag_wr;

	wire wr1_en;
	wire [(`NUM_SET_BITS - 1):0] wr1_idx;
	wire [(`NUM_TAG_BITS - 1):0] wr1_tag;
	wire [63:0] wr1_data;

	wire rd1_en;
	wire [(`NUM_SET_BITS - 1):0] rd1_idx;
	wire [(`NUM_TAG_BITS - 1):0] rd1_tag;

	wire [63:0] rd1_data;
	wire rd1_valid;

	// modules
	cachemem memory(
		.clock(clock),
		.reset(reset),

		.wr1_en(wr1_en),
		.wr1_idx(wr1_idx),
		.wr1_tag(wr1_tag),
		.wr1_data(wr1_data),
		.wr1_dirty(1'b0),

		.rd1_en(rd1_en),
		.rd1_idx(rd1_idx),
		.rd1_tag(rd1_tag),

		.victim_valid(),
		.victim(),
		.vic_idx(),

		.miss_valid_rd(miss_valid_rd),
		.miss_idx_rd(miss_idx_rd),
		.miss_tag_rd(miss_tag_rd),

		.miss_valid_wr(miss_valid_wr),
		.miss_idx_wr(miss_idx_wr),
		.miss_tag_wr(miss_tag_wr),

		.rd1_data(rd1_data),
		.rd1_valid(rd1_valid)
	);

	icache controller(
		.clock(clock),
		.reset(reset),

		//inputs
		.proc2Icache_addr(proc2Icache_addr),

		.Imem2proc_response(Imem2proc_response),
		.Imem2proc_data(mem2proc_data),
		.Imem2proc_tag(mem2proc_tag),

		.cache_miss_valid_rd(miss_valid_rd),
		.cache_miss_idx_rd(miss_idx_rd),
		.cache_miss_tag_rd(miss_tag_rd),
		.cache_miss_valid_wr(miss_valid_wr),
		.cache_miss_idx_wr(miss_idx_wr),
		.cache_miss_tag_wr(miss_tag_wr),
		.cache_rd_data(rd1_data),
		.cache_rd_valid(rd1_valid),

		//outputs
		.Icache_data_out(Icache_data_out),
		.Icache_valid_out(Icache_valid_out),

		.proc2Imem_command(proc2Imem_command),
		.proc2Imem_addr(proc2Imem_addr),

		.cache_wr_en(wr1_en),
		.cache_wr_idx(wr1_idx),
		.cache_wr_tag(wr1_tag),
		.cache_wr_data(wr1_data),
		.cache_rd_en(rd1_en),
		.cache_rd_idx(rd1_idx),
		.cache_rd_tag(rd1_tag)
	);

endmodule
