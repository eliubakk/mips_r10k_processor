`include "../../sys_defs.vh"

`define SQ_SIZE 16
`define index_t ($clog2(`SQ_SIZE) - 1)

module SQ(
	input clock,
	input reset,

	// read signals
	input rd_en, // load queue wants to read data at an address in SQ
	input addr_rd, // the address the load queue wants to read
	input ld_pos, // the tail of the sq at the time the load was dispatched

	// dispatch signals
	input dispatch_en, // 1 when a store is getting dispatched
	input dispatch_addr, // addr of the store
	input dispatch_addr_ready, // if the store address is ready (direct store vs indirect store)
	input dispatch_data, // data to store 
	input dispatch_data_ready, // if the data of store is ready (direct store vs indirect store)
	
	// execute signals
	input ex_en, // 1 when a store is being executed
	input ex_index, // the index/tag of the store that is being executed
	input ex_addr, // the address calculated during execute
	input ex_addr_en, // 1 if want to use ex_addr for the address (direct vs indirect store)
	input ex_data, // the data calculated during execute
	input ex_data_en, // 1 if want to use ex_data for the data (direct vs indirect store)

	// retire signals
	input rt_en, // 1 when a store is at retire
	input rt_index, // the index/tag of the store that is being retired

	// read outputs
	output logic data_rd, // the data that is being read by the load
	output logic rd_valid, // whether the data that is being read is ready

	// general outputs
	output logic tail_out,
	output logic full
);

	// internal data

	logic [31:0] [`SQ_SIZE - 1:0] addr;
	logic [31:0] [`SQ_SIZE - 1:0] addr_next;

	logic [`SQ_SIZE - 1:0] addr_ready;
	logic [`SQ_SIZE - 1:0] addr_ready_next;

	logic [63:0] [`SQ_SIZE - 1:0] data;
	logic [63:0] [`SQ_SIZE - 1:0] data_next;

	logic [`SQ_SIZE - 1:0] data_ready;
	logic [`SQ_SIZE - 1:0] data_ready_next;

	logic [`index_t:0] head;
	logic [`index_t:0] head_next;

	logic [`index_t:0] tail;
	logic [`index_t:0] tail_next;

	logic addr_rd_ready;
	logic [`SQ_SIZE - 1:0] addr_rd_hits;

	CAM #(	.LENGTH(`SQ_SIZE),
		.WIDTH(1),
		.NUM_TAGS(1),
		.TAG_SIZE(32))
	cam(
		.enable(rd_en),
		.tags(addr_rd),
		.table_in(addr_next),
		.hits(addr_rd_hits)
	);

	// assigns

	always_comb begin
		// default case
		addr_next = addr;
		data_next = data;
		head_next = head;
		tail_next = tail;

		// retire signals
		if (rt_en) begin
			head_next = rt_index;
		end

		// execute signals
		if (ex_en) begin
			if (ex_addr_en) begin
				addr_next[ex_index] = ex_addr;
				addr_ready_next[ex_index] = 1;
			end
			if (ex_data_en) begin
				data_next[ex_index] = ex_data;
				data_ready_next[ex_index] = 1;
			end
		end

		// dispatch signals
		if (dispatch_en) begin
			// determine if dispatch can be successful
			if (tail_next + 1'b1 != head_next) begin
				addr_next[tail_next] = dispatch_addr;
				addr_ready_next[tail_next] = dispatch_addr_ready;
				data_next[tail_next] = dispatch_data;
				data_ready_next[tail_next] = dispatch_data_ready;
				++tail_next;
			end
		end

		// read signals
		if (rd_en) begin
			if (head_next <= tail_next) begin
				addr_rd_ready = &addr_rd_hits[head_next:ld_pos];
			end else begin
				addr_rd_ready = &addr_rd_hits[head_next:`SQ_SIZE - 1] & 
						&addr_rd_hits[0:tail_next];
			end
			
		end
	end

	always_ff @(posedge clock) begin
		if (reset) begin
			for (int i = 0; i < `SQ_SIZE; ++i) begin
				addr[i] <= 0;
				addr_ready[i] <= 0;
				data[i] <= 0;
				data_ready[i] <= 0;
			end
			head <= 0;
			tail <= 0;
		end else begin
			addr <= addr_next;
			addr_ready <= addr_ready_next;
			data <= data_next;
			data_ready <= data_ready_next;
			head <= head_next;
			tail <= tail_next;
		end
	end

endmodule
