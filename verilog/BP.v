// Entire branch predictor module
// Should include BTB, GSHARE, OBQ 
`include "../sys_defs.vh"
`include "./BTB.v"
`include "./GSHARE.v"
`include "./OBQ.v"	

`define	DEBUG_OUT

// Need to define parameters in sys_defs.vh
// For GSHARE
`define GHT_BIT	4
`define PC_BIT	4
// For BTB
`define TAG_SIZE 10	// Tag bit size
`define TARGET_SIZE 12	// Target address size, BTB will store [TARGET_SIZE+1:2]
`define BTB_ROW	16	// BTB row size : 5~10% of I$ size
//Index : 		pc[$clog2(BTB_ROW)+1:2]
//Tag : 		pc [(TAG_SIZE+$clog2(BTB_ROW)+1):($clog2(BTB_ROW)+2)], 
//Target address : 	pc[TARGET_SIZE+1:2]



module  BP(
	input 				clock,    // Clock
	input 				reset,  // Asynchronous reset active low
	input 				enable, // Clock Enable

	input				if_branch,		// input PC is for valid branch instruction
	input		[31:0]		pc_in,			// PC
	// Comes after execute state(after branch calculation)
	input				ex_en_branch,		// enabled when the instruction is branch  
	input				ex_branch_taken,	// enabled when the branch is taken
	input		[31:0]		ex_pc,			// PC of the executed branch instruction
	input		[31:0]		calculated_pc,  	// Calculated target PC
		

		

	
	`ifdef DEBUG_OUT
	`endif
	output				next_pc_valid,		// Enabled when next_pc value is valid pc
	output		
	output		[31:0]		next_pc			
	
);

	// BTB signals
	logic	[31:0]	target_pc; 	
	logic		valid_target;


	// OBQ signals
	logic write_en;
	OBQ_ROW_T bh_row;

	logic clear_en;
	logic [$clog2(`OBQ_SIZE)-1:0] index;
	
	logic bh_pred_valid;
	OBQ_ROW_T bh_pred;


	// output wires
	OBQ_ROW_T [`OBQ_SIZE-1:0] obq_out;
	logic [$clog2(`OBQ_SIZE)-1:0] tail_out;
	logic bh_pred_valid;
	OBQ_ROW_T bh_pred;



	// GSHARE signals
 
	logic							obq_bh_pred_valid;
	logic	[`GHT_BIT-1:0]					obq_gh_in;
	logic							clear_en;

	logic							prediction_valid;
	logic	 						prediction;
	// BTB module	


	BTB btb0(
		// inputs
		.clock(clock), 
		.reset(reset), 
		.enable(enable), 
		.pc_in(pc_in),
		.if_branch(if_branch),	
		.ex_pc(ex_pc),
		.calculated_pc(calculated_pc),
		.ex_branch_taken(ex_branch_taken),
		.ex_en_branch(ex_en_branch),
		
		// outputs 
	
		
		.target_pc(target_pc),
		.valid_target(valid_target)
	);

	// OBQ module
	OBQ obq0(
		// inputs
		.clock(clock),
		.reset(reset),
		.write_en(write_en),
		.bh_row(bh_row),
		.clear_en(clear_en),
		.index(index),

		// outputs
		.obq_out(obq_out),
		.tail_out(tail_out),
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
		.pc_in(pc_in),
		.obq_bh_pred_valid(obq_bh_pred_valid),
		.obq_gh_in(obq_gh_in),
		.clear_en(clear_en),
		
		// outputs 
		.prediction_valid(prediction_valid),
		.prediction_out(prediction)
	);



	always_ff @(posedge clock) begin
	

	end

endmodule
