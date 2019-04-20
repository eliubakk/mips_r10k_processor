/////////////////////////////////////////////////////////////////////////
//                                                                     //
//                                                                     //
//   Modulename :  testbench.v                                         //
//                                                                     //
//  Description :  Testbench module for the verisimple pipeline;       //
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

// `ifdef PIPELINE
// `include "sys_defs.vh"
// `else
// `include "../../sys_defs.vh"
// `endif
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


//`define NUM_WAYS 4
`include "../../cache_defs.vh"

// typedef struct packed {
//	logic [63:0] data;
//	logic [(`NUM_TAG_BITS - 1):0] tag;
//	logic valid;
//	logic dirty;
//} CACHE_LINE_T;

//  typedef struct packed {
//    CACHE_LINE_T [(NUM_DCACHE_WAYS-1):0] cache_lines;
//  } CACHE_SET_T;

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
  logic mem_co_valid_inst;   
  logic [63:0] mem_co_NPC ;        
  logic [31:0] mem_co_IR ;
	CACHE_SET_T [(`NUM_SETS - 1):0] dcache_data; 
 
  int pipe_counter; 
  int copy_pipe_counter;
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

  task show_br_pred_accuracy;
     real br_accuracy;
	begin
		br_accuracy = 100.0*(branch_pred_count)/(branch_inst_count);
		$display("\n-------------Branch prediction accuracy : %0d correct / %0d branch instrs = %.4f percent",branch_pred_count,branch_inst_count, br_accuracy);
	end
  endtask 

	logic [`NUM_SET_BITS - 1:0] set_idx;
  // Show contents of a range of Unified Memory, in both hex and decimal
  task show_mem_with_decimal;
    input [31:0] start_addr;
    input [31:0] end_addr;
    int showing_data;
    begin

	for (int i = 0; i < `NUM_SETS; ++i) begin
		for (int j = 0; j < `NUM_WAYS; ++j) begin
			set_idx = i;
			//$display("set = %d way = %d valid = %b dirty = %b", i, j, dcache_data[i].cache_lines[j].valid, dcache_data[i].cache_lines[j].dirty);
			//$display("tag = %d data = %d", dcache_data[i].cache_lines[j].tag, dcache_data[i].cache_lines[j].data);
			if (dcache_data[i].cache_lines[j].valid /*&& dcache_data[i].cache_lines[j].dirty*/) begin
				//$display("valid and dirty");
				memory.unified_memory[{dcache_data[i].cache_lines[j].tag, set_idx}] = dcache_data[i].cache_lines[j].data;
			end
		end
	end

      $display("@@@");
      showing_data=0;
      for(int k=start_addr;k<=end_addr; k=k+1)
        if (memory.unified_memory[k] != 0) begin
          $display("@@@ mem[%5d] = %x : %0d", k*8, memory.unified_memory[k], 
                                                    memory.unified_memory[k]);

          showing_data=1;
        end else if(showing_data!=0) begin
	  showing_data=0;
          $display("@@@");
        end
	$display("@@@");
    end
  endtask  // task show_mem_with_decimal
	task display_stages;
		begin
			 if (clock_count == 10000) begin
       show_mem_with_decimal(0,`MEM_64BIT_LINES - 1); 
				$finish;
			 end
			//$display("\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
			$display("------------------------------------------------------------------------------Cycle: %d-----------------------------------------------------------------------", clock_count);
			$display("Pipeline Assigns");
			//display_icache;
			//$display("proc2mem_command: %d proc2mem_addr %d Dmem2proc_response: %d Imem2proc_response: %d", pipeline_0.proc2mem_command, pipeline_0.proc2mem_addr, pipeline_0.Dmem2proc_response, pipeline_0.Imem2proc_response);
			//display_memory;
			//display_cache;
			//display_if_stage;
		//	 display_if_id;
			//display_id_stage;
			//$display("LOOK HERE!!!!!!!!!!!!!!!!!!!!");
			//$display("free_rows_next: %d fr_empty: %b rob_full: %b id_di_enable: %b ", pipeline_0.free_rows_next, pipeline_0.fr_empty, pipeline_0.rob_full, pipeline_0.id_di_enable);
	//	display_id_di;
	//	$display(" if_stage_dispatch_en : %b, if_valid_inst_out : %b,_ if_fetch_NPC_out : %h, if_IR_out : %h, if_PC_reg : %h", pipeline_0.if_stage_dispatch_en, pipeline_0.if_valid_inst_out, pipeline_0.if_fetch_NPC_out, pipeline_0.if_IR_out, pipeline_0.if_PC_reg);
		// display_IQ;	
		//	display_di_issue;
			//display_RS_table;
		//display_ROB_table; //  *********************************
		//	display_map_table;
		//	$display("free_reg_dispatched : %d, free_list_tail", pipeline_0.fr_free_reg_T, pipeline_0.fr_tail_out);
		//	$display("rega : %d, regb : %d, destreg: %d", pipeline_0.id_ra_idx, pipeline_0.id_rb_idx, pipeline_0.id_rdest_idx);
		//	$display("map_table Told : %d, Told_busy: %b, map_table_T1: %d,T1_busy: %b,  map_table_T2: %d, T2_busy: %b", pipeline_0.T_old[5:0], pipeline_0.T_old[6], pipeline_0.id_inst_out.T1[5:0], pipeline_0.id_inst_out.T1[6],  pipeline_0.id_inst_out.T2[5:0], pipeline_0.id_inst_out.T2[6]);
		
		//	display_issue_ex;
			// display_is_ex_registers;
		//	display_ex;
			// display_ex_co_registers;
		//	display_complete;
		//	$display("CDB input : tag in : %d, cdb_ex_valid : %d", pipeline_0.co_reg_wr_idx_out, pipeline_0.co_valid_inst_selected); 
			//$display("CDB output : CDB_tag_out : %d, CDB_en_out : %d, busy : %d", pipeline_0.CDB_tag_out, pipeline_0.CDB_en_out, pipeline_0.busy);
			//display_co_re_registers;
			//display_arch_table;
		//	display_free_list_table;// *****************************
		//	display_arch_table;  // *****************************
			//display_phys_reg;	
		//	$display("ROB output to arch map - busy: %b, T_old : %b, T_new : %b", pipeline_0.rob_retire_out.busy, pipeline_0.rob_retire_out.T_old, pipeline_0.rob_retire_out.T_new);				
			//display_ROB_table;
		//	$display("dispatch_en : %b, dispatch_no_hazard : %b ",pipeline_0.dispatch_en, pipeline_0.dispatch_no_hazard);
			//$display("enalbe : %b, CAM_en: %b, head: %d, tail: %d", pipeline_0.enable, pipeline_0.CDB_enable, pipeline_0.head_reg, pipeline_0.tail_reg);
			// display_id_di;
			
		//	$display("branch_not_taken : %d, pred_incorrect : %d", pipeline_0.branch_not_taken, !pipeline_0.ret_pred_correct);
			
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
	// $display("@@@@@@memory1");
`ifdef PIPELINE
    $readmemh("program.mem", memory.unified_memory);
`endif
`ifndef PIPELINE
    $readmemh("../../program.mem", memory.unified_memory);
`endif

	// $display("@@@@@@memory2");
    @(posedge clock);
    @(posedge clock);
    `SD;
    // This reset is at an odd time to avoid the pos & neg clock edges

    reset = 1'b0;
    $display("@@  %t  Deasserting System reset......\n@@\n@@", $realtime);

    wb_fileno = $fopen("writeback.out");
	// $display("@@@Start");

//----Check issue_reg

	/*
	for(int p=0; p<5; p++) begin

	$display("issue_reg.inst.halt[p] = %b", pipeline_0.issue_reg[p].inst.halt);
 
	end
	*/

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
	 // display_stages;
	 if (clock_count == 20000) begin
	   $finish;
	 end
  end 

  // Count the number of branch instructions and correctly predicted branches
  always @(posedge clock) begin
	if(reset) begin
		branch_inst_count <= `SD 0;
		branch_pred_count <= `SD 0;
	end else begin
		if(pipeline_branch_en) begin
			branch_inst_count <= `SD branch_inst_count +1;
		end
		if(pipeline_branch_en & pipeline_branch_pred_correct) begin
			branch_pred_count <= `SD branch_pred_count +1;
		end
	end
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
            
           // print_stage("|", co_ret_IR, co_ret_NPC[31:0], {31'b0,co_ret_valid_inst});
          
            print_stage("|", `NOOP_INST, retire_reg_NPC[31:0], {31'b0,retire_inst_busy});
	end else begin
            //print_stage("|", ex_co_IR, ex_co_NPC[31:0], {0});
           // print_stage("|", co_ret_IR, co_ret_NPC[31:0], {0});

            print_stage("|", `NOOP_INST, retire_reg_NPC[31:0], {0});
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
      // $display("@*@*@*@*@*@*@*@*@*@*@*@*@*@*@*@*@*@");
      // $display("issue_next_inst_opcode=%t issue_next_npc=%d issue_next_valid_inst=%b",issue_next_inst_opcode,issue_next_npc, issue_next_valid_inst);
      // $display("@@@@@@@@@@@@@@@@@@  pipe_counter=%t",pipe_counter);
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
//, PHYS_REG=%d, PHYS_REG_FROM_ARCH=%d, Cycle : %d
           $fdisplay(wb_fileno, "PC=%x, REG[%d]=%x",
                     pipeline_commit_NPC,
                     pipeline_commit_wr_idx,
                     pipeline_commit_wr_data/*,
		    pipeline_commit_phys_reg,
			pipeline_commit_phys_from_arch,
			clock_count*/
		     );
        else
          $fdisplay(wb_fileno, "PC=%x, ---",pipeline_commit_NPC);
      end

      // deal with any halting conditions
      if(pipeline_error_status != NO_ERROR) begin
        // for (int i = 0; i < 10; ++i) begin
        //   @(posedge clock);
        // end

	// write cache to main mem
	

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
	show_br_pred_accuracy;
        print_close(); // close the pipe_print output file
        $fclose(wb_fileno);
	@(posedge clock);
	@(negedge clock);
	#1 $finish;
      end

    end  // if(reset)   
  end 

endmodule  // module testbench
