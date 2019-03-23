//`include "sys_defs.vh"
`define DEBUG

`define index_t ($clog2(`OBQ_SIZE))

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
	output [`index_t:0] tail_out,
	`endif

	output [`index_t:0] row_tag,	// the index/tag for the newly inserted branch history entry
	output bh_pred_valid,		// whether the currently output branch history entry is valid
	output OBQ_ROW_T bh_pred	// predicted branch history path
);

	// internal data
	OBQ_ROW_T [`OBQ_SIZE-1:0] obq;
	OBQ_ROW_T [`OBQ_SIZE-1:0] obq_next;

	logic [`index_t:0] tail;
	logic [`index_t:0] tail_next;

	logic [`index_t:0] row_tag_index;
	logic [`index_t:0] row_tag_next;

	// assign statements
	`ifdef DEBUG
	assign obq_out 		= obq;
	assign tail_out 	= tail;
	`endif

	// bh_pred_valid is valid as long as tail is not at index 0
	assign bh_pred_valid 	= (tail > 0);

	// bh_pred is the most recent prediction entry
	assign bh_pred 		= obq[tail-1];
	// row_tag is the index at which the last branch history was inserted
	assign row_tag 		= row_tag_index; // tail - 1;

	// combinational next state logic
	always_comb begin

		// default values for next state logic
		obq_next = obq;
		tail_next = tail;
		row_tag_next = row_tag;

		if (write_en & clear_en & shift_en) begin

			// determine tail_next
			if ((shift_index < tail) & (index < tail)) begin
				if (shift_index == index) begin
					// if the entry we are shifting out is
					// the same entry we want to clear
					// from, then tail_next should be
					// 1 because a new entry is also being
					// added
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

			// insert the new branch history
			if (tail_next == 0) begin
				obq_next[0] 	= bh_row;
				row_tag_next 	= 0;
			end else begin
				obq_next[tail_next - 1] = bh_row;
				row_tag_next 		= tail_next - 1;
			end
		end else if (write_en & clear_en) begin

			// clear everything and place new branch history at
			// new end
			if (index < tail) begin
				tail_next 	= index + 1;
				obq_next 	= obq;
				obq_next[index] = bh_row;
				row_tag_next 	= index;

				// if we are clearing the table, this implies
				// that our prediction was incorrect and
				// therefore we need to update the last bit
				// of the most recent valid branch history
				obq_next[index - 1].branch_history[`BH_SIZE - 1] = ~obq_next[index - 1].branch_history[`BH_SIZE - 1];
			end else begin
				obq_next[tail] 	= bh_row;
				tail_next 	= tail + 1;
				row_tag_next 	= tail;
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
				obq_next[tail - shift_index - 1] 	= bh_row;
				row_tag_next 				= tail - shift_index - 1;
			end else if (tail < `OBQ_SIZE) begin
				obq_next[tail] 	= bh_row;
				tail_next 	= tail + 1;
				row_tag_next 	= tail;
			end
		end else if (clear_en & shift_en) begin

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
				// if we are clearing the table, this implies
				// that our prediction was incorrect and
				// therefore we need to update the last bit
				// of the most recent valid branch history
				obq_next[index - shift_index - 2].branch_history[`BH_SIZE - 1] = ~obq_next[index - shift_index - 2].branch_history[`BH_SIZE - 1];
			end
		end else if (shift_en) begin

			// shift all the entries over
			if (shift_index < tail) begin
				for (int i = 0; i < `OBQ_SIZE; ++i) begin
					if (i - shift_index > 0) begin
						obq_next[i - shift_index - 1] = obq[i];
					end
				end
				tail_next = tail - shift_index - 1;
			end
		end else if (write_en) begin
			// write the newest branch history table into the 
			// tail index of the obq
			if (tail < `OBQ_SIZE) begin
				obq_next[tail] 	= bh_row;
				tail_next 	= tail + 1;
				row_tag_next 	= tail;
			end
		end else if (clear_en) begin
			if (index < tail) begin
				obq_next[index - 1].branch_history[`BH_SIZE - 1] = ~obq[index - 1].branch_history[`BH_SIZE - 1];
				tail_next = index;
			end
		end
	end

	// sequential logic
	always_ff @(posedge clock) begin
		if (reset) begin
			for (int i = 0; i < `OBQ_SIZE; ++i) begin
				obq[i].branch_history <= 0; // reset to all not taken
			end
			tail 		<= 0;
			row_tag_index 	<= 0;
		end else begin
			obq 		<= obq_next;
			tail 		<= tail_next;
			row_tag_index 	<= row_tag_next;
		end
	end

endmodule // OBQ
