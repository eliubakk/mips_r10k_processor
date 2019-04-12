//                                                                     //
//   Modulename :  pipeline.v                                          //
//                                                                     //
//  Description :  Top-level module of the verisimple pipeline;        //
//                 This instantiates and connects the 5 stages of the  //
//                 Verisimple pipeline togeather.                      //
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////
`include "../../sys_defs.vh"
`define DEBUG
`define SD #1

module pipeline (
    //input   PHYS_REG [`FL_SIZE-1:0] free_check_point,    
    //input MAP_ROW_T [`NUM_GEN_REG-1:0]	map_check_point,
    input         clock,                    // System clock
    input         reset,                    // System reset
    input	        enable,
    input [3:0]   mem2proc_response,        // Tag from memory about current request
    input [63:0]  mem2proc_data,            // Data coming back from memory
    input [3:0]   mem2proc_tag,              // Tag from memory about current reply

    output logic [1:0]  proc2mem_command,    // command sent to memory
    output logic [63:0] proc2mem_addr,      // Address sent to memory
    output logic [63:0] proc2mem_data,      // Data sent to memory

    output logic [3:0]  pipeline_completed_insts,
    output ERROR_CODE   pipeline_error_status,
    output logic [4:0]  pipeline_commit_wr_idx,
    output logic [63:0] pipeline_commit_wr_data,
    output logic        pipeline_commit_wr_en,
    output logic [63:0] pipeline_commit_NPC,
    output logic [5:0]  pipeline_commit_phys_reg,
    output logic [5:0]  pipeline_commit_phys_from_arch,

    // testing hooks (these must be exported so we can test
    // the synthesized version) data is tested by looking at
    // the final values in memory

    // Outputs from IF-Stage 
    output logic [63:0] if_NPC_out,
    output logic [31:0] if_IR_out,
    output logic        if_valid_inst_out,

    // Outputs from IF/ID Pipeline Register
    output logic [63:0] if_id_NPC,
    output logic [31:0] if_id_IR,
    output logic        if_id_valid_inst,

    //outputs from ID/DI Pipeline Register
    output logic [63:0] id_di_NPC,
    output logic [31:0] id_di_IR,
    output logic        id_di_valid_inst,

    // Outputs from DI/IS Pipeline Register       // can output the values from the RS
    output logic [`RS_SIZE-1:0][63:0] rs_table_out_npc,
    output logic [`RS_SIZE-1:0][31:0] rs_table_out_inst_opcode,
    output logic [`RS_SIZE-1:0]       rs_table_out_inst_valid_inst,

    // Outputs from IS/EX Pipeline Register   
    output logic [`NUM_FU_TOTAL-1:0][63:0] issue_reg_npc,
    output logic [`NUM_FU_TOTAL-1:0][31:0] issue_reg_inst_opcode,
    output logic [`NUM_FU_TOTAL-1:0]       issue_reg_inst_valid_inst,
    output RS_ROW_T [`NUM_FU_TOTAL-1:0]			issue_next,
    // // Outputs from ID/EX Pipeline Register
    // output logic [63:0] id_ex_NPC,
    // output logic [31:0] id_ex_IR,
    // output logic        id_ex_valid_inst,

    // // Outputs from EX/MEM Pipeline Register
    // output logic [4:0][63:0] ex_mem_NPC,
    // output logic [4:0] ex_mem_IR,
    // output logic [4:0]       ex_mem_valid_inst,

    // Outputs from MEM/COMP Pipeline Register
      output logic mem_co_valid_inst,   
      output logic [63:0] mem_co_NPC ,        
      output logic [31:0] mem_co_IR ,         
 
    // Outputs from EX/COM Pipeline Register
    output logic [`NUM_FU_TOTAL-1:0][63:0] ex_co_NPC,
    output logic [`NUM_FU_TOTAL-1:0][31:0] ex_co_IR,
    output logic [`NUM_FU_TOTAL-1:0]       ex_co_valid_inst,

    // Outputs from COM/RET Pipeline Register
    output logic [63:0] co_ret_NPC,
    output logic [31:0] co_ret_IR,
    output logic        co_ret_valid_inst,

    //Module outputs
    output RS_ROW_T   [(`RS_SIZE-1):0]    rs_table_out,
    output PHYS_REG   [`NUM_GEN_REG-1:0]  arch_table, 
    output ROB_ROW_T  [`ROB_SIZE-1:0]	    ROB_table_out,
    output MAP_ROW_T  [`NUM_GEN_REG-1:0]	map_table_out,
    output PHYS_REG   [`FL_SIZE-1:0]      free_list_out,

    output logic if_id_enable,
    output logic RS_enable,
    output logic is_pr_enable,
    output logic CDB_enable, 
    output logic ROB_enable, 
    output logic mem_co_enable,
    
    output logic co_ret_enable, 
    output logic dispatch_en, 
    output logic branch_not_taken,
    output logic [`NUM_FU_TOTAL-1:0]   is_ex_enable,
    output logic [`NUM_FU_TOTAL-1:0]   ex_co_enable
);
  parameter FU_NAME [0:(`NUM_TYPE_FU - 1)] FU_NAME_VAL = {FU_ALU, FU_LD, FU_MULT, FU_BR};
  parameter FU_IDX [0:(`NUM_TYPE_FU - 1)] FU_BASE_IDX = {FU_ALU_IDX, FU_LD_IDX, FU_MULT_IDX, FU_BR_IDX};
  parameter [0:(`NUM_TYPE_FU - 1)][1:0] NUM_OF_FU_TYPE = {2'b10,2'b01,2'b01,2'b01};

  // Pipeline register enables
  // logic         if_id_enable, RS_enable, is_pr_enable, CDB_enable, ROB_enable, co_re_enable, co_ret_enable, dispatch_en, branch_not_taken;
  // logic [4:0]   is_ex_enable, ex_co_enable;
  logic fr_read_en;
  logic [`NUM_FU_TOTAL-1:0] issue_stall;
  // Output from the branch predictor
  logic   bp_output;

`ifdef DEBUG
	logic		[`BH_SIZE-1:0]				gshare_ght_out;
	logic		[2**(`BH_SIZE)-1:0]			gshare_pht_out;
	OBQ_ROW_T 	[`OBQ_SIZE-1:0]				obq_out;
	logic 		[$clog2(`OBQ_SIZE)-1:0] 		obq_head_out;
	logic 		[$clog2(`OBQ_SIZE)-1:0] 		obq_tail_out;
	logic 		[`BTB_ROW-1:0]				btb_valid_out;
	logic		[`BTB_ROW-1:0]	[`TAG_SIZE-1:0]		btb_tag_out;
	logic		[`BTB_ROW-1:0]	[`TARGET_SIZE-1:0]	btb_target_address_out;
	logic 		[`RAS_SIZE - 1:0] [31:0] 		ras_stack_out;
	logic 		[$clog2(`RAS_SIZE) - 1:0] 		ras_head_out;
	logic 		[$clog2(`RAS_SIZE) - 1:0] 		ras_tail_out;
`endif



  
  // Outputs from ID stage
  logic [63:0]  id_rega_out;
  logic [63:0]  id_regb_out;
  RS_ROW_T      id_inst_out;
  GEN_REG       id_ra_idx, id_rb_idx, id_rdest_idx;

  //outputs from the maptable
  MAP_ROW_T [`NUM_GEN_REG-1:0]	map_table_out;
  PHYS_REG 		T1; // Output for Dispatch and goes to RS
	PHYS_REG 		T2; // Output for Dispatch and goes to RS
  PHYS_REG    T_old;	// Output for Dispatch and goes to ROB

  // outputs of ID/DI stage
  RS_ROW_T id_di_inst_in;
  GEN_REG id_di_rega;
  GEN_REG id_di_regb;

  logic dispatch_no_hazard;
  logic ROB_enable;

  // outputs from dispatch stage
  RS_ROW_T [(`RS_SIZE - 1):0]		rs_table_out;             // for debugging
  logic   [$clog2(`RS_SIZE):0] rs_free_rows_next_out;
  wand								rs_full;
 // RS_ROW_T [`NUM_FU_TOTAL-1:0]			issue_next;
  
  //Outputs from IS/EX Pipeline Register
  RS_ROW_T [`NUM_FU_TOTAL-1:0] issue_reg;
  logic [`NUM_FU_TOTAL-1:0][63:0] is_ex_T1_value;
  logic [`NUM_FU_TOTAL-1:0][63:0] is_ex_T2_value;
  logic [`NUM_FU_TOTAL-1:0][1:0][63:0] pr_tags_values; 
  logic [`NUM_FU_TOTAL-1:0][1:0][$clog2(`NUM_PHYS_REG)-1:0] issue_reg_tags;
	logic [`NUM_PHYS_REG-1:0][63:0] phys_reg;

  // Outputs from EX-Stage
  logic [`NUM_FU_TOTAL-1:0][63:0] ex_alu_result_out;
  logic ex_take_branch_out;
	logic done;

  logic [`NUM_FU_TOTAL-1:0][$clog2(`NUM_PHYS_REG)-1:0] ex_reg_tags;
  logic [`NUM_FU_TOTAL-1:0]				ex_reg_valid;
  
 RS_ROW_T [3:0] ex_mult_reg; // multiplicationn registers
//   // Outputs from EX/MEM Pipeline Register
//   logic   PHYS_REG [4:0] ex_mem_dest_reg_idx;//Physical register index[T]
//   logic   [4:0]      ex_mem_rd_mem;
//   logic   [4:0]      ex_mem_wr_mem;
//   logic   [4:0]      ex_mem_halt;
//   logic   [4:0]      ex_mem_illegal;
//   logic  [4:0][63:0] ex_mem_rega;
//   logic  [3:0][63:0] ex_mem_alu_result;
//   logic              ex_mem_take_branch;

  // // Outputs from MEM-Stage
   logic [63:0] mem_result_out;
   logic        mem_stall_out;

  // Outputs from EX/COM Pipeline Register
  FU_REG              ex_co_halt;
  FU_REG              ex_co_illegal;
  logic  [`NUM_FU_TOTAL-1:0][$clog2(`NUM_PHYS_REG)-1:0] ex_co_dest_reg_idx;
  logic  [`NUM_FU_TOTAL-1:0][63:0]  ex_co_alu_result;
  logic               ex_co_take_branch;
  logic               ex_co_done;
  FU_REG              ex_co_wr_mem;  
  FU_REG              ex_co_rd_mem;
  logic [63:0] ex_co_rega;

// Outputs from MEM/COM Pipeline Register
  logic  mem_co_halt;
  logic  mem_co_illegal;
  PHYS_REG  mem_co_dest_reg_idx;
  logic [63:0] mem_co_alu_result;


  //Outputs from the complete stage
  logic         co_halt_selected;
  logic         co_illegal_selected;
  PHYS_REG      co_reg_wr_idx_out;
  logic [63:0]  co_reg_wr_data_out;
  logic         co_reg_wr_en_out;
  logic         co_take_branch_selected;
  logic [63:0]  co_NPC_selected;
  logic         co_valid_inst_selected;
  FU_REG        co_selected; // alu which is granted the request from priority selector
  logic         co_branch_valid;
  logic         co_branch_prediction;      
  logic [31:0]  co_IR_selected;
  logic [63:0]  co_alu_result_selected;
  logic         psel_enable;
  FU_REG        gnt_bus;

  // Outputs from COM/RETIRE Pipeline Register    //
  logic         co_ret_halt;
  logic         co_ret_illegal;
  PHYS_REG      co_ret_dest_reg_idx;
  logic [63:0]  co_ret_result;
  logic         co_ret_take_branch;
  logic [63:0]  co_ret_NPC;
  logic [31:0]  co_ret_IR;
  logic         co_ret_valid_inst;
  logic         co_ret_branch_valid;
  logic         co_ret_branch_prediction;


logic branch_valid_disp;  //branch_valid_disp
  //outputs from the ROB
  //PHYS_REG                    rob_fl_arch_Told;
  //PHYS_REG                    rob_arch_retire_reg;
  //logic                       arch_fr_enable;
  ROB_ROW_T rob_retire_out;
  logic [$clog2(`ROB_SIZE):0] rob_free_rows_next_out;
  logic							          rob_full_out;
  ROB_ROW_T [`ROB_SIZE-1:0]		ROB_table_out;
  logic [$clog2(`ROB_SIZE):0] rob_tail_out, rob_head_out;

  //Outputs for the free list
  PHYS_REG [`FL_SIZE-1:0]     fr_rs_rob_T;
  logic [$clog2(`FL_SIZE):0]  fr_tail_out;
  logic [$clog2(`FL_SIZE):0]  fr_num_free_entries; 
	logic fr_empty; 
  PHYS_REG fr_free_reg_T;

  //Outputs from the arch map
  PHYS_REG [`NUM_GEN_REG-1:0] arch_table;

  //Outputs form cdb
  PHYS_REG  CDB_tag_out;
  logic 		CDB_en_out; 
  logic 		busy;

  //Inputs and Outputs form the freelist check
  PHYS_REG [`FL_SIZE - 1:0]   free_list_in;
  logic [$clog2(`FL_SIZE):0]  tail_in;
  
  PHYS_REG [`FL_SIZE - 1:0]   free_list_check;
  logic [$clog2(`FL_SIZE):0]  tail_check;
  logic fr_wr_en;
  
  // // Outputs from MEM/WB Pipeline Register
  // logic         mem_wb_halt;
  // logic         mem_wb_illegal;
  // logic   [4:0] mem_wb_dest_reg_idx;
  // logic  [63:0] mem_wb_result;
  // logic         mem_wb_take_branch;
  logic stall_struc;

  // Outputs from RETIRE-Stage  (These loop back to the register file in ID)
  logic	       retire_inst_busy;
  logic [63:0] retire_reg_wr_data;
  logic  [5:0] retire_reg_wr_idx;
  logic        retire_reg_wr_en;
  logic [63:0] retire_reg_NPC;
  logic  [5:0] retire_reg_phys;;
	logic head_halt;
  logic rob_retire_out_halt;
  logic rob_retire_out_take_branch;
logic rob_retire_out_T_new; 
logic rob_retire_out_T_old; 	
  // Memory interface/arbiter wires
  logic [63:0] proc2Dmem_addr, proc2Imem_addr;
  logic  [1:0] proc2Dmem_command, proc2Imem_command;
  logic  [3:0] Imem2proc_response, Dmem2proc_response;

  // Icache wires
  logic [63:0] cachemem_data;
  logic        cachemem_valid;
  logic  [4:0] Icache_rd_idx;
  logic  [7:0] Icache_rd_tag;
  logic  [4:0] Icache_wr_idx;
  logic  [7:0] Icache_wr_tag;
  logic        Icache_wr_en;
  logic [63:0] Icache_data_out, proc2Icache_addr;
  logic        Icache_valid_out;

  assign pipeline_completed_insts = {3'b0, retire_inst_busy};
  assign pipeline_error_status =  co_ret_illegal  ? HALTED_ON_ILLEGAL :
                                  rob_retire_out_halt ? HALTED_ON_HALT :
                                  NO_ERROR;

  
	// TEMPORARY HACK, DEFINITELY CHANGE THIS WHEN WE ADD THE MEMORY STAGE
	// FOR MEMORY INSTRUCTIONS
//	assign proc2Dmem_command = mem_co_enable ? BUS_LOAD : BUS_NONE;

  assign proc2mem_command =
      (proc2Dmem_command == BUS_NONE) ? proc2Imem_command:proc2Dmem_command;
  assign proc2mem_addr =
      (proc2Dmem_command == BUS_NONE) ? proc2Imem_addr:proc2Dmem_addr;
  assign Dmem2proc_response = 
      (proc2Dmem_command == BUS_NONE) ? 0 : mem2proc_response;
  assign Imem2proc_response =
      (proc2Dmem_command == BUS_NONE) ? mem2proc_response : 0;


  // Actual cache (data and tag RAMs)
  cache cachememory (// inputs
    .clock(clock),
    .reset(reset),
    .wr1_en(Icache_wr_en),
    .wr1_idx(Icache_wr_idx),
    .wr1_tag(Icache_wr_tag),
    .wr1_data(mem2proc_data),

    .rd1_idx(Icache_rd_idx),
    .rd1_tag(Icache_rd_tag),

    // outputs
    .rd1_data(cachemem_data),
    .rd1_valid(cachemem_valid)
  );
 
  // Cache controller
  icache icache_0(// inputs 
    .clock(clock),
    .reset(reset),

    .Imem2proc_response(Imem2proc_response),
    .Imem2proc_data(mem2proc_data),
    .Imem2proc_tag(mem2proc_tag),

    .proc2Icache_addr(proc2Icache_addr),
    .cachemem_data(cachemem_data),
    .cachemem_valid(cachemem_valid),

    // outputs
    .proc2Imem_command(proc2Imem_command),
    .proc2Imem_addr(proc2Imem_addr),

    .Icache_data_out(Icache_data_out),
    .Icache_valid_out(Icache_valid_out),
    .current_index(Icache_rd_idx),
    .current_tag(Icache_rd_tag),
    .last_index(Icache_wr_idx),
    .last_tag(Icache_wr_tag),
    .data_write_enable(Icache_wr_en)
  );



  //////////////////////////////////////////////////
  //                                              //
  //                  IF-Stage                    //
  //                                              //
  //////////////////////////////////////////////////
 
BR_SIG if_branch_inst;
BR_SIG if_id_branch_inst;
BR_SIG id_branch_inst;
BR_SIG id_di_branch_inst;
BR_SIG di_branch_inst;
BR_SIG di_is_branch_inst;
BR_SIG is_branch_inst;
BR_SIG is_ex_branch_inst;
BR_SIG ex_branch_inst;
BR_SIG ex_co_branch_inst;
BR_SIG co_branch_inst;
BR_SIG co_ret_branch_inst;
BR_SIG ret_branch_inst;

logic [63:0] if_PC_reg;
logic ret_pred_correct;

logic if_bp_NPC_valid;
logic [63:0] if_bp_NPC;

logic [63:0] if_fetch_NPC_out;

logic [$clog2(`OBQ_SIZE)-1 : 0] ex_co_branch_index, co_branch_index;
logic [63:0]	ex_co_branch_target, co_branch_target;


 if_stage if_stage_0 (
    // Inputs
    .clock (clock),
    .reset (reset),
    .co_ret_valid_inst(retire_inst_busy),		// ret_branch_inst.en
    .co_ret_take_branch(rob_retire_out_take_branch),	// ret_branch_inst.taken
    .co_ret_target_pc(retire_reg_NPC),			// 
    .Imem2proc_data(Icache_data_out),
    .Imem_valid(Icache_valid_out),
    .dispatch_en(dispatch_no_hazard),				// if_id_enable vs dispatch_no_hazard : doesn't matter. Imem_valid is the key factor
    .co_ret_branch_valid(ret_branch_inst.en),
    .if_bp_NPC(if_bp_NPC),					// If BP prediction is valid, then next PC is updated pc from BP
    .if_bp_NPC_valid(if_bp_NPC_valid),

    // Outputs
    .if_NPC_out(if_fetch_NPC_out), 
    .if_IR_out(if_IR_out),
    .if_PC_reg(if_PC_reg),
    .proc2Imem_addr(proc2Icache_addr),
    .if_valid_inst_out(if_valid_inst_out)
  );

// Small decoder for branch predictor

	always_comb begin
		// Initial value
		if_branch_inst.en = 1'b0;
		if_branch_inst.cond = 1'b0;
		if_branch_inst.direct = 1'b0;
		if_branch_inst.ret = 1'b0;
		if_branch_inst.pc = 64'h0;
		//if_branch_inst.br_idx = {($clog2(`OBQ_SIZE)){0}};
		//if_branch_inst.prediction = 0;
		//if_branch_inst.taken = 0;

		if(if_valid_inst_out & dispatch_no_hazard & !branch_not_taken) begin // BP is valid only when instruction is valid & dispatch is enabled and not flushing
			if_branch_inst.pc = if_PC_reg; // Save current PC
			case (if_IR_out[31:26])
				//COND & DIRECT
				`BEQ_INST, `BNE_INST, `BLE_INST, `BLT_INST, `BGE_INST, `BGT_INST, `BLBC_INST, `BLBS_INST : begin
					if_branch_inst.en = 1'b1;
					if_branch_inst.cond = 1'b1;
					if_branch_inst.direct = 1'b1;
					if_branch_inst.ret = 1'b0;
				end
				//UNCOND & DIRECT
				`BR_INST, `BSR_INST : begin
					if_branch_inst.en = 1'b1;
					if_branch_inst.cond = 1'b0;
					if_branch_inst.direct = 1'b1;
					if_branch_inst.ret = 1'b0;
				end
				// UNCOND & INDIRECT
				`JSR_GRP : begin
					case (if_IR_out[20:19])
					// NOT RETURN
						`JMP_INST, `JSR_INST, `JSR_CO_INST : begin
							if_branch_inst.en = 1'b1;
							if_branch_inst.cond = 1'b0;
							if_branch_inst.direct = 1'b0;
							if_branch_inst.ret = 1'b0;
						end
					// RETURN
						`RET_INST : begin
							if_branch_inst.en = 1'b1;
							if_branch_inst.cond = 1'b0;
							if_branch_inst.direct = 1'b0;
							if_branch_inst.ret = 1'b1;
						end
					endcase
				end			

			endcase	
		end


	end


// Branch predictor prediction evaluation
//1. Direct Cond : target PC incorrect or Prediction incorrect
//2. Direct Uncond : target PC incorrect
//3. Direct cond : target PC incorrect
 
	always_comb begin 
		ret_pred_correct = 1'b1;
		if(ret_branch_inst.en) begin
			if(ret_branch_inst.cond & ret_branch_inst.direct) begin
				ret_pred_correct = (ret_branch_inst.pred_pc == retire_reg_NPC) & (ret_branch_inst.prediction == rob_retire_out_take_branch);
			end else if ( !ret_branch_inst.cond) begin
				if(!ret_branch_inst.ret) begin
					ret_pred_correct = (ret_branch_inst.pred_pc == retire_reg_NPC);
				end else begin
					ret_pred_correct = 1'b1;// No need to flush when the instructon is return
				end
			end
		end
	end

//Flushing condition : During the branch retirement, When the prediction is incorrect
assign branch_not_taken = ret_branch_inst.en & (~ret_pred_correct); //
//should change this, chk1
//assign branch_not_taken = ret_branch_inst.en & rob_retire_out_take_branch; 
 
 
	BP bp0(
		// inputs
		.clock(clock), 
		.reset(reset), 
		.enable(enable),
		
		.if_en_branch(if_branch_inst.en),
		.if_cond_branch(if_branch_inst.cond),
		.if_direct_branch(if_branch_inst.direct),
		.if_return_branch(if_branch_inst.ret), 
		.if_pc_in(if_PC_reg),

		.rt_en_branch(ret_branch_inst.en),			//Get value from retire_inst_busy
		.rt_cond_branch(ret_branch_inst.cond),			
		.rt_direct_branch(ret_branch_inst.direct),		 
		.rt_return_branch(ret_branch_inst.ret),
		.rt_pc(ret_branch_inst.pc),
		.rt_branch_taken(rob_retire_out_take_branch),		// Get value from ret_branch_inst.taken
		.rt_prediction_correct(ret_pred_correct),
		.rt_calculated_pc(retire_reg_NPC),			// This is not come from ret_branc_inst 
		.rt_branch_index(ret_branch_inst.br_idx),		

		// outputs 
		`ifdef DEBUG
		.gshare_ght_out(gshare_ght_out),
		.gshare_pht_out(gshare_pht_out),		
		.obq_out(obq_out),
		.obq_head_out(obq_head_out),
		.obq_tail_out(obq_tail_out),
		.btb_valid_out(btb_valid_out),
		.btb_tag_out(btb_tag_out),
		.btb_target_address_out(btb_target_address_out),
		.ras_stack_out(ras_stack_out),
		.ras_head_out(ras_head_out),
		.ras_tail_out(ras_tail_out),
		`endif
		.next_pc_valid(if_bp_NPC_valid), // Should add this, chk2
		.next_pc_index(if_branch_inst.br_idx),
		.next_pc(if_bp_NPC),
		.next_pc_prediction(if_branch_inst.prediction) // Should add this, chk3

	);


  // Determine the next pc (from Fetch unit or from BP)
	assign if_NPC_out =  if_fetch_NPC_out;
	assign if_branch_inst.pred_pc = if_bp_NPC_valid ? if_bp_NPC : 64'h0 ;
//	assign if_bp_NPC_valid = 1'b0;// Should remove this, chk4
//	assign if_branch_inst.prediction = 1'b0;	// Should remove this, chk5
  //////////////////////////////////////////////////
  //                                              //
  //            IF/ID Pipeline Register           //
  //                                              //
  //////////////////////////////////////////////////
  
assign if_id_enable = (dispatch_no_hazard && if_valid_inst_out); 
//assign if_id_enable = (dispatch_no_hazard && Icache_valid_out); 
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if(reset | branch_not_taken) begin
      if_id_NPC        <= `SD 0;
      if_id_IR         <= `SD `NOOP_INST;
      if_id_valid_inst <= `SD `FALSE;
     
	if_id_branch_inst.en 		<= `SD 1'b0;
	if_id_branch_inst.cond 		<= `SD 1'b0;
	if_id_branch_inst.direct 	<= `SD 1'b0;
	if_id_branch_inst.ret		<= `SD 1'b0;
	if_id_branch_inst.pc 		<= `SD 64'h0;
	if_id_branch_inst.pred_pc	<= `SD 64'h0;
	if_id_branch_inst.br_idx 	<= `SD {($clog2(`OBQ_SIZE)){0}};
	if_id_branch_inst.prediction 	<= `SD 0;
	//if_id_branch_inst.taken 	<= `SD 0;


 
    end else if(if_id_enable) begin
      if_id_NPC        <= `SD if_NPC_out;
      if_id_IR         <= `SD if_IR_out;
      if_id_valid_inst <= `SD if_valid_inst_out;

	if_id_branch_inst	<= `SD if_branch_inst;

    end else if (!dispatch_no_hazard) begin // Freeze the register if there is dispatch hazard
      if_id_NPC        <= `SD if_id_NPC;
      if_id_IR         <= `SD if_id_IR;
      if_id_valid_inst <= `SD if_id_valid_inst;
	
	if_id_branch_inst	<= `SD if_id_branch_inst;

    end else begin
      if_id_NPC        <= `SD 0;
      if_id_IR         <= `SD `NOOP_INST;
      if_id_valid_inst <= `SD `FALSE;

	if_id_branch_inst.en 		<= `SD 1'b0;
	if_id_branch_inst.cond 		<= `SD 1'b0;
	if_id_branch_inst.direct 	<= `SD 1'b0;
	if_id_branch_inst.ret	 	<= `SD 1'b0;
	if_id_branch_inst.pc 		<= `SD 64'h0;
	if_id_branch_inst.pred_pc	<= `SD 64'h0;
	if_id_branch_inst.br_idx 	<= `SD {($clog2(`OBQ_SIZE)){0}};
	if_id_branch_inst.prediction 	<= `SD 0;
	//if_id_branch_inst.taken 	<= `SD 0;


    end
  end
  
  //////////////////////////////////////////////////
  //                                              //
  //                  ID-Stage                    //
  //                                              //
  //////////////////////////////////////////////////
  id_stage id_stage_0 (// Inputs
    .clock(clock),
    .reset(reset),
    .if_id_IR(if_id_IR),
    .if_id_valid_inst(if_id_valid_inst),
    // .if_id_valid_inst(if_valid_inst_out),
    // .retire_reg_wr_en(retire_reg_wr_en),
    // .retire_reg_wr_idx(retire_reg_wr_idx),
    // .retire_reg_wr_data(wb_reg_wr_data_out),

    // Outputs
    //.id_ra_value_out(id_rega_out),
    //.id_rb_value_out(id_regb_out),
    .id_opa_select_out(id_inst_out.inst.opa_select),
    .id_opb_select_out(id_inst_out.inst.opb_select),
    //.id_dest_reg_idx_out(id_inst_out.inst.dest_reg),
    .id_alu_func_out(id_inst_out.inst.alu_func),
    .id_fu_name_out(id_inst_out.inst.fu_name),
    .id_rd_mem_out(id_inst_out.inst.rd_mem),
    .id_wr_mem_out(id_inst_out.inst.wr_mem),
    .id_ldl_mem_out(id_inst_out.inst.ldl_mem),
    .id_stc_mem_out(id_inst_out.inst.stc_mem),
    .id_cond_branch_out(id_inst_out.inst.cond_branch),
    .id_uncond_branch_out(id_inst_out.inst.uncond_branch),
    .id_halt_out(id_inst_out.inst.halt),
    .id_cpuid_out(id_inst_out.inst.cpuid),
    .id_illegal_out(id_inst_out.inst.illegal),
    .id_valid_inst_out(id_inst_out.inst.valid_inst),
    .ra_idx(id_ra_idx),
    .rb_idx(id_rb_idx),
    .rdest_idx(id_rdest_idx)
  );

  // Instantiating the map table
  Map_Table m1( //Inputs
    .clock(clock),
  	.reset(reset),
  	.enable(fr_read_en),		// Should not read during stalling for structural hazard
  	.reg_a(id_ra_idx), 		// Comes from Decode duringmem2proc_data
  	.reg_b(id_rb_idx), 		// Comes from Decode duringmem2proc_data
  	.reg_dest(id_rdest_idx), 	// Comes from Dmem2proc_data
  	.free_reg(fr_free_reg_T), 	// Comes from Free List durmem2proc_data
  	.CDB_tag_in(CDB_tag_out), 	// Comes from CDB durinmem2proc_data
  	.CDB_en(CDB_enable),     	// Comes from CDB during Commitmem2proc_data
  	.map_check_point(arch_table),
  	.branch_incorrect(branch_not_taken),
  	
    .map_table_out(map_table_out),
  	.T1(id_inst_out.T1), 		// Output for Dispatch and goes to RS
  	.T2(id_inst_out.T2), 		// Output for Dispatch and goes to RS
  	.T_old(T_old) 		// Output for Dispatch and goes to RS and ROB
  );

  //Instantiating the freelist
  
  // assign fr_read_en= if_id_enable & id_inst_out.inst.valid_inst ;
	assign fr_read_en = id_inst_out.inst.valid_inst & dispatch_no_hazard; // Should not read during stalling for structural hazard
	assign fr_wr_en = (rob_retire_out.T_old == `DUMMY_REG) ? 0 : 1; 
	
	logic id_no_dest_reg;// Instructions that does not have destination register
	assign id_no_dest_reg = (id_rdest_idx == `ZERO_REG );

  Free_List f0(
    // INPUTS
    .clock(clock),
    .reset(reset),
    .enable(fr_wr_en),// Write enable from ROB during retire
    .T_old(rob_retire_out.T_old), // Comes from ROB during Retire Stage
    .T_new(rob_retire_out.T_new),
    .dispatch_en(fr_read_en), // Structural Hazard detection during Dispatch
    .id_no_dest_reg(id_no_dest_reg), // enabled when dispatched instruction is branch
    // inputs for branch misprediction
    .branch_incorrect(branch_not_taken),
    //.free_check_point(free_list_check),
    //.tail_check_point(tail_check),

    `ifdef DEBUG
    .free_list_out(fr_rs_rob_T),
    .tail_out(fr_tail_out),
    `endif

    .num_free_entries(fr_num_free_entries), // Used for Dispatch Hazard
    .empty(fr_empty), // Used for Dispatch Hazard
    .free_reg(fr_free_reg_T) // Output for Dispatch for other modules
  );

 // Update the free list check point when the instruction is branch
// assign free_list_in = ;
 //assign tail_in = ;
  

  //Instantiating the freelist check_point
 /* Free_List_Check flc(
    .clock(clock),
    .enable(enable),
    .free_list_in(free_list_in),
    .tail_in(tail_in),

    .free_list_check(free_list_check),

    .tail_check(tail_check)
  );*/

  always_comb begin
    if (id_inst_out.inst.valid_inst) begin
      assign  id_inst_out.T = fr_free_reg_T;
    end else begin
      assign  id_inst_out.T = `DUMMY_REG;
    end
  end
  // if (fr_read_en) assign id_inst_out.T = fr_free_reg_T;
  // else            assign id_inst_out.T = `DUMMY_REG;
  
  //For ROB
  assign id_inst_out.inst_opcode = if_id_IR;
  assign id_inst_out.npc = if_id_NPC; 
  assign id_branch_inst = if_id_branch_inst;	

  //////////////////////////////////////////////////
  //                                              //
  //                  ID/DI-registers             //
  //                                              //
  //////////////////////////////////////////////////

logic dispatch_no_hazard_comb;
logic dispatch_no_hazard_RS;

  assign dispatch_no_hazard_comb =  ~((rs_free_rows_next_out == 0) | fr_empty | (rob_free_rows_next_out == 0)); 
always_ff @(posedge clock) begin

	dispatch_no_hazard <= `SD  dispatch_no_hazard_comb;  
	//dispatch_no_hazard_RS <= `SD dispatch_no_hazard;
	end

	assign id_di_enable = (dispatch_no_hazard && if_id_valid_inst); 
  //assign id_di_enable = (dispatch_no_hazard && if_valid_inst_out);  // always enabled
  //assign id_di_enable = if_valid_inst_out;
	// synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
      if (reset | branch_not_taken) begin
        id_di_rega    <= `SD 0;
        id_di_regb    <= `SD 0;
        id_di_inst_in <= `SD EMPTY_ROW;
        id_di_NPC     <= `SD 0;
        id_di_IR      <= `SD `NOOP_INST;
        id_di_valid_inst  <=`SD `FALSE;
       
 	id_di_branch_inst.en 		<= `SD 1'b0;
	id_di_branch_inst.cond 		<= `SD 1'b0;
	id_di_branch_inst.direct 	<= `SD 1'b0;
	id_di_branch_inst.ret	 	<= `SD 1'b0;
	id_di_branch_inst.pc 		<= `SD 64'h0;
	id_di_branch_inst.pred_pc	<= `SD 64'h0;
	id_di_branch_inst.br_idx 	<= `SD {($clog2(`OBQ_SIZE)){0}};
	id_di_branch_inst.prediction 	<= `SD 0;
	//id_di_branch_inst.taken 	<= `SD 0;


      end else if(id_di_enable) begin // Update the value
        id_di_rega    <= `SD id_rega_out;
        id_di_regb    <= `SD id_regb_out;
        id_di_inst_in <= `SD id_inst_out;
        id_di_NPC     <= `SD if_id_NPC;
        id_di_IR      <= `SD if_id_IR;
        id_di_valid_inst  <= `SD if_id_valid_inst;

	id_di_branch_inst <= `SD if_id_branch_inst;

      end else if(!dispatch_no_hazard) begin // Freeze current value
        id_di_rega    <= `SD id_di_rega;
        id_di_regb    <= `SD id_di_regb;
        id_di_inst_in <= `SD id_di_inst_in;
        id_di_NPC     <= `SD id_di_NPC;
        id_di_IR      <= `SD id_di_IR;
        id_di_valid_inst  <=`SD id_di_valid_inst;

	id_di_branch_inst <= `SD if_id_branch_inst;

     end else  begin
        id_di_rega    <= `SD 0;
        id_di_regb    <= `SD 0;
        id_di_inst_in <= `SD EMPTY_ROW;
        id_di_NPC     <= `SD 0;
        id_di_IR      <= `SD `NOOP_INST;
        id_di_valid_inst  <=`SD `FALSE;
        
	id_di_branch_inst.en 		<= `SD 1'b0;
	id_di_branch_inst.cond 		<= `SD 1'b0;
	id_di_branch_inst.direct 	<= `SD 1'b0;
	id_di_branch_inst.ret	 	<= `SD 1'b0;
	id_di_branch_inst.pc 		<= `SD 64'h0;
	id_di_branch_inst.pred_pc	<= `SD 64'h0;
	id_di_branch_inst.br_idx 	<= `SD {($clog2(`OBQ_SIZE)){0}};
	id_di_branch_inst.prediction 	<= `SD 0;
	//id_di_branch_inst.taken 	<= `SD 0;


	end
  end

  //////////////////////////////////////////////////
  //                                              //
  //                  DI/ISSUE-stages             //
  //                                              //
  //////////////////////////////////////////////////

  assign issue_stall = ~is_ex_enable;
  //assign dispatch_en= ~((free_rows_next == 0) | fr_empty | rob_full_out); 
  assign dispatch_en = dispatch_no_hazard & id_di_valid_inst; 
   //assign RS_enable= (dispatch_en && if_id_valid_inst);
  assign ROB_enable = dispatch_no_hazard & id_inst_out.inst.valid_inst;
  assign RS_enable = dispatch_no_hazard & id_di_valid_inst;
	 RS #(.FU_NAME_VAL(FU_NAME_VAL),
       .FU_BASE_IDX(FU_BASE_IDX),
       .NUM_OF_FU_TYPE(NUM_OF_FU_TYPE)) RS0(
    // inputs
    .clock(clock), 
    .reset(reset), 
    .enable(enable), 
    .CAM_en(CDB_enable), 
    .CDB_in(CDB_tag_out), 
    .dispatch_valid(RS_enable),
    .inst_in(id_di_inst_in), 
    .branch_not_taken(branch_not_taken), 
    .issue_stall(issue_stall),
    .di_branch_inst_idx(id_di_branch_inst.br_idx),//*** Heewoo added to store branch index in RS
    
    // outputs
    .rs_table_out(rs_table_out), 
    .issue_out(issue_next), 
    .free_rows_next(rs_free_rows_next_out),
    .rs_full(rs_full)
  );

  genvar j;
  
  always_comb begin
    for(int i = 0; i < `RS_SIZE; i += 1) begin
      rs_table_out_npc[i] = rs_table_out[i].npc;
      rs_table_out_inst_opcode[i] = rs_table_out[i].inst_opcode;
      rs_table_out_inst_valid_inst[i] = rs_table_out[i].inst.valid_inst;
    end
  end
  
  //////////////////////////////////////////////////
  //                                              //
  //                  ISSUE/EX-Stage              //
  //                                              //
  //////////////////////////////////////////////////


  // synopsys sync_set_reset "reset"
  // always_ff @(posedge clock) begin
  //   if(reset) begin
  //     for(int i = 0; i < `NUM_FU_TOTAL; i += 1) begin
  //       issue_reg[i] <= `SD EMPTY_ROW;
  //     end
  //   end else if(is_ex_enable) begin
  //     issue_reg <= `SD issue_next;
  //   end
  // end

