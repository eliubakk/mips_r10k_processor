`include "../../sys_defs.vh"
module retire_buffer(clock, reset,
              evicted, evicted_valid,
              Rmem2proc_response,
              proc2Rmem_command, proc2Rmem_addr, proc2Rmem_data,
              full);
	parameter NUM_WAYS = 4;
	parameter WR_PORTS = 1;

	`define NUM_SET_BITS $clog2(32/NUM_WAYS)
	`define NUM_TAG_BITS (13-`NUM_SET_BITS)

	typedef struct packed {
		logic [63:0] data;
		logic [(`NUM_TAG_BITS-1):0] tag;
		logic valid;
		logic dirty;
	} CACHE_LINE_T;

	typedef struct packed {
		CACHE_LINE_T line;
		logic [(`NUM_SET_BITS-1):0] idx;
	} VIC_CACHE_T;

	typedef struct packed {
		logic [63:0] address;
		logic [63:0] data;
		logic valid;
	} RETIRE_BUF_T;

	const RETIRE_BUF_T EMPTY_RETIRE_BUF =
	{
		64'b0,
		64'b0,
		1'b0
	};

	//inputs
	input clock, reset;
	input VIC_CACHE_T [(WR_PORTS-1):0] evicted;
	input [(WR_PORTS-1):0] evicted_valid;
	input [3:0]  Rmem2proc_response;

	//outputs
	output logic [1:0]  proc2Rmem_command;
	output logic [63:0] proc2Rmem_addr;
	output logic [63:0] proc2Rmem_data;
	output logic full;

	RETIRE_BUF_T [(`RETIRE_SIZE-1):0] retire_queue, retire_queue_next;
	logic [$clog2(`RETIRE_SIZE):0] retire_queue_tail, retire_queue_tail_next;
	logic [$clog2(`RETIRE_SIZE):0] send_req_ptr, send_req_ptr_next;

	logic send_request;
	logic request_not_accepted;
	logic update_queue;
	//logic mem_done;

	assign full = (retire_queue_tail >= (`RETIRE_SIZE-WR_PORTS));

	assign request_not_accepted = send_request? (Rmem2proc_response == 0) :
	  											(send_req_ptr < retire_queue_tail); 

	assign proc2Rmem_addr = send_request? retire_queue[send_req_ptr].address :
	  									  64'b0;
	assign proc2Rmem_command = send_request? BUS_STORE :
	  										 BUS_NONE;
	assign proc2Rmem_data = send_request? retire_queue[send_req_ptr].data :
	  									  64'b0;

	assign update_queue = send_request? (Rmem2proc_response != 0) :
	  									1'b0;

	always_comb begin
		retire_queue_next = retire_queue;
		retire_queue_tail_next = retire_queue_tail;
		send_req_ptr_next = send_req_ptr;

		if(update_queue) begin
			retire_queue_next[`RETIRE_SIZE-1:0] = {EMPTY_RETIRE_BUF, retire_queue[`RETIRE_SIZE-1:1]};
			retire_queue_tail_next -= 1;
			if(send_req_ptr > 0) begin
				send_req_ptr_next -= 1;
			end
		end

		for(int i = 0; i < WR_PORTS; ++i) begin
			if(evicted_valid[i] & evicted[i].line.dirty & ~full) begin
				retire_queue_next[retire_queue_tail].address = {32'b0, 
																evicted[i].line.tag, 
																evicted[i].idx,
																3'b0};
				retire_queue_next[retire_queue_tail].data = evicted[i].line.data;
				retire_queue_next[retire_queue_tail].valid = 1'b1;
				retire_queue_tail_next += 1;
			end
		end
	end

	always_ff @(posedge clock) begin
		if(reset) begin
			for(int i = 0; i < `RETIRE_SIZE; ++i) begin
				retire_queue[i] <= `SD EMPTY_RETIRE_BUF;
			end
			retire_queue_tail <= `SD 0;
			send_req_ptr 	  <= `SD 0;
			send_request 	  <= `SD 0;
		end else begin
			retire_queue 	  <= `SD retire_queue_next;
			retire_queue_tail <= `SD retire_queue_tail_next;
			send_req_ptr 	  <= `SD send_req_ptr_next;
			send_request      <= `SD request_not_accepted;
		end
	end	

endmodule // retire_buffer