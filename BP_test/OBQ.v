//`include "sys_defs.vh"
`define DEBUG_OUT

`define index_t ($clog2(`OBQ_SIZE))

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
	input shift_en,
	input [`index_t:0] shift_index,

	// outputs
	`ifdef DEBUG_OUT
	output OBQ_ROW_T [`OBQ_SIZE-1:0] obq_out,
	output [`index_t:0] tail_out,
	`endif

	output [`index_t:0] row_tag, // Index from OBQ
	output bh_pred_valid,
	output OBQ_ROW_T bh_pred // predicted branch history path
);

	// internal data
	OBQ_ROW_T [`OBQ_SIZE-1:0] obq;
	OBQ_ROW_T [`OBQ_SIZE-1:0] obq_next;

	logic [`index_t:0] tail;
	logic [`index_t:0] tail_next;

	logic [`index_t:0] row_tag_index;
	logic [`index_t:0] row_tag_next;

	// assign statements
	`ifdef DEBUG_OUT
	assign obq_out = obq;
	assign tail_out = tail;
	`endif
	assign bh_pred_valid = (tail > 0);
	assign bh_pred = obq[tail-1];
	assign row_tag = row_tag_index; // tail - 1;

	// should refactor, this has a lot of if statements to avoid latches
	// combinational next state logic
	always_comb begin

		obq_next = obq;
		tail_next = tail;
		row_tag_next = row_tag;

		if (write_en & clear_en & shift_en) begin

			// determine tail_next
			if ((shift_index < tail) & (index < tail)) begin
				if (shift_index == index) begin
					tail_next = 1;
				end else begin
					tail_next = index - shift_index;
				end
			end else if (shift_index < tail) begin
				tail_next = tail - shift_index;
			end else if (index < tail) begin
				tail_next = index + 1;
			end else begin
				tail_next = tail + 1;
			end

			// shift all the entries over
			if (shift_index < tail) begin
				for (int i = 0; i < `OBQ_SIZE; ++i) begin
					if (i - shift_index > 0) begin
						obq_next[i - shift_index - 1] = obq[i];
					end
				end
			end
			// we want to clear everything and then
			// insert the new branch history table

			// clear the entries just by updating the tail ptr

			if (shift_index < tail & index < tail) begin
				obq_next[index - 2 - shift_index].branch_history[`BH_SIZE - 1] = ~obq_next[index - 2 - shift_index].branch_history[`BH_SIZE - 1];
			end else if (index < tail) begin
				obq_next[index - 1].branch_history[`BH_SIZE - 1] = ~obq_next[index - 1].branch_history[`BH_SIZE - 1];
			end

			/*
			if (index != 0 & (index < tail)) begin
				// if we are clearing the table, this implies
				// that our prediction was incorrect and
				// therefore we need to update the last bit
				// of the most recent valid branch history
				obq_next[index - 1 - shift_index].branch_history[`BH_SIZE-1] = ~obq_next[index - 1 - shift_index].branch_history[`BH_SIZE-1];
			end
			*/

			// insert the new branch history
			if (tail_next == 0) begin
				obq_next[0] = bh_row;
				row_tag_next = 0;
			end else begin
				obq_next[tail_next - 1] = bh_row;
				row_tag_next = tail_next - 1;
			end
		end else if (write_en & clear_en) begin
			// clear everything and place new branch history at
			// new end
			if (index < tail) begin
				tail_next = index + 1;
				obq_next = obq;
				obq_next[index] = bh_row;
				row_tag_next = index;
				if (index > 0) begin
					// if we are clearing the table, this implies
					// that our prediction was incorrect and
					// therefore we need to update the last bit
					// of the most recent valid branch history
					obq_next[index - 1].branch_history[`BH_SIZE-1] = ~obq_next[index - 1].branch_history[`BH_SIZE-1];
				end
			end else begin
				obq_next = obq;
				obq_next[tail] = bh_row;
				tail_next = tail + 1;
				row_tag_next = tail;
			end
		end else if (write_en & shift_en) begin
			// shift and append at end

			if (shift_index < tail) begin
			
				// shift all the entries over
				for (int i = 0; i < `OBQ_SIZE; ++i) begin
					if (i - shift_index > 0) begin
						obq_next[i - shift_index - 1] = obq[i];
					end
				end
				tail_next = tail - shift_index;
	
				// insert new entry
				obq_next[tail - shift_index - 1] = bh_row;
				row_tag_next = tail - shift_index - 1;
			end else if (tail < `OBQ_SIZE) begin
				obq_next = obq;
				obq_next[tail] = bh_row;
				tail_next = tail + 1;
				row_tag_next = tail;
			end else begin
				obq_next = obq;
				tail_next = tail;
				row_tag_next = row_tag_index;
			end
		end else if (clear_en & shift_en) begin
			tail_next = tail;
			obq_next = obq;

			// decide tail_next
			if (shift_index < tail & index < tail) begin
				if (shift_index == index) begin
					tail_next = 0;
				end else begin
					tail_next = index - shift_index - 1;
				end
			end else if (shift_index < tail) begin
				tail_next = tail - shift_index - 1;
			end else if (index < tail) begin
				tail_next = index;
			end else begin
				tail_next = tail;
			end

			// shift all the entries over
			if (shift_index < tail) begin
				for (int i = 0; i < `OBQ_SIZE; ++i) begin
					if (i - shift_index > 0) begin
						obq_next[i - shift_index - 1] = obq[i];
					end
				end
			end

			// clear the entries just by updating the tail ptr
			if (index < tail) begin
				if (index != 0) begin
					// if we are clearing the table, this implies
					// that our prediction was incorrect and
					// therefore we need to update the last bit
					// of the most recent valid branch history
					obq_next[index - shift_index - 2].branch_history[`BH_SIZE-1] = ~obq_next[index - shift_index - 2].branch_history[`BH_SIZE-1];
				end
			end
		end else if (shift_en & ~write_en & ~clear_en) begin
			// shift all the entries over
			if (shift_index < tail) begin
				for (int i = 0; i < `OBQ_SIZE; ++i) begin
					if (i - shift_index > 0) begin
						obq_next[i - shift_index - 1] = obq[i];
					end
				end
				tail_next = tail - shift_index - 1;
			end else begin
				tail_next = tail;
				obq_next = obq;
			end
		end else if (write_en & ~shift_en & ~clear_en) begin
			// write the newest branch history table into the 
			// tail index of the obq
			if (tail < `OBQ_SIZE) begin
				obq_next = obq;
				obq_next[tail] = bh_row;
				tail_next = tail + 1;
				row_tag_next = tail;
			end else begin
				obq_next = obq;
				tail_next = tail;
				row_tag_next = row_tag_index;
			end
		end else if (clear_en & ~shift_en & ~write_en) begin
			if (index < tail) begin
				obq_next = obq;
				obq_next[index - 1].branch_history[`BH_SIZE - 1] = ~obq[index - 1].branch_history[`BH_SIZE - 1];
				tail_next = index;
			end else begin
				obq_next = obq;
				tail_next = tail;
				row_tag_next = row_tag_index;
			end
		end else begin
			obq_next = obq;
			tail_next = tail;
			row_tag_next = row_tag_index;
		end
	end

	// sequential logic
	always_ff @(posedge clock) begin
		if (reset) begin
			for (int i = 0; i < `OBQ_SIZE; ++i) begin
				obq[i].branch_history <= 0; // reset to all not taken
			end
			tail <= 0;
			row_tag_index <= 0;
		end else begin
			obq <= obq_next;
			tail <= tail_next;
			row_tag_index <= row_tag_next;
		end
	end

endmodule // OBQ
