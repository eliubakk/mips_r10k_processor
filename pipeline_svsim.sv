`ifndef SYNTHESIS

//
// This is an automatically generated file from 
// dc_shell Version O-2018.06 -- May 21, 2018
//

// For simulation only. Do not modify.

module pipeline_svsim (
            input         clock,                        input         reset,                        input	        enable,
    input [3:0]   mem2proc_response,            input [63:0]  mem2proc_data,                input [3:0]   mem2proc_tag,              
    output logic [1:0]  proc2mem_command,        output logic [63:0] proc2mem_addr,          output logic [63:0] proc2mem_data,      
   
    output logic [1:0]	proc2Rmem_command_out,	    output logic [1:0]	proc2Dmem_command_out,	    output logic [1:0]	proc2Imem_command_out,	    output logic	send_request_out,
    output logic	unanswered_miss_out,

    output logic [3:0]  pipeline_completed_insts,
    output ERROR_CODE   pipeline_error_status,
    output logic [4:0]  pipeline_commit_wr_idx,
    output logic [63:0] pipeline_commit_wr_data,
    output logic        pipeline_commit_wr_en,
    output logic [63:0] pipeline_commit_NPC,
    output logic [5:0]  pipeline_commit_phys_reg,
    output logic [5:0]  pipeline_commit_phys_from_arch,


    output logic	pipeline_branch_en,
    output logic	pipeline_branch_pred_correct,
    

    output logic	       retire_inst_busy,
    output logic [63:0] retire_reg_NPC,

            
        output logic [63:0] if_NPC_out,
    output logic [31:0] if_IR_out,
    output logic        if_valid_inst_out,

        output logic [63:0] if_id_NPC,
    output logic [31:0] if_id_IR,
    output logic        if_id_valid_inst,

        output logic [63:0] id_di_NPC,
    output logic [31:0] id_di_IR,
    output logic        id_di_valid_inst,

        output logic [16-1:0][63:0] rs_table_out_npc,
    output logic [16-1:0][31:0] rs_table_out_inst_opcode,
    output logic [16-1:0]       rs_table_out_inst_valid_inst,

        output logic [6-1:0][63:0] issue_reg_npc,
    output logic [6-1:0][31:0] issue_reg_inst_opcode,
    output logic [6-1:0]       issue_reg_inst_valid_inst,
    output RS_ROW_T [6-1:0]			issue_next,
                
                
	output CACHE_SET_T [((32/4) - 1):0] dcache_data,
  output VIC_CACHE_T [(4-1):0] vic_queue_out,
	output RETIRE_BUF_T [(20 - 1):0] retire_queue,
	output logic [$clog2(20):0] retire_queue_tail,


          output logic mem_co_valid_inst,   
      output logic [63:0] mem_co_NPC ,        
      output logic [31:0] mem_co_IR ,         
 
        output logic [6-1:0][63:0] ex_co_NPC,
    output logic [6-1:0][31:0] ex_co_IR,
    output logic [6-1:0]       ex_co_valid_inst,

        output logic [63:0] co_ret_NPC,
    output logic [31:0] co_ret_IR,
    output logic        co_ret_valid_inst,

        output RS_ROW_T   [(16-1):0]    rs_table_out,
    output PHYS_REG   [32-1:0]  arch_table, 
    output ROB_ROW_T  [16-1:0]	    ROB_table_out,
    output MAP_ROW_T  [32-1:0]	map_table_out,
    output PHYS_REG   [16 + 32-1:0]      free_list_out,

    output logic if_id_enable,
    output logic RS_enable,
    output logic is_pr_enable,
    output logic CDB_enable, 
    output logic ROB_enable, 
    output logic mem_co_enable,
    
    output logic co_ret_enable, 
    output logic dispatch_en, 
    output logic branch_not_taken,
    output logic [6-1:0]   is_ex_enable,
    output logic [6-1:0]   ex_co_enable
);
  

  pipeline pipeline( {>>{ clock }}, {>>{ reset }}, {>>{ enable }}, 
        {>>{ mem2proc_response }}, {>>{ mem2proc_data }}, {>>{ mem2proc_tag }}, 
        {>>{ proc2mem_command }}, {>>{ proc2mem_addr }}, {>>{ proc2mem_data }}, 
        {>>{ proc2Rmem_command_out }}, {>>{ proc2Dmem_command_out }}, 
        {>>{ proc2Imem_command_out }}, {>>{ send_request_out }}, 
        {>>{ unanswered_miss_out }}, {>>{ pipeline_completed_insts }}, 
        {>>{ pipeline_error_status }}, {>>{ pipeline_commit_wr_idx }}, 
        {>>{ pipeline_commit_wr_data }}, {>>{ pipeline_commit_wr_en }}, 
        {>>{ pipeline_commit_NPC }}, {>>{ pipeline_commit_phys_reg }}, 
        {>>{ pipeline_commit_phys_from_arch }}, {>>{ pipeline_branch_en }}, 
        {>>{ pipeline_branch_pred_correct }}, {>>{ retire_inst_busy }}, 
        {>>{ retire_reg_NPC }}, {>>{ if_NPC_out }}, {>>{ if_IR_out }}, 
        {>>{ if_valid_inst_out }}, {>>{ if_id_NPC }}, {>>{ if_id_IR }}, 
        {>>{ if_id_valid_inst }}, {>>{ id_di_NPC }}, {>>{ id_di_IR }}, 
        {>>{ id_di_valid_inst }}, {>>{ rs_table_out_npc }}, 
        {>>{ rs_table_out_inst_opcode }}, {>>{ rs_table_out_inst_valid_inst }}, 
        {>>{ issue_reg_npc }}, {>>{ issue_reg_inst_opcode }}, 
        {>>{ issue_reg_inst_valid_inst }}, {>>{ issue_next }}, 
        {>>{ dcache_data }}, {>>{ vic_queue_out }}, {>>{ retire_queue }}, 
        {>>{ retire_queue_tail }}, {>>{ mem_co_valid_inst }}, 
        {>>{ mem_co_NPC }}, {>>{ mem_co_IR }}, {>>{ ex_co_NPC }}, 
        {>>{ ex_co_IR }}, {>>{ ex_co_valid_inst }}, {>>{ co_ret_NPC }}, 
        {>>{ co_ret_IR }}, {>>{ co_ret_valid_inst }}, {>>{ rs_table_out }}, 
        {>>{ arch_table }}, {>>{ ROB_table_out }}, {>>{ map_table_out }}, 
        {>>{ free_list_out }}, {>>{ if_id_enable }}, {>>{ RS_enable }}, 
        {>>{ is_pr_enable }}, {>>{ CDB_enable }}, {>>{ ROB_enable }}, 
        {>>{ mem_co_enable }}, {>>{ co_ret_enable }}, {>>{ dispatch_en }}, 
        {>>{ branch_not_taken }}, {>>{ is_ex_enable }}, {>>{ ex_co_enable }}
 );
endmodule
`endif
