`include "sys_defs.vh"
`define FL_SIZE `NUM_PHYS_REG
`define DEBUG
// would be good idea to create a queue module and create an instance of that
// here...

module Free_List(
	input clock,
	input reset,
	input enable,	// enable signal for the writing of the freelist i.e the new freed regiter
	input PHYS_REG T_old, // Comes from ROB during Retire Stage
	input dispatch_en, // Structural Hazard detection during Dispatch

	// inputs for branch misprediction
	input branch_incorrect,
	input PHYS_REG [`FL_SIZE-1:0] free_check_point,
	input [$clog2(`FL_SIZE):0] tail_check_point,

	`ifdef DEBUG
	output PHYS_REG [`FL_SIZE-1:0] free_list_out,
	output logic [$clog2(`FL_SIZE):0] tail_out,
	`endif

	output [$clog2(`FL_SIZE):0] num_free_entries, // Used for Dispatch Hazard
	output logic empty, // Used for Dispatch Hazard
	output PHYS_REG free_reg // Output for Dispatch for other modules
);

	// internal data
	
	// free_list registers and combinational next_free_list
	PHYS_REG [`FL_SIZE-1:0] free_list;
	PHYS_REG [`FL_SIZE-1:0] next_free_list;

	// tail pointer register and combination next_tail
	logic [$clog2(`FL_SIZE):0] tail;
	logic [$clog2(`FL_SIZE):0] next_tail;

	assign empty = (tail == 0);
	assign free_reg = free_list[0];
	assign num_free_entries = tail;
	`ifdef DEBUG
	assign free_list_out = free_list;
	assign tail_out = tail;
	`endif

	always_comb begin

		if (branch_incorrect) begin
			next_free_list = free_check_point;
			next_tail = tail_check_point;
		end else if (dispatch_en & enable) begin
			// Reg is getting retired AND getting sent out
			for (int i = 0; i < `FL_SIZE; ++i) begin
				next_free_list[i] = free_list[i+1];
			end
			next_free_list[tail - 1] = T_old;
			next_tail = tail;
		end else if (enable) begin
			// Register is getting retired
			if (tail == `FL_SIZE) begin
				next_free_list = free_list;
				next_tail = tail;
			end else begin
				next_free_list = free_list;
				next_free_list[tail] = T_old;
				next_tail = tail + 1;
			end
		end else if (dispatch_en) begin
			// Register is getting dispatched
			if (tail == 0) begin
				next_free_list = free_list;
				next_tail = tail;
			end else begin 
				for (int i = 0; i < `FL_SIZE; ++i) begin
					next_free_list[i] = free_list[i + 1];
				end
				next_tail = tail - 1;
			end

		end else begin
			// Remain the same state
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
			end
			tail 		<= `NUM_GEN_REG;
		end else begin
			free_list <= next_free_list;
			tail <= next_tail;
		end
	end

endmodule // Free_List
