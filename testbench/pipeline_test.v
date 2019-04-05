/////////////////////////////////////////////////////////////////////////
//                                                                     //
//                                                                     //
//   Modulename :  testbench.v                                         //
//                                                                     //
//  Description :  Testbench module for the verisimple pipeline;       //
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

`include "../../sys_defs.vh"

extern void print_header(string str);
extern void print_cycles(int valid);
extern void print_stage(string div, int inst, int npc, int valid_inst);
//extern void print_stage_array_RS_size(string div, int inst[`RS_SIZE], int npc[`RS_SIZE], int valid_inst[`RS_SIZE]);
//extern void print_stage_array_RS_size(string div, int inst[`RS_SIZE], int npc[`RS_SIZE], int valid_inst[`RS_SIZE]);
extern void print_reg(int wb_reg_wr_data_out_hi, int wb_reg_wr_data_out_lo,
                      int wb_reg_wr_idx_out, int wb_reg_wr_en_out);
extern void print_membus(int proc2mem_command, int mem2proc_response,
                         int proc2mem_addr_hi, int proc2mem_addr_lo,
                         int proc2mem_data_hi, int proc2mem_data_lo);
extern void print_close();


module testbench;

  // variables used in the testbench
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
  logic  [5:0] pipeline_commit_wr_idx;
  logic [63:0] pipeline_commit_wr_data;
  logic        pipeline_commit_wr_en;
  logic [63:0] pipeline_commit_NPC;
  logic	[5:0]  pipeline_commit_phys_reg;

  logic [63:0] if_NPC_out;
  logic [31:0] if_IR_out;
  logic        if_valid_inst_out;
  logic [63:0] if_id_NPC;
  logic [31:0] if_id_IR;
  logic        if_id_valid_inst;
  // logic [63:0] id_di_NPC;
  // logic [31:0] id_di_IR;
  // logic        id_di_valid_inst;
  // logic [63:0] ex_mem_NPC;
  // logic [31:0] ex_mem_IR;
  // logic        ex_mem_valid_inst;
  // logic [63:0] mem_wb_NPC;
  // logic [31:0] mem_wb_IR;
  // logic        mem_wb_valid_inst;
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
  int pipe_counter; 
  int copy_pipe_counter;
  // Instantiate the Pipeline
  pipeline #(.FU_NAME_VAL({FU_ALU, FU_LD, FU_MULT, FU_BR}),
  .FU_BASE_IDX({FU_ALU_IDX, FU_LD_IDX, FU_MULT_IDX, FU_BR_IDX}),
  .NUM_OF_FU_TYPE({2'b10,2'b01,2'b01,2'b01})) pipeline_0(
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

    .if_NPC_out(if_NPC_out),
    .if_IR_out(if_IR_out),
    .if_valid_inst_out(if_valid_inst_out),
    .if_id_NPC(if_id_NPC),
    .if_id_IR(if_id_IR),
    .if_id_valid_inst(if_id_valid_inst),
    .id_di_NPC(id_di_NPC),
    .id_di_IR(id_di_IR),
    .id_di_valid_inst(id_di_valid_inst),
    // .id_ex_NPC(id_ex_NPC),
    // .id_ex_IR(id_ex_IR),
    // .id_ex_valid_inst(id_ex_valid_inst),
    // .ex_mem_NPC(ex_mem_NPC),
    // .ex_mem_IR(ex_mem_IR),
    // .ex_mem_valid_inst(ex_mem_valid_inst),
    // .mem_wb_NPC(mem_wb_NPC),
    // .mem_wb_IR(mem_wb_IR),
    // .mem_wb_valid_inst(mem_wb_valid_inst)
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

  // assign pipeline_commit_NPC = 64'h10;
  // assign pipeline_commit_wr_idx = 5'h10;
  // assign pipeline_commit_wr_data = 64'h8;
  // assign pipeline_completed_insts = 4'h2;
  // assign pipeline_commit_wr_en = 1'b1;
  // Instantiate the Data Memory
  mem memory (
    // Inputs
    .clk               (clock),
    .proc2mem_command  (proc2mem_command),
    .proc2mem_addr     (proc2mem_addr),
    .proc2mem_data     (proc2mem_data),

    // Outputs

    .mem2proc_response (mem2proc_response),
    .mem2proc_data     (mem2proc_data),
    .mem2proc_tag      (mem2proc_tag)
  );
  always_comb begin
    for(integer i=0; i< `NUM_FU_TOTAL; i=i+1) begin
      issue_next_npc[i] = issue_next[i].npc;
      issue_next_inst_opcode[i] = issue_next[i].inst_opcode;
      issue_next_valid_inst[i] = issue_next[i].inst.valid_inst;
    end
  end

  // Generate System Clock
  always begin
    #(`VERILOG_CLOCK_PERIOD/2.0);
    clock = ~clock;
  end

  //Task to desplay input/output
  task show_input_output_port;
    begin
      $display("Inputs");
      $display("clock = %d reset: %d mem2proc_response = %d mem2proc_data: %d mem2proc_tag: %d", clock, reset, mem2proc_response, mem2proc_data, mem2proc_tag);
      $display("***********************************");
      $display("Oututs1");
      $display("proc2mem_command = %d proc2mem_addr: %d proc2mem_data = %d", proc2mem_command, proc2mem_addr, proc2mem_data);
      $display("***********************************");
      $display("Oututs2");
      $display("pipeline_completed_insts = %d pipeline_error_status: %d pipeline_commit_wr_data = %d pipeline_commit_wr_idx: %d pipeline_commit_wr_en: %d pipeline_commit_NPC: %d", pipeline_completed_insts, pipeline_error_status, pipeline_commit_wr_data, pipeline_commit_wr_idx, pipeline_commit_wr_en, pipeline_commit_NPC);
      $display("***********************************");
      $display("Oututs3");
      $display("if_NPC_out = %d if_IR_out: %d if_valid_inst_out = %d if_id_NPC: %d if_id_IR: %d if_id_valid_inst: %d id_di_NPC: %d id_di_IR: %d id_di_valid_inst: %d", if_NPC_out, if_IR_out, if_valid_inst_out, if_id_NPC, if_id_IR, if_id_valid_inst, id_di_NPC, id_di_IR, id_di_valid_inst);
      $display("***********************************");
     // $display("Oututs4");
     // $display("rs_table_out_npc = %d rs_table_out_inst_opcode: %d rs_table_out_inst_valid_inst = %d issue_reg_npc: %d issue_reg_inst_opcode: %d issue_reg_inst_valid_inst: %d ex_co_NPC: %d ex_co_IR: %d ex_co_valid_inst: %d co_ret_NPC: %d co_ret_IR: %d rs_table_out: %d arch_table: %d ROB_table_out: %d free_list_out: %d co_ret_valid_inst: %d", rs_table_out_npc, rs_table_out_inst_opcode, rs_table_out_inst_valid_inst, issue_reg_npc, issue_reg_inst_opcode, issue_reg_inst_valid_inst, ex_co_NPC, ex_co_IR, ex_co_valid_inst, co_ret_NPC, co_ret_IR, rs_table_out, arch_table, ROB_table_out, free_list_out, co_ret_valid_inst);
     // $display("***********************************");
    end
  endtask  // task show_clk_count 

  // Task to display # of elapsed clock edges
  task show_clk_count;
    real cpi;

    begin
      cpi = (clock_count + 1.0) / instr_count+1;
      $display("@@  %0d cycles / %0d instrs = %f CPI\n@@",
                clock_count+1, instr_count+1, cpi);
      $display("@@  %4.2f ns total time to execute\n@@\n",
                clock_count*`VIRTUAL_CLOCK_PERIOD);
    end
  endtask  // task show_clk_count 

  // Show contents of a range of Unified Memory, in both hex and decimal
  task show_mem_with_decimal;
    input [31:0] start_addr;
    input [31:0] end_addr;
    int showing_data;
    begin
      $display("@@@");
      showing_data=0;
      for(int k=start_addr;k<=end_addr; k=k+1)
        if (memory.unified_memory[k] != 0) begin
          $display("@@@ mem[%5d] = %x : %0d", k*8, memory.unified_memory[k], 
                                                    memory.unified_memory[k]);
          showing_data=1;
        end else if(showing_data!=0) begin
          $display("@@@");
        end
    end
  endtask  // task show_mem_with_decimal

  task display_RS_table;

		begin
				$display("**********************************************************\n");
				$display("------------------------RS TABLE----------------------------\n");

			$display("issue_reg");
			for (int i = 0; i < 5; ++i) begin
				$display("issue_reg[%d].inst.valid_inst: %b", i, pipeline_0.issue_reg[i].inst.valid_inst);
				$display("ex_co_enable[%d]: %b", i, pipeline_0.ex_co_enable[i]);
			end


			$display("issue_idx_valid_shift");
			for (int i = 0; i < `NUM_FU_TOTAL; ++i) begin
				$display("issue_idx_valid_shifted[%d] = %b", i, pipeline_0.RS0.issue_idx_valid_shifted[i]);
			end 
			$display("issue_idx_valid");
			for (int i = 0; i < `NUM_FU_TOTAL; ++i) begin
				$display("issue_idx_valid[%d]: %b", i, pipeline_0.RS0.issue_idx_valid[i]);
			end

			for(integer i=0;i<`RS_SIZE;i=i+1) begin
				$display("RS_Row = %d,  busy = %d, Function = %d, T = %7.0b T1 = %7.0b, T2 = %7.0b ", i, rs_table_out[i].busy, rs_table_out[i].inst.fu_name,rs_table_out[i].T, rs_table_out[i].T1, rs_table_out[i].T2);
			end
			$display("*******************************************************************\n");

		end
	endtask

  task display_arch_table;
		begin
			$display("-----------Archtecture Map Table-----------");
			for(integer k=0;k<`NUM_GEN_REG;k=k+1) begin
				$display("Reg:%d, Phys Reg : %d", k, arch_table[k][5:0]); 
			end
			$display("------------------------------------------\n");	
		end
	endtask
  task display_map_table;
		begin
			$display("-----------Map Table-----------");
			for(integer k=0;k<`NUM_GEN_REG;k=k+1) begin
				$display("Reg:%d, pluas: %b, Phys Reg : %d", k, pipeline_0.map_table_out[k][6],pipeline_0.map_table_out[k][5:0]); 
			end
			$display("------------------------------------------\n");	
		end
	endtask


  task display_ROB_table;
		begin
		//	@(posedge clock);
		//	#2;
				$display("**********************************************************\n");
				$display("------------------------ROB TABLE----------------------------\n");

			$display("INPUTS");
			$display("T_old_in: %d T_new_in: %d CDB_tag_in: %d CAM_en: %b dispatch_en: %b branch_not_taken: %b", pipeline_0.T_old, pipeline_0.fr_rs_rob_T, pipeline_0.CDB_tag_out, pipeline_0.CDB_enable, pipeline_0.dispatch_en, pipeline_0.branch_not_taken);
			$display("OUTPUTS");
			$display("rob_retire.T_old: %d rob_retire.T_new: %d rob_retire.busy: %b rob_free_rows_next: %d rob_full: %b tail: %d head: %d", pipeline_0.rob_retire_out.T_old, pipeline_0.rob_retire_out.T_new, pipeline_0.rob_retire_out.busy, pipeline_0.rob_free_rows_next_out, pipeline_0.rob_full_out, pipeline_0.rob_tail_out, pipeline_0.rob_head_out);
			for(integer i=0;i<`ROB_SIZE;i=i+1) begin
				$display("ROB_Row = %d,  busy = %d, halt = %d, T_new = %7.0b T_old = %7.0b ", i, pipeline_0.ROB_table_out[i].busy, pipeline_0.ROB_table_out[i].halt,  pipeline_0.ROB_table_out[i].T_new, pipeline_0.ROB_table_out[i].T_old);
			end
				//$display("T free = %7.0b T arch = %7.0b tail= %d head= %d T_out_valid = %b ROB full = %b, ROB free entries = %d",T_free, T_arch, tail_reg, head_reg, T_out_valid, rob_full, rob_free_entries);
			$display("*******************************************************************\n");

		end
	endtask

 /* task display_free_list_table;
		input	PHYS_REG [`NUM_PHYS_REG-1:0] list;
		begin
    $display("**********************************************************\n");
				$display("------------------------Freelist TABLE----------------------------\n");
			for (integer i = 0; i < `NUM_PHYS_REG; ++i) begin
				$display("i = %d tag: %d", i, list[i]);
        $display("*******************************************************************\n");
			end	
		end
	endtask
*/


 	task display_free_list_table;
		begin
			$display("\n----------------------------Freelist Table----------------------------\n");
			$display("Free_list_size : %d, Free_list_tail : %d",`FL_SIZE, pipeline_0.fr_tail_out);
			for (integer i = 0; i<`FL_SIZE; ++i) begin
				$display("%dth line : %d", i, pipeline_0.fr_rs_rob_T[i]);
			end
		end
	endtask
	task display_inst;
		input DECODED_INST _inst_in;
		begin
			$display("\t\topa_select: %d opb_select: %d dest_reg_sel: %d alu_func: %d fu_name: %d", _inst_in.opa_select, _inst_in.opb_select, _inst_in.dest_reg, _inst_in.alu_func, _inst_in.fu_name);
			$display("\t\trd_mem: %b wr_mem: %b ldl_mem: %b stc_mem: %b cond_branch: %b uncond_branch: %b halt: %b cpuid: %d illegal: %b valid_inst: %b", _inst_in.rd_mem, _inst_in.wr_mem, _inst_in.ldl_mem, _inst_in.stc_mem, _inst_in.cond_branch, _inst_in.uncond_branch, _inst_in.halt, _inst_in.cpuid, _inst_in.illegal, _inst_in.valid_inst);
		end 
	endtask

	task display_memory;
		begin
			$display("\nmain memory---------------------------------------------------------------");
			$display("mem input : proc2mem_command:%h, proc2mem_addr:%h, proc2mem_data:%h", proc2mem_command, proc2mem_addr, proc2mem_data);
			$display("mem_output : mem2proc_response:%h, mem2proc_data:%h, mem2proc_tag:%h", mem2proc_response, mem2proc_data, mem2proc_tag);
			$display("Memory array for first 20 rows");
			for(int p=0;p<20;p++) begin
				$display(" row %d : %h",p, memory.unified_memory[p][63:0]);
			end
		end
	endtask

	task display_phys_reg;
		begin
			$display("\n Physical register files-------------------------------------");
      for(int p = 0; p < `NUM_FU_TOTAL; p += 1) begin
			 $display("FU: %d rda_idx %b, rda_out: %d, rdb_idx: %b, rdb_out: %d, wr_en: %b, wr_idx: %b, wr_data: %d", p, pipeline_0.issue_reg_tags[p][0], pipeline_0.pr_tags_values[p][0], pipeline_0.issue_reg_tags[p][1], pipeline_0.pr_tags_values[p][0], pipeline_0.ex_co_valid_inst[p], pipeline_0.ex_co_dest_reg_idx[p], pipeline_0.ex_co_alu_result[p]);
			end
      for(int p=0;p<64;p++) begin
				$display("%dth phys reg value : %h", p, pipeline_0.phys_reg[p]);
				
			end	
		end
	endtask

	task display_cache;
		begin
			$display("\nCache memory---------------------------------------------------------------------");
			$display("inputs");
			$display("wr1_en: %b wr1_idx: %h wr1_tag: %h wr1_data %h rd1_idx: %h rd1_tag: %h", pipeline_0.Icache_wr_en, pipeline_0.Icache_wr_idx, pipeline_0.Icache_wr_tag, pipeline_0.mem2proc_data, pipeline_0.Icache_rd_idx, pipeline_0.Icache_rd_tag);
			$display("outputs");
			$display("rd1_data: %d rd1_valid: %b", pipeline_0.cachemem_data, pipeline_0.cachemem_valid);
			$display("----------------------------------Cache Memory------------------------------------");
			for (int p = 0; p < 32; ++p) begin
				$display("data[%d] = %h tags[%d] = %h valids[%d] = %b", p, pipeline_0.cachememory.data[p], p, pipeline_0.cachememory.tags[p], p, pipeline_0.cachememory.valids[p]);
			end
			$display("----------------------------------------------------------------------------------");
		end
	endtask

	task display_icache;
		begin
			$display("\nicache--------------------------------------------------------------------------");
			$display("inputs:");
			$display("Imem2proc_response: %h, Imem2_proc_data: %h, Imem2proc_tag: %h, proc2Icache_addr: %h, cachemem_data: %h, cachemem_valid: %b", pipeline_0.Imem2proc_response, pipeline_0.mem2proc_data, pipeline_0.mem2proc_tag, pipeline_0.proc2Icache_addr, pipeline_0.cachemem_data, pipeline_0.cachemem_valid);
			$display("outputs:");
			$display("proc2Imem_command: %d proc2Imem_addr: %h Icache_data_out: %h Icache_valid_out: %d current_index: %d current_tag: %d last_index: %d last_tag: %d data_write_enable: %b", pipeline_0.proc2Imem_command, pipeline_0.proc2Imem_addr, pipeline_0.Icache_data_out, pipeline_0.Icache_valid_out, pipeline_0.Icache_rd_idx, pipeline_0.Icache_rd_tag, pipeline_0.Icache_wr_idx, pipeline_0.Icache_wr_tag, pipeline_0.Icache_wr_en);
		end
	endtask

	task display_if_stage;
		begin
			$display("\nif_stage---------------------------------------------------------------------");
			$display("inputs");
			$display("co_ret_valid_inst: %b co_ret_take_branch: %b co_ret_target_pc: %d Imem2proc_data: %h Imem_valid: %b dispatch_en: %b co_ret_branch_valid: %b", pipeline_0.co_ret_valid_inst, pipeline_0.co_ret_take_branch, pipeline_0.co_ret_result, pipeline_0.Icache_data_out, pipeline_0.Icache_valid_out, pipeline_0.dispatch_en, pipeline_0.co_ret_branch_valid);
			$display("outputs");
			$display("if_NPC_out: %d, if_IR_out: %h proc2Imem_addr: %h if_valid_inst_out: %d", pipeline_0.if_NPC_out, pipeline_0.if_IR_out, pipeline_0.proc2Icache_addr, pipeline_0.if_valid_inst_out);
		end
	endtask

	task display_if_id;
		begin
			$display("\nif_id pipeline registers---------------------------------------------------");
			$display("if_id_enable: %b if_id_NPC: %d if_id_IR: %h if_id_valid_inst: %b", pipeline_0.dispatch_en, pipeline_0.if_id_NPC, pipeline_0.if_id_IR, pipeline_0.if_id_valid_inst);
		end
	endtask

	task display_id_stage;
		begin
  	$display("\n id pipeline registers---------------------------------------------------");
      
			// $display("if_id_enable: %b if_id_NPC: %d if_id_IR: %h if_id_valid_inst: %b", pipeline_0.dispatch_en, pipeline_0.if_NPC_out, pipeline_0.if_IR_out, pipeline_0.if_valid_inst_out);
      $display("if_id_IR: %h if_id_valid_inst: %b", pipeline_0.if_id_IR, pipeline_0.if_id_valid_inst);
      $display("id_opa_select_out: %d id_opb_select_out: %d", pipeline_0.id_inst_out.inst.opa_select, pipeline_0.id_inst_out.inst.opb_select);
      $display("id_alu_func_out: %d id_fu_name_out: %d", pipeline_0.id_inst_out.inst.alu_func, pipeline_0.id_inst_out.inst.fu_name);
      $display("id_rd_mem_out: %d id_wr_mem_out: %d id_ldl_mem_out: %d id_stc_mem_out: %d", pipeline_0.id_inst_out.inst.rd_mem, pipeline_0.id_inst_out.inst.wr_mem, pipeline_0.id_inst_out.inst.ldl_mem, pipeline_0.id_inst_out.inst.stc_mem);
      $display("id_cond_branch_out: %b id_uncond_branch_out: %b id_halt_out: %b id_cpuid_out: %d id_illegal_out: %b", pipeline_0.id_inst_out.inst.cond_branch, pipeline_0.id_inst_out.inst.uncond_branch, pipeline_0.id_inst_out.inst.halt, pipeline_0.id_inst_out.inst.cpuid, pipeline_0.id_inst_out.inst.illegal);
      $display("id_valid_inst_out: %b", pipeline_0.id_inst_out.inst.valid_inst);
      $display("ra_idx: %d rb_idx: %d rdest_idx: %d", pipeline_0.id_ra_idx, pipeline_0.id_rb_idx, pipeline_0.id_rdest_idx);
      
   		end
	endtask

	task display_id_di;
		begin
			$display("\n id_di pipeline registers---------------------------------------------");
			$display("id_di_enable: %b, dispatch_no_hazard: %b, if_valid_inst_out : %b", pipeline_0.id_di_enable, pipeline_0.dispatch_no_hazard, pipeline_0.if_valid_inst_out);
			$display("id_di_rega: %d, id_di_regb: %d, id_di_inst_in: %h", pipeline_0.id_di_rega, pipeline_0.id_di_regb, pipeline_0.id_di_inst_in); 			
			$display("id_di_NPC: %d, id_di_IR: %h, id_di_valid_inst: %b",pipeline_0.id_di_NPC, pipeline_0.id_di_IR, pipeline_0.id_di_valid_inst );

		end
	endtask


	task display_di_issue;
		begin
			$display("\n di_issue stage---------------------------------------------------------");
			$display("issue_stall: %b dispatch_en: %b branch_not_taken: %b RS_enable: %b", pipeline_0.issue_stall, pipeline_0.dispatch_en, pipeline_0.branch_not_taken, pipeline_0.RS_enable);
			$display("\n RESERVATION STATION INPUT WIRES---------------------------------------");
			//$display("enable: %b CAM_en: %b CAM_in: %d dispatch_valid: %b branch_not_taken: %b issue_stall: %b", pipeline_0.RS_enable, pipeline_0.CDB_enable, pipeline_0.CDB_in, pipeline_0.dispatch_en, pipeline_0.branch_not_taken, pipeline_0.issue_stall);
			$display("\n INST GOING INTO RS");
			display_inst(pipeline_0.id_di_inst_in);
		end
	endtask

	task display_issue_ex;
		begin
			$display("\n issue execute pipeline registers-----------------------------------------");
			$display("issue_reg:");
			for (int i = 0; i < `NUM_FU_TOTAL; ++i) begin
				$display("\t\tissue_reg[%d] T = %d T1 = %d T2 = %d busy: %b inst_opcode: %h npc: %d", i, pipeline_0.issue_reg[i].T, pipeline_0.issue_reg[i].T1, pipeline_0.issue_reg[i].T2, pipeline_0.issue_reg[i].busy, pipeline_0.issue_reg[i].inst_opcode, pipeline_0.issue_reg[i].npc);
			end
			$display("issue_reg WIRES (those that are assigned");
			for (int i = 0; i < `NUM_FU_TOTAL; ++i) begin
				//$display("\t\ti = %d issue_reg_T1 = %d issue_reg_T2 = %d issue_reg_inst_opcode = %h", i, pipeline_0.issue_reg_T1[i], pipeline_0.issue_reg_T2[i], pipeline_0.issue_reg_inst_opcode[i]);
			end
		end
	endtask

	task display_is_ex_registers;
		begin
			$display("\n issue execute pipeline registers-----------------------------------------");
			for (int i = 0; i < 5; ++i) begin
				$display("is_ex_enable[%d]: %b is_ex_T1_value[%d]: %d is_ex_T2_value[%d]: %d", i, pipeline_0.is_ex_enable[i], i, pipeline_0.is_ex_T1_value[i], i, pipeline_0.is_ex_T2_value[i]);
			end
		end
	endtask

	task display_ex;
		begin
			$display("\n execute state -------------------------------------------------------");
			for(int i = 0; i<5 ; ++i) begin
				$display(" %dth ALU output", i);
				$display("ex_alu_result_out : %d", pipeline_0.ex_alu_result_out[i]);
				$display("ex_take_branch_out :%b", pipeline_0.ex_take_branch_out[i]);
			end
		end
	endtask

	task display_ex_co_registers;
		begin
			$display("\n execute/complete state registers--------------------------------------");
			for (int i=0; i<5; ++i) begin
				$display("%dth registers", i);
				$display("ex_co_NPC: %d, ex_co_IR: %h, ex_co_dest_reg_idx: %d", pipeline_0.ex_co_NPC[i], pipeline_0.ex_co_IR[i], pipeline_0.ex_co_dest_reg_idx[i]);
				$display("ex_co_wr_mem: %d, ex_co_halt: %b, ex_co_illegal: %b, ex_co_valid_inst: %b", pipeline_0.ex_co_wr_mem[i], pipeline_0.ex_co_halt[i], pipeline_0.ex_co_illegal[i], pipeline_0.ex_co_valid_inst[i]);
				$display("ex_co_alu_result: %d", pipeline_0.ex_co_alu_result[i]); 

			end
			
			$display("Done and branch signals, ex_co_done: %d, ex_co_taken_branch: %b", pipeline_0.ex_co_done, pipeline_0.ex_co_take_branch);	
		end
	endtask

	task display_complete;
		begin
			$display("\n complete state--------------------------------------------------");
			$display("psel_enable: %b, co_branch_prediction: %b, CDB_enable: %b", pipeline_0.psel_enable, pipeline_0.co_branch_prediction, pipeline_0.CDB_enable);
			$display("CDB output: CDB_tag_out: %d, CDB_en_out: %b, CDB_busy: %b", pipeline_0.CDB_tag_out, pipeline_0.CDB_en_out, pipeline_0.busy);

		end
	endtask

	task display_co_re_registers;
		begin
			$display("\n Complete/Retire pipeline registers----------------------------------------");
			$display("co_ret_NPC: %h, co_ret_IR: %h, co_ret_halt: %b, co_ret_valid_inst: %b", pipeline_0.co_ret_NPC, pipeline_0.co_ret_IR, pipeline_0.co_ret_halt, pipeline_0.co_ret_valid_inst);
		end
	endtask

	task display_stages;
		begin
			 if (clock_count == 10000) begin
				$finish;
			 end
			$display("\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
			$display("------------------------------------------------------------------------------Cycle: %d-----------------------------------------------------------------------", clock_count);
			$display("Pipeline Assigns");
			//$display("proc2mem_command: %d proc2mem_addr %d Dmem2proc_response: %d Imem2proc_response: %d", pipeline_0.proc2mem_command, pipeline_0.proc2mem_addr, pipeline_0.Dmem2proc_response, pipeline_0.Imem2proc_response);
			//display_memory;
			//display_cache;
			//display_icache;
			//display_if_stage;
			// display_if_id;
			//display_id_stage;
			//$display("LOOK HERE!!!!!!!!!!!!!!!!!!!!");
			//$display("free_rows_next: %d fr_empty: %b rob_full: %b id_di_enable: %b ", pipeline_0.free_rows_next, pipeline_0.fr_empty, pipeline_0.rob_full, pipeline_0.id_di_enable);
		//display_id_di;
			
			//display_di_issue;
			//display_RS_table;
		display_ROB_table;
		//	display_map_table;
		//	$display("free_reg_dispatched : %d, free_list_tail", pipeline_0.fr_free_reg_T, pipeline_0.fr_tail_out);
		//	$display("rega : %d, regb : %d, destreg: %d", pipeline_0.id_ra_idx, pipeline_0.id_rb_idx, pipeline_0.id_rdest_idx);
		//	$display("map_table Told : %d, Told_busy: %b, map_table_T1: %d,T1_busy: %b,  map_table_T2: %d, T2_busy: %b", pipeline_0.T_old[5:0], pipeline_0.T_old[6], pipeline_0.id_inst_out.T1[5:0], pipeline_0.id_inst_out.T1[6],  pipeline_0.id_inst_out.T2[5:0], pipeline_0.id_inst_out.T2[6]);
		
		//	display_issue_ex;
		//	display_is_ex_registers;
		//	display_ex;
		//	display_ex_co_registers;
		//	display_complete;
		//	$display("CDB input : tag in : %d, cdb_ex_valid : %d", pipeline_0.co_reg_wr_idx_out, pipeline_0.co_valid_inst_selected); 
			//$display("CDB output : CDB_tag_out : %d, CDB_en_out : %d, busy : %d", pipeline_0.CDB_tag_out, pipeline_0.CDB_en_out, pipeline_0.busy);
		//	display_co_re_registers;
			//display_arch_table;
			//display_free_list_table;
			//display_phys_reg;	
		//	$display("ROB output to arch map - busy: %b, T_old : %b, T_new : %b", pipeline_0.rob_retire_out.busy, pipeline_0.rob_retire_out.T_old, pipeline_0.rob_retire_out.T_new);				
			//display_ROB_table;
			//$display("dispatch_en : %b, dispatch_no_hazard : %b ",pipeline_0.dispatch_en, pipeline_0.dispatch_no_hazard);
			//$display("enalbe : %b, CAM_en: %b, head: %d, tail: %d", pipeline_0.enable, pipeline_0.CDB_enable, pipeline_0.head_reg, pipeline_0.tail_reg);
			// display_id_di;
			// display_RS;
			
			//$display("halt : %b", pipeline_0.head_halt);
			$display("\n");

		end
	endtask

  initial begin
  
    clock = 1'b0;
    reset = 1'b0;

    // Pulse the reset signal
    $display("@@\n@@\n@@  %t  Asserting System reset......", $realtime);
    @(negedge clock);		// HW added
	reset = 1'b1;
    @(posedge clock);
    @(posedge clock);
	$display("@@@@@@memory1");
    $readmemh("../../program.mem", memory.unified_memory);

	$display("@@@@@@memory2");
    @(posedge clock);
    @(posedge clock);
    `SD;
    // This reset is at an odd time to avoid the pos & neg clock edges

    reset = 1'b0;
    $display("@@  %t  Deasserting System reset......\n@@\n@@", $realtime);

    wb_fileno = $fopen("../../writeback.out");
	$display("@@@Start");

//----Check issue_reg

	for(int p=0; p<5; p++) begin

	$display("issue_reg.inst.halt[p] = %b", pipeline_0.issue_reg[p].inst.halt);
 
	end

    //Open header AFTER throwing the reset otherwise the reset state is displayed
    print_header("                                                                                                        D-MEM Bus &\n");
    print_header("Cycle:      IF      |     ID      |     DI      |     IS      |     EX      |     CMP     |     RE      Reg Result");
  end


  // Count the number of posedges and number of instructions completed
  // till simulation ends
  always @(posedge clock) begin
    if(reset) begin
      clock_count <= `SD 0;
      instr_count <= `SD 0;
    end else begin
      clock_count <= `SD (clock_count + 1);
      instr_count <= `SD (instr_count + pipeline_completed_insts);
    end
	`SD;
	 display_stages;
  end  

  
  always @(negedge clock) begin


/*	$display("co_ret_enable: %b co_halt_selected: %b", pipeline_0.co_ret_enable, pipeline_0.co_halt_selected);
	for(int p=0; p<5; p++) begin

	$display("issue_reg.inst.halt[p] = %b", pipeline_0.issue_reg[p].inst.halt);
 
	end
	$display("pc_reg = %d", pipeline_0.if_stage_0.PC_reg);
*/

    if(reset)
      $display("@@\n@@  %t : System STILL at reset, can't show anything\n@@",
               $realtime);
    else begin
      `SD;
      `SD;
       //print tables
     //display_RS_table();
     //display_arch_table();
     //display_ROB_table();
     //display_free_list_table(free_list_out);
     //show_input_output_port();
       pipe_counter= 0;
       // print the piepline stuff via c code to the pipeline.out
       for (integer i = 0; i < `NUM_FU_TOTAL; i=i+1) begin
        //if (issue_next[i].busy) begin
          if (pipe_counter==0) begin
            print_cycles(1);
            print_stage(" ", if_IR_out, if_NPC_out[31:0], {31'b0,if_valid_inst_out});
            print_stage("|", if_id_IR, if_id_NPC[31:0], {31'b0,if_id_valid_inst});
            print_stage("|", id_di_IR, id_di_NPC[31:0], {31'b0,id_di_valid_inst});
          end else begin
            print_cycles(0);
            print_stage(" ", if_IR_out, if_NPC_out[31:0], 0);
            print_stage("|", if_id_IR, if_id_NPC[31:0], 0);
            print_stage("|", id_di_IR, id_di_NPC[31:0], 0);
          end
          //for (integer i = 0; i < `RS_SIZE; i=i+1) begin
          print_stage("|", issue_next_inst_opcode[i], issue_next_npc[i][31:0], {31'b0,issue_next_valid_inst[i]});
          //end
          //for (integer i = 0; i < `NUM_FU_TOTAL; i=i+1) begin
         // if (`NUM_FU_TOTAL>pipe_counter)
            print_stage("|", issue_reg_inst_opcode[i], issue_reg_npc[i][31:0], {31'b0,issue_reg_inst_valid_inst[i]});
            print_stage("|", ex_co_IR[i], ex_co_NPC[i][31:0], {31'b0,ex_co_valid_inst[i]});
          //end
         // else
            //print_stage("|", issue_reg_inst_opcode[0], issue_reg_npc[0][31:0], {0});
          if (pipe_counter==0) begin
            
            print_stage("|", co_ret_IR, co_ret_NPC[31:0], {31'b0,co_ret_valid_inst});
          end else begin
            //print_stage("|", ex_co_IR, ex_co_NPC[31:0], {0});
            print_stage("|", co_ret_IR, co_ret_NPC[31:0], {0});
          end
          print_reg(pipeline_commit_wr_data[63:32], pipeline_commit_wr_data[31:0],
                    {27'b0,pipeline_commit_wr_idx}, {31'b0,pipeline_commit_wr_en});
          print_membus({30'b0,proc2mem_command}, {28'b0,mem2proc_response},
                        proc2mem_addr[63:32], proc2mem_addr[31:0],
                        proc2mem_data[63:32], proc2mem_data[31:0]);
          pipe_counter = pipe_counter+1;
        //end
      end
      copy_pipe_counter = pipe_counter;
      $display("@*@*@*@*@*@*@*@*@*@*@*@*@*@*@*@*@*@");
      $display("issue_next_inst_opcode=%t issue_next_npc=%d issue_next_valid_inst=%b",issue_next_inst_opcode,issue_next_npc, issue_next_valid_inst);
      $display("@@@@@@@@@@@@@@@@@@  pipe_counter=%t",pipe_counter);
      // if (`NUM_FU_TOTAL>copy_pipe_counter)begin
      //   for (integer i = copy_pipe_counter; i < `NUM_FU_TOTAL; i=i+1) begin        
      //     if (pipe_counter==0) begin
      //         print_cycles(1);
      //         print_stage(" ", if_IR_out, if_NPC_out[31:0], {31'b0,if_valid_inst_out});
      //         print_stage("|", if_id_IR, if_id_NPC[31:0], {31'b0,if_id_valid_inst});
      //         print_stage("|", id_di_IR, id_di_NPC[31:0], {31'b0,id_di_valid_inst});
      //     end else begin
      //         print_cycles(0);
      //         print_stage(" ", if_IR_out, if_NPC_out[31:0], 0);
      //         print_stage("|", if_id_IR, if_id_NPC[31:0], 0);
      //         print_stage("|", id_di_IR, id_di_NPC[31:0], 0);
      //       end
      //       print_stage("|", issue_next_inst_opcode[0], issue_next_npc[0][31:0], {0});
      //       print_stage("|", issue_reg_inst_opcode[i], issue_reg_npc[i][31:0], {31'b0,issue_reg_inst_valid_inst[i]});
      //       if (pipe_counter==0) begin
      //         print_stage("|", ex_co_IR, ex_co_NPC[31:0], {31'b0,ex_co_valid_inst});
      //         print_stage("|", co_ret_IR, co_ret_NPC[31:0], {31'b0,co_ret_valid_inst});
      //       end else begin
      //         print_stage("|", ex_co_IR, ex_co_NPC[31:0], {0});
      //         print_stage("|", co_ret_IR, co_ret_NPC[31:0], {0});
      //       end
      //       print_reg(pipeline_commit_wr_data[63:32], pipeline_commit_wr_data[31:0],
      //                 {27'b0,pipeline_commit_wr_idx}, {31'b0,pipeline_commit_wr_en});
      //       print_membus({30'b0,proc2mem_command}, {28'b0,mem2proc_response},
      //                     proc2mem_addr[63:32], proc2mem_addr[31:0],
      //                     proc2mem_data[63:32], proc2mem_data[31:0]);
      //     pipe_counter = pipe_counter+1;
      //     end
      //   end
       // print the writeback information to writeback.out
       if(pipeline_completed_insts>0) begin
         if(pipeline_commit_wr_en)
           $fdisplay(wb_fileno, "PC=%x, REG[%d]=%x",
                     pipeline_commit_NPC-4,
                     pipeline_commit_wr_idx,
                     pipeline_commit_wr_data//,
		    //pipeline_commit_phys_reg, 
		     );
        else
          $fdisplay(wb_fileno, "PC=%x, ---",pipeline_commit_NPC-4);
      end

      // deal with any halting conditions
      if(pipeline_error_status != NO_ERROR) begin
        $display("@@@ Unified Memory contents hex on left, decimal on right: ");
        show_mem_with_decimal(0,`MEM_64BIT_LINES - 1); 
          // 8Bytes per line, 16kB total

        $display("@@  %t : System halted\n@@", $realtime);

        case(pipeline_error_status)
          HALTED_ON_MEMORY_ERROR:  
              $display("@@@ System halted on memory error");
          HALTED_ON_HALT:          
              $display("@@@ System halted on HALT instruction");
          HALTED_ON_ILLEGAL:
              $display("@@@ System halted on illegal instruction");
          default: 
              $display("@@@ System halted on unknown error code %x",
                       pipeline_error_status);
        endcase
        $display("@@@\n@@");
        show_clk_count;
        print_close(); // close the pipe_print output file
        $fclose(wb_fileno);
	@(posedge clock);
	@(negedge clock);
	#1 $finish;
      end

    end  // if(reset)   
  end 

endmodule  // module testbench
