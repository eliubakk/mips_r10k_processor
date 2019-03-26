`include "../../sys_defs.vh"
`timescale 1ns/100ps
`define DEBUG

module RAS(
	input clock,
	input reset,
	input write_en,
	input clear_en,
	input [31:0] current_pc,

	`ifdef DEBUG
	output logic [`RAS_SIZE - 1:0] [31:0] stack_out,
	output logic [$clog2(`RAS_SIZE) - 1:0] head_out,
	output logic [$clog2(`RAS_SIZE) - 1:0] tail_out,
	`endif

	output logic [31:0] next_pc,
	output logic valid_out
);

	// internal data

	// array to implement stack	
	logic [`RAS_SIZE - 1:0] [31:0] stack;
	logic [`RAS_SIZE - 1:0] [31:0] stack_next;

	// top pointer to keep track of top/size of RAS
	// tail is the top and head is the oldest next_pc
	logic [$clog2(`RAS_SIZE) - 1:0] head;
	logic [$clog2(`RAS_SIZE) - 1:0] head_next;
	logic [$clog2(`RAS_SIZE) - 1:0] tail;
	logic [$clog2(`RAS_SIZE) - 1:0] tail_next;

	// assign statements
	// valid_out is 1 if the size is greater than 0
	assign valid_out = head != tail;

	// if size > 0, then output the last element
	// else output doesnt matter
	assign next_pc = stack[tail - 1];

	`ifdef DEBUG
	assign stack_out = stack;
	assign head_out = head;
	assign tail_out = tail;
	`endif

	always_comb begin

		// default values
		stack_next = stack;
		head_next = head;
		tail_next = tail;

		if (write_en & clear_en) begin
			// push at location of pop
			stack_next[tail - 1] = current_pc + 4;
		end else if (write_en) begin
			// push
			stack_next[tail] = current_pc + 4;
			tail_next = tail + 1;
			if (tail_next == head) begin
				head_next = head + 1;
			end
		end else if (clear_en) begin
			// pop
			if (head != tail) begin
				tail_next = tail - 1;
			end
		end
	end

	always_ff @(posedge clock) begin
		if (reset) begin
			for (int i = 0; i < `RAS_SIZE; ++i) begin
				stack[i] <= 0;
			end
			head <= 0;
			tail <= 0;
		end else begin
			stack <= stack_next;
			head <= head_next;
			tail <= tail_next;
		end
	end

endmodule
