`include "sys_defs.vh"

`define index_t ($clog2(`OBQ_SIZE) - 1)

// in this module, we assume the oldest branch history table
// is at the lowest index (i.e. index 0)

module OBQ(
	// inputs
	input clock,
	input reset,
	input write_en,
	input OBQ_ROW_T bh_row, // branch history row from pipeline
	input clear_en,
	input [`index_t:0] index,

	// outputs
	`ifdef DEBUG
	output OBQ_ROW_T [`OBQ_SIZE-1:0] obq_out,
	output [`index_t:0] tail_out,
	`endif
	output OBQ_ROW_T bh_pred // predicted branch history path
);

	// internal data
	OBQ_ROW_T [`OBQ_SIZE-1:0] obq;
	OBQ_ROW_T [`OBQ_SIZE-1:0] obq_next;

	logic [`index_t:0] tail;
	logic [`index_t:0] tail_next;

	// assign statements
	`ifdef DEBUG
	assign obq_out = obq;
	assign tail_out = tail;
	`endif

	// combinational next state logic
	always_comb begin
		if (write_en & clear_en) begin
			// we want to clear everything and then
			// insert the new branch history table

			// clear all the entries from counter onwards
			for (int i = index; i < `OBQ_SIZE; ++i) begin
				obq_next[i].branch_history = (`BH_SIZE-1)'d0;
			end

			// insert the new branch history
			tail_next = index + 1;
			obq_next[index] = bh_row;
		end else if (write_en) begin
			// write the newest branch history table into the 
			// tail index of the obq
			if (tail < `OBQ_SIZE) begin
				obq_next[tail] = bh_row;
				tail_next = tail + 1;
			end else begin
				obq_next = obq;
				tail_next = tail;
			end
		end else if (clear_en) begin
			// clear all the entries from counter onwards
			for (int i = index; i < `OBQ_SIZE; ++i) begin
				obq_next[i].branch_history = (`BH_SIZE-1)'d0;
			end
			tail_next = index;
		end else begin
			obq_next = obq;
			tail_next = tail;
		end
	end

	// sequential logic
	always_ff @(posedge clock) begin
		if (reset) begin
			for (int i = 0; i < `OBQ_SIZE; ++i) begin
				obq[i].branch_history <= (`BH_SIZE-1)'d0; // reset to all not taken
			end
			tail <= ($clog2(`BH_SIZE)-1)'d0;
		end else begin
			obq <= obq_next;
			tail <= tail_next;
		end
	end

endmodule // OBQ