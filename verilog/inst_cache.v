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
	wire wr1_en;
	wire [(`NUM_SET_BITS - 1):0] wr1_idx;
	wire [(`NUM_TAG_BITS - 1):0] wr1_tag;

	wire rd1_en = 1'b1;
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
		.wr1_data(mem2proc_data),
		.wr1_dirty(1'b0),

		.rd1_en(rd1_en),
		.rd1_idx(rd1_idx),
		.rd1_tag(rd1_tag),

		.victim_valid(),
		.victim(),
		.vic_idx(),

		.miss_valid_rd(),
		.miss_idx_rd(),
		.miss_tag_rd(),

		.miss_valid_wr(),
		.miss_idx_wr(),
		.miss_tag_wr(),

		.rd1_data(rd1_data),
		.rd1_valid(rd1_valid)
	);

	icache controller(
		.clock(clock),
		.reset(reset),

		.Imem2proc_response(Imem2proc_response),
		.Imem2proc_data(mem2proc_data),
		.Imem2proc_tag(mem2proc_tag),

		.proc2Icache_addr(proc2Icache_addr),
		.cachemem_data(rd1_data),
		.cachemem_valid(rd1_valid),

		.proc2Imem_command(proc2Imem_command),
		.proc2Imem_addr(proc2Imem_addr),

		.Icache_data_out(Icache_data_out),
		.Icache_valid_out(Icache_valid_out),

		.current_index(rd1_idx),
		.current_tag(rd1_tag),
		.last_index(wr1_idx),
		.last_tag(wr1_tag),
		.data_write_enable(wr1_en)
	);

	// assign statements


	// combinational logic
	always_comb begin
	end

	// sequential logic
	always_ff @(posedge clock) begin
	end

endmodule
