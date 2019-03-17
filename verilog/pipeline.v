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

`timescale 1ns/100ps

module pipeline (

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


    // Outputs from ID/EX Pipeline Register
    output logic [63:0] id_ex_NPC,
    output logic [31:0] id_ex_IR,
    output logic        id_ex_valid_inst,


    // Outputs from EX/MEM Pipeline Register
    output logic [63:0] ex_mem_NPC,
    output logic [31:0] ex_mem_IR,
    output logic        ex_mem_valid_inst,


    // Outputs from MEM/WB Pipeline Register
    output logic [63:0] mem_wb_NPC,
    output logic [31:0] mem_wb_IR,
    output logic        mem_wb_valid_inst

  );

  // Pipeline register enables
  logic   if_id_enable, RS_enable, issue_ex_enable, ex_mem_enable, CDB_en, ROB_enable, co_re_enable;

  // Outputs from ID stage
  logic [63:0]   id_rega_out;
  logic [63:0]   id_regb_out;
  ALU_OPA_SELECT id_opa_select_out;
  ALU_OPB_SELECT id_opb_select_out;
  logic  [4:0]   id_dest_reg_idx_out;
  ALU_FUNC       id_alu_func_out;
  logic          id_rd_mem_out;
  logic          id_wr_mem_out;
  logic          id_cond_branch_out;
  logic          id_uncond_branch_out;
  logic          id_halt_out;
  logic          id_illegal_out;
  logic          id_valid_inst_out;
  logic [4:0]    ra_idx, rb_idx, rc_idx ; 

  //outputs from the maptable
  logic MAP_ROW_T [`NUM_GEN_REG-1:0]	map_table_out;
  logic PHYS_REG 		T1, 		// Output for Dispatch and goes to RS
	logic PHYS_REG 		T2, 		// Output for Dispatch and goes to RS
	logic PHYS_REG 		T 		// Output for Dispatch and goes to RS and ROB
);
  
  // outputs from dispatch stage
  RS_ROW_T [(`RS_SIZE - 1):0]		rs_table_out;             // for debugging
  RS_ROW_T [`NUM_FU-1:0]			issue_next;
  logic 	[$clog2(`NUM_FU) - 1:0]	issue_cnt;
  wand								rs_full;

  
  //Outputs from IS/EX Pipeline Register
   RS_ROW_T [`NUM_FU-1:0]			issue_reg;
  
  
  // Outputs from ID/EX Pipeline Register
  logic  [63:0]   id_ex_rega;
  logic  [63:0]   id_ex_regb;
  ALU_OPA_SELECT  id_ex_opa_select;
  ALU_OPB_SELECT  id_ex_opb_select;
  logic   [4:0]   id_ex_dest_reg_idx;
  ALU_FUNC        id_ex_alu_func;
  logic           id_ex_rd_mem;
  logic           id_ex_wr_mem;
  logic           id_ex_cond_branch;
  logic           id_ex_uncond_branch;
  logic           id_ex_halt;
  logic           id_ex_illegal;

  // Outputs from EX-Stage
  logic [63:0] ex_alu_result_out;
  logic        ex_take_branch_out;

  // Outputs from EX/MEM Pipeline Register
  logic   [4:0] ex_mem_dest_reg_idx;
  logic         ex_mem_rd_mem;
  logic         ex_mem_wr_mem;
  logic         ex_mem_halt;
  logic         ex_mem_illegal;
  logic  [63:0] ex_mem_rega;
  logic  [63:0] ex_mem_alu_result;
  logic         ex_mem_take_branch;

  // Outputs from MEM-Stage
  logic [63:0] mem_result_out;
  logic        mem_stall_out;

  // Outputs from MEM/WB Pipeline Register
  logic         mem_wb_halt;
  logic         mem_wb_illegal;
  logic   [4:0] mem_wb_dest_reg_idx;
  logic  [63:0] mem_wb_result;
  logic         mem_wb_take_branch;

  // Outputs from WB-Stage  (These loop back to the register file in ID)
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

  assign pipeline_completed_insts = {3'b0, mem_wb_valid_inst};
  assign pipeline_error_status =  mem_wb_illegal  ? HALTED_ON_ILLEGAL :
                                  mem_wb_halt     ? HALTED_ON_HALT :
                                  NO_ERROR;

  assign pipeline_commit_wr_idx = wb_reg_wr_idx_out;
  assign pipeline_commit_wr_data = wb_reg_wr_data_out;
  assign pipeline_commit_wr_en = wb_reg_wr_en_out;
  assign pipeline_commit_NPC = mem_wb_NPC;

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
    .mem_wb_valid_inst(mem_wb_valid_inst),
    .ex_mem_take_branch(ex_mem_take_branch),
    .ex_mem_target_pc(ex_mem_alu_result),
    .Imem2proc_data(Icache_data_out),
    .Imem_valid(Icache_valid_out),

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
  assign if_id_enable = 1'b1; // always enabled
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if(reset) begin
      if_id_NPC        <= `SD 0;
      if_id_IR         <= `SD `NOOP_INST;
      if_id_valid_inst <= `SD `FALSE;
    end // if (reset)
    else if (if_id_enable) begin
      if_id_NPC        <= `SD if_NPC_out;
      if_id_IR         <= `SD if_IR_out;
      if_id_valid_inst <= `SD if_valid_inst_out;
    end // if (if_id_enable)
  end // always
   
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
    .wb_reg_wr_en_out(wb_reg_wr_en_out),
    .wb_reg_wr_idx_out(wb_reg_wr_idx_out),
    .wb_reg_wr_data_out(wb_reg_wr_data_out),

    // Outputs
    .id_ra_value_out(id_rega_out),
    .id_rb_value_out(id_regb_out),
    .id_opa_select_out(id_opa_select_out),
    .id_opb_select_out(id_opb_select_out),
    .id_dest_reg_idx_out(id_dest_reg_idx_out),
    .id_alu_func_out(id_alu_func_out),
    .id_fu_name(id_fu_name_out),
    .id_rd_mem_out(id_rd_mem_out),
    .id_wr_mem_out(id_wr_mem_out),
    .id_ldl_mem_out(id_ldl_mem_out),
    .id_stc_mem_out(id_stc_mem_out),
    .id_cond_branch_out(id_cond_branch_out),
    .id_uncond_branch_out(id_uncond_branch_out),
    .id_halt_out(id_halt_out),
    .id_cpuid_out(id_cpuid_out),
    .id_illegal_out(id_illegal_out),
    .id_valid_inst_out(id_valid_inst_out)
    .ra_idx(id_ra_idx),
    .rb_idx(id_rb_idx),
    .rc_idx(id_rc_idx)

  );

// Instantiating the map table
  Map_Table m1( //Inputs
  .clock(clock),
	.reset(reset),
	.enable(enable),
	.reg_a(id_ra_idx), 		// Comes from Decode during Dispatch
	.reg_b(id_rb_idx), 		// Comes from Decode during Dispatch 
	.reg_dest(id_dest_reg_idx_out), 	// Comes from Decode during Dispatch
	.free_reg(free_reg), 	// Comes from Free List during Dispatch
	.CDB_tag_in(CDB_tag_in), 	// Comes from CDB during Commit
	.CDB_en(CDB_en), 	// Comes from CDB during Commit
	.map_check_point(map_check_point),
	.branch_incorrect(branch_incorrect),
	
  .map_table_out(map_table_out),
	.T1(T1), 		// Output for Dispatch and goes to RS
	.T2(T2), 		// Output for Dispatch and goes to RS
	.T(T) 		// Output for Dispatch and goes to RS and ROB

  )



  // Instantiate the physical register file used by this pipeline
  

  //////////////////////////////////////////////////
  //                                              //
  //                  DI/ISSUE-Stage                    //
  //                                              //
  //////////////////////////////////////////////////
  
  RS RS0(
      // inputs
      .clock(clock), 
      .reset(reset), 
      .enable(RS_enable), 
      .CAM_en(CAM_en), 
      .CDB_in(CDB_in), 
      .dispatch_valid(dispatch_valid),
      .inst_in({id_opa_select_out, id_opb_select_out, id_dest_reg_idx_out, id_alu_func_out, id_fu_name_out, id_rd_mem_out, id_wr_mem_out,
       id_ldl_mem_out, id_stc_mem_out, id_cond_branch_out, id_uncond_branch_out, id_halt_out, id_cpuid_out, id_illegal_out, id_valid_inst_out,T , T1, T2, 0}), 
      .LSQ_busy(LSQ_busy),                //black box
      .branch_not_taken(!ex_take_branch_out),     //check for this

      // outputs
      .rs_table_out(rs_table_out), 
      .issue_out(issue_next), 
      .issue_cnt(issue_cnt), 
      .rs_full(rs_full)
    );

  //////////////////////////////////////////////////
  //                                              //
  //                  ISSUE/EX-Stage                    //
  //                                              //
  //////////////////////////////////////////////////

  assign issue_ex_enable = 1'b1; // always enabled
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if(reset) begin
      issue_reg<= `SD 0;
    end
    else begin
      issue_reg<= `SD issue_next;
    end
  end


//Instantiating the physical register
phys_regfile regf_0 (
    .rda_idx(T1),
    .rda_out(T1_value), 

    .rdb_idx(T2),
    .rdb_out(T2_value),

    .wr_clk(clock),
    .wr_en(wb_phys_reg_wr_en_out),
    .wr_idx(T),
    .wr_data(T_value)
  );




  // Note: Decode signals for load-lock/store-conditional and "get CPU ID"
  //  instructions (id_{ldl,stc}_mem_out, id_cpuid_out) are not connected
  //  to anything because the provided EX and MEM stages do not implement
  //  these instructions.  You will have to implement these instructions
  //  if you plan to do a multicore project.

  //////////////////////////////////////////////////
  //                                              //
  //            IS/EX Pipeline Register           //
  //                                              //
  //////////////////////////////////////////////////
  assign id_ex_enable = 1'b1; // always enabled
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      id_ex_NPC           <= `SD 0;//don't change this
      id_ex_IR            <= `SD `NOOP_INST;
      id_ex_rega          <= `SD 0;
      id_ex_regb          <= `SD 0;
      id_ex_opa_select    <= `SD ALU_OPA_IS_REGA;
      id_ex_opb_select    <= `SD ALU_OPB_IS_REGB;
      id_ex_dest_reg_idx  <= `SD `ZERO_REG;
      id_ex_alu_func      <= `SD ALU_ADDQ;
      id_ex_rd_mem        <= `SD 0;
      id_ex_wr_mem        <= `SD 0;
      id_ex_cond_branch   <= `SD 0;
      id_ex_uncond_branch <= `SD 0;
      id_ex_halt          <= `SD 0;
      id_ex_illegal       <= `SD 0;
      id_ex_valid_inst    <= `SD 0;
    end else begin // if (reset)
      if (id_ex_enable) begin
        id_ex_NPC           <= `SD if_id_NPC;//don't change this
        id_ex_IR            <= `SD if_id_IR;
        id_ex_rega          <= `SD id_rega_out;
        id_ex_regb          <= `SD id_regb_out;
        id_ex_opa_select    <= `SD id_opa_select_out;
        id_ex_opb_select    <= `SD id_opb_select_out;
        id_ex_dest_reg_idx  <= `SD id_dest_reg_idx_out;
        id_ex_alu_func      <= `SD id_alu_func_out;
        id_ex_rd_mem        <= `SD id_rd_mem_out;
        id_ex_wr_mem        <= `SD id_wr_mem_out;
        id_ex_cond_branch   <= `SD id_cond_branch_out;
        id_ex_uncond_branch <= `SD id_uncond_branch_out;
        id_ex_halt          <= `SD id_halt_out;
        id_ex_illegal       <= `SD id_illegal_out;
        id_ex_valid_inst    <= `SD id_valid_inst_out;
      end // if
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
    .id_ex_NPC(id_ex_NPC), 
    .id_ex_IR(id_ex_IR),
    .id_ex_rega(id_ex_rega),
    .id_ex_regb(id_ex_regb),
    .id_ex_opa_select(id_ex_opa_select),
    .id_ex_opb_select(id_ex_opb_select),
    .id_ex_alu_func(id_ex_alu_func),
    .id_ex_cond_branch(id_ex_cond_branch),
    .id_ex_uncond_branch(id_ex_uncond_branch),

    // Outputs
    .ex_alu_result_out(ex_alu_result_out),
    .ex_take_branch_out(ex_take_branch_out)
    );


  //////////////////////////////////////////////////
  //                                              //
  //           EX/MEM Pipeline Register           //
  //                                              //
  //////////////////////////////////////////////////
  assign ex_mem_enable = ~mem_stall_out;
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      ex_mem_NPC          <= `SD 0;
      ex_mem_IR           <= `SD `NOOP_INST;
      ex_mem_dest_reg_idx <= `SD `ZERO_REG;
      ex_mem_rd_mem       <= `SD 0;
      ex_mem_wr_mem       <= `SD 0;
      ex_mem_halt         <= `SD 0;
      ex_mem_illegal      <= `SD 0;
      ex_mem_valid_inst   <= `SD 0;
      ex_mem_rega         <= `SD 0;
      ex_mem_alu_result   <= `SD 0;
      ex_mem_take_branch  <= `SD 0;
    end else begin
      if (ex_mem_enable) begin
        // these are forwarded directly from ID/EX latches
        ex_mem_NPC          <= `SD id_ex_NPC;
        ex_mem_IR           <= `SD id_ex_IR;
        ex_mem_dest_reg_idx <= `SD id_ex_dest_reg_idx;
        ex_mem_rd_mem       <= `SD id_ex_rd_mem;
        ex_mem_wr_mem       <= `SD id_ex_wr_mem;
        ex_mem_halt         <= `SD id_ex_halt;
        ex_mem_illegal      <= `SD id_ex_illegal;
        ex_mem_valid_inst   <= `SD id_ex_valid_inst;
        ex_mem_rega         <= `SD id_ex_rega;
        // these are results of EX stage
        ex_mem_alu_result   <= `SD ex_alu_result_out;
        ex_mem_take_branch  <= `SD ex_take_branch_out;
      end // if
    end // else: !if(reset)
  end // always
   
  //////////////////////////////////////////////////
  //                                              //
  //                 MEM-Stage                    //
  //                                              //
  //////////////////////////////////////////////////
  mem_stage mem_stage_0 (// Inputs
     .clock(clock),
     .reset(reset),
     .ex_mem_rega(ex_mem_rega),
     .ex_mem_alu_result(ex_mem_alu_result), 
     .ex_mem_rd_mem(ex_mem_rd_mem),
     .ex_mem_wr_mem(ex_mem_wr_mem),
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

  wire [4:0] mem_dest_reg_idx_out =
             mem_stall_out ? `ZERO_REG : ex_mem_dest_reg_idx;
  wire mem_valid_inst_out = ex_mem_valid_inst & ~mem_stall_out;

  //////////////////////////////////////////////////
  //                                              //
  //           MEM/WB Pipeline Register           //
  //                                              //
  //////////////////////////////////////////////////
  assign mem_wb_enable = 1'b1; // always enabled
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      mem_wb_NPC          <= `SD 0;
      mem_wb_IR           <= `SD `NOOP_INST;
      mem_wb_halt         <= `SD 0;
      mem_wb_illegal      <= `SD 0;
      mem_wb_valid_inst   <= `SD 0;
      mem_wb_dest_reg_idx <= `SD `ZERO_REG;
      mem_wb_take_branch  <= `SD 0;
      mem_wb_result       <= `SD 0;
    end else begin
      if (mem_wb_enable) begin
        // these are forwarded directly from EX/MEM latches
        mem_wb_NPC          <= `SD ex_mem_NPC;
        mem_wb_IR           <= `SD ex_mem_IR;
        mem_wb_halt         <= `SD ex_mem_halt;
        mem_wb_illegal      <= `SD ex_mem_illegal;
        mem_wb_valid_inst   <= `SD mem_valid_inst_out;
        mem_wb_dest_reg_idx <= `SD mem_dest_reg_idx_out;
        mem_wb_take_branch  <= `SD ex_mem_take_branch;
        // these are results of MEM stage
        mem_wb_result       <= `SD mem_result_out;
      end // if
    end // else: !if(reset)
  end // always


  //////////////////////////////////////////////////
  //                                              //
  //                  WB-Stage                    //
  //                                              //
  //////////////////////////////////////////////////
  wb_stage wb_stage_0 (
    // Inputs
    .clock(clock),
    .reset(reset),
    .mem_wb_NPC(mem_wb_NPC),
    .mem_wb_result(mem_wb_result),
    .mem_wb_dest_reg_idx(mem_wb_dest_reg_idx),
    .mem_wb_take_branch(mem_wb_take_branch),
    .mem_wb_valid_inst(mem_wb_valid_inst),

    // Outputs
    .reg_wr_data_out(wb_reg_wr_data_out),
    .reg_wr_idx_out(wb_reg_wr_idx_out),
    .reg_wr_en_out(wb_reg_wr_en_out)
  );

endmodule  // module verisimple
