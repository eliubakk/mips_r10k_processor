`include "../../sys_defs.vh"
`define DEBUG
//Instruction queue
////SIZE is defined to 10 in sys_defs
////Gets data from fetch2 (Branch predictor) and send data to decode
//1. When there is structural hazard in ROB, RS, Freelist, then stall sending
//instruction to decode
//2. When the instruction queue is full, stall fetch
//3. When the branch is mispredicted, flush the queue
//4. When same instruction goes in to the queue on multiple cycle, fetch only
//one time


module IQ(
	input 		clock,
	input 		reset,
	input 		fetch_valid, // Fetched instruction is valid
	input INST_Q	if_inst_in,	
	input 			dispatch_no_hazard, // No structural hazard in ROB, RS, and Free list
	input	        branch_incorrect, // Flushing due to branch misprediction(branch not taken)	

	`ifdef DEBUG
	output INST_Q [`IQ_SIZE-1:0] inst_queue_out,
	output  [$clog2(`IQ_SIZE):0] inst_queue_entry,	
	`endif
	output		  inst_queue_full_out,
	output INST_Q if_inst_out
);



	// internal data

	INST_Q [`IQ_SIZE-1:0] 		inst_queue, next_inst_queue;
	logic  [$clog2(`IQ_SIZE):0] 	tail, next_tail;
	logic				inst_queue_full, next_inst_queue_full;
	// Check for duplicate fetch
	logic				duplicate_fetch;
	logic				fetch_en;	

	`ifdef DEBUG
	assign inst_queue_out = inst_queue;
	assign inst_queue_entry = tail;
	`endif

	//assign inst_queue_full 	= (tail >= `IQ_SIZE-1) & !(dispatch_no_hazard);
	//assign fetch_en		= fetch_valid & !duplicate_fetch; 
	assign fetch_en		= fetch_valid;

	assign inst_queue_full_out = inst_queue_full;

	always_comb begin
		next_inst_queue = inst_queue;
		next_tail = tail;
		next_inst_queue_full = inst_queue_full;
	
		// For duplicate fetching - pc comparsion is
		// expensive....leave for later use
/*		duplicate_fetch = 1'b0;
		if(tail == 0) begin
			if( (if_inst_out.valid_inst) & (if_inst_in.valid_inst) & (if_inst_out.npc == if_inst_in.npc) & (if_inst_out.ir == if_inst_in.ir)) begin
				duplicate_fetch = 1'b1;
			end 
		end else begin
			if (inst_queue[tail-1].valid_inst & if_inst_in.valid_inst & (inst_queue[tail-1].npc == if_inst_in.npc) & (inst_queue[tail-1].ir == if_inst_in.ir)) begin
				duplicate_fetch = 1'b1;
			end
		end
*/
	
		if(fetch_en) begin
			if (tail != `IQ_SIZE) begin
				next_inst_queue[tail]	= if_inst_in;
				next_tail				= tail + 1;
				next_inst_queue_full	= (tail >= `IQ_SIZE-2);
			end

		end
	end

  	// synopsys sync_set_reset "reset"
	always_ff @(posedge clock) begin
		if (reset | branch_incorrect) begin
			for (int i = 0; i < `IQ_SIZE; i += 1) begin
				inst_queue[i] <= `SD EMPTY_INST_Q;
			end	
			tail 			<= `SD {`IQ_SIZE{1'b0}};
			inst_queue_full	<= `SD 1'b0;
			if_inst_out 	<= `SD EMPTY_INST_Q;
		end else if(dispatch_no_hazard & (next_tail != 0)) begin
			// Fetched instruction in IQ
			if_inst_out	<= `SD next_inst_queue[0];
			for (int i=0; i< `IQ_SIZE; i=i+1) begin
				inst_queue[i] <= `SD next_inst_queue[i+1];
			end
			inst_queue[`IQ_SIZE-1] <= EMPTY_INST_Q;
			tail			<= `SD next_tail-1;
			inst_queue_full	<= `SD (next_tail >= `IQ_SIZE-1);
		end else begin 
			// There is dispatch hazard or queue is empty, no dispatch
			if_inst_out		<= `SD EMPTY_INST_Q;
			inst_queue		<= `SD next_inst_queue;
			tail 			<= `SD next_tail;
			inst_queue_full	<= `SD next_inst_queue_full;
		end
	end

endmodule // Free_List
