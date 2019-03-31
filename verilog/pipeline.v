/////////////////////////////////////////////////////////////////////////
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
//  output RS_ROW_T[`NUM_FU_TOTAL-1 :0] issue_next,


    // // Outputs from ID/EX Pipeline Register
    // output logic [63:0] id_ex_NPC,
    // output logic [31:0] id_ex_IR,
    // output logic        id_ex_valid_inst,

    

    // // Outputs from EX/MEM Pipeline Register
    // output logic [4:0][63:0] ex_mem_NPC,
    // output logic [4:0] ex_mem_IR,
    // output logic [4:0]       ex_mem_valid_inst,


     // Outputs from EX/COM Pipeline Register
     output logic [4:0][63:0] ex_co_NPC,
     output logic [4:0][31:0] ex_co_IR,
     output logic [4:0]       ex_co_valid_inst,

    // Outputs from COM/RET Pipeline Register
    output logic [63:0] co_ret_NPC,
    output logic [31:0] co_ret_IR,
    output logic        co_ret_valid_inst,

    //Module outputs
  output RS_ROW_T [(`RS_SIZE-1):0]		rs_table_out,
  output PHYS_REG [`NUM_GEN_REG-1:0] arch_table, 
  output  ROB_ROW_T [`ROB_SIZE:1]		ROB_table_out,
  output MAP_ROW_T [`NUM_GEN_REG-1:0]	map_table_out,
  output PHYS_REG [`FL_SIZE-1:0] free_list_out,
	output logic [$clog2(`FL_SIZE):0] tail_out,

  output logic if_id_enable,
  output logic RS_enable,
  output logic is_pr_enable,
  output logic CDB_enable, 
  output logic ROB_enable, 
  
  output logic co_ret_enable, 
  output logic dispatch_en, 
  output logic branch_not_taken,
  output  logic [4:0]   is_ex_enable,
  output  logic [4:0]   ex_co_enable
);
  parameter FU_NAME [0:(`NUM_TYPE_FU - 1)] FU_NAME_VAL = {FU_ALU, FU_LD, FU_MULT, FU_BR};
  parameter FU_IDX [0:(`NUM_TYPE_FU - 1)] FU_BASE_IDX = {FU_ALU_IDX, FU_LD_IDX, FU_MULT_IDX, FU_BR_IDX};
  parameter [0:(`NUM_TYPE_FU - 1)][1:0] NUM_OF_FU_TYPE = {2'b10,2'b01,2'b01,2'b01};

  // Pipeline register enables
  // logic         if_id_enable, RS_enable, is_pr_enable, CDB_enable, ROB_enable, co_re_enable, co_ret_enable, dispatch_en, branch_not_taken;
  // logic [4:0]   is_ex_enable, ex_co_enable;
  logic fr_read_en;
  logic [4:0]   issue_stall;
  // Output from the branch predictor
  logic   bp_output;
  
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

  // outputs from dispatch stage
  RS_ROW_T [(`RS_SIZE - 1):0]		rs_table_out;             // for debugging
  logic   [$clog2(`RS_SIZE):0] free_rows_next;
  wand								rs_full;
  
  // outputs from dispatch stage
  RS_ROW_T [`NUM_FU_TOTAL-1:0]			issue_next;
  logic 	[$clog2(`NUM_FU_TOTAL) - 1:0]	issue_cnt;

  
  //Outputs from IS/EX Pipeline Register
  RS_ROW_T [`NUM_FU_TOTAL-1:0] issue_reg;
  logic [4:0][63:0] is_ex_T1_value;
  logic [4:0][63:0] is_ex_T2_value;
  logic [4:0][63:0] pr_T1_value; 
  logic [4:0][63:0] pr_T2_value;    
  PHYS_REG [4:0] issue_reg_T1;
   PHYS_REG [4:0] issue_reg_T2;

  // Outputs from EX-Stage
  logic [4:0][63:0] ex_alu_result_out;
  logic             ex_take_branch_out;
	logic         done;
  

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
  // logic [63:0] mem_result_out;
  // logic        mem_stall_out;

  // Outputs from EX/COM Pipeline Register
  FU_REG              ex_co_halt;
  FU_REG              ex_co_illegal;
  PHYS_REG [4:0]      ex_co_dest_reg_idx;
  logic  [4:0][63:0]  ex_co_alu_result;
  logic               ex_co_take_branch;
  logic               ex_co_done;
  FU_REG              ex_co_wr_mem;  


  //Outputs from the complete stage
  logic         co_halt_selected;
  logic         co_illegal_selected;
  PHYS_REG      co_reg_wr_idx_out;
  logic [63:0]  co_reg_wr_data_out;
  logic         co_reg_wr_en_out;
  logic         co_take_branch_selected;
  logic         co_NPC_selected;
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
  logic         co_ret_NPC;
  logic         co_ret_IR;
  logic         co_ret_valid_inst;
  logic         co_ret_branch_valid;
  logic         co_ret_branch_prediction;

  //outputs from the ROB
  PHYS_REG                    rob_fl_arch_Told;
  PHYS_REG                    rob_arch_retire_reg;
  logic                       arch_fr_enable;
  logic [$clog2(`ROB_SIZE):0] rob_free_entries;
  logic							          rob_full;
  ROB_ROW_T [`ROB_SIZE-1:0]		ROB_table_out;
  logic [$clog2(`ROB_SIZE):0] tail_reg, head_reg;

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

  //Outputs form the freelist check
  PHYS_REG [`FL_SIZE - 1:0]   free_list_check;
  logic [$clog2(`FL_SIZE):0]  tail_check;

  
  // // Outputs from MEM/WB Pipeline Register
  // logic         mem_wb_halt;
  // logic         mem_wb_illegal;
  // logic   [4:0] mem_wb_dest_reg_idx;
  // logic  [63:0] mem_wb_result;
  // logic         mem_wb_take_branch;

  // Outputs from RETIRE-Stage  (These loop back to the register file in ID)
  logic [63:0] wb_reg_wr_data_out;
  logic  [4:0] wb_reg_wr_idx_out;
  logic        wb_reg_wr_en_out;

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

  assign pipeline_completed_insts = {3'b0, co_ret_valid_inst};
  assign pipeline_error_status =  co_ret_illegal  ? HALTED_ON_ILLEGAL :
                                  co_ret_halt     ? HALTED_ON_HALT :
                                  NO_ERROR;

  // assign pipeline_commit_wr_idx = wb_reg_wr_idx_out;
  // assign pipeline_commit_wr_data = wb_reg_wr_data_out;
  // assign pipeline_commit_wr_en = wb_reg_wr_en_out;
  // assign pipeline_commit_NPC = mem_wb_NPC;

	// TEMPORARY HACK, DEFINITELY CHANGE THIS WHEN WE ADD THE MEMORY STAGE
	// FOR MEMORY INSTRUCTIONS
	assign proc2Dmem_command = BUS_NONE;

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
  if_stage if_stage_0 (
    // Inputs
    .clock (clock),
    .reset (reset),
    .co_ret_valid_inst(co_ret_valid_inst),
    .co_ret_take_branch(co_ret_take_branch),
    .co_ret_target_pc(co_ret_alu_result),
    .Imem2proc_data(Icache_data_out),
    .Imem_valid(Icache_valid_out),
    .dispatch_en(dispatch_en),
    .co_ret_branch_valid(co_ret_branch_valid),

    // Outputs
    .if_NPC_out(if_NPC_out), 
    .if_IR_out(if_IR_out),
    .proc2Imem_addr(proc2Icache_addr),
    .if_valid_inst_out(if_valid_inst_out)
  );

  //////////////////////////////////////////////////
  //                                              //
  //            IF/ID Pipeline Register           //
  //                                              //
  //////////////////////////////////////////////////
  assign if_id_enable = (dispatch_en && if_valid_inst_out); 
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if(reset) begin
      if_id_NPC        <= `SD 0;
      if_id_IR         <= `SD `NOOP_INST;
      if_id_valid_inst <= `SD `FALSE;
    end else if(if_id_enable) begin
      if_id_NPC        <= `SD if_NPC_out;
      if_id_IR         <= `SD if_IR_out;
      if_id_valid_inst <= `SD if_valid_inst_out;
    end else begin
      if_id_NPC        <= `SD if_id_NPC;
      if_id_IR         <= `SD if_id_IR;
      if_id_valid_inst <= `SD if_id_valid_inst;
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
    // .wb_reg_wr_en_out(wb_reg_wr_en_out),
    // .wb_reg_wr_idx_out(wb_reg_wr_idx_out),
    // .wb_reg_wr_data_out(wb_reg_wr_data_out),

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
  	.enable(id_inst_out.inst.valid_inst),
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
  
  assign fr_read_en= if_id_enable & id_inst_out.inst.valid_inst ;
  Free_List f0(
    // INPUTS
    .clock(clock),
    .reset(reset),
    .enable(id_inst_out.inst.valid_inst),
    .T_old(rob_fl_arch_Told), // Comes from ROB during Retire Stage
    .dispatch_en(fr_read_en), // Structural Hazard detection during Dispatch

    // inputs for branch misprediction
    .branch_incorrect(branch_not_taken),
    .free_check_point(free_list_check),
    .tail_check_point(tail_check),

    `ifdef DEBUG
    .free_list_out(fr_rs_rob_T),
    .tail_out(fr_tail_out),
    `endif

    .num_free_entries(fr_num_free_entries), // Used for Dispatch Hazard
    .empty(fr_empty), // Used for Dispatch Hazard
    .free_reg(fr_free_reg_T) // Output for Dispatch for other modules
  );

//Instantiating the freelist check_point
  Free_List_Check flc(
    .clock(clock),
    .enable(enable),
    .free_list_in(free_list_in),
    .tail_in(tail_in),

    .free_list_check(free_list_check),

    .tail_check(tail_check)
  );

  always_comb begin
    if (id_inst_out.inst.valid_inst) begin
    assign  id_inst_out.T = fr_free_reg_T;
    end else begin
    assign  id_inst_out.T = `DUMMY_REG;
    end
  end
  // if (fr_read_en) assign id_inst_out.T = fr_free_reg_T;
  // else            assign id_inst_out.T = `DUMMY_REG;
  
  
  assign id_inst_out.inst_opcode = if_id_IR;
  assign id_inst_out.npc = if_id_NPC; 

  //////////////////////////////////////////////////
  //                                              //
  //                  ID/DI-Stage                 //
  //                                              //
  //////////////////////////////////////////////////

  assign id_di_enable = (dispatch_en && if_valid_inst_out); // always enabled
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
      if (reset) begin
        id_di_rega    <= `SD 0;
        id_di_regb    <= `SD 0;
        id_di_inst_in <= `SD EMPTY_ROW;
        id_di_NPC     <= `SD 0;
        id_di_IR      <= `SD `NOOP_INST;
        id_di_valid_inst  <=`SD `FALSE;
        
      end else if(id_di_enable) begin
        id_di_rega    <= `SD id_rega_out;
        id_di_regb    <= `SD id_regb_out;
        id_di_inst_in <= `SD id_inst_out;
        id_di_NPC     <= `SD if_id_NPC;
        id_di_IR      <= `SD if_id_IR;
        id_di_valid_inst  <= `SD if_id_valid_inst;
      end
  end

  //////////////////////////////////////////////////
  //                                              //
  //                  DI/ISSUE-Stage              //
  //                                              //
  //////////////////////////////////////////////////

  assign issue_stall= ~is_ex_enable;
  assign dispatch_en= ~((free_rows_next == 0) | fr_empty | rob_full) ;
  assign branch_not_taken = 0;//!co_ret_take_branch;    // for flushing
  assign RS_enable= (dispatch_en && if_valid_inst_out);
  RS #(.FU_NAME_VAL(FU_NAME_VAL),
       .FU_BASE_IDX(FU_BASE_IDX),
       .NUM_OF_FU_TYPE(NUM_OF_FU_TYPE)) RS0(
    // inputs
    .clock(clock), 
    .reset(reset), 
    .enable(RS_enable), 
    .CAM_en(CDB_enable), 
    .CDB_in(CDB_in), 
    .dispatch_valid(dispatch_en),
    .inst_in(id_di_inst_in), 
    .branch_not_taken(branch_not_taken), 
    .issue_stall(issue_stall),
    
    // outputs
    .rs_table_out(rs_table_out), 
    .issue_out(issue_next), 
    .free_rows_next(free_rows_next),
    .rs_full(rs_full)
  );

  genvar j;
  
  always_comb begin
    for(integer i=0; i< `RS_SIZE; i=i+1) begin
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
  always_ff @(posedge clock) begin
    if(reset) begin
      for(int i = 0; i < `NUM_FU_TOTAL; i += 1) begin
        issue_reg[i] <= `SD EMPTY_ROW;
      end
    end else if(is_ex_enable) begin
      issue_reg <= `SD issue_next;
    end
  end

  genvar i;
  for(i=0; i< `NUM_FU_TOTAL; i=i+1) begin
    assign issue_reg_T1[i]= issue_reg[i].T1;
    assign issue_reg_T2[i]= issue_reg[i].T2;
    assign issue_reg_inst_opcode[i] = issue_reg[i].inst_opcode;
  end
  //Instantiating the physical register
  assign is_pr_enable = 1;
  phys_regfile regf_0 (
    .rda_idx(issue_reg_T1),
    .rda_out(pr_T1_value), 

    .rdb_idx(issue_reg_T2),
    .rdb_out(pr_T2_value),

    .wr_clk(clock),
    .wr_en(ex_co_valid_inst),
    .wr_idx(ex_co_dest_reg_idx[`phys_index_t:0]),
    .wr_data(ex_co_alu_result)
  );

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
    for (integer i=0; i<5; i=i+1) begin
      is_ex_enable[i] = (~issue_reg[i].inst.valid_inst | (issue_reg[i].inst.valid_inst & ex_co_enable[i]));; // always enabled
    end
  end
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
     // id_di_NPC           <= `SD 0;//don't change this    // already have a slot in issue table
     // id_di_IR            <= `SD `NOOP_INST;
      is_ex_T1_value[0]   <= `SD 0;
      is_ex_T1_value[1]   <= `SD 0;
      is_ex_T1_value[2]   <= `SD 0;
      is_ex_T1_value[3]   <= `SD 0;
      is_ex_T1_value[4]   <= `SD 0;
      is_ex_T1_value[5]   <= `SD 0;
      is_ex_T2_value[0]   <= `SD 0;
      is_ex_T2_value[1]   <= `SD 0;
      is_ex_T2_value[2]   <= `SD 0;
      is_ex_T2_value[3]   <= `SD 0;
      is_ex_T2_value[4]   <= `SD 0;
      is_ex_T2_value[5]   <= `SD 0;
      // id_di_opa_select    <= `SD ALU_OPA_Iid_ex_rega
      // id_ex_opb_select    <= `SD ALU_OPB_Iid_ex_rega
      // id_ex_dest_reg_idx  <= `SD `ZERO_REGid_ex_rega
      // id_ex_alu_func      <= `SD ALU_ADDQ;id_ex_rega
      // id_ex_rd_mem        <= `SD 0;
      // id_ex_wr_mem        <= `SD 0;
      // id_ex_cond_branch   <= `SD 0;
      // id_ex_uncond_branch <= `SD 0;
      // id_ex_halt          <= `SD 0;
      // id_ex_illegal       <= `SD 0;
      // id_ex_valid_inst    <= `SD 0;
    end else if(is_ex_enable) begin // if (reset)
        //id_ex_NPC           <= `SD if_id_NPC;// alrady have a slot in issue table
       // id_ex_IR            <= `SD if_id_IR;
        is_ex_T1_value    <= `SD pr_T1_value;
        is_ex_T2_value    <= `SD pr_T2_value;
        // id_ex_opa_select    <= `SD id_opa_select_out;
        // id_ex_opb_select    <= `SD id_opb_select_out;
        // id_ex_dest_reg_idx  <= `SD id_dest_reg_idx_out;
        // id_ex_alu_func      <= `SD id_alu_func_out;
        // id_ex_rd_mem        <= `SD id_rd_mem_out;
        // id_ex_wr_mem        <= `SD id_wr_mem_out;
        // id_ex_cond_branch   <= `SD id_cond_branch_out;
        // id_ex_uncond_branch <= `SD id_uncond_branch_out;
        // id_ex_halt          <= `SD id_halt_out;
        // id_ex_illegal       <= `SD id_illegal_out;
        // id_ex_valid_inst    <= `SD id_valid_inst_out;
    end // else: !if(reset)
  end // always


  //////////////////////////////////////////////////
  //                                              //
  //                  EX-Stage                    //
  //                                              //
  //////////////////////////////////////////////////
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


  //////////////////////////////////////////////////
  //                                              //
  //           EX/CO Pipeline Register            //
  //                                              //
  //////////////////////////////////////////////////
  // not sure whether it can be directly assigned
  always_comb begin
    for (integer i=0; i<3; i=i+1) begin
      ex_co_enable[i]= (~ex_co_valid_inst[i])| (ex_co_valid_inst[i] & co_selected[i]);
    end
  end
 
  //enable signal for the multipler  register
  assign ex_co_enable[3]=  (~done & ~ex_co_valid_inst[3]) | (done & co_selected[3] & ex_co_valid_inst[3]); 

  assign ex_co_enable[4]= (~ex_co_valid_inst[4]| (ex_co_valid_inst[4] & co_selected[4]));
  

  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin//Initialize all registers once
    for (integer i=0; i<= 5; i=i+1) begin
      if (reset) begin
          ex_co_NPC[i]          <= `SD 0;
          ex_co_IR[i]           <= `SD `NOOP_INST;
          ex_co_dest_reg_idx[i] <= `SD `ZERO_REG;
        //  ex_co_rd_mem[i]       <= `SD 0;
          ex_co_wr_mem[i]       <= `SD 0;
          ex_co_halt[i]         <= `SD 0;
          ex_co_illegal[i]      <= `SD 0;
          ex_co_valid_inst[i]   <= `SD 0;
          //ex_co_rega[i]         <= `SD 0;
          ex_co_alu_result[i]   <= `SD 0;
      end else if(ex_co_enable[i]) begin
          // these are forwarded directly from ID/EX latches
          ex_co_NPC[i]          <= `SD issue_reg[i].npc;
          ex_co_IR[i]           <= `SD issue_reg[i].inst_opcode;
          ex_co_dest_reg_idx[i] <= `SD issue_reg[i].T;
         // ex_co_rd_mem       <= `SD issue_reg.inst.rd_mem;
          ex_co_wr_mem[i]       <= `SD issue_reg[i].inst.wr_mem;
          ex_co_halt[i]         <= `SD issue_reg[i].inst.halt;
          ex_co_illegal[i]      <= `SD issue_reg[i].inst.illegal;
          ex_co_valid_inst[i]   <= `SD issue_reg[i].inst.valid_inst;
          //ex_co_rega         <= `SD is_ex_T1_value[2];        //only for the load-store alu
          // these are results of EX stage
          ex_co_alu_result[i]   <= `SD ex_alu_result_out[i];      
      end // else: !if(reset)
    end // for loop end
  end // always

  always_ff @(posedge clock) begin
    if (reset) begin
      ex_co_done <= `SD 0;
      ex_co_take_branch  <= `SD 0;
    end else if(ex_co_enable[3]) begin
      ex_co_done  <= `SD done;
      ex_co_take_branch  <= `SD ex_take_branch_out;
    end
  end
  
   
//   //////////////////////////////////////////////////
//   //                                              //
//   //                 MEM-Stage                    //
//   //                                              //
//   //////////////////////////////////////////////////
//   mem_stage mem_stage_0 (// Inputs
//      .clock(clock),
//      .reset(reset),
//      .ex_mem_rega(ex_mem_rega),
//      .ex_mem_alu_result(ex_mem_ls_result), 
//      .ex_mem_rd_mem(ex_mem_rd_mem[2]),
//      .ex_mem_wr_mem(ex_mem_wr_mem[2]),
//      .Dmem2proc_data(mem2proc_data),
//      .Dmem2proc_tag(mem2proc_tag),
//      .Dmem2proc_response(Dmem2proc_response),
     
//      // Outputs
//      .mem_result_out(mem_result_out),
//      .mem_stall_out(mem_stall_out),
//      .proc2Dmem_command(proc2Dmem_command),
//      .proc2Dmem_addr(proc2Dmem_addr),
//      .proc2Dmem_data(proc2mem_data)
//             );

//   wire [4:0] mem_dest_reg_idx_out =
//              mem_stall_out ? `ZERO_REG : issue_reg[2].T;
//   wire mem_valid_inst_out = ex_mem_valid_inst[2] & ~mem_stall_out;

//   for (i=0; i<5; i=i+1) begin
//     if ()
//   end

// //////////////////////////////////////////////////
//   //                                              //
//   //           MEM/COMP Pipeline Register           //
//   //                                              //
//   //////////////////////////////////////////////////
// assign ex_co_enable = 1'b1; // always enabled
//   // synopsys sync_set_reset "reset"
//   always_ff @(posedge clock) begin
//     if (reset) begin
//       mem_co_NPC          <= `SD 0;
//       mem_co_IR           <= `SD `NOOP_INST;
//       mem_co_halt         <= `SD 0;
//       mem_co_illegal      <= `SD 0;
//       mem_co_valid_inst   <= `SD 0;
//       mem_co_dest_reg_idx <= `SD `ZERO_REG;
//       mem_co_take_branch  <= `SD 0;
//       mem_co_result       <= `SD 0;
//       mem_co_clear_valid  <= `SD 0;
//     end else begin
//       if (mem_co_enable) begin
//         // these are forwarded directly from EX/MEM latches
//         mem_co_NPC          <= `SD ex_mem_NPC;
//         mem_co_IR           <= `SD ex_mem_IR;
//         mem_co_halt         <= `SD ex_mem_halt;
//         mem_co_illegal      <= `SD ex_mem_illegal;
//         mem_co_valid_inst[4:0]   <= `SD mem_valid_inst_out;
//         mem_co_dest_reg_idx[1:0]  <= `SD ex_mem_dest_reg_idx[1:0];
//         mem_co_dest_reg_idx[2] <= `SD mem_dest_reg_idx_out;
//         mem_co_dest_reg_idx[3] <= `SD ex_mem_dest_reg_idx[3];
//         mem_co_take_branch  <= `SD ex_mem_take_branch;
//         // these are results of MEM stage
//         mem_co_result[3:0]  <= `SD ex_mem_alu_result[3:0]
//         mem_co_result[4]       <= `SD mem_result_out;
//         mem_co_clear_valid[mem_co_selected]    <= `SD 1;
//       end // if
//     end // else: !if(reset)
//   end // always


  //////////////////////////////////////////////////
  //                                              //
  //           complete stage                     //
  //                                              //
  //////////////////////////////////////////////////
  
  
  
  
  assign psel_enable = ex_co_valid_inst[0] | ex_co_valid_inst[1] | ex_co_valid_inst[2] | done | ex_co_valid_inst[4]; // ask the use of wor
  //priority encoder to select the results of the execution stage to put in cdb
  psel_generic #(`NUM_FU_TOTAL, 1) psel(
		.req({ ex_co_valid_inst[4], ex_co_done, ex_co_valid_inst[2:0]}),  // becasue the valid bit of mult will not be the request signal instead the done signal will be
		.en(psel_enable),
		.gnt(co_selected),
    .gnt_bus(gnt_bus)
	);
  
    always_comb begin
      if (|co_selected == 1) begin
        for (integer i=0; i< 5; i=i+1) begin
          if(co_selected[i]==1) begin
            co_NPC_selected               =    ex_co_NPC[i];
            co_IR_selected                =    ex_co_IR[i];
            co_halt_selected              =    ex_co_halt[i];
            co_illegal_selected           =    ex_co_illegal[i];
            co_valid_inst_selected        =    ex_co_valid_inst[i];
            co_reg_wr_idx_out             =    ex_co_dest_reg_idx[i];
            co_take_branch_selected       =    ex_co_take_branch[i];
            co_alu_result_selected        =    ex_co_alu_result[i];
             if(ex_co_IR[i] == 6'h18 )   co_branch_valid =    1;            // To check whether the inst is branch or not
             else                  co_branch_valid =    0;    
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
   
      
    
   

  assign co_branch_prediction = (co_take_branch_selected  == bp_output) ? 1:0 ;// Branch prediction or misprediction
  assign CDB_enable = psel_enable & ~co_branch_valid;                                       // check if theres any valid signal in the alu and also if the inst is branch or not 
  
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
//     .mem_wb_NPC(ex_co_NPC_selected),
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
    if (reset) begin
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
   
  ROB R0(
    // INPUTS
  	.clock(clock),
  	.reset(reset),
  	.enable(enable),
  	.T_old_in(T_old), // Comes from Map Table During Dispatch
  	.T_new_in(fr_rs_rob_T), // Comes from Free List During Dispatch
  	.CDB_tag_in(CDB_tag_out), // Comes from CDB during Commit
  	.CAM_en(CDB_enable), // Comes from CDB during Commit
  	.dispatch_en(dispatch_en), // Structural Hazard detection during Dispatch
  	.branch_not_taken(branch_not_taken),

  	// OUTPUTS
  	.T_free(rob_fl_arch_Told), // Output for Retire Stage goes to Free List
  	.T_arch(rob_arch_retire_reg), // Output for Retire Stage goes to Arch Map

  	.T_out_valid(arch_fr_enable),
  	.rob_free_entries(rob_free_entries),
  	.rob_full(rob_full), // Used for Dispatch Hazard
  	
  	.ROB_table_out(ROB_table_out),
  	.tail_reg(tail_reg), 
    .head_reg(head_reg)
  );

  //Intsantiating the arch map
  Arch_Map_Table a0(
  	.clock(clock),
  	.reset(reset),
  	.enable(arch_enable),
  	.T_new_in(rob_arch_retire_reg), // Comes from ROB during Retire
    .T_old_in(rob_fl_arch_Told), //What heewoo added. It is required to find which entry should I update. Comes from ROB during retire.

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
  //   .mem_wb_NPC(mem_wb_NPC),
  //   .mem_wb_result(mem_wb_result),
  //   .mem_wb_dest_reg_idx(mem_wb_dest_reg_idx),
  //   .mem_wb_take_branch(mem_wb_take_branch),
  //   .mem_wb_valid_inst(mem_wb_valid_inst),

  //   // Outputs
  //   .reg_wr_data_out(wb_reg_wr_data_out),
  //   .reg_wr_idx_out(wb_reg_wr_idx_out),
  //   .reg_wr_en_out(wb_reg_wr_en_out)
  // );

endmodule  // module verisimple
