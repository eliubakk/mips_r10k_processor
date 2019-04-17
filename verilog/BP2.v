// Entire branch predictor module
// Should include BTB, GSHARE, OBQ 
`ifndef PIPELINE
`include "../../sys_defs.vh"
`ifndef SIMV
`include "../../verilog/BTB.v"
`include "../../verilog/RAS.v"
`include "../../verilog/PHT_TWO_SC.v"
`endif
`endif
`define	DEBUG

// Branch misprediction : input is index and clear_en is 1
// Branch correct prediction : input is index and shift_en is 1
//
//Index : 		pc[$clog2(BTB_ROW)+1:2]
//Tag : 		pc [(TAG_SIZE+$clog2(BTB_ROW)+1):($clog2(BTB_ROW)+2)], 
//Target address : 	pc[TARGET_SIZE+1:2]

//-------------------------------Module behavior---------------------------
//1. Conditional and direct 	: Fetch : READ BTB, PHT_TWO_SC, assign br idx
//				  Retire : Update BTB, PHT_TWO_SC
//2. Conditional and indirect 	: Fetch : READ BTB, PHT_TWO_SC, assign br idx
//				  Retire : Update BTB, GSHARE/OBQ
//
//3. Unconditional and direct 	: 
//Fetch : Read BTB, mark as branch_taken
//Retire : Update BTB only

//4. Unconditional and indirect : 
//Fetch : X return - Bring next_pc from BTB, store pc+4 to RAS, (if BTB match, them mark as
//	branch taken)
//	    return - Read RAS and clear it, mark as branch_taken  
//Retire : X return - Write next_pc to BTB
//	    return - Do nothing
//
//BTB is updated when branch is taken (retire)
// Gshare and OBQ are updated when the prediction is wrong (retire)
// RAS is updated when the new instruction comes in (fetch)
//*** May need small decoder at the FETCH outside of BP module
//----------------------------------------------------------------------

module  BP2(
	input 					clock,    // Clock
	input 					reset,  // Asynchronous reset active low
	input 					enable, // Clock Enable

	input					if_en_branch,		// Valid branch instruction
	input					if_cond_branch,		// enabled when the branch is conditional
	input					if_direct_branch,	// enabled when the branch is direct
	input					if_return_branch,	// enabled when the branch is return(Uncond Direct)		
	input		[31:0]			if_pc_in,		// input PC
	// Comes after execute state(after branch calculation)
	input					rt_en_branch,		// enabled when the instruction is branch  
	input					rt_cond_branch,		// enabled when it is conditional branch
	input					rt_direct_branch,       // enbaled when it is direct
	input					rt_return_branch,
	input					rt_branch_taken,	// enabled when the branch is actullly taken
	input					rt_prediction_correct,  // enabled when the branch prediction is correct 
	input		[31:0]			rt_pc,			// PC of the executed branch instruction
	input		[31:0]			rt_calculated_pc,  	// Calculated target PC
	input	[$clog2(`OBQ_SIZE) - 1:0]	rt_branch_index,	// Executed branch's OBQ index 
		
	
	`ifdef DEBUG
//	output		logic	[`BH_SIZE-1:0]				gshare_ght_out,
//	output		logic	[2**(`BH_SIZE)-1:0]			gshare_pht_out,
//	output		OBQ_ROW_T 		[`OBQ_SIZE-1:0]		obq_out,
//	output		logic [$clog2(`OBQ_SIZE)-1:0] 			obq_head_out,
//	output		logic [$clog2(`OBQ_SIZE)-1:0] 			obq_tail_out,
	
	output		logic	[`PHT_ROW-1:0][1:0]			pht_out,
	output		logic 	[`BTB_ROW-1:0]				btb_valid_out,
	output		logic	[`BTB_ROW-1:0]	[`TAG_SIZE-1:0]		btb_tag_out,
	output		logic	[`BTB_ROW-1:0]	[`TARGET_SIZE-1:0]	btb_target_address_out,
	output 		logic [`RAS_SIZE - 1:0] [31:0] 			ras_stack_out,
	output 		logic [$clog2(`RAS_SIZE) - 1:0] 		ras_head_out,
	output 		logic [$clog2(`RAS_SIZE) - 1:0] 		ras_tail_out,
	`endif

	output		logic						next_pc_valid,		// Enabled when next_pc value is valid pc
	output 		logic 	[$clog2(`OBQ_SIZE) - 1:0]		next_pc_index, 		// ************Index from OBQ	
	output		logic	[31:0]					next_pc,
	output		logic						next_pc_prediction	// enabled when next pc is predicted to be taken
	
);
	// Do not fetch during rollback
	
		logic roll_back;	

	// Branch index without OBQ
	logic	[$clog2(`OBQ_SIZE)-1 :0]	br_idx, next_br_idx;	

	// Inputs for submodules
		// For 2bit bimodal
		logic bp_read_en;				// Fetch, enabled for conditional branch, read prediction
		logic bp_write_en;				// Retire, enabled for conditional branch, update prediction

		// For BTB
		logic btb_read_en;
		logic btb_write_en;

		// For RAS
		logic ras_write_en;				// Fetch, RAS write((write_en in RAS) of uncond-indirect
		logic ras_read_en;				// Fetch, RAS read(clear_en in RAS) of return (uncond direct)

	// Outputs for submodules
		// For 2bit bimodal
		logic if_prediction_valid;
		logic if_prediction;

		// BTB signals
		logic	[31:0]			btb_next_pc; 	
		logic				btb_next_pc_valid;

		// RAS signals
		logic	[31:0]			ras_next_pc;
		logic				ras_next_pc_valid;

	// Outputs for BP module
		logic					next_pc_valid_calc;
		logic 	[$clog2(`OBQ_SIZE) - 1:0]	next_pc_index_calc; 		
		logic	[31:0]				next_pc_calc;
		logic					next_pc_prediction_calc;	


	// BP module output, should be combinational 
	/*	assign next_pc_valid 		= reset ? 1'b0 : next_pc_valid_calc;
		//assign next_pc_index 		= reset ? {($clog2(`OBQ_SIZE) - 1){0}} : next_pc_index_calc;
		assign next_pc_index 		= reset ? {($clog2(`OBQ_SIZE)-1){0}} : br_idx;
		assign next_pc			= reset ? 32'h0 : next_pc_calc;
		assign next_pc_prediction	= reset ? 1'b0 : next_pc_prediction_calc;	    
*/
		assign next_pc_valid 		= next_pc_valid_calc;
		assign next_pc_index 		= br_idx;
		assign next_pc			= next_pc_calc;
		assign next_pc_prediction	= next_pc_prediction_calc;	    

	//----------Value evaluation
	// Fetch is invalid during roll back
	assign roll_back	= rt_en_branch & ~rt_prediction_correct; 

	// Prediction is incorrect when
	// 1. Direct Cond : target PC incorrect or prediction incorrect
	// 2. Direct Uncond : target PC incorrect
	// 3. Direct Cond : target PC incorrect


	// 1. Input value evaluation

	//------Bimodal predictor

	
	// During Fetch
	assign bp_read_en = (!roll_back) & if_en_branch & if_cond_branch;
	// During retire
	assign bp_write_en = rt_en_branch & rt_cond_branch; 	

	//----- BTB
	// During fetch		/ Everytime when branch comes in except return
	// branch
	assign btb_read_en	= (!roll_back) & if_en_branch & !(if_return_branch); 				
	// During retirement	/ update when branch is taken (except
	//return)
	assign btb_write_en	= rt_en_branch & rt_branch_taken & !rt_return_branch ; 				

	// -----RAS	
	// During fetch 	/ unconditional indirect but not return branch
	assign ras_write_en	=  (!roll_back) & if_en_branch & !if_cond_branch & !if_direct_branch & !if_return_branch;
	// During fetch		/ return branch
	assign ras_read_en	=  (!roll_back) & if_en_branch & if_return_branch;				

	// internal registers


	// 2bit bimodal predictor
	
	PHT_TWO_SC pht_0(
		// inputs
		.clock(clock), 
		.reset(reset), 
		.enable(enable), 
		.if_branch(bp_read_en),
		.if_pc_in(if_pc_in),
		.rt_branch(bp_write_en),
		.rt_pc_in(rt_pc),
		.rt_branch_taken(rt_branch_taken),
		
		// outputs 
		`ifdef DEBUG
		.pht_out(pht_out),
		`endif	
	
		.if_prediction(if_prediction),
		.if_prediction_valid(if_prediction_valid)
	);



	// BTB module	

	BTB btb0(
		// inputs
		.clock(clock), 
		.reset(reset), 
		.enable(enable), 
		.pc_in(if_pc_in),
		.if_branch(btb_read_en),	
		.ex_pc(rt_pc),
		.calculated_pc(rt_calculated_pc),
		.ex_branch_taken(rt_branch_taken),
		.ex_en_branch(btb_write_en),
		
		// outputs 
		`ifdef DEBUG
		.valid_out(btb_valid_out),
		.tag_out(btb_tag_out),
		.target_address_out(btb_target_address_out),
		`endif
		
		.target_pc(btb_next_pc),
		.valid_target(btb_next_pc_valid)
	);

	// RAS module

	RAS ras0 (
		// inputs
		.clock(clock),
		.reset(reset),
		.write_en(ras_write_en),
		.clear_en(ras_read_en),
		.current_pc(if_pc_in),

		// outputs
		`ifdef DEBUG
		.stack_out(ras_stack_out),
		.head_out(ras_head_out),
		.tail_out(ras_tail_out),
		`endif
		.next_pc(ras_next_pc),
		.valid_out(ras_next_pc_valid)

	);


	// --------------------------------------------------------
	// ---------------------Determining the output of BP module
	// --------------------------------------------------------
	
	always_comb begin
		// value initialization
		next_pc_valid_calc			= 1'b0;
		//next_pc_index_calc			= {($clog2(`OBQ_SIZE+1)){0}}; 						
	
		next_br_idx				= br_idx; 						
		next_pc_calc				= if_pc_in + 4;			
		next_pc_prediction_calc			= 1'b0;

		if(enable) begin
			// Instruction should not fetch during roll back!
			if(roll_back) begin
				next_pc_valid_calc = 1'b0;

			end else begin

				if(if_en_branch & if_cond_branch) begin
				// ----------Conditional direct/indirect
				// If prediction is taken, then bring value from BTB
				// If prediction is not taken or BTB not match, then PC+4
					if(if_prediction_valid & if_prediction & btb_next_pc_valid) begin
						next_pc_valid_calc	 = 1'b1;
						//next_pc_index_calc	 = bh_index;
						next_br_idx		= br_idx + 1;
						next_pc_calc		 = btb_next_pc;
						next_pc_prediction_calc	 = 1'b1;
					end else begin
						next_pc_valid_calc	 = 1'b0;
						//next_pc_index_calc	 = bh_index;
						next_br_idx		= br_idx + 1;
						next_pc_calc		 = if_pc_in + 4;
						next_pc_prediction_calc	 = 1'b0;
					end			
					

				end else if(if_en_branch & !if_cond_branch & if_direct_branch) begin
				// ----------Unconditional direct
				//Bring value from BTB when it is in BTB,
				// PC + 4 when BTB not match
					if(btb_next_pc_valid) begin
						next_pc_valid_calc	 = 1'b1;
						//next_pc_index_calc	 = {($clog2(`OBQ_SIZE) - 1){0}};
						next_br_idx		= br_idx + 1;
						next_pc_calc		 = btb_next_pc;
						next_pc_prediction_calc	 = 1'b1;
					end else begin
						next_pc_valid_calc	 = 1'b0;
						//next_pc_index_calc	 = {($clog2(`OBQ_SIZE) - 1){0}};
						next_br_idx		= br_idx + 1;
						next_pc_calc		 = if_pc_in + 4;
						next_pc_prediction_calc	 = 1'b0;
					end
			
				end else if (if_en_branch & !if_cond_branch & !if_direct_branch) begin
			// ----------Unconditional indirect
			// Find the next PC at the BTB, if not, then PC+4
			// For return : bring value from RAS when it is in
			// RAS, PC +4 when RAS not match
					if(if_return_branch) begin
						if(ras_next_pc_valid) begin
							next_pc_valid_calc	 = 1'b1;
							//next_pc_index_calc	 = {($clog2(`OBQ_SIZE)+1){0}};
							next_br_idx		= br_idx + 1;
							next_pc_calc		 = ras_next_pc;
							next_pc_prediction_calc	 = 1'b1;
						end else begin
							next_pc_valid_calc	 = 1'b0;
							//next_pc_index_calc	 = {($clog2(`OBQ_SIZE)+1){0}};
							next_br_idx		= br_idx + 1;
							next_pc_calc		 = if_pc_in + 4;
							next_pc_prediction_calc	 = 1'b0;
						end 
					end else begin
						if(btb_next_pc_valid) begin
							next_pc_valid_calc	 = 1'b1;
							//next_pc_index_calc	 = {($clog2(`OBQ_SIZE)+1){0}};
							next_br_idx		= br_idx + 1;
							next_pc_calc		 = btb_next_pc;
							next_pc_prediction_calc	 = 1'b1;
						end else begin
							next_pc_valid_calc	 = 1'b0;
							//next_pc_index_calc	 = {($clog2(`OBQ_SIZE)+1){0}};
							next_br_idx		= br_idx + 1;
							next_pc_calc		 = if_pc_in + 4;
							next_pc_prediction_calc	 = 1'b0;
						end
					end

				end else begin
					next_pc_valid_calc	= 1'b0;
				end
			end
		end
			

	end


	always_ff @(posedge clock) begin
		if(reset) begin
			br_idx <= `SD {($clog2(`OBQ_SIZE)){0}};
		end else begin
			br_idx <= `SD next_br_idx;
		end

	end

/*	always_ff @(posedge clock) begin

		if(reset) begin
			next_pc_valid		<= 1'b0;
			next_pc_index		<= {($clog2(`OBQ_SIZE) - 1){0}};
			next_pc			<= 32'h0;
			next_pc_prediction	<= 1'b0;
		end else begin
			next_pc_valid		<= next_pc_valid_calc;
			next_pc_index		<= next_pc_index_calc;
			next_pc			<= next_pc_calc;
			next_pc_prediction	<= next_pc_prediction_calc;

		end
*/

/*
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

	end*/

endmodule
