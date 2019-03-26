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
extern void print_cycles();
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
  logic [4:0][63:0] ex_co_NPC;
  logic [4:0] ex_co_IR;
  logic [4:0]       ex_co_valid_inst;
  logic [63:0] co_ret_NPC;
  logic [31:0] co_ret_IR;
  logic        co_ret_valid_inst;

  RS_ROW_T	[(`RS_SIZE-1):0]		rs_table_out;
  PHYS_REG		[`NUM_GEN_REG-1:0]	arch_table;
  ROB_ROW_T [`ROB_SIZE:1]		ROB_table_out;
  PHYS_REG [`NUM_PHYS_REG-1:0] free_list_out;

  // Instantiate the Pipeline
  pipeline #(.FU_NAME_VAL({FU_ALU, FU_LD, FU_MULT, FU_BR}),
  .FU_BASE_IDX({FU_ALU_IDX, FU_LD_IDX, FU_MULT_IDX, FU_BR_IDX}),
  .NUM_OF_FU_TYPE({2'b10,2'b01,2'b01,2'b01})) pipeline_0(
    // Inputs
    .clock             (clock),
    .reset             (reset),
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
    .rs_table_out(rs_table_out),
    .arch_table(arch_table),
    .ROB_table_out(ROB_table_out),
    .free_list_out(free_list_out),
    .co_ret_valid_inst(co_ret_valid_inst)
  );


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
      $display("Oututs4");
      $display("rs_table_out_npc = %d rs_table_out_inst_opcode: %d rs_table_out_inst_valid_inst = %d issue_reg_npc: %d issue_reg_inst_opcode: %d issue_reg_inst_valid_inst: %d ex_co_NPC: %d ex_co_IR: %d ex_co_valid_inst: %d co_ret_NPC: %d co_ret_IR: %d rs_table_out: %d arch_table: %d ROB_table_out: %d free_list_out: %d co_ret_valid_inst: %d", rs_table_out_npc, rs_table_out_inst_opcode, rs_table_out_inst_valid_inst, issue_reg_npc, issue_reg_inst_opcode, issue_reg_inst_valid_inst, ex_co_NPC, ex_co_IR, ex_co_valid_inst, co_ret_NPC, co_ret_IR, rs_table_out, arch_table, ROB_table_out, free_list_out, co_ret_valid_inst);
      $display("***********************************");
    end
  endtask  // task show_clk_count 

  // Task to display # of elapsed clock edges
  task show_clk_count;
    real cpi;

    begin
      cpi = (clock_count + 1.0) / instr_count;
      $display("@@  %0d cycles / %0d instrs = %f CPI\n@@",
                clock_count+1, instr_count, cpi);
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
          showing_data=0;
        end
      $display("@@@");
    end
  endtask  // task show_mem_with_decimal

  task display_RS_table;

		begin
				$display("**********************************************************\n");
				$display("------------------------RS TABLE----------------------------\n");

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
				$display("Reg:%d, Phys Reg : %d", k, arch_table[k]); 
			end
			$display("------------------------------------------\n");	
		end
	endtask

  task display_ROB_table;
		begin
			@(posedge clock);
			#2;
				$display("**********************************************************\n");
				$display("------------------------ROB TABLE----------------------------\n");

			for(integer i=1;i<=`ROB_SIZE;i=i+1) begin
				$display("ROB_Row = %d,  busy = %d, T_new_out = %7.0b T_old_out = %7.0b ", i, ROB_table_out[i].busy, ROB_table_out[i].T_new_out, ROB_table_out[i].T_old_out);
			end
				$display("T free = %7.0b T arch = %7.0b tail= %d head= %d T_out_valid = %b ROB full = %b, ROB free entries = %d",T_free, T_arch, tail_reg, head_reg, T_out_valid, rob_full, rob_free_entries);
			$display("*******************************************************************\n");

		end
	endtask

  task display_free_list_table;
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

  initial begin
  
    clock = 1'b0;
    reset = 1'b0;

    // Pulse the reset signal
    $display("@@\n@@\n@@  %t  Asserting System reset......", $realtime);
    reset = 1'b1;
    @(posedge clock);
    @(posedge clock);

    $readmemh("program.mem", memory.unified_memory);

    @(posedge clock);
    @(posedge clock);
    `SD;
    // This reset is at an odd time to avoid the pos & neg clock edges

    reset = 1'b0;
    $display("@@  %t  Deasserting System reset......\n@@\n@@", $realtime);

    wb_fileno = $fopen("writeback.out");
    
    //Open header AFTER throwing the reset otherwise the reset state is displayed
    print_header("                                                                            D-MEM Bus &\n");
    print_header("Cycle:    IF    |    ID    |    DI    |    IS    |    EX    |    CMP    |    RE    Reg Result");
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
  end  


  always @(negedge clock) begin
    if(reset)
      $display("@@\n@@  %t : System STILL at reset, can't show anything\n@@",
               $realtime);
    else begin
      `SD;
      `SD;
       //print tables
       display_RS_table();
       display_arch_table();
       display_ROB_table();
       display_free_list_table(free_list_out);
       show_input_output_port();
       
       // print the piepline stuff via c code to the pipeline.out
       print_cycles();
       print_stage(" ", if_IR_out, if_NPC_out[31:0], {31'b0,if_valid_inst_out});
       print_stage("|", if_id_IR, if_id_NPC[31:0], {31'b0,if_id_valid_inst});
       print_stage("|", id_di_IR, id_di_NPC[31:0], {31'b0,id_di_valid_inst});
       for (integer i = 0; i < `RS_SIZE; i=i+1) begin
        print_stage("|", rs_table_out_inst_opcode[i], rs_table_out_npc[i][31:0], {31'b0,rs_table_out_inst_valid_inst[i]});
       end
       for (integer i = 0; i < `NUM_FU_TOTAL; i=i+1) begin
        print_stage("|", issue_reg_inst_opcode[i], issue_reg_npc[i][31:0], {31'b0,issue_reg_inst_valid_inst[i]});
       end
       print_stage("|", ex_co_IR, ex_co_NPC[31:0], {31'b0,ex_co_valid_inst});
       print_stage("|", co_ret_IR, co_ret_NPC[31:0], {31'b0,co_ret_valid_inst});
       print_reg(pipeline_commit_wr_data[63:32], pipeline_commit_wr_data[31:0],
                 {27'b0,pipeline_commit_wr_idx}, {31'b0,pipeline_commit_wr_en});
       print_membus({30'b0,proc2mem_command}, {28'b0,mem2proc_response},
                    proc2mem_addr[63:32], proc2mem_addr[31:0],
                    proc2mem_data[63:32], proc2mem_data[31:0]);


       // print the writeback information to writeback.out
       if(pipeline_completed_insts>0) begin
         if(pipeline_commit_wr_en)
           $fdisplay(wb_fileno, "PC=%x, REG[%d]=%x",
                     pipeline_commit_NPC-4,
                     pipeline_commit_wr_idx,
                     pipeline_commit_wr_data);
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
        #100 $finish;
      end

    end  // if(reset)   
  end 

endmodule  // module testbench
