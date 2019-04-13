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
	INST_Q				if_inst;

	`ifdef DEBUG
	assign inst_queue_out = inst_queue;
	assign inst_queue_entry = tail;
	`endif

	assign inst_queue_full 	= (tail == `IQ_SIZE);

	always_comb begin
		next_inst_queue = inst_queue;
		next_tail = tail;
		if_inst[i].valid_inst 			= 1'b0;
		if_inst[i].npc				= 64'h0;
		if_inst[i].ir				= `NOOP_INST;
		if_inst[i].branch_inst.en		= 1'b0; 
		if_inst[i].branch_inst.cond		= 1'b0;    		
		if_inst[i].branch_inst.direct		= 1'b0;
		if_inst[i].branch_inst.ret		= 1'b0;
		if_inst[i].branch_inst.pc		= 64'h0;
		if_inst[i].branch_inst.pred_pc		= 64'h0;
		if_inst[i].branch_inst.br_idx		= {($clog2(`OBQ_SIZE)){0}};
		if_inst[i].branch_inst.prediction	= 1'b0;



		if(branch_incorrect) begin // During flushing

			next_inst_queue[i].valid_inst 			= 1'b0;
			next_inst_queue[i].npc				= 64'h0;
			next_inst_queue[i].ir				= `NOOP_INST;
			next_inst_queue[i].branch_inst.en		= 1'b0; 
			next_inst_queue[i].branch_inst.cond		= 1'b0;    		
			next_inst_queue[i].branch_inst.direct		= 1'b0;
			next_inst_queue[i].branch_inst.ret		= 1'b0;
			next_inst_queue[i].branch_inst.pc		= 64'h0;
			next_inst_queue[i].branch_inst.pred_pc		= 64'h0;
			next_inst_queue[i].branch_inst.br_idx		= {($clog2(`OBQ_SIZE)){0}};
			next_inst_queue[i].branch_inst.prediction	= 1'b0;

			next_tail = 0;		
		end else begin
			if( fetch_en & dispatch_no_hazard) begin // Fetch and decode
				if (tail ==0 ) begin
					if_inst = if_inst_in;
				end else begin
					if_inst		 = inst_queue[0];
					next_inst_queue  = {if_inst_in, inst_queue[`IQ_SIZE-1:1]}; 
				end

		end else if ( !fetch_en & dispatch_no_hazard) begin // decode only
				if( tail !=0 ) begin
					if_inst			= inst_queue[0];
					for (int i=0; i<`IQ_SIZE-1; i=i+1) begin
						next_inst_queue[i] = inst_queue[i+1];
					end
					next_tail		= tail - 1;
				end
			end else if ( fetch_en & !dispatch_no_hazard) begin // fetch only
				if( tail != `IQ_SIZE) begin
					next_inst_queue[tail]	= if_inst_in; 	
					next_tail		= tail + 1;	
					
				end
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

				if_inst_out[i].valid_inst 		<= `SD 1'b0;
				if_inst_out[i].npc			<= `SD 64'h0;
				if_inst_out[i].ir			<= `SD `NOOP_INST;
				if_inst_out[i].branch_inst.en		<= `SD 1'b0; 
				if_inst_out[i].branch_inst.cond		<= `SD 1'b0;    		
				if_inst_out[i].branch_inst.direct	<= `SD 1'b0;
				if_inst_out[i].branch_inst.ret		<= `SD 1'b0;
				if_inst_out[i].branch_inst.pc		<= `SD 64'h0;
				if_inst_out[i].branch_inst.pred_pc	<= `SD 64'h0;
				if_inst_out[i].branch_inst.br_idx	<= `SD {($clog2(`OBQ_SIZE)){0}};
				if_inst_out[i].branch_inst.prediction	<= `SD 1'b0;

		end else begin

				inst_queue	<= `SD next_inst_queue;
				tail		<= `SD next_tail;
				if_inst_out	<= `SD if_inst;
		end
	end

endmodule // Free_List
