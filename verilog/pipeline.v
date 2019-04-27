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
//`include "../../cache_defs.vh"
`define DEBUG
`define SD #1

module pipeline (
    //input   PHYS_REG [`FL_SIZE-1:0] free_check_point,    
    //input MAP_ROW_T [`NUM_GEN_REG-1:0]	map_check_point,
    input         clock,                    // System clock
    input         reset,                    // System reset
    input	        enable,
    input MEM_TAG   mem2proc_response,        // Tag from memory about current request
    input [63:0]    mem2proc_data,            // Data coming back from memory
    input MEM_TAG   mem2proc_tag,              // Tag from memory about current reply

    output BUS_COMMAND  proc2mem_command,    // command sent to memory
    output logic [63:0] proc2mem_addr,      // Address sent to memory
    output logic [63:0] proc2mem_data,      // Data sent to memory

   
    output BUS_COMMAND	proc2Rmem_command_out,	// For synthesize debugging
    output BUS_COMMAND	proc2Dmem_command_out,	// For synthesize debugging
    output BUS_COMMAND	proc2Imem_command_out,	// For synthesize debugging
    output logic	send_request_out,
    output logic	unanswered_miss_out,

    output logic [3:0]  pipeline_completed_insts,
    output ERROR_CODE   pipeline_error_status,
    output GEN_REG      pipeline_commit_wr_idx,
    output logic [63:0] pipeline_commit_wr_data,
    output logic        pipeline_commit_wr_en,
    output logic [63:0] pipeline_commit_NPC,
    output PHYS_REG     pipeline_commit_phys_reg,
    output PHYS_REG     pipeline_commit_phys_from_arch,

    // To record the branch prediction accuracy

    output logic	pipeline_branch_en,
    output logic	pipeline_branch_pred_correct,
    

    output logic	      retire_inst_busy,
    output logic [63:0] retire_reg_NPC,

    // testing hooks (these must be exported so we can test
    // the synthesized version) data is tested by looking at
    // the final values in memory

    // Outputs from DI/IS Pipeline Register       // can output the values from the RS

    // Outputs from IS/EX Pipeline Register   
    output RS_ROW_T [`NUM_FU_TOTAL-1:0]		 issue_next,
    // // Outputs from ID/EX Pipeline Register

    // // Outputs from EX/MEM Pipeline Register

    output CACHE_SET_T [(`NUM_SETS-1):0] dcache_data,
    output VIC_CACHE_T [(`VIC_SIZE-1):0] vic_queue_out,
    output RETIRE_BUF_T [(`RETIRE_SIZE-1):0] retire_queue,
    output logic [$clog2(`RETIRE_SIZE):0] retire_queue_tail,

    // Outputs from MEM/COMP Pipeline Register
    output logic        mem_co_valid_inst,   
    output logic [63:0] mem_co_NPC,        
    output logic [31:0] mem_co_IR,         
 
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
  parameter FU_NAME [0:(`NUM_TYPE_FU - 1)] FU_NAME_VAL = {FU_ALU, FU_LD, FU_MULT, FU_BR, FU_ST};
  parameter FU_IDX [0:(`NUM_TYPE_FU - 1)] FU_BASE_IDX = {FU_ALU_IDX, FU_LD_IDX, FU_MULT_IDX, FU_BR_IDX, FU_ST_IDX};
  parameter [0:(`NUM_TYPE_FU - 1)][1:0] NUM_OF_FU_TYPE = {2'b10,2'b01,2'b01,2'b01, 2'b01};


  // --------------------------Fetch1 signals  


  // -------------------------Fetch2 signals

  // Output from the branch predictor
  logic   bp_output;

	/*logic		[`BH_SIZE-1:0]				gshare_ght_out;
	logic		[2**(`BH_SIZE)-1:0]			gshare_pht_out;
	OBQ_ROW_T 	[`OBQ_SIZE-1:0]				obq_out;
	logic 		[$clog2(`OBQ_SIZE)-1:0] 		obq_head_out;
	logic 		[$clog2(`OBQ_SIZE)-1:0] 		obq_tail_out;*/
	logic [`BTB_ROW-1:0]				         btb_valid_out;
	logic	[`BTB_ROW-1:0][`TAG_SIZE-1:0]  btb_tag_out;
	logic	[`BTB_ROW-1:0][`TARGET_SIZE-1:0]	btb_target_address_out;
	logic [`RAS_SIZE - 1:0][31:0] ras_stack_out;
	logic [$clog2(`RAS_SIZE)-1:0] ras_head_out;
	logic [$clog2(`RAS_SIZE)-1:0] ras_tail_out;

  // -------------------------------Instruction queue
 	INST_Q [`IQ_SIZE-1:0] 		  inst_queue_out;
	logic  [$clog2(`IQ_SIZE):0] inst_queue_entry;
	logic		inst_queue_full;
	INST_Q	iq_inst_in, if_id_inst;


  // -----------------------------------Decode stage
  
  // Outputs from ID stage
  logic [63:0]  id_rega_out;
  logic [63:0]  id_regb_out;
  DECODED_INST  id_inst_out;
  GEN_REG       id_ra_idx, id_rb_idx, id_rdest_idx;

  //outputs from the maptable
  MAP_ROW_T   [`NUM_GEN_REG-1:0]	map_table_out;
  PHYS_REG 		T1; // Output for Dispatch and goes to RS
	PHYS_REG 		T2; // Output for Dispatch and goes to RS
  PHYS_REG    T_old;	// Output for Dispatch and goes to ROB

  // --------------------------------Dispatch stage

  // outputs of ID/DI stage
  INST_Q   id_di_iq_inst;
  GEN_REG  id_di_ra_idx, id_di_rb_idx, id_di_rdest_idx;
  
  RS_ROW_T id_di_inst;
  RS_ROW_T di_inst_in;

  logic dispatch_no_hazard;
  logic ROB_enable;

  // Pipeline register enables
  logic fr_read_en;
  FU_REG issue_stall;

  //-----------------------------------Issue stage

  // outputs from dispatch stage
  RS_ROW_T [(`RS_SIZE-1):0]		  rs_table_out;             // for debugging
  logic    [$clog2(`RS_SIZE):0] rs_free_rows_next_out;
  wand  rs_full;
  // RS_ROW_T [`NUM_FU_TOTAL-1:0]			issue_next;
 
  // ---------------------------------Ex stage
 
  //Outputs from IS/EX Pipeline Register
  RS_ROW_T [`NUM_FU_TOTAL-1:0] issue_reg;
  logic [`NUM_FU_TOTAL-1:0][63:0] is_ex_T1_value;
  logic [`NUM_FU_TOTAL-1:0][63:0] is_ex_T2_value;
  logic [`NUM_FU_TOTAL-1:0][1:0][63:0] pr_tags_values; 
  logic [`NUM_FU_TOTAL-1:0][1:0][`PHYS_IDX] issue_reg_tags;
	logic [`NUM_PHYS_REG-1:0][63:0] phys_reg;

  // Outputs from EX-Stage
  logic [`NUM_FU_TOTAL-1:0][63:0] ex_alu_result_out;
  logic ex_take_branch_out;
	logic done;

  logic [`NUM_FU_TOTAL-1:0][`PHYS_IDX] ex_reg_tags;
  logic [`NUM_FU_TOTAL-1:0]				     ex_reg_valid;
  
  RS_ROW_T [3:0] ex_mult_reg; // multiplicationn registers

  // ------------------------------------Mem stage

  // // Outputs from MEM-Stage
   logic [63:0] mem_result_out;
   logic        mem_stall_out;
   logic        mem_rd_stall;

  // Outputs from MEM/COM Pipeline Register
  logic  mem_co_halt;
  logic  mem_co_illegal;
  logic [`PHYS_IDX]   mem_co_dest_reg_idx;
  logic [63:0] mem_co_alu_result;
  
  LQ_ROW_T mem_co_load_out;
  
  logic  mem_co_halt_comb;
  logic  mem_co_illegal_comb;
  logic [`PHYS_IDX]   mem_co_dest_reg_idx_comb;
  logic [63:0] mem_co_alu_result_comb;
  logic mem_co_valid_inst_comb;   
  logic [63:0] mem_co_NPC_comb;        
  logic [31:0] mem_co_IR_comb;    



// ---------------------------------Complete stage

  // Outputs from EX/COM Pipeline Register
  RS_ROW_T [`NUM_FU_TOTAL-1:0] ex_co_inst;
  FU_REG              ex_co_halt;
  FU_REG              ex_co_illegal;
  logic  [`NUM_FU_TOTAL-1:0][`PHYS_IDX] ex_co_dest_reg_idx;
  logic  [`NUM_FU_TOTAL-1:0][63:0]  ex_co_alu_result;
  logic  [`NUM_FU_TOTAL-1:0][63:0]  ex_co_br_disp;
  logic  [63:0]       ex_co_br_wr_data;
  logic               ex_co_unconditional_branch;
  logic               ex_co_take_branch;
  logic               ex_co_done;
  FU_REG              ex_co_wr_mem;  
  FU_REG              ex_co_rd_mem;
  logic [63:0] ex_co_rega, ex_co_rega_st;
  SQ_INDEX_T   [1:0] ex_co_sq_idx; // index 0 is for store, index 1 is for load


  //Outputs from the complete stage
  RS_ROW_T co_inst_selected;
  LQ_ROW_T co_lq_load_selected;

  //logic         co_halt_selected;
  //logic         co_illegal_selected;
  //PHYS_REG      co_reg_wr_idx_out;
  logic         co_take_branch_selected;
  logic [63:0]  co_NPC_selected;
  SQ_INDEX_T  [1:0] co_sq_idx;
  logic         co_valid_inst_selected;
  FU_REG        co_selected; // alu which is granted the request from priority selector
  logic         co_branch_valid;
  logic         co_branch_prediction;      
  logic [31:0]  co_IR_selected;
  logic [63:0]  co_alu_result_selected;
  logic         psel_enable;
  FU_REG        gnt_bus;
  logic co_ret_branch_valid;
  logic co_ret_branch_prediction;

// -----------------------------------Retire stage

  // Outputs from COM/RETIRE Pipeline Register    //
  logic         co_ret_halt;
  logic         co_ret_illegal;
  PHYS_REG      co_ret_dest_reg_idx;
  logic [63:0]  co_ret_result;
  logic         co_ret_take_branch;
  logic [63:0]  co_ret_NPC;
  logic [31:0]  co_ret_IR;

  logic branch_valid_disp;  //branch_valid_disp
  
// Retire signals from ROB

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

// ------------------------------Signals from modules

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
  logic [`PHYS_IDX] retire_reg_wr_idx;
  logic             retire_reg_wr_en;
  logic [63:0] retire_reg_NPC;
  logic [`PHYS_IDX] retire_reg_phys;
	logic head_halt;
  logic rob_retire_out_halt;
  logic rob_retire_out_illegal;
  logic rob_retire_out_take_branch;
  logic rob_retire_out_T_new; 
  logic rob_retire_out_T_old; 	
  logic [31:0] rob_retire_opcode;
  logic rob_retire_out_is_store;
  // Memory interface/arbiter wires
  logic [63:0] proc2Dmem_addr, proc2Imem_addr, proc2Rmem_addr;
  logic [63:0] proc2Rmem_data, proc2Dmem_data;
  logic [1:0]  proc2Dmem_command, proc2Imem_command, proc2Rmem_command;
  logic [3:0]  Dmem2proc_response, Imem2proc_response, Rmem2proc_response;
  logic [63:0] Dmem2proc_data, Imem2proc_data;
  logic [3:0]  Dmem2proc_tag, Imem2proc_tag, Rmem2proc_tag;
  
  // Icache wires
  logic [63:0] Icache_data_out, proc2Icache_addr;
  logic        Icache_valid_out;

  assign pipeline_completed_insts = {3'b0, retire_inst_busy};
  assign pipeline_error_status =  rob_retire_out_illegal  ? HALTED_ON_ILLEGAL :
                                  rob_retire_out_halt ? HALTED_ON_HALT :
                                  NO_ERROR;

  //---------------------------For synthesis debugging

  assign proc2Rmem_command_out = proc2Rmem_command;
  assign proc2Dmem_command_out = proc2Dmem_command;
  assign proc2Imem_command_out = proc2Imem_command;
 
	// TEMPORARY HACK, DEFINITELY CHANGE THIS WHEN WE ADD THE MEMORY STAGE
	// FOR MEMORY INSTRUCTIONS
//	assign proc2Dmem_command = mem_co_enable ? BUS_LOAD : BUS_NONE;

  logic tag_in_lq;

  mem_controller memory(
    .clock(clock), 
    .reset(reset), 

    //inputs
    .proc2Dmem_command(proc2Dmem_command),
    .proc2Dmem_addr(proc2Dmem_addr), 
    .proc2Dmem_data(proc2Dmem_data),
    .proc2Imem_command(proc2Imem_command),
    .proc2Imem_addr(proc2Imem_addr), 
    .proc2Imem_data(64'b0),
    .proc2Rmem_command (proc2Rmem_command),
    .proc2Rmem_addr    (proc2Rmem_addr),
    .proc2Rmem_data    (proc2Rmem_data),
    .mem2proc_response(mem2proc_response), 
    .mem2proc_data(mem2proc_data),
    .mem2proc_tag(mem2proc_tag),

    //outputs
    .Dmem2proc_response(Dmem2proc_response),
    .Dmem2proc_data(Dmem2proc_data),
    .Dmem2proc_tag(Dmem2proc_tag),
    .Imem2proc_response(Imem2proc_response),
    .Imem2proc_data(Imem2proc_data), 
    .Imem2proc_tag(Imem2proc_tag),
    .Rmem2proc_response(Rmem2proc_response),
    .Rmem2proc_tag(Rmem2proc_tag),
    .proc2mem_command(proc2mem_command), 
    .proc2mem_addr(proc2mem_addr), 
    .proc2mem_data(proc2mem_data)
  );

  // assign proc2mem_command = (proc2Dmem_command == BUS_NONE) ? proc2Imem_command : proc2Dmem_command;
  // assign proc2mem_addr = (proc2Dmem_command == BUS_NONE) ? proc2Imem_addr : proc2Dmem_addr;
  // assign Dmem2proc_response = (proc2Dmem_command == BUS_NONE) ? 0 : mem2proc_response;
  // assign Imem2proc_response = (proc2Dmem_command == BUS_NONE) ? mem2proc_response : 0;
  // assign Imem2proc_data = !tag_in_lq ? mem2proc_data : 0;
  // assign Imem2proc_tag = !tag_in_lq ? mem2proc_tag : 0;
  //assign Dmem2proc_data = tag_in_lq ? mem2proc_data : 0;
  //assign Dmem2proc_tag = tag_in_lq ? mem2proc_tag : 0;
  // assign Dmem2proc_tag = (proc2Dmem_command == BUS_LOAD) ? mem2proc_tag : 0;

	icache inst_memory(
				.clock(clock),
				.reset(reset),
       	.branch_not_taken(branch_not_taken), 
        //inputs
        //from if_stage
        .proc2Icache_addr(proc2Icache_addr),
        //from main memory
				.Imem2proc_response(Imem2proc_response),
				.Imem2proc_data(Imem2proc_data),
				.Imem2proc_tag(Imem2proc_tag),
				
        //outputs
        //to if_stage
				.Icache_data_out(Icache_data_out),
				.Icache_valid_out(Icache_valid_out),
        //to main memory
        .proc2Imem_command(proc2Imem_command),
        .proc2Imem_addr(proc2Imem_addr)
	);

  // store to load forwarding signals from memory stage
  logic load_wants_store;
  logic [31:0] load_rd_addr;
  SQ_INDEX_T load_spos_tail;

  // store dispatch signals
  logic dispatch_is_store;
  logic [31:0] dispatch_store_addr;
  logic dispatch_store_addr_ready;
  logic [63:0] dispatch_store_data;
  logic dispatch_store_data_ready;

  // store execute signals
  logic execute_is_store;
  SQ_INDEX_T store_spos_tail;
  logic [31:0] ex_store_addr;
  logic ex_store_addr_valid;
  logic [63:0] ex_store_data;
  logic ex_store_data_valid;

  // store retire signals
  logic retire_is_store;
  logic retire_is_store_next;

  // store queue output 
  logic [63:0] sq_data_out;
  logic sq_data_valid;
  SQ_INDEX_T sq_tail;
  logic sq_full;
  logic sq_data_not_found; // define logic
  logic [63:0] sq_head_address, sq_head_data; // define logic

  // general wires for store queue
  logic sq_hazard;

  // assign sq_data_not_found = sq_data_valid;

  // logic stall_load_during_ex_co;
  // assign stall_load_during_ex_co = ex_co_valid_inst[FU_LD_IDX] & sq_data_not_found & !mem_co_enable[FU_LD_IDX];

  // Store Queue Module
  SQ store_queue(
    .clock(clock),
    .reset(reset),

    .branch_incorrect(branch_not_taken),
    .rd_en(load_wants_store),
    .addr_rd(load_rd_addr),
    .ld_pos(load_spos_tail),

    .dispatch_en(dispatch_is_store),
    .dispatch_addr(dispatch_store_addr),
    .dispatch_addr_ready(dispatch_store_addr_ready),
    .dispatch_data(dispatch_store_data),
    .dispatch_data_ready(dispatch_store_data_ready),

    .ex_en(execute_is_store),
    .ex_index(store_spos_tail),
    .ex_addr(ex_store_addr),
    .ex_addr_en(ex_store_addr_valid),
    .ex_data(ex_store_data),
    .ex_data_en(ex_store_data_valid),

    .rt_en(rob_retire_out_is_store),

    .data_rd(sq_data_out),
    .rd_valid(sq_data_valid), // checks for if data that exists is valid

    .store_head_data(sq_head_data),
    .store_head_addr(sq_head_address),
    .store_data_stall(sq_data_not_found),

    .tail_out(sq_tail),
    .full(sq_full)
  );

// Load queue signals
  LQ_ROW_T lq_load_in;
  logic lq_write_en;
  logic lq_pop_en;
  logic [63:0] lq_miss_data;
  logic [63:0] lq_miss_addr;
  logic lq_miss_valid;

  LQ_ROW_T lq_load_out, mem_lq_load_out;
  logic lq_read_valid, mem_lq_read_valid;
  logic lq_full;

  //assign lq_pop_en = mem_stall_out;

  LQ load_queue(
    .clock(clock),
    .reset(reset),
    .branch_incorrect(branch_not_taken),
    .load_in(lq_load_in),
    .write_en(lq_write_en),
    .pop_en(lq_pop_en),
    .lq_miss_data(lq_miss_data),
    .lq_miss_addr(lq_miss_addr),
    .lq_miss_valid(lq_miss_valid),

    .load_out(lq_load_out),
    .read_valid(lq_read_valid),
    .full(lq_full)
  );

  //////////////////////////////////////////////////
  //                                              //
  //                  IF-Stage (Fetch 1)          //
  //                                              //
  //////////////////////////////////////////////////
  // For different stages of fetch
  // Fetch 1 outputs
  FETCHED_INST_T if1_fetched_inst_out;

  // Fetch 1/2 registers
  FETCHED_INST_T if1_if2_fetched_inst;

  // Fetch 2(BP) outputs
  BR_SIG    if2_branch_inst;

  BR_SIG ret_branch_inst;
  logic  ret_pred_correct;

  BR_IDX_REG   ex_co_branch_index, co_branch_index;
  logic [63:0] ex_co_branch_target, co_branch_target;

  logic if_stage_dispatch_en;

  assign if_stage_dispatch_en = !inst_queue_full;

  if_stage if_stage_0 (
    // Inputs
    .clock (clock),
    .reset (reset),
    .co_ret_valid_inst(rob_retire_out.busy),		// ret_branch_inst.en
    .co_ret_take_branch(branch_not_taken),	// ret_branch_inst.taken
    .co_ret_target_pc(rob_retire_out.npc),			// 
    .Imem2proc_data(Icache_data_out),
    .Imem_valid(Icache_valid_out),
    .dispatch_en(if_stage_dispatch_en),				// if_id_enable vs dispatch_no_hazard : doesn't matter. Imem_valid is the key factor
    .co_ret_branch_valid(ret_branch_inst.en),
    .if_bp_NPC(if2_branch_inst.pred_pc),					// If BP prediction is valid, then next PC is updated pc from BP
    .if_bp_NPC_valid(if2_branch_inst.pred_pc_valid),

    // Outputs
    .proc2Imem_addr(proc2Icache_addr),
    .if_fetched_inst_out(if1_fetched_inst_out)
  );
  // Branch predictor prediction evaluation
  //1. Direct Cond : target PC incorrect or Prediction incorrect
  //2. Direct Uncond : target PC incorrect
  //3. Direct cond : target PC incorrect
 
	always_comb begin 
		ret_pred_correct = 1'b1;
		if(rob_retire_out.branch_inst.en) begin
			if(rob_retire_out.branch_inst.cond & rob_retire_out.branch_inst.direct) begin
				ret_pred_correct = (rob_retire_out.branch_inst.pred_pc == rob_retire_out.npc) & (rob_retire_out.branch_inst.prediction == rob_retire_out.take_branch);
			end else if (!rob_retire_out.branch_inst.cond) begin
			//	if(!ret_branch_inst.ret) begin
					ret_pred_correct = (rob_retire_out.branch_inst.pred_pc == rob_retire_out.npc);
			//	end else begin
			//		ret_pred_correct = 1'b1;
			//	end
			end
		end
	end

  //Flushing condition : During the branch retirement, When the prediction is incorrect
  assign branch_not_taken = rob_retire_out.branch_inst.en & (~ret_pred_correct); //
  //should change this, chk1
  //assign branch_not_taken = ret_branch_inst.en & rob_retire_out_take_branch; 
 

  /////////////////////////////////////////////////////////////////////////
  //
  //		Fetch1 /Fetch2 pipelne register
  //
  ////////////////////////////////////////////////////////////////////////
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
  	if(reset | branch_not_taken | if2_branch_inst.pred_pc_valid) begin
      if1_if2_fetched_inst <= `SD EMPTY_FETCHED_INST;
  	end else if(if1_fetched_inst_out.valid_inst) begin
      if1_if2_fetched_inst <= `SD if1_fetched_inst_out;
  	end else begin
  		if1_if2_fetched_inst <= `SD EMPTY_FETCHED_INST;
  	end
  end

  ///////////////////////////////////////////////////////////////////////////////////
  //										//
  //		 Branch predictor stage (Fetch 2)
  //
  ////////////////////////////////////////////////////////////////////////////////

  // Small decoder for branch predictor
  // We may divide the branch predictor and fetch stage
	always_comb begin
		// Initial value
    if2_branch_inst = EMPTY_BR_SIG;

		if(if1_if2_fetched_inst.valid_inst) begin // 
			if2_branch_inst.pc = if1_if2_fetched_inst.pc; // Save current PC
			case (if1_if2_fetched_inst.ir[31:26])
				//COND & DIRECT
				`BEQ_INST, `BNE_INST, `BLE_INST, `BLT_INST, `BGE_INST, `BGT_INST, `BLBC_INST, `BLBS_INST : begin
					if2_branch_inst.en = 1'b1;
					if2_branch_inst.cond = 1'b1;
					if2_branch_inst.direct = 1'b1;
				end
				//UNCOND & DIRECT
				`BR_INST, `BSR_INST : begin
					if2_branch_inst.en = 1'b1;
					if2_branch_inst.direct = 1'b1;
				end
				// UNCOND & INDIRECT
				`JSR_GRP : begin
					case (if1_if2_fetched_inst.ir[20:19])
            // NOT RETURN
						`JMP_INST, `JSR_INST, `JSR_CO_INST : begin
							if2_branch_inst.en = 1'b1;
						end
            // RETURN
						`RET_INST : begin
							if2_branch_inst.en = 1'b1;
							if2_branch_inst.ret = 1'b1;
						end
						default : begin
							if2_branch_inst.en = 1'b0;
							if2_branch_inst.cond = 1'b0;
							if2_branch_inst.direct = 1'b0;
							if2_branch_inst.ret = 1'b0;
						end	
					endcase
				end
				default : begin
					if2_branch_inst.en = 1'b0;
					if2_branch_inst.cond = 1'b0;
					if2_branch_inst.direct = 1'b0;
					if2_branch_inst.ret = 1'b0;
				end			
			endcase	
		end // if(valid_inst)
	end

	BP2 bp0(
		// inputs
		.clock(clock), 
		.reset(reset), 
		.enable(enable),
		
		.if_en_branch(if2_branch_inst.en),
		.if_cond_branch(if2_branch_inst.cond),
		.if_direct_branch(if2_branch_inst.direct),
		.if_return_branch(if2_branch_inst.ret), 
		.if_pc_in(if1_if2_fetched_inst.pc[31:0]),

		.rt_en_branch(rob_retire_out.branch_inst.en),			//Get value from retire_inst_busy
		.rt_cond_branch(rob_retire_out.branch_inst.cond),			
		.rt_direct_branch(rob_retire_out.branch_inst.direct),		 
		.rt_return_branch(rob_retire_out.branch_inst.ret),
		.rt_pc(rob_retire_out.branch_inst.pc[31:0]),
		.rt_branch_taken(rob_retire_out.take_branch),		// Get value from ret_branch_inst.taken
		.rt_prediction_correct(ret_pred_correct),
		.rt_calculated_pc(rob_retire_out.npc[31:0]),			// This is not come from ret_branc_inst 
		.rt_branch_index(rob_retire_out.branch_inst.br_idx),		

		// outputs 
		`ifdef DEBUG
	/*	.gshare_ght_out(gshare_ght_out),
		.gshare_pht_out(gshare_pht_out),		
		.obq_out(obq_out),
		.obq_head_out(obq_head_out),
		.obq_tail_out(obq_tail_out),*/
		.btb_valid_out(btb_valid_out),
		.btb_tag_out(btb_tag_out),
		.btb_target_address_out(btb_target_address_out),
		.ras_stack_out(ras_stack_out),
		.ras_head_out(ras_head_out),
		.ras_tail_out(ras_tail_out),
		`endif
		.next_pc_valid(if2_branch_inst.pred_pc_valid), // Should add this, chk2
		.next_pc_index(if2_branch_inst.br_idx),
		.next_pc(if2_branch_inst.pred_pc),
		.next_pc_prediction(if2_branch_inst.prediction) // Should add this, chk3

	);

  //////////////////////////////////////////////////////////////////////////////
  //									      //
  //	Instruction queue to decouple Structural hazard stalling and Fetch.   //
  // 	Behaves like IF/ID pipeline register.				      //
  // 							    		      //
  //////////////////////////////////////////////////////////////////////////////
	assign iq_inst_in.fetched_inst = if1_if2_fetched_inst;
  assign iq_inst_in.branch_inst = if2_branch_inst;
	logic IQ_read_en;
	//assign IQ_fetch_en = if_valid_inst_out & !if_bp_NPC_valid; // When branch prediction is valid, do not fetch the next instruction

	//assign IQ_fetch_en = if_valid_inst_out;
	IQ iq0(
 		// inputs
		.clock(clock),
		.reset(reset),
		.fetch_valid(iq_inst_in.fetched_inst.valid_inst),
		.if_inst_in(iq_inst_in),
		.dispatch_no_hazard(dispatch_no_hazard),
		.branch_incorrect(branch_not_taken),
		
		// outputs
		`ifdef DEBUG
		.inst_queue_out(inst_queue_out),
		.inst_queue_entry(inst_queue_entry),
		`endif
		.inst_queue_full_out(inst_queue_full),
		.if_inst_out(if_id_inst)
	);

  //////////////////////////////////////////////////
  //                                              //
  //                  ID-Stage                    //
  //                                              //
  //////////////////////////////////////////////////
  id_stage id_stage_0 (
    // Inputs
    .clock(clock),
    .reset(reset),
    .if_id_IR(if_id_inst.fetched_inst.ir),
    .if_id_valid_inst(if_id_inst.fetched_inst.valid_inst),
   
    // Outputs
    .id_inst_out(id_inst_out),
    .ra_idx(id_ra_idx),
    .rb_idx(id_rb_idx),
    .rdest_idx(id_rdest_idx)
  );

  //////////////////////////////////////////////////
  //                                              //
  //                  ID/DI-registers             //
  //                                              //
  //////////////////////////////////////////////////

  assign dispatch_no_hazard_comb =  ~((rs_free_rows_next_out == 0) | fr_empty | (rob_free_rows_next_out == 0) | (sq_hazard)); 
  assign dispatch_no_hazard = dispatch_no_hazard_comb; // CHECK THIS CAUSE OF CONFLICT

  assign id_di_enable = (id_inst_out.inst.valid_inst & dispatch_no_hazard); 
  //assign id_di_enable = (dispatch_no_hazard && if_valid_inst_out);  // always enabled
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset | branch_not_taken) begin
      id_di_inst      <= `SD EMPTY_ROW;
      id_di_ra_idx    <= `SD `ZERO_REG;
      id_di_rb_idx    <= `SD `ZERO_REG;
      id_di_rdest_idx <= `SD `ZERO_REG;
      id_di_iq_inst   <= `SD EMPTY_INST_Q;
    end else if(id_di_enable) begin 
      // Update the value
      id_di_inst      <= `SD id_inst_out;
      id_di_ra_idx    <= `SD id_ra_idx;
      id_di_rb_idx    <= `SD id_rb_idx;
      id_di_rdest_idx <= `SD id_rdest_idx;
      id_di_iq_inst   <= `SD if_id_inst;
    end
  end

  //////////////////////////////////////////////////
  //                                              //
  //                  DI-Stage                    //
  //                                              //
  //////////////////////////////////////////////////
  
  //Instantiating the freelist
	assign fr_read_en = (id_di_inst.valid_inst & dispatch_no_hazard); // Should not read during stalling for structural hazard
	assign fr_wr_en = (& rob_retire_out.T_old[`PHYS_IDX])? 0 : 1; 
	
	logic id_no_dest_reg;// Instructions that does not have destination register
	assign id_no_dest_reg = (id_di_rdest_idx == `ZERO_REG);

  assign free_list_out = fr_rs_rob_T;

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

    `ifdef DEBUG
    .free_list_out(fr_rs_rob_T),
    .tail_out(fr_tail_out),
    `endif

    .num_free_entries(fr_num_free_entries), // Used for Dispatch Hazard
    .empty(fr_empty), // Used for Dispatch Hazard
    .free_reg(fr_free_reg_T) // Output for Dispatch for other modules
  );

  // Instantiating the map table
  Map_Table m1( //Inputs
    .clock(clock),
    .reset(reset),
    .enable(fr_read_en),    // Should not read during stalling for structural hazard
    .reg_a(id_ra_idx),    // Comes from Decode duringmem2proc_data
    .reg_b(id_rb_idx),    // Comes from Decode duringmem2proc_data
    .reg_dest(id_rdest_idx),  // Comes from Dmem2proc_data
    .free_reg(fr_free_reg_T),   // Comes from Free List durmem2proc_data
    .CDB_tag_in(CDB_tag_out),   // Comes from CDB durinmem2proc_data
    .CDB_en(CDB_enable),      // Comes from CDB during Commitmem2proc_data
    .map_check_point(arch_table),
    .branch_incorrect(branch_not_taken),
    
    .map_table_out(map_table_out),
    .T1(di_inst_in.T1),    // Output for Dispatch and goes to RS
    .T2(di_inst_in.T2),    // Output for Dispatch and goes to RS
    .T_old(T_old)     // Output for Dispatch and goes to RS and ROB
  );
  
  assign di_inst_in.inst = id_di_inst;
  assign di_inst_in.T = fr_free_reg_T;
  assign di_inst_in.ir = id_di_iq_inst.fetched_inst.ir;
  assign di_inst_in.npc = id_di_iq_inst.fetched_inst.npc;
  assign di_inst_in.br_idx = id_di_iq_inst.branch_inst.br_idx;
  assign di_inst_in.sq_idx = sq_tail;

  // store queue tail assignment
  //assign id_inst_out.sq_idx = sq_tail;

  assign dispatch_is_store = (id_di_inst.fu_name == FU_ST & id_di_inst.valid_inst);
  assign dispatch_store_addr = 64'b0; 
  assign dispatch_store_addr_ready = 1'b0; 
  assign dispatch_store_data = 64'b0;
  assign dispatch_store_data_ready = 1'b0;
  assign sq_hazard = (dispatch_is_store & sq_full);

  assign issue_stall = ~is_ex_enable;
  assign dispatch_en = (dispatch_no_hazard & di_inst_in.inst.valid_inst); 
  assign ROB_enable = di_inst_in.inst.valid_inst;
  assign RS_enable = di_inst_in.inst.valid_inst;
  // INSTANTIATING THE ROB
  //assign branch_valid_disp = (id_inst_out.inst.fu_name == FU_BR) ? 1 : 0;

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
    .CDB_sq_valid(ex_co_inst[FU_ST_IDX].busy),
    .CDB_sq_idx(ex_co_inst[FU_ST_IDX].sq_idx),
    .dispatch_en(dispatch_en), // Structural Hazard detection during Dispatch
    .branch_not_taken(branch_not_taken),
    .halt_in(di_inst_in.inst.halt),
    .opcode(di_inst_in.ir),
    .take_branch(co_take_branch_selected),
    //.branch_valid(branch_valid_disp), // ***Heewoo Same as id_di_branch_inst.en
    .id_branch_inst(id_di_iq_inst.branch_inst), // ***Heewoo added 
    .wr_idx(id_di_rdest_idx),
    .npc(di_inst_in.npc),
    .is_store(dispatch_is_store),
    .sq_idx_in(di_inst_in.sq_idx),
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

  RS #(.FU_NAME_VAL(FU_NAME_VAL),
       .FU_BASE_IDX(FU_BASE_IDX),
       .NUM_OF_FU_TYPE(NUM_OF_FU_TYPE)) RS0(
    // inputs
    .clock(clock), 
    .reset(reset), 
    .enable(enable), 
    .CAM_en(CDB_enable), 
    .CDB_in(CDB_tag_out), 
    .dispatch_valid(dispatch_en),
    .inst_in(di_inst_in), 
    .branch_not_taken(branch_not_taken), 
    .issue_stall(issue_stall),
    
    // outputs
    .rs_table_out(rs_table_out), 
    .issue_out(issue_next), 
    .free_rows_next(rs_free_rows_next_out),
    .rs_full(rs_full)
  );
 
  //////////////////////////////////////////////////
  //                                              //
  //            IS/EX Pipeline Register           //
  //                                              //
  //////////////////////////////////////////////////
  always_comb begin
    for (int i = 0; i < `NUM_FU_TOTAL; i += 1) begin
      is_ex_enable[i] = (~issue_reg[i].inst.busy | (issue_reg[i].inst.busy & ex_co_enable[i])); // always enabled - Original stuff
    end
  end

  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    for(int i = 0; i < `NUM_FU_TOTAL; i += 1) begin
      if(reset | branch_not_taken) begin
        issue_reg[i] <= `SD EMPTY_ROW;
      end else if(is_ex_enable[i]) begin // if (reset)
        issue_reg[i] <= `SD issue_next[i];
      end else if(~is_ex_enable[i]) begin
		    issue_reg[i] <= `SD issue_reg[i];
	    end else begin
        issue_reg[i] <= `SD EMPTY_ROW;
      end // else: !if(reset)
    end
  end // always


  //////////////////////////////////////////////////
  //                                              //
  //                  EX-Stage                    //
  //                                              //
  //////////////////////////////////////////////////
  //genvar ig; // Input of physreg
  for(genvar ig = 0; ig < `NUM_FU_TOTAL; ig += 1) begin
    assign issue_reg_tags[ig][0] = issue_reg[ig].T1[`PHYS_IDX];
    assign issue_reg_tags[ig][1] = issue_reg[ig].T2[`PHYS_IDX];
  end

  // Multiplication : Write after execution 
  assign is_pr_enable = 1;
  phys_regfile regf_0(
    .rd_idx(issue_reg_tags),
    .rd_out(pr_tags_values),

   	.phys_registers_out(phys_reg),
    
    .wr_clk(clock),
    .wr_en({1'b0, 
            ex_co_inst[FU_BR_IDX].busy,
            ex_co_inst[FU_MULT_IDX].busy, 
            mem_co_load_out.data_valid,
            ex_co_inst[FU_ALU2_IDX].busy, 
            ex_co_inst[FU_ALU_IDX].busy}),
    .wr_idx({{$clog2(`NUM_PHYS_REG){1'b1}},
              ex_co_inst[FU_BR_IDX].T[`PHYS_IDX],
              ex_co_inst[FU_MULT_IDX].T[`PHYS_IDX],
              mem_co_load_out.dest_reg[`PHYS_IDX],
              ex_co_inst[FU_ALU2_IDX].T[`PHYS_IDX],
              ex_co_inst[FU_ALU_IDX].T[`PHYS_IDX]}),
    .wr_data({64'b0, 
              ex_co_br_wr_data, 
              ex_alu_result_out[FU_MULT_IDX], 
              mem_co_load_out.data, 
              ex_co_alu_result[FU_ALU2_IDX:0]})
  );

  for(genvar ig = 0; ig < `NUM_FU_TOTAL; ++ig) begin
  	assign is_ex_T1_value[ig] = (reset) ? 64'b0 : pr_tags_values[ig][0];
  	assign is_ex_T2_value[ig] = (reset) ? 64'b0 : pr_tags_values[ig][1];  
  end

  ex_stage ex_stage_0(
    // Inputs
    .clock(clock),
    .reset(reset), 
    .issue_reg(issue_reg),
    .T1_value(is_ex_T1_value),
    .T2_value(is_ex_T2_value),
    
    // Outputs
    .ex_alu_result_out(ex_alu_result_out),
    .ex_take_branch_out(ex_take_branch_out),
    .done(done)
  );

  //signals from ex to sq for stores
  assign execute_is_store = (issue_reg[FU_ST_IDX].inst.valid_inst & ex_co_enable[FU_ST_IDX]); // store is in 5th ex_co reg
  assign store_spos_tail = issue_reg[FU_ST_IDX].sq_idx; //ex_co_sq_idx[0];
  assign ex_store_addr = ex_alu_result_out[FU_ST_IDX];
  assign ex_store_addr_valid = 1'b1;
  assign ex_store_data = is_ex_T1_value[FU_ST_IDX];
  assign ex_store_data_valid = 1'b1;

  //////////////////////////////////////////////////
  //                                              //
  //           EX/CO Pipeline Register            //
  //                                              //
  //////////////////////////////////////////////////

  // Registers for multiplication pipeline. issue_reg_in[3] is the input
  // multiplication output is pipelined... We should directly use mult output as
  // a register.
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if(reset | branch_not_taken) begin
      for(int i = 0; i < 4; ++i) begin
        ex_mult_reg[i] <= `SD EMPTY_ROW;
      end
    end else begin
      ex_mult_reg <= `SD {ex_mult_reg[1],ex_mult_reg[0],issue_reg[FU_MULT_IDX]};
    end
  end

  // not sure whether it can be directly assigned
  always_comb begin
    for (int i = 0; i < FU_LD_IDX; ++i) begin
      ex_co_enable[i] = (~ex_co_valid_inst[i]) | (ex_co_valid_inst[i] & co_selected[i]);
    end
  end
  assign ex_co_enable[FU_LD_IDX] = ~ex_co_valid_inst[FU_LD_IDX] | (ex_co_valid_inst[FU_LD_IDX] & ((sq_data_valid & mem_co_enable) | (~sq_data_valid & ~sq_data_not_found & ~lq_full)));
  
  //enable signal for the multipler  register
  assign ex_co_enable[FU_MULT_IDX] = 1;
  assign ex_co_done = done; // Done itself is enabled during complete stage
  
  assign ex_co_enable[FU_BR_IDX] = (~ex_co_valid_inst[FU_BR_IDX] | (ex_co_valid_inst[FU_BR_IDX] & co_selected[FU_BR_IDX]));
  assign ex_co_enable[FU_ST_IDX] = (~ex_co_valid_inst[FU_ST_IDX] | (ex_co_valid_inst[FU_ST_IDX] & co_selected[FU_ST_IDX]));

  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin//Initialize all registers once
    for (int i = 0; i < `NUM_FU_TOTAL; i += 1) begin
      if (reset | branch_not_taken) begin
        ex_co_inst[i]       <= `SD EMPTY_ROW;
        ex_co_alu_result[i] <= `SD 64'b0;
      end else if (ex_co_enable[i]) begin
        // these are forwarded directly from ID/EX latches
        ex_co_inst[i]       <= (i == FU_MULT_IDX)? ex_mult_reg[3] : issue_reg[i];
   		  ex_co_alu_result[i] <= `SD ex_alu_result_out[i];
      end 
    end // for loop end
  end // always

  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset | branch_not_taken) begin
      ex_co_rega          <= `SD 64'b0;
      ex_co_rega_st       <= `SD 64'b0;
      ex_co_take_branch   <= `SD 1'b0;
      ex_co_branch_index  <= `SD `ZERO_BR_IDX;
      ex_co_unconditional_branch <= `SD 1'b0;
      ex_co_br_wr_data    <= `SD 64'b0;
      ex_co_branch_target <= `SD 1'b0;
    end 
    if(ex_co_enable[FU_BR_IDX]) begin
      ex_co_rega          <= `SD is_ex_T1_value[FU_BR_IDX];
      ex_co_take_branch   <= `SD ex_take_branch_out;
      ex_co_branch_index  <= `SD issue_reg[FU_BR_IDX].br_idx;
      ex_co_unconditional_branch <= `SD issue_reg[FU_BR_IDX].inst.uncond_branch;
      ex_co_br_wr_data    <= `SD (issue_reg[FU_BR_IDX].inst.uncond_branch)? issue_reg[FU_BR_IDX].npc : ex_alu_result_out[FU_BR_IDX];
      ex_co_branch_target <= `SD ex_alu_result_out[FU_BR_IDX]; 
    end 
    if(ex_co_enable[FU_ST_IDX]) begin
      ex_co_rega_st <= `SD is_ex_T1_value[FU_ST_IDX];
    end
  end

//   //////////////////////////////////////////////////
//   //                                              //
//   //                 MEM-Stage                    //
//   //                                              //
//   //////////////////////////////////////////////////

  //signals from ld fu to sq
  assign load_wants_store = ex_co_inst[FU_LD_IDX].inst.busy;
  assign load_spos_tail = ex_co_inst[FU_LD_IDX].sq_idx;
  assign load_rd_addr = ex_co_alu_result[FU_LD_IDX];

  // add stall logic for ex_co registers with LQ   logic lq_full;
  logic mem_co_stall;
  assign mem_co_stall = !co_selected[FU_LD_IDX] & mem_co_valid_inst;
  
  assign lq_load_in.valid_inst =  ex_co_inst[FU_LD_IDX].inst.valid_inst;
  assign lq_load_in.NPC        =  ex_co_inst[FU_LD_IDX].npc;
  assign lq_load_in.IR         =  ex_co_inst[FU_LD_IDX].ir;
  assign lq_load_in.halt       =  ex_co_inst[FU_LD_IDX].inst.halt;
  assign lq_load_in.illegal    =  ex_co_inst[FU_LD_IDX].inst.illegal;
  assign lq_load_in.dest_reg   =  ex_co_inst[FU_LD_IDX].T;
  assign lq_load_in.alu_result =  ex_co_alu_result[FU_LD_IDX];
  assign lq_load_in.data       =  sq_data_valid? sq_data_out :
                                  mem_rd_stall? 64'b0 : 
                                  mem_result_out;
  assign lq_load_in.data_valid = sq_data_valid | ~mem_rd_stall;

  assign lq_write_en = ex_co_inst[FU_LD_IDX].inst.valid_inst & 
                       ((mem_rd_stall & ~sq_data_valid & ~sq_data_not_found) | mem_co_stall);

  //assign lq_pop_en = tag_in_lq;
  // assign lq_mem_tag = Dmem2proc_response;
   
  assign lq_pop_en = ~mem_co_stall;
  
  mem_stage mem_stage_0 (
    // Inputs
     .clock(clock),
     .reset(reset),
     .rd_mem(ex_co_inst[FU_LD_IDX].inst.rd_mem),
     .rd_addr(lq_load_in.alu_result), 
     .wr_mem(rob_retire_out_is_store),
     .wr_addr(sq_head_address),
     .wr_data(sq_head_data),
     .Dmem2proc_data(Dmem2proc_data),
     .Dmem2proc_tag(Dmem2proc_tag),
     .Dmem2proc_response(Dmem2proc_response),
     .Rmem2proc_response(Rmem2proc_response),
     .Rmem2proc_tag     (Rmem2proc_tag),
     .sq_data_not_found(sq_data_not_found),   // addresses in store are not ready
     .sq_data_valid(sq_data_valid),           // adddress not found
     
     // Outputs
     .sets_out(dcache_data),
     .vic_queue_out(vic_queue_out),
  	 .retire_queue_out(retire_queue),
  	 .retire_queue_tail_out(retire_queue_tail),
     .mem_result_out(mem_result_out),
     .mem_rd_stall(mem_rd_stall),
     .mem_stall_out(mem_stall_out),
     .mem_rd_miss_addr_out (lq_miss_addr),
     .mem_rd_miss_data_out (lq_miss_data),
     .mem_rd_miss_valid_out(lq_miss_valid),
     .proc2Dmem_command(proc2Dmem_command),
     .proc2Dmem_addr(proc2Dmem_addr),
     .proc2Dmem_data(proc2Dmem_data),
     .proc2Rmem_command    (proc2Rmem_command),
     .proc2Rmem_addr       (proc2Rmem_addr),
     .proc2Rmem_data       (proc2Rmem_data)
  );

  //logic [`PHYS_IDX] mem_dest_reg_idx_out = mem_rd_stall? {$clog2(`NUM_PHYS_REG){1'b1}} :
  //                                                        ex_co_dest_reg_idx[FU_LD_IDX];
  //wire mem_valid_inst_out = ex_co_inst[FU_LD_IDX].inst.valid_inst & ~mem_rd_stall;

  //assign stall_struc = ((ex_co_inst[FU_LD_IDX].inst.rd_mem & ~ex_co_inst[FU_LD_IDX].inst.wr_mem)
  //                       |(~ex_co_inst[FU_LD_IDX].inst.rd_mem & ex_co_inst[FU_LD_IDX].inst.wr_mem)) & (ex_co_inst[FU_LD_IDX].inst.valid_inst);

  //////////////////////////////////////////////////
  //                                              //
  //           mem/co Pipeline Reg                //
  //                                              //
  //////////////////////////////////////////////////

  logic mem_co_comb;
  assign mem_co_comb = ex_co_inst[FU_LD_IDX].inst.valid_inst & (sq_data_valid | ~mem_rd_stall);
  
  assign mem_co_enable = ((~mem_co_valid_inst) | (mem_co_valid_inst  & co_selected[FU_LD_IDX]));
 
  // synopsys sync_set_reset "reset"
 always_ff @(posedge clock) begin
    if (reset | branch_not_taken) begin
      mem_co_load_out <= `SD EMPTY_LQ_ROW;
    end else if (mem_co_enable & ~mem_co_stall) begin
      mem_co_load_out.valid_inst <= `SD mem_co_comb? lq_load_in.valid_inst : 
                                                    (lq_load_out.valid_inst & lq_read_valid);
      mem_co_load_out.NPC        <= `SD mem_co_comb? lq_load_in.NPC : 
                                                     lq_load_out.NPC;
      mem_co_load_out.IR         <= `SD mem_co_comb? lq_load_in.IR : 
                                                     lq_load_out.IR;  
      mem_co_load_out.halt       <= `SD mem_co_comb? lq_load_in.halt : 
                                                     lq_load_out.halt;
      mem_co_load_out.illegal    <= `SD mem_co_comb? lq_load_in.illegal : 
                                                     lq_load_out.illegal;
      mem_co_load_out.dest_reg   <= `SD mem_co_comb? lq_load_in.dest_reg : 
                                                     lq_load_out.dest_reg;  
      mem_co_load_out.alu_result <= `SD mem_co_comb? lq_load_in.alu_result : 
                                                     lq_load_out.alu_result;
      mem_co_load_out.data       <= `SD (lq_load_in.valid_inst & sq_data_valid)? sq_data_out :
                                        (lq_load_in.valid_inst & ~mem_rd_stall)? mem_result_out :
                                                                                 lq_load_out.data;                                                                                                   
    end                                                                            
  end
  
  //////////////////////////////////////////////////
  //                                              //
  //           complete stage                     //
  //                                              //
  //////////////////////////////////////////////////
  
  assign psel_enable = ex_co_inst[FU_ALU_IDX].inst.valid_inst | 
                       ex_co_inst[FU_ALU2_IDX].inst.valid_inst |
                       mem_co_load_out.valid_inst |
                       done | 
                       ex_co_inst[FU_BR_IDX].inst.valid_inst |
                       ex_co_inst[FU_ST_IDX].valid_inst; // ask the use of wor
  //priority encoder to select the results of the execution stage to put in cdb
  //Mult has the priority
  psel_generic #(.WIDTH(`NUM_FU_TOTAL), .NUM_REQS(1)) psel(
		.req({ex_co_done, ex_co_inst[FU_ST_IDX].busy, ex_co_inst[FU_BR_IDX].inst.busy, mem_co_load_out.valid_inst, ex_co_inst[FU_ALU2_IDX].inst.busy, ex_co_inst[FU_ALU_IDX].inst.busy}),  // becasue the valid bit of mult will not be the request signal instead the done signal will be
		.en(psel_enable),
		.gnt({co_selected[FU_MULT_IDX], co_selected[FU_ST_IDX], co_selected[FU_BR_IDX], co_selected[FU_LD_IDX:FU_ALU_IDX]}),
    .gnt_bus({gnt_bus[FU_MULT_IDX], gnt_bus[FU_ST_IDX], gnt_bus[FU_BR_IDX], gnt_bus[FU_LD_IDX:FU_ALU_IDX]})
	);
  
  always_comb begin
    co_inst_selected = EMPTY_ROW;
    co_lq_load_selected = EMPTY_LQ_ROW;
    co_alu_result_selected = 64'b0;
    co_branch_valid = 1'b0;
    co_take_branch_selected = 1'b0;
    co_branch_index = `ZERO_BR_IDX;
    co_branch_target = 64'b0;

    if (|co_selected) begin
      for (int i = 0; i < `NUM_FU_TOTAL; ++i) begin
        if(co_selected[i]) begin
          if(i == FU_LD_IDX) begin
            co_lq_load_selected = mem_co_load_out;
            co_alu_result_selected = mem_co_load_out.alu_result;
          end else begin
            co_inst_selected =  ex_co_inst[i];
            co_alu_result_selected = ex_co_alu_result[i];
            if(i == FU_BR_IDX) begin // For branch            
              co_branch_valid = ex_co_inst[FU_BR_IDX].inst.valid_inst;
              co_take_branch_selected = ex_co_take_branch;
              co_branch_index = ex_co_inst[FU_BR_IDX].br_idx;
              co_branch_target = ex_co_branch_target;
            end
          end
        end         
      end 
    end 
  end
      
  // For branch 

   
  //assign co_branch_prediction = (co_take_branch_selected  == bp_output) ? 1:0 ;// Branch prediction or misprediction
  
  assign CDB_enable = psel_enable; 
  //assign CDB_enable = psel_enable & ~co_branch_valid;                                       // check if theres any valid signal in the alu and also if the inst is branch or not 
  PHYS_REG co_tag_in = (co_selected[FU_LD_IDX])? co_lq_load_selected.dest_reg :
                                                  co_inst_selected.T;
  logic co_tag_valid = (co_selected[FU_LD_IDX])? co_lq_load_selected.valid_inst :
                                                  co_inst_selected.busy;

  //Instantiated the CDB
  CDB CDB_0(
    // Inputs
    .clock(clock),    // Clock
    .reset(reset),  // Asynchronous reset active low
    .enable(CDB_enable), // Clock Enable
    .tag_in(cdb_tag_in),	// Comes from FU, during commit
    .ex_valid(cdb_tag_valid),

    // Outputs
    .CDB_tag_out(CDB_tag_out), // Output for commit, goes to modules
    .CDB_en_out(CDB_en_out),  // Output for commit, goes to modules
    .busy(busy)
  );



