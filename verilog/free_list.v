`define FL_SIZE `NUM_PHYS_REG

// would be good idea to create a queue module and create an instance of that
// here...

module Free_List(
	input clock,
	input reset,
	input enable,
	input PHYS_REG T_old, // Comes from ROB during Retire Stage
	input dispatch_en, // Structural Hazard detection during Dispatch

	output [$clog2(`NUM_PHYS_REG)-1:0] num_free_entries, // Used for Dispatch Hazard
	output empty, // Used for Dispatch Hazard
	output PHYS_REG free_reg // Output for Dispatch for other modules
);

	// internal data
	
	// free_list registers and combinational next_free_list
	PHYS_REG [`FL_SIZE-1:0] free_list;
	PHYS_REG [`FL_SIZE-1:0] next_free_list;

	// tail pointer register and combination next_tail
	logic [$clog2(`FL_SIZE)-1:0] tail;
	logic [$clog2(`FL_SIZE)-1:0] next_tail;

	always_comb begin
		// RETIRE STAGE
		if (enable) begin
			// if retire stage is retiring a register
			// that register should be added to free list
			// hence, insert at tail position of queue
			next_free_list[tail] = T_old;
			next_tail = tail + 1;
		end else begin
			next_free_list = free_list;
			next_tail = tail;
		end

		// DISPATCH STAGE
		if (dispatch_en) begin
			// inst is getting dispatched so we need
			// to pop off the next free reg
			// if dispatch_en is 1 then that means
			// that there is at least 1 free reg
			// because if it was 0, then outside modules
			// would not have set dispatch_en to 1
			free_reg = free_list[0];
			
			if (enable) begin
				// if enable, then that means a reg was pushed
				// into queue during retire
				/*
 				not sure if this way works...
				next_free_list = {{(`FL_SIZE - tail){0}}, T_old, free_reg[tail-1:1]};
				*/
				// not sure how this way synthesizes...
				for (int i = tail; i < `FL_SIZE; i += 1) begin
					next_free_list[i] = `DUMMY_REG;
				end
				next_free_list[tail-1:0] = {T_old, free_reg[tail-1:1]};
				// if both dispatch_en and enable, that means 
				// something is getting pushed in and popped
				// off so tail must remain in same position
				next_tail = tail;
			end else begin
				// nothing is getting pushed into queue
				next_free_list[tail-2:0] = {free_reg[tail-1:1]};
				next_tail = tail - 1;
			end
		end else if (~enable) begin
			// nothing getting pushed or popped off
			next_free_list = free_list;
			next_tail = tail;
		end
	end

	always_ff @(posedge clock) begin
		if (reset) begin
			// if reset, set i = pr_(num_gen + i), 0 -> 32,
			// 1->33 ...
			// this is because the map_table initializes
			// all the gen purpose regs to be pr0 to 
			// pr(num_gen- 1)
			for (int i = 0; i < `NUM_GEN_REG; i += 1) begin
				free_list[i] 		<= {0, `NUM_GEN_REG + i};
				next_free_list[i] 	<= {0, `NUM_GEN_REG + i};
			end
			tail 		<= `NUM_GEN_REG;
			next_tail 	<= `NUM_GEN_REG;
		end else begin
			free_list <= next_free_list;
		end
	end

endmodule // Free_List
