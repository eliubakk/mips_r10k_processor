`include "../../sys_defs.vh"
`define DEBUG

module ROB(
		input clock,
		input reset,
		input enable,
		input PHYS_REG [`SS_SIZE-1:0] T_old_in, // Comes from Map Table During Dispatch
		input PHYS_REG [`SS_SIZE-1:0] T_new_in, // Comes from Free List During Dispatch
		input 		   [`SS_SIZE-1:0] halt_in,
		input PHYS_REG [`SS_SIZE-1:0] CDB_tag_in, // Comes from CDB during Commit
		input		   [`SS_SIZE-1:0] CAM_en, // Comes from CDB during Commit
		input						CDB_br_valid, // ** Heewoo added ,need a way to deal with multiple branches
		input  [$clog2(`OBQ_SIZE)-1 : 0 ] CDB_br_idx, // *** Heewoo Comes from CDB during commit, distinguish branch 
		input		   [`SS_SIZE-1:0] dispatch_en, // Structural Hazard detection during Dispatch
		input branch_not_taken,
		input [`SS_SIZE-1:0][31:0] opcode,
		input			take_branch,
		//input 			branch_valid,    //***Heewoo
		//: Replaced with id_branch_inst
		input BR_SIG		id_branch_inst,		//***Heewoo
		input [`SS_SIZE][4:0]	wr_idx,
		input [`SS_SIZE][31:0]	npc,
		input [63:0] co_alu_result,

		// OUTPUTS
		output ROB_ROW_T [`SS_SIZE-1:0] retire_out, // Output for Retire Staget
		output logic 	[$clog2(`ROB_SIZE):0] free_rows_next,
		output wand	full // Used for Dispatch Hazard
		`ifdef DEBUG 
			, output ROB_ROW_T [`ROB_SIZE-1:0]	 ROB_table_out,
			output logic [$clog2(`ROB_SIZE):0] tail_out, head_out,
			output logic [$clog2(`ROB_SIZE):0] tail_next_out, head_next_out,
			output logic [`ROB_SIZE-1:0] ready_to_retire_out,
			output logic [`SS_SIZE-1:0][$clog2(`ROB_SIZE):0] retire_idx_out,
			output logic [`SS_SIZE-1:0] retire_idx_valid_out,
			output logic [`SS_SIZE-1:0][$clog2(`ROB_SIZE):0] dispatch_idx_out
		`endif
	);

	logic [$clog2(`ROB_SIZE):0] tail, tail_next, head, head_next;
	logic head_next_busy;

	wire [`ROB_SIZE-1:0] ready_to_retire;
	wire [`SS_SIZE-1:0][$clog2(`ROB_SIZE):0] retire_idx;
	wire [`SS_SIZE-1:0] retire_idx_valid;
	logic [`SS_SIZE-1:0] retired;

	logic [`SS_SIZE-1:0][$clog2(`ROB_SIZE):0] dispatch_idx;
	logic [`SS_SIZE-1:0] dispatched;
						
	ROB_ROW_T [`ROB_SIZE-1:0] ROB_table, ROB_table_next;


	//CAM VARIABLES
	logic [(`SS_SIZE-1):0][($clog2(`NUM_PHYS_REG)-1):0] cam_tags_in;
	logic [(`ROB_SIZE-1):0][($clog2(`NUM_PHYS_REG)-1):0] cam_table_in;
	logic [(`ROB_SIZE-1):0][(`SS_SIZE-1):0] cam_hits;	

	`ifdef DEBUG 
		assign ROB_table_out = ROB_table;
		assign tail_out = tail;
		assign head_out = head;
		assign tail_next_out = tail_next;
		assign head_next_out = head_next;
		assign ready_to_retire_out = ready_to_retire;
		assign retire_idx_out = retire_idx;
		assign retire_idx_valid_out = retire_idx_valid;
		assign dispatch_idx_out = dispatch_idx;
	`endif

	genvar ig;
	for (ig = 0; ig < `ROB_SIZE; ig += 1) begin
		assign full = ROB_table[ig].busy;
	end

	//CAM LOGIC
	for(ig = 0; ig < `ROB_SIZE; ig += 1) begin
		assign cam_table_in[ig] = ROB_table[ig].T_new[($clog2(`NUM_PHYS_REG)-1):0];
	end
	for(ig = 0; ig < `SS_SIZE; ig += 1) begin
		assign cam_tags_in[ig] = CDB_tag_in[ig][($clog2(`NUM_PHYS_REG)-1):0];
	end
	//Instantiate CAM module for CBD
	CAM #(.LENGTH(`ROB_SIZE),
		  .WIDTH(1),
		  .NUM_TAGS(`SS_SIZE),
		  .TAG_SIZE($clog2(`NUM_PHYS_REG))) robcam ( 
		.enable(CAM_en),
		.tags(cam_tags_in),
		.table_in(cam_table_in),
		.hits(cam_hits)
	);

	for(ig = 0; ig < `ROB_SIZE; ig += 1) begin
		assign ready_to_retire[ig] = (ROB_table[ig].busy) & (ROB_table[ig].T_new[$clog2(`NUM_PHYS_REG)] | (| cam_hits[ig]));
	end

	for(ig = `SS_SIZE-1; ig >= 0 ; ig -= 1) begin
		assign retire_idx[ig] = ((head - (`SS_SIZE - 1 - ig)) < `ROB_SIZE)? (head - (`SS_SIZE - 1 - ig)) :
																		 (`ROB_SIZE + head - (`SS_SIZE - 1 - ig));
		assign retire_idx_valid[ig] = ((head < tail) & ((retire_idx[ig] <= head) | (retire_idx[ig] >= tail)))
										| ((head >= tail) & (retire_idx[ig] >= tail));
	end

	always_comb begin
		ROB_table_next = ROB_table;
		retired = {`SS_SIZE{1'b0}};
		dispatched = {`SS_SIZE{1'b0}};
		head_next = head;
		tail_next = tail;
		for(int i = 0; i < `SS_SIZE; i += 1) begin
			retire_out[i].T_old = `DUMMY_REG;
			retire_out[i].T_new = `DUMMY_REG;
			retire_out[i].halt = 1'b0;
			retire_out[i].busy = 1'b0;
			retire_out[i].opcode =  `NOOP_INST;
			retire_out[i].take_branch = 1'b0;
			//retire_out[i].branch_valid = 1'b0;
			retire_out[i].wr_idx = `ZERO_REG;
			retire_out[i].npc = 64'h0;
	
			retire_out[i].branch_inst.en 		= 1'b0;
			retire_out[i].branch_inst.cond 		= 1'b0;
			retire_out[i].branch_inst.direct 	= 1'b0;
			retire_out[i].branch_inst.ret	 	= 1'b0;
			retire_out[i].branch_inst.pc 		= 64'h0;
			retire_out[i].branch_inst.pred_pc 		= 64'h0;
			retire_out[i].branch_inst.br_idx 	= {($clog2(`OBQ_SIZE)){0}};
			retire_out[i].branch_inst.prediction 	= 0;
			//retire_out[i].branch_inst.taken 	= 0;

		end

		// update tag ready bits from CBD 
		for (int i = 0; i < `ROB_SIZE; i += 1) begin
			if(ROB_table[i].branch_inst.en) begin// When branch is broadcasting
				ROB_table_next[i].T_new[$clog2(`NUM_PHYS_REG)] |= (| cam_hits[i])/*& CDB_br_valid & (CDB_br_idx == ROB_table[i].branch_inst.br_idx)*/;
			end else begin
				ROB_table_next[i].T_new[$clog2(`NUM_PHYS_REG)] |= (| cam_hits[i]);
			end
			ROB_table_next[i].take_branch = (take_branch & ROB_table[i].branch_inst.en & (CDB_br_valid & (CDB_br_idx == ROB_table[i].branch_inst.br_idx))) ? 1'b1 : ROB_table[i].take_branch; // **** Heewoo changed for multiple branches
			ROB_table_next[i].npc = (take_branch & ROB_table[i].branch_inst.en & (CDB_br_valid & (CDB_br_idx == ROB_table[i].branch_inst.br_idx))) ? co_alu_result : ROB_table[i].npc; // **** Heewoo changed for multiple branches
		end

	// if(take_branch)	begin
	// 	for (int i=0 ; i< `ROB_SIZE; i= i+1) begin
	// 		if (ROB_table[i].branch_valid) begin
	// 			ROB_table_next[i].take_branch = take_branch;
	// 			break; 
	// 		end
	// 	end
	// end

		//RETIRE STAGE
		if(!branch_not_taken) begin	// When it is not flush
			for(int i = `SS_SIZE-1; i >= 0; i -= 1) begin
				if(enable & retire_idx_valid[i] & ready_to_retire[retire_idx[i]]) begin
					//if table is busy and T_new is ready, retire
					retire_out[i] = ROB_table_next[retire_idx[i]];
					retired[i] = 1'b1;
					ROB_table_next[retire_idx[i]].busy = 1'b0;
				end else begin
					break;
				end
			end
		end else begin // during flush, do not retire
			retired = {`SS_SIZE{1'b0}};
			for(int i = 0; i < `SS_SIZE; i += 1) begin
				retire_out[i].T_old = `DUMMY_REG;
				retire_out[i].T_new = `DUMMY_REG;
				retire_out[i].halt = 1'b0;
				retire_out[i].busy = 1'b0;
				retire_out[i].opcode =  `NOOP_INST;
				retire_out[i].take_branch = 1'b0;
			//	retire_out[i].branch_valid = 1'b0;
				retire_out[i].wr_idx = `ZERO_REG;
				retire_out[i].npc = 64'h0;

				retire_out[i].branch_inst.en 		= 1'b0;
				retire_out[i].branch_inst.cond 		= 1'b0;
				retire_out[i].branch_inst.direct 	= 1'b0;
				retire_out[i].branch_inst.ret	 	= 1'b0;
				retire_out[i].branch_inst.pc 		= 64'h0;
				retire_out[i].branch_inst.pred_pc	= 64'h0;
				retire_out[i].branch_inst.br_idx 	= {($clog2(`OBQ_SIZE)){0}};
				retire_out[i].branch_inst.prediction 	= 0;
				//retire_out[i].branch_inst.taken 	= 0;


			end
	

		end
		

		head_next = (BIT_COUNT_LUT[retired] == 0)? head :
					(retire_idx[`SS_SIZE-1-(BIT_COUNT_LUT[retired]-1)] == tail)? tail :
					(retire_idx[`SS_SIZE-1-(BIT_COUNT_LUT[retired]-1)] == 0)? `ROB_SIZE - 1:
												retire_idx[`SS_SIZE-1-(BIT_COUNT_LUT[retired]-1)] - 1;
												
		head_next_busy = ROB_table_next[head_next].busy;
			
		for(int i = 0; i < `SS_SIZE; i += 1) begin
				dispatch_idx[`SS_SIZE-1-i] = ((tail - head_next_busy - i) < `ROB_SIZE)? (tail - head_next_busy - i) :
																		  (`ROB_SIZE + tail - head_next_busy - i);
		end

		//DISPATCH STAGE
		for (int i = `SS_SIZE-1; i >= 0; i -= 1) begin
			if((((i == `SS_SIZE-1) && (dispatch_idx[i] == head_next)) | (dispatch_idx[i] != head_next))
				& !ROB_table_next[dispatch_idx[i]].busy 
				& dispatch_en[i]
				& enable) begin
				ROB_table_next[dispatch_idx[i]].T_new = T_new_in[i];
				ROB_table_next[dispatch_idx[i]].T_old = T_old_in[i];
				ROB_table_next[dispatch_idx[i]].halt = halt_in[i];
				ROB_table_next[dispatch_idx[i]].busy = 1'b1;
				ROB_table_next[dispatch_idx[i]].opcode = opcode[i];
				ROB_table_next[dispatch_idx[i]].take_branch = take_branch;
				//ROB_table_next[dispatch_idx[i]].branch_valid = branch_valid;
				ROB_table_next[dispatch_idx[i]].branch_inst = id_branch_inst; // What Heewoo Added 
				ROB_table_next[dispatch_idx[i]].wr_idx = wr_idx[i];
				ROB_table_next[dispatch_idx[i]].npc = npc[i];
				dispatched[i] = 1'b1;
			end
		end

		tail_next = (BIT_COUNT_LUT[dispatched] == 0)? tail : 
							dispatch_idx[`SS_SIZE-1-(BIT_COUNT_LUT[dispatched]-1)];	
			
		free_rows_next = (head_next == tail_next)? `ROB_SIZE - ROB_table_next[tail_next].busy :
						  (head_next > tail_next)? `ROB_SIZE - (head_next - tail_next + 1) :
						   				  		   (tail_next - head_next - 1);
	end

	//UPDATE_FLIP_FLOPS
	always_ff @(posedge clock) begin
		if (reset | branch_not_taken) begin
			for (int i = 0; i < `ROB_SIZE; i += 1) begin
				ROB_table[i].T_new <= `SD `DUMMY_REG;
				ROB_table[i].T_old <= `SD `DUMMY_REG;
				ROB_table[i].halt <= `SD 1'b0;
				ROB_table[i].busy <= `SD 1'b0;	
				ROB_table[i].opcode <= `SD `NOOP_INST;
				ROB_table[i].take_branch <= `SD 1'b0;
				//ROB_table[i].branch_valid <= `SD 1'b0;
				ROB_table[i].wr_idx <= `SD `ZERO_REG;
				ROB_table[i].npc <= `SD 64'h0;

				ROB_table[i].branch_inst.en 		<= `SD 1'b0;
				ROB_table[i].branch_inst.cond 		<= `SD 1'b0;
				ROB_table[i].branch_inst.direct 	<= `SD 1'b0;
				ROB_table[i].branch_inst.ret	 	<= `SD 1'b0;
				ROB_table[i].branch_inst.pc 		<= `SD 64'h0;
				ROB_table[i].branch_inst.pred_pc	<= `SD 64'h0;
				ROB_table[i].branch_inst.br_idx 	<= `SD {($clog2(`OBQ_SIZE)){0}};
				ROB_table[i].branch_inst.prediction 	<= `SD 0;
				//ROB_table[i].branch_inst.taken 		<= `SD 0;



			end
			tail <= `SD `ROB_SIZE-1;
			head <= `SD `ROB_SIZE-1;
		end else begin
			ROB_table <= `SD ROB_table_next;
			tail <= `SD tail_next;
			head <= `SD head_next;
		end
	end

endmodule // ROB
