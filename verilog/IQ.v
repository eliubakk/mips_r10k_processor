`include "../../sys_defs.vh"
`define DEBUG
//Instruction queue
//SIZE is defined to 10 in sys_defs
//Gets data from fetch2 (Branch predictor) and send data to decode
//1. When there is structural hazard in ROB, RS, Freelist, then stall sending
//instruction to decode
//2. When the instruction queue is full, stall fetch
//3. When the branch is mispredicted, flush the queue

module IQ(
	input 		clock,
	input 		reset,
	input 		fetch_en, // Fetched instruction is valid
	input INST_Q	if_inst_in,	
	input 		dispatch_no_hazard, // No structural hazard in ROB, RS, and Free list
	input	        branch_incorrect, // Flushing due to branch misprediction(branch not taken)	

	`ifdef DEBUG
	output INST_Q [`IQ_SIZE-1:0] inst_queue_out,
	output	[$clog2(`IQ_SIZE):0] inst_queue_entry,	
	`endif
	output		inst_queue_full,
	output INST_Q	if_inst_out

);



	// internal data

	INST_Q [`IQ_SIZE-1:0] 		inst_queue, next_inst_queue;
	logic  [$clog2(`IQ_SIZE):0] 	tail, next_tail;

	`ifdef DEBUG
	assign inst_queue_out = inst_queue;
	assign inst_queue_entry = tail;
	`endif

	always_comb begin
		inst_queue_next = inst_queue;
		next_tail = tail;

		if(branch_incorrect) begin // During flushing


		end else begin
			if( fetch_en & dispatch_no_hazard) begin // Fetch and dispatch

			end else if ( !fetch_en & dispatch_no_hazard) begin // dispatch only

			end else if ( fetch_en & !dispatch_no_hazard) begin // fetch only

			end else begin // Do nothing
				inst_queue_next = inst_queue;
				next_tail = tail;
			end

		end

	end


	always_ff @(posedge clock) begin
		if (reset) begin
			for (int i = 0; i < `IQ_SIZE; i += 1) begin
				inst_queue[i].valid_inst 		<= `SD 1'b0;
				inst_queue[i].npc			<= `SD 64'h0;
				inst_queue[i].ir			<= `SD `NOOP_INST;
				inst_queue[i].branch_inst.en		<= `SD 1'b0; 
				inst_queue[i].branch_inst.cond		<= `SD 1'b0;    		
				inst_queue[i].branch_inst.direct	<= `SD 1'b0;
				inst_queue[i].branch_inst.ret		<= `SD 1'b0;
				inst_queue[i].branch_inst.pc		<= `SD 64'h0;
				inst_queue[i].branch_inst.pred_pc	<= `SD 64'h0;
				inst_queue[i].branch_inst.br_idx	<= `SD {($clog2(`OBQ_SIZE)){0}};
				inst_queue[i].branch_inst.prediction	<= `SD 1'b0;
			end
			tail 						<= `SD 0;
		end else begin

				inst_queue	<= `SD next_inst_queue;
				tail		<= `SD next_tail;
		end
	end

endmodule // Free_List
