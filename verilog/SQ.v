`include "../../sys_defs.vh"
`define DEBUG

module SQ(
	input clock,
	input reset,

	// read signals
	input rd_en, // load queue wants to read data at an address in SQ
	input [31:0] addr_rd, // the address the load queue wants to read
	input SQ_INDEX_T ld_pos, // the tail of the sq at the time the load was dispatched

	// dispatch signals
	input dispatch_en, // 1 when a store is getting dispatched
	input [31:0] dispatch_addr, // addr of the store
	input dispatch_addr_ready, // if the store address is ready (direct store vs indirect store)
	input [63:0] dispatch_data, // data to store 
	input dispatch_data_ready, // if the data of store is ready (direct store vs indirect store)
	
	// execute signals
	input ex_en, // 1 when a store is being executed
	input SQ_INDEX_T ex_index, // the index/tag of the store that is being executed
	input [31:0] ex_addr, // the address calculated during execute
	input ex_addr_en, // 1 if want to use ex_addr for the address (direct vs indirect store)
	input [63:0] ex_data, // the data calculated during execute
	input ex_data_en, // 1 if want to use ex_data for the data (direct vs indirect store)

	// retire signals
	input rt_en, // 1 when a store is at retire
	// input [`index_t:0] rt_index, // the index/tag of the store that is being retired

	`ifdef DEBUG
	output logic [`SQ_SIZE-1:0] [31:0] addr_out,
	output logic [`SQ_SIZE-1:0] addr_ready_out,
	output logic [`SQ_SIZE-1:0] [63:0] data_out,
	output logic [`SQ_SIZE-1:0] data_ready_out,
	output SQ_INDEX_T head_out,
	`endif

	// read outputs
	output logic [63:0] data_rd, // the data that is being read by the load
	output logic rd_valid, // whether the data that is being read is ready

	output logic [63:0] store_head_data,
	output logic [63:0] store_head_addr,
	output logic store_data_stall,

	// general outputs
	output SQ_INDEX_T tail_out, // the index of the store being dispatched
	output logic full
);

	// internal data
	logic [`SQ_SIZE-1:0] [31:0] addr;
	logic [`SQ_SIZE-1:0] [31:0] addr_next;

	logic [`SQ_SIZE-1:0] addr_ready;
	logic [`SQ_SIZE-1:0] addr_ready_next;

	logic [`SQ_SIZE-1:0] [63:0] data;
	logic [`SQ_SIZE-1:0] [63:0] data_next;

	logic [`SQ_SIZE-1:0] data_ready;
	logic [`SQ_SIZE-1:0] data_ready_next;

	SQ_INDEX_T head;
	SQ_INDEX_T head_next;

	SQ_INDEX_T tail;
	SQ_INDEX_T tail_next;

	
	logic addr_rd_ready;

	logic [`SQ_SIZE-1:0] stall_req;

	logic [`SQ_SIZE-1:0] load_req;
	logic [`SQ_SIZE-1:0] load_gnt;
	SQ_INDEX_T data_rd_idx;

	psel_generic #(
		.WIDTH(`SQ_SIZE),
		.NUM_REQS(1)
	)
	psel(
		.req(load_req),
		.en(rd_en),
		.gnt(load_gnt)
	);

	encoder #(
		.WIDTH(`SQ_SIZE)
	)
	enc(
		.in(load_gnt),
		.out(data_rd_idx)
	);

	// assigns
	assign data_rd = data_next[data_rd_idx];
	assign rd_valid = |load_req & !store_data_stall;
	assign tail_out = tail_next;
	assign full = (tail + 1'b1 == head);

	assign addr_out = addr;
	assign addr_ready_out = addr_ready;
	assign data_out = data;
	assign data_ready_out = data_ready;
	assign head_out = head;

	assign store_head_data = data[head];
	assign store_head_addr = addr[head];

	for (genvar i = 0; i < `SQ_SIZE; ++i) begin
	  assign stall_req[i] = ((i < ld_pos) & (head_next <= tail_next ? (head_next <= i & i < tail_next) : (head_next <= i | i < tail_next))) & ~addr_ready_next[i];
	end
	assign store_data_stall = |stall_req;

	// for (genvar i = 0; i < `SQ_SIZE; ++i) begin
	//   assign stall_req[i] = (addr_ready[i]) | ~((i <= ld_pos) & (head <= tail ? (head <= i & i < tail) : (head <= i | i < tail)));
	// end
	// assign store_data_stall = ~(&stall_req);
	
	always_comb begin
		// default case
		addr_next = addr;
		data_next = data;
		head_next = head;
		tail_next = tail;
		addr_ready_next = addr_ready;
		data_ready_next = data_ready;

		// retire signals
		if (rt_en) begin
			addr_ready_next[head_next] = 0;
			data_ready_next[head_next] = 0;
			++head_next;
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

			for (int i = 0; i < `SQ_SIZE; ++i) begin
				load_req[i] = (addr_rd == addr_next[i]) & (addr_ready_next[i]) & (i < ld_pos) & (head_next <= tail_next ? (head_next <= i & i < tail_next) : (head_next <= i | i < tail_next));
			end
		end else begin
			load_req = 0;
		end
	end
  // synopsys sync_set_reset "reset"
	always_ff @(posedge clock) begin
		if (reset) begin
			for (int i = 0; i < `SQ_SIZE; ++i) begin
				addr[i] <= `SD 0;
				addr_ready[i] <= `SD 0;
				data[i] <= `SD 0;
				data_ready[i] <= `SD 0;
			end
			head <= `SD 0;
			tail <= `SD 0;
		end else begin
			addr <= `SD addr_next;
			addr_ready <= `SD addr_ready_next;
			data <= `SD data_next;
			data_ready <= `SD data_ready_next;
			head <= `SD head_next;
			tail <= `SD tail_next;
		end
	end

endmodule