//  Things to do

// add condition for the branch opcode in the psel
// how to handle the target pc for the branch



  //////////////////////////////////////////////////
  //                                              //
  //           COMPLETE/RETIRE Pipeline Register  //
  //                                              //
  //////////////////////////////////////////////////
  // assign co_ret_enable = 1'b1; // always enabled
  // // synopsys sync_set_reset "reset"
  // always_ff @(posedge clock) begin
  //   if (reset | branch_not_taken) begin
  //     co_ret_NPC          <= `SD 64'b0;
  //     co_ret_IR           <= `SD `NOOP_INST;
  //     co_ret_halt         <= `SD 1'b0;
  //     co_ret_illegal      <= `SD 1'b0;
  //     co_ret_valid_inst   <= `SD 1'b0;
  //     co_ret_dest_reg_idx <= `SD `ZERO_REG;
  //     co_ret_take_branch  <= `SD 1'b0;
  //     co_ret_result       <= `SD 64'b0;
  //     co_ret_branch_valid       <= `SD 1'b0;
  //     co_ret_branch_prediction  <= `SD 1'b0;
  //   end else if (co_ret_enable) begin
  //     // these are forwarded directly from EX/MEM latches
  //     co_ret_NPC          <= `SD co_NPC_selected;
  //     co_ret_IR           <= `SD co_IR_selected;
  //     co_ret_halt         <= `SD co_halt_selected;
  //     co_ret_illegal      <= `SD co_illegal_selected;
  //     co_ret_valid_inst   <= `SD co_valid_inst_selected;
  //     co_ret_dest_reg_idx <= `SD co_reg_wr_idx_out;
  //     co_ret_take_branch  <= `SD co_take_branch_selected;
  //     co_ret_result       <= `SD co_alu_result_selected;
  //     co_ret_branch_valid      <= `SD co_branch_valid;
  //     co_ret_branch_prediction <= `SD co_branch_prediction;
  //     // these are results of MEM stage
  //     //co_ret_result       <= `SD mem_co_result_out_selected;
  //   end // else: !if(reset)
  // end // always

  
  // This should be the same as id_di_branch_inst.en;   


  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if(reset | branch_not_taken) begin
      retire_is_store_next <= `SD 1'b0;
      rob_retire_out_halt <= `SD 1'b0;
      rob_retire_out_illegal <= `SD 1'b0;
    end else begin
      retire_is_store_next <= `SD retire_is_store;
      rob_retire_out_halt <= `SD rob_retire_out.halt;
      rob_retire_out_illegal <= `SD rob_retire_out.illegal;
    end
  end
  
  assign retire_is_store = rob_retire_out.is_store & rob_retire_out.busy;//(rob_retire_opcode[31:26] == `STQ_INST) ||
                            //(rob_retire_opcode[31:26] == `STQ_C_INST);

   
  

  // retire_reg_wr_idx is physical register
  assign pipeline_commit_wr_idx = rob_retire_out.wr_idx;
  assign pipeline_commit_wr_data = phys_reg[rob_retire_out.T_new[`PHYS_IDX]];
  assign pipeline_commit_wr_en = rob_retire_out.busy & (rob_retire_out.T_new != `DUMMY_REG);
  assign pipeline_commit_NPC = rob_retire_out.branch_inst.en ? rob_retire_out.branch_inst.pc : 
                                                               rob_retire_out.npc-4;
  assign pipeline_commit_phys_reg = rob_retire_out.T_old;
  assign pipeline_commit_phys_from_arch = arch_table[rob_retire_out.wr_idx][5:0]; 

  // For branch prediction accuracy check

  assign pipeline_branch_en = rob_retire_out.branch_inst.en; 
  assign pipeline_branch_pred_correct = rob_retire_out.branch_inst.en & ret_pred_correct;

//logic rob_retire_out_is_store_comb;
//assign rob_retire_out_is_store_comb = rob_retire_out.is_store & rob_retire_out.busy;

  
// FF between complete and retire

  // synopsys sync_set_reset "reset"
// always_ff @ (posedge clock) begin
// 	if(reset | branch_not_taken) begin
// 		retire_inst_busy <= `SD 1'b0;
// 		retire_reg_wr_idx <= `SD `ZERO_REG;
// 		retire_reg_wr_en <= `SD 1'b0;
// 		retire_reg_NPC <= `SD 64'h4;
// 		retire_reg_phys <= `SD `DUMMY_REG;
// 		rob_retire_out_halt <= `SD 1'b0;
// 		rob_retire_out_take_branch <= `SD 1'b0;
// 		rob_retire_out_T_new <= `SD `DUMMY_REG;
// 		rob_retire_out_T_old <= `SD `DUMMY_REG;
//     rob_retire_opcode <= `SD {32{1'b0}};
	
// 	ret_branch_inst.en 		<= `SD 1'b0;
// 	ret_branch_inst.cond 		<= `SD 1'b0;
// 	ret_branch_inst.direct 	<= `SD 1'b0;
// 	ret_branch_inst.ret 	<= `SD 1'b0;
// 	ret_branch_inst.pc 		<= `SD 64'h0;
// 	ret_branch_inst.pred_pc	<= `SD 64'h0;
// 	ret_branch_inst.br_idx 	<= `SD {($clog2(`OBQ_SIZE)){1'b0}};
// 	ret_branch_inst.prediction 	<= `SD 1'b0;
// 	//ret_branch_inst.taken 	<= `SD 0;


// 	end else begin 
//     rob_retire_opcode <= `SD rob_retire_out.opcode;
// 		retire_inst_busy <= rob_retire_out.busy;
// 		retire_reg_wr_idx <= `SD rob_retire_out.wr_idx;
// 		retire_reg_wr_en <= `SD (rob_retire_out.busy) & (~(rob_retire_out.T_new == `DUMMY_REG) & !rob_retire_out.halt);
// 		retire_reg_NPC <= `SD rob_retire_out.npc;
// 		retire_reg_phys <= `SD rob_retire_out.T_new;
// 		rob_retire_out_halt <= `SD rob_retire_out.halt;
//     rob_retire_out_take_branch <= `SD rob_retire_out.take_branch;
// 		rob_retire_out_T_new <= `SD rob_retire_out.T_new;
// 		rob_retire_out_T_old <= `SD rob_retire_out.T_old;
// 		rob_retire_out_is_store <= `SD rob_retire_out_is_store_comb;
// 		if(rob_retire_out.branch_inst.en) begin // For branch retire
// 			ret_branch_inst.en	<= `SD rob_retire_out.branch_inst.en;
// 			ret_branch_inst.cond	<= `SD rob_retire_out.branch_inst.cond;
// 			ret_branch_inst.direct	<= `SD rob_retire_out.branch_inst.direct;
// 			ret_branch_inst.ret	<= `SD rob_retire_out.branch_inst.ret;
// 			ret_branch_inst.pc	<= `SD rob_retire_out.branch_inst.pc;
// 			ret_branch_inst.pred_pc	<= `SD rob_retire_out.branch_inst.pred_pc;
// 			ret_branch_inst.br_idx	<= `SD rob_retire_out.branch_inst.br_idx;
// 			ret_branch_inst.prediction <= `SD rob_retire_out.branch_inst.prediction;
// 			//ret_branch_inst.taken	<= `SD rob_retire_out.branch_inst.taken;
//  		end else begin
// 			ret_branch_inst.en 		<= `SD 1'b0;
// 			ret_branch_inst.cond 		<= `SD 1'b0;
// 			ret_branch_inst.direct 	<= `SD 1'b0;
// 			ret_branch_inst.ret 	<= `SD 1'b0;
// 			ret_branch_inst.pc 		<= `SD 64'h0;
// 			ret_branch_inst.pred_pc	<= `SD 64'h0;
// 			ret_branch_inst.br_idx 	<= `SD {($clog2(`OBQ_SIZE)){1'b0}};
// 			ret_branch_inst.prediction 	<= `SD 1'b0;
	
// 		end
// 	end
//   end




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

endmodule  // module verisimple