/*  genvar ig;
  for(ig = 0; ig < `NUM_FU_TOTAL; ig += 1) begin
    assign issue_reg_tags[ig][0] = issue_next[ig].T1[$clog2(`NUM_PHYS_REG)-1:0];
    assign issue_reg_tags[ig][1] = issue_next[ig].T2[$clog2(`NUM_PHYS_REG)-1:0];
    assign issue_reg_npc[ig] = issue_next[ig].npc;
    assign issue_reg_inst_opcode[ig] = issue_next[ig].inst_opcode;
    assign issue_reg_inst_valid_inst[ig] = issue_reg[ig].inst.valid_inst;
  end*/
  //Instantiating the physical register
   // Note: Decode signals for load-lock/store-conditional and "get CPU ID"
  //  instructions (id_{ldl,stc}_mem_out, id_cpuid_out) are not connected
  //  to anything because the provided EX and MEM stages do not implement
  //  these instructions.  You will have to implement these instructions
  //  if you plan to do a multicore project.
  // change execution stage module(mult)

  //////////////////////////////////////////////////
  //                                              //
  //            IS/EX Pipeline Register           //
  //                                              //
  //////////////////////////////////////////////////
  always_comb begin
    for (int i = 0; i < `NUM_FU_TOTAL; i += 1) begin
    	//is_ex_enable[i] = (issue_reg[i].inst.valid_inst & ex_co_enable[i]);
    	//is_ex_enable[i] = ex_co_enable[i];
      is_ex_enable[i] = (~issue_reg[i].inst.valid_inst | (issue_reg[i].inst.valid_inst & ex_co_enable[i])); // always enabled - Original stuff
    end
  end
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    for(int i = 0; i < `NUM_FU_TOTAL; i += 1) begin
      if (reset | branch_not_taken) begin
        issue_reg[i]        <= `SD EMPTY_ROW;
      end else if(is_ex_enable[i]) begin // if (reset)
        issue_reg[i] <= `SD issue_next[i];
      end else if (~is_ex_enable[i])begin
		    issue_reg[i] <= `SD issue_reg[i];
	    end else begin
        	issue_reg[i]        <= `SD EMPTY_ROW;
      end // else: !if(reset)
    end
  end // always


  //////////////////////////////////////////////////
  //                                              //
  //                  EX-Stage                    //
  //                                              //
  //////////////////////////////////////////////////
 genvar ig; // Input of physreg
  for(ig = 0; ig < `NUM_FU_TOTAL; ig += 1) begin
    assign issue_reg_tags[ig][0] = issue_reg[ig].T1[$clog2(`NUM_PHYS_REG)-1:0];
    assign issue_reg_tags[ig][1] = issue_reg[ig].T2[$clog2(`NUM_PHYS_REG)-1:0];
    assign issue_reg_npc[ig] = issue_reg[ig].npc;
    assign issue_reg_inst_opcode[ig] = issue_reg[ig].inst_opcode;
    assign issue_reg_inst_valid_inst[ig] = issue_reg[ig].inst.valid_inst;
  end

/*genvar ip; // Output of physreg
  for(ip = 0; ip < `NUM_FU_TOTAL; ip += 1) begin
       if(ip == 3) begin
		 assign ex_reg_valid[3] =  ex_mult_reg[3].inst.valid_inst;
		 assign ex_reg_tags[3] = ex_mult_reg[3].T[$clog2(`NUM_PHYS_REG)-1:0];


	end else begin
		assign ex_reg_valid[ip] = issue_reg[ip].inst.valid_inst;
       		assign ex_reg_tags[ip] = issue_reg[ip].T1[$clog2(`NUM_PHYS_REG)-1:0];
  	end
end*/

// Multiplication : Write after execution 
 assign is_pr_enable = 1;
  phys_regfile regf_0 (
    .rd_idx(issue_reg_tags),
    .rd_out(pr_tags_values),

    `ifdef DEBUG
   	.phys_registers_out(phys_reg),
    `endif
    .wr_clk(clock),
    .wr_en(ex_co_valid_inst),
    .wr_idx(ex_co_dest_reg_idx),
    .wr_data({ex_co_alu_result[4], ex_alu_result_out[3], ex_co_alu_result[2:0]})
  );

 
genvar ik;
  for(ik = 0; ik < `NUM_FU_TOTAL; ++ik) begin
	//assign is_ex_T1_value[ik] = reset? 0 : issue_reg[ik].inst.valid_inst ? pr_tags_values[ik][0] : 0;
	//assign is_ex_T2_value[ik] = reset? 0 : issue_reg[ik].inst.valid_inst ? pr_tags_values[ik][1] : 0;  
	assign is_ex_T1_value[ik] = (reset) ? 0 : pr_tags_values[ik][0];
	assign is_ex_T2_value[ik] = (reset) ? 0 : pr_tags_values[ik][1];  
end

ex_stage ex_stage_0 (
    // Inputs
    .clock(clock),
    .reset(reset), 
    //.id_ex_IR(id_ex_IR),
    .issue_reg(issue_reg),
    .T1_value(is_ex_T1_value),
    .T2_value(is_ex_T2_value),
    // .id_ex_rega(id_ex_rega),
    // .id_ex_regb(id_ex_regb),
    // .id_ex_opa_select(id_ex_opa_select),
    // .id_ex_opb_select(id_ex_opb_select),
    // .id_ex_alu_func(id_ex_alu_func),
    // .id_ex_cond_branch(id_ex_cond_branch),
    // .id_ex_uncond_branch(id_ex_uncond_branch),

    // Outputs
    .ex_alu_result_out(ex_alu_result_out),
   
    .ex_take_branch_out(ex_take_branch_out),
    .done(done)
  );

// Registers for multiplication pipeline. issue_reg_in[3] is the input
// multiplication output is pipelined... We should directly use mult output as
// a register.

always_ff @(posedge clock) begin
	if(reset | branch_not_taken) begin
		for(integer i=0 ; i<3; ++i) begin
			ex_mult_reg[i].npc <= `SD 0;
			ex_mult_reg[i].inst_opcode <= `SD `NOOP_INST;
			ex_mult_reg[i].T <= `SD `ZERO_REG;
			ex_mult_reg[i].inst.wr_mem <= `SD 0;
			
			ex_mult_reg[i].inst.halt<= `SD 0;
			ex_mult_reg[i].inst.illegal <= `SD 0;
			ex_mult_reg[i].inst.valid_inst <= `SD 0;
		end
	end else begin
		ex_mult_reg <=  `SD {ex_mult_reg[1],ex_mult_reg[0],issue_reg[3]};
	end
end


  //////////////////////////////////////////////////
  //                                              //
  //           EX/CO Pipeline Register            //
  //                                              //
  //////////////////////////////////////////////////
  // not sure whether it can be directly assigned
  always_comb begin
    for (integer i=0; i<2; i=i+1) begin
      ex_co_enable[i]= (~ex_co_valid_inst[i])| (ex_co_valid_inst[i] & co_selected[i]);
    end
  end
  assign ex_co_enable[2]= (~ex_co_valid_inst[2])| (ex_co_valid_inst[2] & mem_co_enable);
  //enable signal for the multipler  register
  //assign ex_co_enable[3]=  (done & ~ex_co_valid_inst[3]) | (done & co_selected[3] & ex_co_valid_inst[3]); 
  assign ex_co_enable[3] = 1 ;
  assign ex_co_done = done; // Done itself is enabled during complete stage
  //assign ex_co_alu_result[3] = ex_alu_result_out[3];// Multiplication output is in during complete stage

  assign ex_co_enable[4]= (~ex_co_valid_inst[4]| (ex_co_valid_inst[4] & co_selected[4]));
  /*
   always_comb begin
	for (integer i=0; i<3; i=i+1) begin
      ex_co_enable[i]= (ex_co_valid_inst[i] & co_selected[i]);
    end
  end
 
  //enable signal for the multipler  register
  assign ex_co_enable[3]=  (done & co_selected[3] & ex_co_valid_inst[3]); 

  assign ex_co_enable[4]=  (ex_co_valid_inst[4] & co_selected[4]);
  */
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin//Initialize all registers once
    for (integer i = 0; i < `NUM_FU_TOTAL; i += 1) begin
      if (reset | branch_not_taken) begin
          ex_co_NPC[i]          <= `SD 0;
          ex_co_IR[i]           <= `SD `NOOP_INST;
          ex_co_dest_reg_idx[i] <= `SD `ZERO_REG;
          ex_co_rd_mem[i]       <= `SD 0;
          ex_co_wr_mem[i]       <= `SD 0;
          ex_co_halt[i]         <= `SD 0;
          ex_co_illegal[i]      <= `SD 0;
          ex_co_valid_inst[i]   <= `SD 0;
          //ex_co_rega[i]         <= `SD 0;
          ex_co_alu_result[i]   <= `SD 0;
	  //ex_co_done		<= `SD 1'b0;
      end else if (ex_co_enable[i] && i!=3) begin
		     // these are forwarded directly from ID/EX latches
			    ex_co_NPC[i]          <= `SD issue_reg[i].npc;
       		ex_co_IR[i]           <= `SD issue_reg[i].inst_opcode;
 		      ex_co_dest_reg_idx[i] <= `SD issue_reg[i].T[$clog2(`NUM_PHYS_REG)-1:0];
      		ex_co_rd_mem[i]       <= `SD issue_reg[i].inst.rd_mem;
 		      ex_co_wr_mem[i]       <= `SD issue_reg[i].inst.wr_mem;
      		ex_co_halt[i]         <= `SD issue_reg[i].inst.halt;
       		ex_co_illegal[i]      <= `SD issue_reg[i].inst.illegal;
       		ex_co_valid_inst[i]   <= `SD issue_reg[i].inst.valid_inst;
     		  ex_co_alu_result[i]   <= `SD ex_alu_result_out[i];  
	
	end else if (ex_co_enable[3])  begin // Done is enabled only the one cycle when execution is completed, and comes from issue_reg.inst.valid_inst

          		ex_co_NPC[3]          <= `SD ex_mult_reg[2].npc;
       			ex_co_IR[3]           <= `SD ex_mult_reg[2].inst_opcode;
 		        ex_co_dest_reg_idx[3] <= `SD ex_mult_reg[2].T[$clog2(`NUM_PHYS_REG)-1:0];
 		        ex_co_wr_mem[3]       <= `SD ex_mult_reg[2].inst.wr_mem;
      			ex_co_halt[3]         <= `SD ex_mult_reg[2].inst.halt;
       			ex_co_illegal[3]      <= `SD ex_mult_reg[2].inst.illegal;
       			ex_co_valid_inst[3]   <= `SD ex_mult_reg[2].inst.valid_inst;
			  // these are results of EX stage
     		       ex_co_alu_result[3]   <= `SD ex_alu_result_out[3]; 
			//ex_co_done	      <= `SD done;
      end// else: !if(reset)
    end // for loop end
  end // always

  always_ff @(posedge clock) begin
    if (reset | branch_not_taken) begin
     // ex_co_done <= `SD 0;
     ex_co_rega <= `SD 64'b0;
     // ex_co_rd_mem <= `SD 0;
     // ex_c0_wr_mem <= `SD 0;
      ex_co_take_branch  <= `SD 0;
      ex_co_branch_index <= `SD {$clog2(`OBQ_SIZE){0}};
      ex_co_branch_target <= `SD 0;
    end else if(ex_co_enable[4]) begin
      ex_co_rega <= `SD is_ex_T1_value[2];
      //ex_co_rd_mem <= `SD issue_reg[2].inst;
      //ex_co_wr_mem <= `SD 0;
      ex_co_take_branch  <= `SD ex_take_branch_out;
      ex_co_branch_index <= `SD issue_reg[4].br_idx;
      ex_co_branch_target <=`SD ex_alu_result_out[4]; 
    end 
		//ex_co_done <= `SD 0;

  end
  
   


// //////////////////////////////////////////////////
//   //                                              //
//   //           EX/MEM Pipeline Register           //
//   //                                              //
//   //////////////////////////////////////////////////
//   assign ex_mem_enable = 1'b1; // always enabled
//   // synopsys sync_set_reset "reset"
//   always_ff @(posedge clock) begin
//     if (reset | branch_not_taken) begin
//       ex_mem_NPC          <= `SD 0;
//       ex_mem_IR           <= `SD `NOOP_INST;
//       ex_mem_dest_reg_idx <= `SD `ZERO_REG;
//       ex_mem_rd_mem       <= `SD 0;
//       ex_mem_wr_mem       <= `SD 0;
//       ex_mem_halt         <= `SD 0;
//       ex_mem_illegal      <= `SD 0;
//       ex_mem_valid_inst   <= `SD 0;
//       ex_mem_rega         <= `SD 0;
//       ex_mem_alu_result   <= `SD 0;
//      // ex_mem_take_branch  <= `SD 0;
//     end else begin
//       if (ex_mem_enable)   begin
//       // these are forwarded directly from ID/EX latches
//       ex_mem_NPC          <= `SD ex_co_NPC[2];
//       ex_mem_IR           <= `SD ex_co_IR[2];
//       ex_mem_dest_reg_idx <= `SD ex_co_dest_reg_idx[2];
//       ex_mem_rd_mem       <= `SD ex_co_rd_mem[2];
//       ex_mem_wr_mem       <= `SD ex_co_wr_mem[2];
//       ex_mem_halt         <= `SD ex_co_halt[2];
//       ex_mem_illegal      <= `SD ex_co_illegal[2];
//       ex_mem_valid_inst   <= `SD ex_co_valid_inst[2];
//       ex_mem_rega         <= `SD ex_co_rega;
//       // these are results of EX stage
//       ex_mem_alu_result   <= `SD ex_alu_result_out[2];
//       //ex_mem_take_branch  <= `SD ex_take_branch_out
//     end // if
//    end

//   //////////////////////////////////////////////////
//   //                                              //
//   //                 MEM-Stage                    //
//   //                                              //
//   //////////////////////////////////////////////////
  mem_stage mem_stage_0 (// Inputs
     .clock(clock),
     .reset(reset),
     .ex_mem_rega(ex_co_rega),
     .ex_mem_alu_result(ex_co_alu_result[2]), 
     .ex_mem_rd_mem(ex_co_rd_mem[2]),
     .ex_mem_wr_mem(ex_co_wr_mem[2] ),
     .Dmem2proc_data(mem2proc_data),
     .Dmem2proc_tag(mem2proc_tag),
     .Dmem2proc_response(Dmem2proc_response),
     
     // Outputs
     .mem_result_out(mem_result_out),
     .mem_stall_out(mem_stall_out),
     .proc2Dmem_command(proc2Dmem_command),
     .proc2Dmem_addr(proc2Dmem_addr),
     .proc2Dmem_data(proc2mem_data)
            );

  wire [5:0] mem_dest_reg_idx_out =
             mem_stall_out ? `DUMMY_REG : ex_co_dest_reg_idx[2];
  wire mem_valid_inst_out = ex_co_valid_inst[2] & ~mem_stall_out;

assign stall_struc= ((ex_co_rd_mem[2] & ~ex_co_wr_mem[2]) | (~ex_co_rd_mem[2] & ex_co_wr_mem[2])) & (ex_co_valid_inst[2]) ;

//assign stall_struc= (ex_co_rd_mem[2] & ~ex_co_wr_mem[2]);//   for (i=0; i<5; i=i+1) begin
//     if ()
//   end

  //////////////////////////////////////////////////
  //                                              //
  //           mem/co stage                   //
  //                                              //
  //////////////////////////////////////////////////
  
  assign mem_co_enable= ((~mem_co_valid_inst) | (mem_co_valid_inst & co_selected[2]));
  always_ff @(posedge clock) begin
    if (reset | branch_not_taken ) begin
      mem_co_valid_inst   <= `SD 0;
      mem_co_NPC          <= `SD 0;
      mem_co_IR          <= `SD `NOOP_INST;
      mem_co_halt         <= `SD 0;
      mem_co_illegal      <= `SD 0;
      mem_co_dest_reg_idx <= `SD `DUMMY_REG;
      mem_co_alu_result   <= `SD 64'b0;
    end else if (mem_co_enable) begin
      mem_co_valid_inst   <= `SD mem_valid_inst_out ;
      mem_co_NPC          <= `SD ex_co_NPC[2];
      mem_co_IR           <= `SD ex_co_IR[2];
      mem_co_halt         <= `SD ex_co_halt[2];
      mem_co_illegal      <= `SD ex_co_illegal[2];
      mem_co_dest_reg_idx <= `SD mem_dest_reg_idx_out;
      mem_co_alu_result   <= `SD mem_result_out;
    // end else begin
    //   mem_co_valid_inst   <= `SD mem_valid_inst_out;
    //   mem_co_NPC          <= `SD ex_co_NPC[2];
    //   mem_co_IR          <= `SD ex_co_IR[2];
    //   mem_co_halt         <= `SD ex_co_halt[2];
    //   mem_co_illegal      <= `SD ex_co_illegal[2];
    //   mem_co_dest_reg_idx <= `SD mem_dest_reg_idx_out;
    //   mem_co_alu_result   <= `SD mem_result_out;   
     end
  end
  
 
  
  
  //////////////////////////////////////////////////
  //                                              //
  //           complete stage                     //
  //                                              //
  //////////////////////////////////////////////////
  
  
  
  
  assign psel_enable = ex_co_valid_inst[0] | ex_co_valid_inst[1] | mem_co_valid_inst | done | ex_co_valid_inst[4]; // ask the use of wor
  //priority encoder to select the results of the execution stage to put in cdb
  //Mult has the priority
  psel_generic #(`NUM_FU_TOTAL, 1) psel(
		.req({ ex_co_done, ex_co_valid_inst[4], mem_co_valid_inst, ex_co_valid_inst[1:0]}),  // becasue the valid bit of mult will not be the request signal instead the done signal will be
		.en(psel_enable),
		.gnt({co_selected[3], co_selected[4], co_selected[2:0]}),
    .gnt_bus({gnt_bus[3], gnt_bus[4], gnt_bus[2:0]})
	);
  
    always_comb begin
      if (|co_selected == 1) begin
        for (integer i=0; i< 5; i=i+1) begin
          if(co_selected[i]==1) begin
            if(i==2) begin
              co_NPC_selected               =    mem_co_NPC;
              co_IR_selected                =    mem_co_IR;
              co_halt_selected              =    mem_co_halt;
              co_illegal_selected           =    mem_co_illegal;
              co_valid_inst_selected        =    mem_co_valid_inst;
              co_reg_wr_idx_out             =    mem_co_dest_reg_idx;
              co_take_branch_selected       =    1'b0;
              co_alu_result_selected        =    mem_co_alu_result;
              co_branch_valid               =    1'b0;
            end else begin
              co_NPC_selected               =    ex_co_NPC[i];
              co_IR_selected                =    ex_co_IR[i];
              co_halt_selected              =    ex_co_halt[i];
              co_illegal_selected           =    ex_co_illegal[i];
              co_valid_inst_selected        =    ex_co_valid_inst[i];
              co_reg_wr_idx_out             =    ex_co_dest_reg_idx[i];
              // co_take_branch_selected       =    ex_co_take_branch[i];
              co_alu_result_selected        =    ex_co_alu_result[i];
              if(i == 4) begin // For branch
			          co_branch_valid = ex_co_valid_inst[4];
			          co_take_branch_selected = ex_co_take_branch;
			          co_branch_index = ex_co_branch_index;
			          co_branch_target = ex_co_branch_target;
	          	end
            end
          end         
        end 
      end else begin
          co_NPC_selected             =    0 ;
          co_IR_selected              =   `NOOP_INST;
          co_halt_selected            =    0;
          co_illegal_selected         =    0;
          co_valid_inst_selected      =    0;
          co_reg_wr_idx_out           =   `DUMMY_REG;
          co_take_branch_selected     =    0;
          co_alu_result_selected      =    0;
          co_branch_valid             =    0; 
      end
    end
   
      
  // For branch 

   
  //assign co_branch_prediction = (co_take_branch_selected  == bp_output) ? 1:0 ;// Branch prediction or misprediction
  
  assign CDB_enable = psel_enable; 
  //assign CDB_enable = psel_enable & ~co_branch_valid;                                       // check if theres any valid signal in the alu and also if the inst is branch or not 
  
  //Instantiated the CDB
  CDB CDB_0(
    // Inputs
    .clock(clock),    // Clock
    .reset(reset),  // Asynchronous reset active low
    .enable(CDB_enable), // Clock Enable
    .tag_in(co_reg_wr_idx_out),	// Comes from FU, during commit
    .ex_valid(co_valid_inst_selected),

    // Outputs
    .CDB_tag_out(CDB_tag_out), // Output for commit, goes to modules
    .CDB_en_out(CDB_en_out),  // Output for commit, goes to modules
    .busy(busy)
  );


// wb_stage wb_stage_0 (
//     // Inputs
//     .clock(clock),
//     .reset(reset),
//     .retire_reg_NPC(ex_co_NPC_selected),
//     .mem_wb_result(co_reg_wr_data_out),
//     .mem_wb_dest_reg_idx(co_reg_wr_idx_out),
//     .mem_wb_take_branch(ex_co_take_branch_selected),
//     .mem_wb_valid_inst(ex_co_valid_inst_selected),

//     // Outputs
//     .reg_wr_data_out(co_reg_wr_data_out),
//     .reg_wr_idx_out(co_reg_wr_idx_out),
//     .reg_wr_en_out(co_reg_wr_en_out)
//   );






//  Things to do

// add condition for the branch opcode in the psel
// how to handle the target pc for the branch



  //////////////////////////////////////////////////
  //                                              //
  //           COMPLETE/RETIRE Pipeline Register  //
  //                                              //
  //////////////////////////////////////////////////
  assign co_ret_enable = 1'b1; // always enabled
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset | branch_not_taken) begin
      co_ret_NPC          <= `SD 0;
      co_ret_IR           <= `SD `NOOP_INST;
      co_ret_halt         <= `SD 0;
      co_ret_illegal      <= `SD 0;
      co_ret_valid_inst   <= `SD 0;
      co_ret_dest_reg_idx <= `SD `ZERO_REG;
      co_ret_take_branch  <= `SD 0;
      co_ret_result       <= `SD 0;
      co_ret_branch_valid       <= 'SD 0;
      co_ret_branch_prediction  <= `SD 0;
    end else if (co_ret_enable) begin
      // these are forwarded directly from EX/MEM latches
      co_ret_NPC          <= `SD co_NPC_selected;
      co_ret_IR           <= `SD co_IR_selected;
      co_ret_halt         <= `SD co_halt_selected;
      co_ret_illegal      <= `SD co_illegal_selected;
      co_ret_valid_inst   <= `SD co_valid_inst_selected;
      co_ret_dest_reg_idx <= `SD co_reg_wr_idx_out;
      co_ret_take_branch  <= `SD co_take_branch_selected;
      co_ret_result       <= `SD co_alu_result_selected;
      co_ret_branch_valid      <= `SD co_branch_valid;
      co_ret_branch_prediction <= `SD co_branch_prediction;
      // these are results of MEM stage
      //co_ret_result       <= `SD mem_co_result_out_selected;
    end // else: !if(reset)
  end // always

  // INSTANTIATING THE ROB
   assign branch_valid_disp = (id_inst_out.inst.fu_name ==  FU_BR) ? 1:0 ;
