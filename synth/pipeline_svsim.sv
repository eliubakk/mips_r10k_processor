`ifndef SYNTHESIS

//
// This is an automatically generated file from 
// dc_shell Version O-2018.06 -- May 21, 2018
//

// For simulation only. Do not modify.

module pipeline_svsim (

    input         clock,                        input         reset,                        input [3:0]   mem2proc_response,            input [63:0]  mem2proc_data,                input [3:0]   mem2proc_tag,              
    output logic [1:0]  proc2mem_command,        output logic [63:0] proc2mem_addr,          output logic [63:0] proc2mem_data,      
    output logic [3:0]  pipeline_completed_insts,
    output ERROR_CODE   pipeline_error_status,
    output logic [4:0]  pipeline_commit_wr_idx,
    output logic [63:0] pipeline_commit_wr_data,
    output logic        pipeline_commit_wr_en,
    output logic [63:0] pipeline_commit_NPC,



            

        output logic [63:0] if_NPC_out,
    output logic [31:0] if_IR_out,
    output logic        if_valid_inst_out,

        output logic [63:0] if_id_NPC,
    output logic [31:0] if_id_IR,
    output logic        if_id_valid_inst,


        output logic [63:0] id_ex_NPC,
    output logic [31:0] id_ex_IR,
    output logic        id_ex_valid_inst,


        output logic [63:0] ex_mem_NPC,
    output logic [31:0] ex_mem_IR,
    output logic        ex_mem_valid_inst,


        output logic [63:0] mem_wb_NPC,
    output logic [31:0] mem_wb_IR,
    output logic        mem_wb_valid_inst

  );

    

  pipeline pipeline( {>>{ clock }}, {>>{ reset }}, {>>{ mem2proc_response }}, 
        {>>{ mem2proc_data }}, {>>{ mem2proc_tag }}, {>>{ proc2mem_command }}, 
        {>>{ proc2mem_addr }}, {>>{ proc2mem_data }}, 
        {>>{ pipeline_completed_insts }}, {>>{ pipeline_error_status }}, 
        {>>{ pipeline_commit_wr_idx }}, {>>{ pipeline_commit_wr_data }}, 
        {>>{ pipeline_commit_wr_en }}, {>>{ pipeline_commit_NPC }}, 
        {>>{ if_NPC_out }}, {>>{ if_IR_out }}, {>>{ if_valid_inst_out }}, 
        {>>{ if_id_NPC }}, {>>{ if_id_IR }}, {>>{ if_id_valid_inst }}, 
        {>>{ id_ex_NPC }}, {>>{ id_ex_IR }}, {>>{ id_ex_valid_inst }}, 
        {>>{ ex_mem_NPC }}, {>>{ ex_mem_IR }}, {>>{ ex_mem_valid_inst }}, 
        {>>{ mem_wb_NPC }}, {>>{ mem_wb_IR }}, {>>{ mem_wb_valid_inst }} );
endmodule
`endif
