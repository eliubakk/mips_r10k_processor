`include "../../sys_defs.vh"
`define DEBUG

`define index_t ($clog2(`OBQ_SIZE) - 1)

// in this module, we assume the oldest branch history table
// is at the lowest index (i.e. index 0)

module OBQ(
	// inputs
	input clock,			// clock signal
	input reset,			// reset signal
	input write_en,			// allow new branch history to be written at end
	input OBQ_ROW_T bh_row,		// branch history row from pipeline
	input clear_en,			// allow branch history rows of a certain index be removed
	input [`index_t:0] index,	// the index/tag to clear rows
	input shift_en,			// allow old branch history entries to be removed
	input [`index_t:0] shift_index,	// the index of which branch to be shifted out

	// outputs
	`ifdef DEBUG
	output OBQ_ROW_T [`OBQ_SIZE-1:0] obq_out,
	output [`index_t:0] head_out,
	output [`index_t:0] tail_out,
	`endif

	output [`index_t:0] row_tag,	// the index/tag for the newly inserted branch history entry
	output bh_pred_valid,		// whether the currently output branch history entry is valid
	output OBQ_ROW_T bh_pred	// predicted branch history path
);

	// internal data
	OBQ_ROW_T [`OBQ_SIZE - 1:0] obq;
	OBQ_ROW_T [`OBQ_SIZE - 1:0] obq_next;

	logic [`index_t:0] tail;
	logic [`index_t:0] tail_next;

	logic [`index_t:0] head;
	logic [`index_t:0] head_next;

	logic [`index_t:0] _row_tag;

	// assign statements
	assign obq_out = obq;
	assign tail_out = tail;
	assign head_out = head;

	// assign row_tag = tail;
	assign row_tag = _row_tag;
	assign bh_pred_valid = (head != tail);
	assign bh_pred = obq[tail - 1'b1];

	// combinational logic
	always_comb begin

		// default case
		obq_next = obq;
		tail_next = tail;
		head_next = head;
		_row_tag = tail;

		if (clear_en) begin
			if (head_next <= tail_next) begin
				if ((head <= index) & (index < tail)) begin
					tail_next = index;
				end
			end else begin
				if (~((index < head_next) & (index >= tail_next))) begin
					tail_next = index;
				end
			end
		end

		if (shift_en) begin
			if (head_next <= tail_next) begin
				if ((shift_index >= head_next) & (shift_index < tail_next)) begin
					head_next = shift_index + 1;
				end
			end else begin
				if (~((shift_index < head_next) & (shift_index >= tail_next))) begin
					head_next = shift_index + 1;
				end
			end
		end

		if (write_en) begin
			obq_next[tail_next] = bh_row;
			_row_tag = tail_next;
			++tail_next;
			if (tail_next == head_next) begin
				++head_next;
			end
		end
	end

	// sequential logic
	always_ff @(posedge clock) begin
		if (reset) begin
			for (int i = 0; i < `OBQ_SIZE; ++i) begin
				obq[i].branch_history <= `SD 0;
			end
			tail <= `SD 0;
			head <= `SD 0;
		end else begin
			obq <= `SD obq_next;
			tail <= `SD tail_next;
			head <= `SD head_next;
		end
	end
endmodule // OBQ