// This should be the same as id_di_branch_inst.en;   

  //  genvar i;
  //  for (i=0; i< `ROB_SIZE; i=i+1) begin
  //     if (ROB_table_out[i].branch_valid) begin
  //       take_branch_reg = ex_co_take_branch;
  //       break;
  //     end
    
   
  ROB R0(
    // INPUTS
  	.clock(clock),
  	.reset(reset),
  	.enable(enable),
  	.T_old_in(T_old), // Comes from Map Table During Dispatch
  	.T_new_in(fr_free_reg_T), // Comes from Free List During Dispatch
  	.CDB_tag_in(CDB_tag_out), // Comes from CDB during Commit
  	.CAM_en(CDB_enable), // Comes from CDB during Commit
	.CDB_br_valid(co_branch_valid),// ****Heewoo, branch valid signal
	.CDB_br_idx(co_branch_index), // ******Heewoo, comes from CDB during commit, branch index
  	.dispatch_en(ROB_enable), // Structural Hazard detection during Dispatch
  	.branch_not_taken(branch_not_taken),
	  .halt_in(id_inst_out.inst.halt),
    .opcode(id_inst_out.inst_opcode),
    .take_branch(co_take_branch_selected),
    //.branch_valid(branch_valid_disp), // ***Heewoo Same as id_di_branch_inst.en
    .id_branch_inst(id_branch_inst), // ***Heewoo added 
    .wr_idx(id_rdest_idx),
    .npc(id_inst_out.npc),
    .co_alu_result(co_alu_result_selected),
  	
    // OUTPUTS
    .retire_out(rob_retire_out),
  	.free_rows_next(rob_free_rows_next_out),
  	.full(rob_full_out), // Used for Dispatch Hazard
  	//.head_halt(head_halt),
    `ifdef DEBUG
    .ROB_table_out(ROB_table_out),
  	.tail_out(rob_tail_out), 
    .head_out(rob_head_out)
    `endif
  );

