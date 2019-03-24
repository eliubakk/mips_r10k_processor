// Entire branch predictor module
// Should include BTB, GSHARE, OBQ 
`include "sys_defs.vh"
//`include "BTB.v"
//`include "GSHARE.v"
//`include "OBQ.v"

`define	DEBUG_OUT

// Branch misprediction : input is index and clear_en is 1
// Branch correct prediction : input is index and shift_en is 1
//
//Index : 		pc[$clog2(BTB_ROW)+1:2]
//Tag : 		pc [(TAG_SIZE+$clog2(BTB_ROW)+1):($clog2(BTB_ROW)+2)], 
//Target address : 	pc[TARGET_SIZE+1:2]



module  BP(
	input 					clock,    // Clock
	input 					reset,  // Asynchronous reset active low
	input 					enable, // Clock Enable

	input					if_branch,		// Valid branch instruction
	input		[31:0]			if_pc_in,			// input PC
	// Comes after execute state(after branch calculation)
	input					rt_en_branch,		// enabled when the instruction is branch  
	input					rt_branch_taken,	// enabled when the branch is actullly taken
	input					rt_prediction_correct,  // enabled when the branch prediction is correct 
	input		[31:0]			rt_pc,			// PC of the executed branch instruction
	input		[31:0]			rt_calculated_pc,  	// Calculated target PC
	input	[$clog2(`OBQ_SIZE):0]		rt_branch_index,	// Executed branch's OBQ index 
		

		

	
	`ifdef DEBUG_OUT
	output		logic 	[`BTB_ROW-1:0]				valid_out,
	output		logic	[`BTB_ROW-1:0]	[`TAG_SIZE-1:0]		tag_out,
	output		logic	[`BTB_ROW-1:0]	[`TARGET_SIZE-1:0]	target_address_out,
	output		OBQ_ROW_T 		[`OBQ_SIZE-1:0]		obq_out,
	output		logic [$clog2(`OBQ_SIZE):0] 			tail_out,
	output		logic	[`BH_SIZE-1:0]				ght_out,
	output		logic	[2**(`BH_SIZE)-1:0]			pht_out,
	`endif

	output		logic						next_pc_valid,		// Enabled when next_pc value is valid pc
	output 		logic 	[$clog2(`OBQ_SIZE):0]			next_pc_index, 		// ************Index from OBQ	
	output		logic	[31:0]					next_pc			
	
);
	// Input
		// For GSHARE and OBQ
		logic clear_en;
		logic shift_en;

	// Outputs
		// BTB signals
		logic	[31:0]			target_pc; 	
		logic				valid_target;

		/*`ifdef DEBUG_OUT
		logic 	[`BTB_ROW-1:0]				valid_out;
		logic	[`BTB_ROW-1:0]	[`TAG_SIZE-1:0]		tag_out;
		logic	[`BTB_ROW-1:0]	[`TARGET_SIZE-1:0]	target_address_out;
		`endif*/

		// OBQ signals
		logic 				bh_pred_valid;		// Same as Gshare obq_bh_pred_valid
		OBQ_ROW_T 			bh_pred;		// Same as [`BH_SIZE-1:0] obq_gh_in
		logic	[$clog2(`OBQ_SIZE):0]	bh_index;		// *******Index from OBQ
									// *******Was the branch predicted taken or not taken?

		/*`ifdef DEBUG
		OBQ_ROW_T [`OBQ_SIZE-1:0] obq_out;
		logic [$clog2(`OBQ_SIZE):0] 	tail_out;
		`endif*/


		// GSHARE signals
		logic	[`BH_SIZE-1:0]		ght;
		logic				prediction_valid;
		logic				prediction;
		/*`ifdef DEBUG_OUT
		logic	[2**(`BH_SIZE)-1:0]	pht_out;
		`endif*/


	//Value evaluation
	//
	assign clear_en		= rt_en_branch & ~rt_prediction_correct;  // **************** When the branch prediction was wrong 
	assign shift_en		= rt_en_branch & rt_prediction_correct;
	assign ght_out		= ght;

	// internal registers
//	OBQ_ROW_T last_pred;

	// BTB module	


	BTB btb0(
		// inputs
		.clock(clock), 
		.reset(reset), 
		.enable(enable), 
		.pc_in(if_pc_in),
		.if_branch(if_branch),	
		.ex_pc(rt_pc),
		.calculated_pc(rt_calculated_pc),
		.ex_branch_taken(rt_branch_taken),
		.ex_en_branch(rt_en_branch),
		
		// outputs 
		`ifdef DEBUG_OUT
		.valid_out(valid_out),
		.tag_out(tag_out),
		.target_address_out(target_address_out),
		`endif
		
		.target_pc(target_pc),
		.valid_target(valid_target)
	);

	// OBQ module
	OBQ obq0(
		// inputs
		.clock(clock),
		.reset(reset),
		.write_en(prediction_valid),
		.bh_row(ght),
		.clear_en(clear_en),		// When the prediction is mispredicted
		.index(rt_branch_index),
		.shift_en(shift_en),			// When the branch instruction's prediction is correct, and is retiring
		.shift_index(rt_branch_index),			//??

		// outputs
		`ifdef DEBUG_OUT
		.obq_out(obq_out),
		.tail_out(tail_out),
		`endif

		.row_tag(bh_index),//****************	
		.bh_pred_valid(bh_pred_valid),
		.bh_pred(bh_pred)
	);


	// GSHARE module
	GSHARE gshare0(
		// inputs
		.clock(clock), 
		.reset(reset), 
		.enable(enable),
		.if_branch(if_branch), 
		.pc_in(if_pc_in),
		.obq_bh_pred_valid(bh_pred_valid),
		.obq_gh_in(bh_pred.branch_history),
		.clear_en(clear_en),
		.rt_pc(rt_pc),
		
		// outputs
		`ifdef DEBUG_OUT
		.pht_out(pht_out),
		`endif
		.ght_out(ght), 
		.prediction_valid(prediction_valid),
		.prediction_out(prediction)
	);


	always_ff @(posedge clock) begin

		if(reset) begin
			next_pc		<= 32'h0;
			next_pc_index	<= 0;
			next_pc_valid	<= 1'b1;
		end


		// Next PC value,	
		if(prediction_valid & prediction & valid_target) begin
		// PC=target_PC if the prediction is valid and taken, and BTB has the target PC
		// value 
			next_pc		<= target_pc;
			next_pc_index	<= bh_index;
			next_pc_valid	<= 1'b1;
		end else begin
		// PC=PC+4 for the other cases  (Prediction is valid but not
		// taken, or Prediction is valid but not in the BTB)
			next_pc		<= if_pc_in +4;
			next_pc_index	<= bh_index; //*********************default bh_idx
			next_pc_valid	<= prediction_valid;
		end


	end

endmodule
