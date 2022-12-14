////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  if_stage.v                                          //
//                                                                     //
//  Description :  instruction fetch (IF) stage of the pipeline;       // 
//                 fetch instruction, compute next PC location, and    //
//                 send them down the pipeline.                        //
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

`include "../../sys_defs.vh"
module if_stage(
    input         clock,                  // system clock
    input         reset,                  // system reset
    input         co_ret_valid_inst,      // only go to next instruction when true
                                          // makes pipeline behave as single-cycle
    input        co_ret_take_branch,      // taken-branch signal
    input [63:0] co_ret_target_pc,        // target pc: use if take_branch is TRUE
    input [63:0] Imem2proc_data,          // Data coming back from instruction-memory
    input        Imem_valid,
    input dispatch_en,                    // dispatch enable signal
    input co_ret_branch_valid,            // whether the inst is branch or not

    input [63:0] if_bp_NPC,
    input if_bp_NPC_valid,

    output logic [63:0] proc2Imem_addr,   // Address sent to Instruction memory
    output FETCHED_INST_T if_fetched_inst_out
    //output logic [63:0] if_PC_reg, 	   // Current PC, used in BP to calculate next_PC **** Heewoo Change
    //output logic [63:0] if_NPC_out,        // PC of instruction after fetched (PC+4).
    //output logic [31:0] if_IR_out,        // fetched instruction out
    //output logic        if_valid_inst_out  // when low, instruction is garbage
  );


  logic [63:0] PC_reg;             // PC we are currently fetching
  //logic        ready_for_valid;

  logic [63:0] PC_plus_4;
  logic [63:0] next_PC;
  logic        PC_enable;
  //logic        next_ready_for_valid;
  //logic		     if_valid_inst;
	//assign if_PC_reg = PC_reg;
  assign if_fetched_inst_out.pc = PC_reg;

	assign PC_enable = ((dispatch_en & Imem_valid) & !((if_bp_NPC_valid)) | (co_ret_take_branch));
	// When NPC is given by branch predictor

  assign proc2Imem_addr = PC_reg;

  // this mux is because the Imem gives us 64 bits not 32 bits
  assign if_fetched_inst_out.ir = PC_reg[2] ? Imem2proc_data[63:32] : Imem2proc_data[31:0];

  // default next PC value
  assign PC_plus_4 = PC_reg + 4;

  // next PC is target_pc if there is a taken branch or
  // the next sequential PC (PC+4) if no branch
  // For branch instruction, NPC will be the PC from BP
  // (halting is handled with the enable PC_enable;
  //assign next_PC = if_bp_NPC_valid ? if_bp_NPC : PC_plus_4;
  assign next_PC = PC_plus_4;
	/*assign next_PC = co_ret_take_branch) ?  co_ret_target_pc : 
			if_bp_NPC_valid ? if_bp_NPC : PC_plus_4;*/

  // The take-branch signal must override stalling (otherwise it may be lost)
  //assign PC_enable = if_valid_inst_out || ex_mem_take_branch;

  // Pass PC+4 down pipeline w/instruction
  assign if_fetched_inst_out.npc = PC_plus_4;
  //assign if_NPC_out = PC_plus_4;

  //assign if_valid_inst_out = ready_for_valid && Imem_valid;

  assign if_fetched_inst_out.valid_inst = Imem_valid & dispatch_en;
  //assign if_valid_inst_out = PC_enable; 
  //assign if_valid_inst_out = co_ret_take_branch | PC_enable;
  // assign next_ready_for_valid = (ready_for_valid || co_ret_valid_inst) && 
  //                               !if_valid_inst_out;

  // This register holds the PC value
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if(reset) begin
      PC_reg <= `SD 64'b0;       // initial PC value is 0
   end else if (co_ret_take_branch) begin
      PC_reg <= `SD co_ret_target_pc;
  end else if (!co_ret_take_branch & if_bp_NPC_valid) begin
      PC_reg <= `SD if_bp_NPC;
   end else if(PC_enable) begin
      PC_reg <= `SD next_PC; // transition to next PC
  end 
end  // always

  // This FF controls the stall signal that artificially forces
  // fetch to stall until the previous instruction has completed
  // synopsys sync_set_reset "reset"
  // always_ff @(posedge clock) begin
  //   if (reset)
  //     ready_for_valid <= `SD 1;  // must start with something
  //   else
  //     ready_for_valid <= `SD next_ready_for_valid;
  // end
  
endmodule  // module if_stage