// retire_reg_wr_idx is physical register

  assign pipeline_commit_wr_idx = retire_reg_wr_idx;
  //assign pipeline_commit_wr_data = phys_reg[retire_reg_phys];
  assign pipeline_commit_wr_data = phys_reg[arch_table[retire_reg_wr_idx][5:0]];
  assign pipeline_commit_wr_en = retire_reg_wr_en & (retire_reg_wr_idx != `ZERO_REG) ;
  assign pipeline_commit_NPC = ret_branch_inst.en ? ret_branch_inst.pc : retire_reg_NPC-4;
  assign pipeline_commit_phys_reg = retire_reg_phys;
  assign pipeline_commit_phys_from_arch = arch_table[retire_reg_wr_idx][5:0]; 
  //assign pipeline_commit_wr_idx = rob_retire_out.T_new;
  //assign pipeline_commit_wr_en = rob_retire_out.busy & (~(rob_retire_out.T_new == `ZERO_REG));
  //assign pipeline_commit_NPC = reset ? 64'h4 : 64'h8;

  
// FF between complete and retire

always_ff @ (posedge clock) begin
	if(reset | branch_not_taken) begin
		retire_inst_busy <= `SD 0;
		retire_reg_wr_idx <= `SD `ZERO_REG;
		retire_reg_wr_en <= `SD 0;
		retire_reg_NPC <= `SD 64'h4;
		retire_reg_phys <= `SD 0;
		rob_retire_out_halt <= `SD 0;
		rob_retire_out_take_branch <= `SD 0;
		rob_retire_out_T_new <= `SD `DUMMY_REG;
		rob_retire_out_T_old <= `SD `DUMMY_REG;
	
	ret_branch_inst.en 		<= `SD 1'b0;
	ret_branch_inst.cond 		<= `SD 1'b0;
	ret_branch_inst.direct 	<= `SD 1'b0;
	ret_branch_inst.ret 	<= `SD 1'b0;
	ret_branch_inst.pc 		<= `SD 64'h0;
	ret_branch_inst.pred_pc	<= `SD 64'h0;
	ret_branch_inst.br_idx 	<= `SD {($clog2(`OBQ_SIZE)){0}};
	ret_branch_inst.prediction 	<= `SD 0;
	//ret_branch_inst.taken 	<= `SD 0;


	end else begin 
		retire_inst_busy <= rob_retire_out.busy;
		retire_reg_wr_idx <= `SD rob_retire_out.wr_idx;
		retire_reg_wr_en <= `SD (rob_retire_out.busy) & (~(rob_retire_out.T_new == `ZERO_REG) & !rob_retire_out.halt);
		retire_reg_NPC <= `SD rob_retire_out.npc;
		retire_reg_phys <= `SD rob_retire_out.T_new;
		rob_retire_out_halt <= `SD rob_retire_out.halt;
    		rob_retire_out_take_branch <= `SD rob_retire_out.take_branch;
		rob_retire_out_T_new <= `SD rob_retire_out.T_new;
		rob_retire_out_T_old <= `SD rob_retire_out.T_old;
		
		if(rob_retire_out.branch_inst.en) begin // For branch retire
			ret_branch_inst.en	<= `SD rob_retire_out.branch_inst.en;
			ret_branch_inst.cond	<= `SD rob_retire_out.branch_inst.cond;
			ret_branch_inst.direct	<= `SD rob_retire_out.branch_inst.direct;
			ret_branch_inst.ret	<= `SD rob_retire_out.branch_inst.ret;
			ret_branch_inst.pc	<= `SD rob_retire_out.branch_inst.pc;
			ret_branch_inst.pred_pc	<= `SD rob_retire_out.branch_inst.pred_pc;
			ret_branch_inst.br_idx	<= `SD rob_retire_out.branch_inst.br_idx;
			ret_branch_inst.prediction <= `SD rob_retire_out.branch_inst.prediction;
			//ret_branch_inst.taken	<= `SD rob_retire_out.branch_inst.taken;
 		end else begin
			ret_branch_inst.en 		<= `SD 1'b0;
			ret_branch_inst.cond 		<= `SD 1'b0;
			ret_branch_inst.direct 	<= `SD 1'b0;
			ret_branch_inst.ret 	<= `SD 1'b0;
			ret_branch_inst.pc 		<= `SD 64'h0;
			ret_branch_inst.pred_pc	<= `SD 64'h0;
			ret_branch_inst.br_idx 	<= `SD {($clog2(`OBQ_SIZE)){0}};
			ret_branch_inst.prediction 	<= `SD 0;
	
		end
	end
  end




logic arch_enable;
//assign arch_enable = rob_retire_out.busy & !rob_retire_out.take_branch;
assign arch_enable = rob_retire_out.busy & !branch_not_taken; 
// assign arch_enable = rob_retire_out.busy;
  //Intsantiating the arch map
  Arch_Map_Table a0(
  	.clock(clock),
  	.reset(reset),
  	.enable(arch_enable),
  	.T_new_in(rob_retire_out.T_new), // Comes from ROB during Retire
    .T_old_in(rob_retire_out.T_old), //What heewoo added. It is required to find which entry should I update. Comes from ROB during retire.

  	.arch_map_table(arch_table) // Arch table status, what heewoo changed from GEN_REG to PHYS_REG
 );


  //////////////////////////////////////////////////
  //                                              //
  //                  WB-Stage                    //
  //                                              //
  //////////////////////////////////////////////////
  // wb_stage wb_stage_0 (
  //   // Inputs
  //   .clock(clock),
  //   .reset(reset),
  //   .retire_reg_NPC(mem_wb_NPC),
  //   .mem_wb_result(mem_wb_result),
  //   .mem_wb_dest_reg_idx(mem_wb_dest_reg_idx),
  //   .mem_wb_take_branch(mem_wb_take_branch),
  //   .mem_wb_valid_inst(mem_wb_valid_inst),

  //   // Outputs
  //   .reg_wr_data_out(retire_reg_wr_data),
  //   .reg_wr_idx_out(retire_reg_wr_idx),
  //   .reg_wr_en_out(retire_reg_wr_en)
  // );

endmodule  // module verisimple
