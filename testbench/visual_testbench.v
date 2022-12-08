/////////////////////////////////////////////////////////////////////////
//                                                                     //
//                                                                     //
//   Modulename :  visual_testbench.v                                  //
//                                                                     //
//  Description :  Testbench module for the verisimple pipeline        //
//                   for the visual debugger                           //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

`include "../../sys_defs.vh"
`timescale 1ns/100ps

extern void initcurses(int,int,int,int,int,int,int,int,int,int);
extern void flushpipe();
extern void waitforresponse();
extern void initmem();
extern int get_instr_at_pc(int);
extern int not_valid_pc(int);

module testbench();

  // Registers and wires used in the testbench
  logic        clock;
  logic        reset;
  logic	       enable;
  logic [31:0] clock_count;
  logic [31:0] instr_count;
  int          wb_fileno;

  logic [1:0]  proc2mem_command;
  logic [63:0] proc2mem_addr;
  logic [63:0] proc2mem_data;
  logic  [3:0] mem2proc_response;
  logic [63:0] mem2proc_data;
  logic  [3:0] mem2proc_tag;

  logic  [3:0] pipeline_completed_insts;
  ERROR_CODE   pipeline_error_status;
  logic  [4:0] pipeline_commit_wr_idx;
  logic [63:0] pipeline_commit_wr_data;
  logic        pipeline_commit_wr_en;
  logic [63:0] pipeline_commit_NPC;
  logic	[5:0]  pipeline_commit_phys_reg;
  logic [5:0]  pipeline_commit_phys_from_arch;
  
  logic		pipeline_branch_en;
  logic		pipeline_branch_pred_correct;
  logic	[31:0]	branch_inst_count;
  logic [31:0]  branch_pred_count;

  logic		retire_inst_busy;
  logic	[63:0]  retire_reg_NPC;

  logic [63:0] if_NPC_out;
  logic [31:0] if_IR_out;
  logic        if_valid_inst_out;
  logic [63:0] if_id_NPC;
  logic [31:0] if_id_IR;
  logic        if_id_valid_inst;
  logic [63:0] id_di_NPC;
  logic [31:0] id_di_IR;
  logic        id_di_valid_inst;
  logic [`RS_SIZE-1:0][63:0] rs_table_out_npc;
  logic [`RS_SIZE-1:0][31:0] rs_table_out_inst_opcode;
  logic [`RS_SIZE-1:0]       rs_table_out_inst_valid_inst;  
  logic [`NUM_FU_TOTAL-1:0][63:0] issue_reg_npc;
  logic [`NUM_FU_TOTAL-1:0][31:0] issue_reg_inst_opcode;
  logic [`NUM_FU_TOTAL-1:0]       issue_reg_inst_valid_inst;
  logic [`NUM_FU_TOTAL-1:0][63:0] ex_co_NPC;
  logic [`NUM_FU_TOTAL-1:0][31:0] ex_co_IR;
  logic [`NUM_FU_TOTAL-1:0]       ex_co_valid_inst;
  logic [63:0] co_ret_NPC;
  logic [31:0] co_ret_IR;
  logic        co_ret_valid_inst;
  logic if_id_enable;
  logic RS_enable;
  logic is_pr_enable;
  logic CDB_enable; 
  logic ROB_enable;
  logic co_ret_enable; 
  logic dispatch_en;
  logic [4:0] is_ex_enable;
  logic [4:0]   ex_co_enable;
  logic branch_not_taken;
  RS_ROW_T	[(`RS_SIZE-1):0]		rs_table_out;
  PHYS_REG		[`NUM_GEN_REG-1:0]	arch_table;
  ROB_ROW_T [`ROB_SIZE:1]		ROB_table_out;
  PHYS_REG [`NUM_PHYS_REG-1:0] free_list_out;
  RS_ROW_T[`NUM_FU_TOTAL-1 :0] issue_next;
  logic [`NUM_FU_TOTAL-1:0][63:0] issue_next_npc;
  logic [`NUM_FU_TOTAL-1:0][31:0] issue_next_inst_opcode;
  logic [`NUM_FU_TOTAL-1:0]       issue_next_valid_inst;
  logic mem_co_valid_inst;   
  logic [63:0] mem_co_NPC ;        
  logic [31:0] mem_co_IR ;
	//CACHE_SET_T [(`NUM_SETS - 1):0] dcache_data; 

  integer i;
    int out_file;

  // Instantiate the Pipeline
  pipeline #(.FU_NAME_VAL({FU_ALU, FU_LD, FU_MULT, FU_BR, FU_ST}),
  .FU_BASE_IDX({FU_ALU_IDX, FU_LD_IDX, FU_MULT_IDX, FU_BR_IDX, FU_ST_IDX}),
  .NUM_OF_FU_TYPE({2'b10,2'b01,2'b01,2'b01, 2'b01})) pipeline_0(
    // Inputs
    .clock             (clock),
    .reset             (reset),
    .enable		(1'b1),
    .mem2proc_response (mem2proc_response),
    .mem2proc_data     (mem2proc_data),
    .mem2proc_tag      (mem2proc_tag),


    // Outputs
    .proc2mem_command  (proc2mem_command),
    .proc2mem_addr     (proc2mem_addr),
    .proc2mem_data     (proc2mem_data),

    .pipeline_completed_insts(pipeline_completed_insts),
    .pipeline_error_status(pipeline_error_status),
    .pipeline_commit_wr_data(pipeline_commit_wr_data),
    .pipeline_commit_wr_idx(pipeline_commit_wr_idx),
    .pipeline_commit_wr_en(pipeline_commit_wr_en),
    .pipeline_commit_NPC(pipeline_commit_NPC),
    .pipeline_commit_phys_reg(pipeline_commit_phys_reg),
    .pipeline_commit_phys_from_arch(pipeline_commit_phys_from_arch),
    .pipeline_branch_en(pipeline_branch_en),
    .pipeline_branch_pred_correct(pipeline_branch_pred_correct),

	  .dcache_data(dcache_data),

    .retire_inst_busy(retire_inst_busy),
    .retire_reg_NPC(retire_reg_NPC),

    .if_NPC_out(if_NPC_out),
    .if_IR_out(if_IR_out),
    .if_valid_inst_out(if_valid_inst_out),
    .if_id_NPC(if_id_NPC),
    .if_id_IR(if_id_IR),
    .if_id_valid_inst(if_id_valid_inst),
    .id_di_NPC(id_di_NPC),
    .id_di_IR(id_di_IR),
    .id_di_valid_inst(id_di_valid_inst),
    .rs_table_out_npc(rs_table_out_npc),
    .rs_table_out_inst_opcode(rs_table_out_inst_opcode),
    .rs_table_out_inst_valid_inst(rs_table_out_inst_valid_inst),  
    .issue_reg_npc(issue_reg_npc),
    .issue_reg_inst_opcode(issue_reg_inst_opcode),
    .issue_reg_inst_valid_inst(issue_reg_inst_valid_inst),
    .ex_co_NPC(ex_co_NPC),
    .ex_co_IR(ex_co_IR),
    .ex_co_valid_inst(ex_co_valid_inst),
    .co_ret_NPC(co_ret_NPC),
    .co_ret_IR(co_ret_IR),
    .co_ret_valid_inst(co_ret_valid_inst),
	  .rs_table_out(rs_table_out),
    .arch_table(arch_table),
    .ROB_table_out(ROB_table_out),
    .free_list_out(free_list_out),
     .issue_next(issue_next),
    .co_ret_valid_inst(co_ret_valid_inst),
    .if_id_enable(if_id_enable),
    .RS_enable(RS_enable),
    .is_pr_enable(is_pr_enable),
    .CDB_enable(CDB_enable), 
    .ROB_enable(ROB_enable), 
    .co_ret_enable(co_ret_enable), 
    .dispatch_en(dispatch_en),
    .is_ex_enable(is_ex_enable),
    .ex_co_enable(ex_co_enable), 
    .branch_not_taken(branch_not_taken)
  );

  // Instantiate the Data Memory
  mem memory (// Inputs
            .clk               (clock),
            .proc2mem_command  (proc2mem_command),
            .proc2mem_addr     (proc2mem_addr),
            .proc2mem_data     (proc2mem_data),

             // Outputs

            .mem2proc_response (mem2proc_response),
            .mem2proc_data     (mem2proc_data),
            .mem2proc_tag      (mem2proc_tag)
           );

  // Generate System Clock
  always
  begin
    #(`VERILOG_CLOCK_PERIOD/2.0);
    clock = ~clock;
  end

  // Count the number of posedges and number of instructions completed
  // till simulation ends
  always @(posedge clock)
  begin
    if(reset)
    begin
      clock_count <= `SD 0;
      instr_count <= `SD 0;
    end
    else
    begin
      clock_count <= `SD (clock_count + 1);
      instr_count <= `SD (instr_count + pipeline_completed_insts);
    end
  end  

  initial
  begin
    clock = 0;
    reset = 0;

    // Call to initialize visual debugger
    // *Note that after this, all stdout output goes to visual debugger*
    // each argument is number of registers/signals for the group
    // (IF, IF/ID, ID, ID/EX, EX, EX/MEM, MEM, MEM/WB, WB, Misc)
    initcurses(6,4,15,128,48,128,8,10,5,2);

    // Pulse the reset signal
    reset = 1'b1;
    @(posedge clock);
    @(posedge clock);

    // Read program contents into memory array
    $readmemh("program.mem", memory.unified_memory);

    @(posedge clock);
    @(posedge clock);
    `SD;
    // This reset is at an odd time to avoid the pos & neg clock edges
    reset = 1'b0;
  end

  always @(negedge clock)
  begin
    if(!reset)
    begin
      `SD;
      `SD;

      // deal with any halting conditions
      if(pipeline_error_status!=NO_ERROR)
      begin
        #100
        $display("\nDONE\n");
        waitforresponse();
        flushpipe();
        $finish;
      end

    end
  end 

  // This block is where we dump all of the signals that we care about to
  // the visual debugger.  Notice this happens at *every* clock edge.
  // integer i;
  always @(clock) begin
    #2;

    // Dump clock and time onto stdout
    $display("c%h%7.0d",clock,clock_count);
    $display("t%8.0f",$time);
    $display("z%h",reset);

    //       $write("%h", pipeline_0.phys_reg[pipeline_0.arch_table[i][5:0]]);

    //out_file = $fopen("output.txt");

    // dump ARF contents
    $write("a");
    for(i = 0; i < 32; i=i+1)
    begin
      $write("%h", pipeline_0.phys_reg[pipeline_0.arch_table[i][5:0]]);
      //$fdisplay(out_file, "%h", pipeline_0.phys_reg[pipeline_0.arch_table[i][5:0]]);
    end
    $display("");

    // dump IR information so we can see which instruction
    // is in each stage
    $write("p");
    $write("%h%h%h%h%h%h%h%h%h%h ",
            pipeline_0.if1_IR_out, pipeline_0.if1_valid_inst_out,
            pipeline_0.if_id_IR,  pipeline_0.if_id_valid_inst,
            //pipeline_0.id_ex_IR,  pipeline_0.id_ex_valid_inst,
            pipeline_0.id_di_IR, pipeline_0.id_di_valid_inst,
            //pipeline_0.ex_mem_IR, pipeline_0.ex_mem_valid_inst,
            pipeline_0.issue_next[0].inst_opcode, pipeline_0.issue_next[0].inst.valid_inst,
            //pipeline_0.mem_wb_IR, pipeline_0.mem_wb_valid_inst);
            pipeline_0.issue_reg_inst_opcode[0], pipeline_0.issue_reg_inst_valid_inst[0]);
    $display("");
    
    // Dump interesting register/signal contents onto stdout
    // format is "<reg group prefix><name> <width in hex chars>:<data>"
    // Current register groups (and prefixes) are:
    // f: IF   d: ID   e: EX   m: MEM    w: WB  v: misc. reg
    // g: IF/ID   h: ID/EX  i: EX/MEM  j: MEM/WB

    // IF signals (6) - prefix 'f'
    $display("fNPC 16:%h",          pipeline_0.if_NPC_out);
    $display("fIR 8:%h",            pipeline_0.if_IR_out);
    $display("fImem_addr 16:%h",    pipeline_0.if_stage_0.proc2Imem_addr);
    $display("fPC_en 1:%h",         pipeline_0.if_stage_0.PC_enable);
    $display("fPC_reg 16:%h",       pipeline_0.if_stage_0.PC_reg);
    $display("fif_valid 1:%h",      pipeline_0.if_valid_inst_out);

    // IF/ID signals (4) - prefix 'g'
    $display("genable 1:%h",        pipeline_0.if_id_enable);
    $display("gNPC 16:%h",          pipeline_0.if_id_NPC);
    $display("gIR 8:%h",            pipeline_0.if_id_IR);
    $display("gvalid 1:%h",         pipeline_0.if_id_valid_inst);

    // ID signals (13) - prefix 'd'
    // $display("dra_idx 2:%h",         pipeline_0.id_ra_idx);
    // $display("drb_idx 2:%h",         pipeline_0.id_rb_idx);
    // $display("ddest_idx 2:%h",         pipeline_0.id_rdest_idx);
    //$display("ddest_reg 2:%h",      pipeline_0.id_dest_reg_idx_out);
    $display("dopa_sel 1:%h",       pipeline_0.id_inst_out.inst.opa_select);
    $display("dopb_sel 1:%h",       pipeline_0.id_inst_out.inst.opb_select);
    $display("ddest_sel 1:%h",       pipeline_0.id_inst_out.inst.dest_reg);
    $display("dalu_func 2:%h",      pipeline_0.id_inst_out.inst.alu_func);
    $display("dfu_name 1:%h",      pipeline_0.id_inst_out.inst.fu_name);
    $display("drd_mem 1:%h",        pipeline_0.id_inst_out.inst.rd_mem);
    $display("dwr_mem 1:%h",        pipeline_0.id_inst_out.inst.wr_mem);
    $display("dldl_mem 1:%h",        pipeline_0.id_inst_out.inst.ldl_mem);
    $display("dstc_mem 1:%h",        pipeline_0.id_inst_out.inst.stc_mem);
    $display("dcond_br 1:%h",       pipeline_0.id_inst_out.inst.cond_branch);
    $display("duncond_br 1:%h",     pipeline_0.id_inst_out.inst.uncond_branch);
    $display("dhalt 1:%h",          pipeline_0.id_inst_out.inst.halt);
    $display("dcpuid 1:%h",       pipeline_0.id_inst_out.inst.cpuid);
    $display("dillegal 1:%h",       pipeline_0.id_inst_out.inst.illegal);
    $display("dvalid 1:%h",         pipeline_0.id_inst_out.inst.valid_inst);

    // ID/EX signals (16) - prefix 'h'
    // $display("henable 1:%h",        pipeline_0.id_ex_enable);
    // $display("hNPC 16:%h",          pipeline_0.id_ex_NPC); 
    // $display("hIR 8:%h",            pipeline_0.id_ex_IR); 
    // $display("hrega 16:%h",         pipeline_0.id_ex_rega); 
    // $display("hregb 16:%h",         pipeline_0.id_ex_regb); 
    // $display("hdest_reg 2:%h",      pipeline_0.id_ex_dest_reg_idx);
    // $display("hrd_mem 1:%h",        pipeline_0.id_ex_rd_mem);
    // $display("hwr_mem 1:%h",        pipeline_0.id_ex_wr_mem);
    // $display("hopa_sel 1:%h",       pipeline_0.id_ex_opa_select);
    // $display("hopb_sel 1:%h",       pipeline_0.id_ex_opb_select);
    // $display("halu_func 2:%h",      pipeline_0.id_ex_alu_func);
    // $display("hcond_br 1:%h",       pipeline_0.id_ex_cond_branch);
    // $display("huncond_br 1:%h",     pipeline_0.id_ex_uncond_branch);
    // $display("hhalt 1:%h",          pipeline_0.id_ex_halt);
    // $display("hillegal 1:%h",       pipeline_0.id_ex_illegal);
    // $display("hvalid 1:%h",         pipeline_0.id_ex_valid_inst);
    for (int s=0; s<`ROB_SIZE; s+=1) begin
      $display("h 2:%h",  pipeline_0.ROB_table_out[s].T_new);
      $display("h 2:%h",   pipeline_0.ROB_table_out[s].T_old);
      $display("h 1:%h",  pipeline_0.ROB_table_out[s].busy);
      $display("h 1:%h",   pipeline_0.ROB_table_out[s].halt);
      $display("h 8:%h",   pipeline_0.ROB_table_out[s].opcode);
      $display("h 1:%h",   pipeline_0.ROB_table_out[s].take_branch);
      $display("h 2:%h",   pipeline_0.ROB_table_out[s].wr_idx);
      $display("h 16:%h",   pipeline_0.ROB_table_out[s].npc);
    end
      // $display("h 2:%h",  pipeline_0.ROB_table_out[0].T_new);
      // $display("h 2:%h",   pipeline_0.ROB_table_out[0].T_old);
      // $display("h 1:%h",  pipeline_0.ROB_table_out[0].busy);
      // $display("h 1:%h",   pipeline_0.ROB_table_out[0].halt);
      // $display("h 8:%h",   pipeline_0.ROB_table_out[0].opcode);
      // $display("h 1:%h",   pipeline_0.ROB_table_out[0].take_branch);
      // $display("h 2:%h",   pipeline_0.ROB_table_out[0].wr_idx);
      // $display("h 16:%h",   pipeline_0.ROB_table_out[0].npc);
    // EX signals (4) - prefix 'e'
    // $display("eopa_mux 16:%h",      pipeline_0.ex_stage_0.opa_mux_out);
    // $display("eopb_mux 16:%h",      pipeline_0.ex_stage_0.opb_mux_out);
    // $display("ealu_result 16:%h",   pipeline_0.ex_alu_result_out);
    // $display("etake_branch 1:%h",   pipeline_0.ex_take_branch_out);
      $display("e[0] 2:%h",      pipeline_0.free_list_out[0]);
      $display("e[1] 2:%h",      pipeline_0.free_list_out[1]);
      $display("e[2] 2:%h",      pipeline_0.free_list_out[2]);
      $display("e[3] 2:%h",      pipeline_0.free_list_out[3]);
      $display("e[4] 2:%h",      pipeline_0.free_list_out[4]);
      $display("e[5] 2:%h",      pipeline_0.free_list_out[5]);
      $display("e[6] 2:%h",      pipeline_0.free_list_out[6]);
      $display("e[7] 2:%h",      pipeline_0.free_list_out[7]);
      $display("e[8] 2:%h",      pipeline_0.free_list_out[8]);
      $display("e[9] 2:%h",      pipeline_0.free_list_out[9]);
      $display("e[10] 2:%h",      pipeline_0.free_list_out[10]);
      $display("e[11] 2:%h",      pipeline_0.free_list_out[11]);
      $display("e[12] 2:%h",      pipeline_0.free_list_out[12]);
      $display("e[13] 2:%h",      pipeline_0.free_list_out[13]);
      $display("e[14] 2:%h",      pipeline_0.free_list_out[14]);
      $display("e[15] 2:%h",      pipeline_0.free_list_out[15]);
      $display("e[16] 2:%h",      pipeline_0.free_list_out[16]);
      $display("e[17] 2:%h",      pipeline_0.free_list_out[17]);
      $display("e[18] 2:%h",      pipeline_0.free_list_out[18]);
      $display("e[19] 2:%h",      pipeline_0.free_list_out[19]);
      $display("e[20] 2:%h",      pipeline_0.free_list_out[20]);
      $display("e[21] 2:%h",      pipeline_0.free_list_out[21]);
      $display("e[22] 2:%h",      pipeline_0.free_list_out[22]);
      $display("e[23] 2:%h",      pipeline_0.free_list_out[23]);
      $display("e[24] 2:%h",      pipeline_0.free_list_out[24]);
      $display("e[25] 2:%h",      pipeline_0.free_list_out[25]);
      $display("e[26] 2:%h",      pipeline_0.free_list_out[26]);
      $display("e[27] 2:%h",      pipeline_0.free_list_out[27]);
      $display("e[28] 2:%h",      pipeline_0.free_list_out[28]);
      $display("e[29] 2:%h",      pipeline_0.free_list_out[29]);
      $display("e[30] 2:%h",      pipeline_0.free_list_out[30]);
      $display("e[31] 2:%h",      pipeline_0.free_list_out[31]);
      $display("e[32] 2:%h",      pipeline_0.free_list_out[32]);
      $display("e[33] 2:%h",      pipeline_0.free_list_out[33]);
      $display("e[34] 2:%h",      pipeline_0.free_list_out[34]);
      $display("e[35] 2:%h",      pipeline_0.free_list_out[35]);
      $display("e[36] 2:%h",      pipeline_0.free_list_out[36]);
      $display("e[37] 2:%h",      pipeline_0.free_list_out[37]);
      $display("e[38] 2:%h",      pipeline_0.free_list_out[38]);
      $display("e[39] 2:%h",      pipeline_0.free_list_out[39]);
      $display("e[40] 2:%h",      pipeline_0.free_list_out[40]);
      $display("e[41] 2:%h",      pipeline_0.free_list_out[41]);
      $display("e[42] 2:%h",      pipeline_0.free_list_out[42]);
      $display("e[43] 2:%h",      pipeline_0.free_list_out[43]);
      $display("e[44] 2:%h",      pipeline_0.free_list_out[44]);
      $display("e[45] 2:%h",      pipeline_0.free_list_out[45]);
      $display("e[46] 2:%h",      pipeline_0.free_list_out[46]);
      $display("e[47] 2:%h",      pipeline_0.free_list_out[47]);

    // EX/MEM signals (12) - prefix 'i'
    // $display("ienable 1:%h",        pipeline_0.ex_mem_enable);
    // $display("iNPC 16:%h",          pipeline_0.ex_mem_NPC);
    // $display("iIR 8:%h",            pipeline_0.ex_mem_IR);
    // $display("irega 16:%h",         pipeline_0.ex_mem_rega);
    // $display("ialu_result 16:%h",   pipeline_0.ex_mem_alu_result);
    // $display("idest_reg 2:%h",      pipeline_0.ex_mem_dest_reg_idx);
    // $display("ird_mem 1:%h",        pipeline_0.ex_mem_rd_mem);
    // $display("iwr_mem 1:%h",        pipeline_0.ex_mem_wr_mem);
    // $display("itake_branch 1:%h",   pipeline_0.ex_mem_take_branch);
    // $display("ihalt 1:%h",          pipeline_0.ex_mem_halt);
    // $display("iillegal 1:%h",       pipeline_0.ex_mem_illegal);
    // $display("ivalid 1:%h",         pipeline_0.ex_mem_valid_inst);
    // $display("ienable 1:%h",        pipeline_0.ex_co_enable[0]);//good candidate to replace with rs
    // $display("iNPC 16:%h",          pipeline_0.ex_co_NPC[0]);
    // $display("iIR 8:%h",            pipeline_0.ex_co_IR[0]);
    // $display("ialu_result 16:%h",   pipeline_0.ex_co_alu_result[0]);
    // $display("idest_reg 2:%h",      pipeline_0.ex_co_dest_reg_idx[0]);
    // $display("ird_mem 1:%h",        pipeline_0.ex_co_rd_mem[0]);
    // $display("iwr_mem 1:%h",        pipeline_0.ex_co_wr_mem[0]);
    // $display("ihalt 1:%h",          pipeline_0.ex_co_halt[0]);
    // $display("iillegal 1:%h",       pipeline_0.ex_co_illegal[0]);
    // $display("ivalid 1:%h",         pipeline_0.ex_co_valid_inst[0]);
    for (int s=0; s<`RS_SIZE; s+=1) begin
      $display("i 2:%h",  pipeline_0.rs_table_out[s].T);
      $display("i 2:%h",   pipeline_0.rs_table_out[s].T1);
      $display("i 2:%h",   pipeline_0.rs_table_out[s].T2);
      $display("i 1:%h",  pipeline_0.rs_table_out[s].busy);
      $display("i 8:%h",   pipeline_0.rs_table_out[s].inst_opcode);
      $display("i 16:%h",   pipeline_0.rs_table_out[s].npc);
      $display("i 2:%h",   pipeline_0.rs_table_out[s].sq_idx);
      $display("i 2:%h",   pipeline_0.rs_table_out[s].br_idx);
    end
    // MEM signals (5) - prefix 'm'
    // $display("mmem_data 16:%h",     pipeline_0.mem_stage_0.Dmem2proc_data);
    // $display("mresult_out 16:%h",   pipeline_0.mem_result_out);
    // $display("m2Dmem_data 16:%h",   pipeline_0.proc2mem_data);
    // $display("m2Dmem_addr 16:%h",   pipeline_0.proc2Dmem_addr);
    // $display("m2Dmem_cmd 1:%h",     pipeline_0.proc2Dmem_command);
    $display("menable 1:%h",        pipeline_0.mem_co_enable);
    $display("mNPC 16:%h",          pipeline_0.mem_co_NPC);
    $display("mIR 8:%h",            pipeline_0.mem_co_IR);
    $display("malu_result 16:%h",   pipeline_0.mem_co_alu_result);
    $display("mdest_reg 2:%h",      pipeline_0.mem_co_dest_reg_idx);
    $display("mhalt 1:%h",          pipeline_0.mem_co_halt);
    $display("millegal 1:%h",       pipeline_0.mem_co_illegal);
    $display("mvalid 1:%h",         pipeline_0.mem_co_valid_inst);

    // MEM/WB signals (9) - prefix 'j'
    // $display("jenable 1:%h",        pipeline_0.mem_wb_enable);
    // $display("jNPC 16:%h",          pipeline_0.mem_wb_NPC);
    // $display("jIR 8:%h",            pipeline_0.mem_wb_IR);
    // $display("jresult 16:%h",       pipeline_0.mem_wb_result);
    // $display("jdest_reg 2:%h",      pipeline_0.mem_wb_dest_reg_idx);
    // $display("jtake_branch 1:%h",   pipeline_0.mem_wb_take_branch);
    // $display("jhalt 1:%h",          pipeline_0.mem_wb_halt);
    // $display("jillegal 1:%h",       pipeline_0.mem_wb_illegal);
    // $display("jvalid 1:%h",         pipeline_0.mem_wb_valid_inst);
    $display("jenable 1:%h",        pipeline_0.co_ret_enable);
    $display("jNPC 16:%h",          pipeline_0.co_ret_NPC);
    $display("jIR 8:%h",            pipeline_0.co_ret_IR);
    $display("jresult 16:%h",       pipeline_0.co_ret_result);
    $display("jdest_reg 2:%h",      pipeline_0.co_ret_dest_reg_idx);
    $display("jtake_branch 1:%h",   pipeline_0.co_ret_take_branch);
    $display("jhalt 1:%h",          pipeline_0.co_ret_halt);
    $display("jillegal 1:%h",       pipeline_0.co_ret_illegal);
    $display("jvalid 1:%h",         pipeline_0.co_ret_valid_inst);
    $display("jbranch_prediction 1:%h",         pipeline_0.co_ret_branch_prediction);

    // WB signals (3) - prefix 'w'
    // $display("wwr_data 16:%h",      pipeline_0.wb_reg_wr_data_out);
    // $display("wwr_idx 2:%h",        pipeline_0.wb_reg_wr_idx_out);
    // $display("wwr_en 1:%h",         pipeline_0.wb_reg_wr_en_out);
    $display("winst_busy 1:%h",      pipeline_0.retire_inst_busy);
    $display("wreg_wr_idx 2:%h",        pipeline_0.retire_reg_wr_idx);
    $display("wreg_wr_en 1:%h",         pipeline_0.retire_reg_wr_en);
    $display("wreg_NPC 8:%h",        pipeline_0.retire_reg_NPC);
    $display("wreg_phys 2:%h",         pipeline_0.retire_reg_phys);

    // Misc signals (9) - prefix 'v'
    $display("vcompleted 1:%h",     pipeline_0.pipeline_completed_insts);
    $display("vpipe_err 1:%h",      pipeline_error_status);
    // $display("vI$_data 16:%h",      pipeline_0.Icache_data_out);
    // $display("vI$_valid 1:%h",      pipeline_0.Icache_valid_out);
    // $display("vI$_rd_idx 2:%h",     pipeline_0.Icache_rd_idx);
    // $display("vI$_rd_tag 6:%h",     pipeline_0.Icache_rd_tag);
    // $display("vI$_wr_idx 2:%h",     pipeline_0.Icache_wr_idx);
    // $display("vI$_wr_tag 6:%h",     pipeline_0.Icache_wr_tag);
    // $display("vI$_wr_en 1:%h",      pipeline_0.Icache_wr_en);


    // must come last
    $display("break");

    // This is a blocking call to allow the debugger to control when we
    // advance the simulation
    waitforresponse();
  end
endmodule
