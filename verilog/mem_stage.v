/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  mem_stage.v                                         //
//                                                                     //
//  Description :  memory access (MEM) stage of the pipeline;          //
//                 this stage accesses memory for stores and loads,    // 
//                 and selects the proper next PC value for branches   // 
//                 based on the branch condition computed in the       //
//                 previous stage.                                     // 
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////
`include "../../sys_defs.vh"

`define NUM_WAYS 4
`include "../../cache_defs.vh"

module mem_stage(
    input         clock,              // system clock
    input         reset,              // system reset
    input         rd_mem,      // read memory? (from decoder)
    input  [63:0] rd_addr,        // regA value from reg file (store data)
    input         wr_mem,      // write memory? (from decoder)
    input  [63:0] wr_addr,
    input  [63:0] wr_data,  // incoming ALU result from EX
    input  [63:0] Dmem2proc_data,
    input   [3:0] Dmem2proc_tag, Dmem2proc_response,
    input   [3:0] Rmem2proc_response,
    input         sq_data_not_found,   // store addresses in the store queue not calculated
    input         sq_data_valid,       //address not found for forwarding

    output [63:0] mem_result_out,      // outgoing instruction result (to MEM/WB)
    output        mem_rd_stall,
    output        mem_stall_out,
    output [63:0] mem_rd_miss_addr_out,
    output [63:0] mem_rd_miss_data_out,
    output logic  mem_rd_miss_valid_out,
    output [1:0] proc2Dmem_command,
    output [63:0] proc2Dmem_addr,      // Address sent to data-memory
    output [63:0] proc2Dmem_data,      // Data sent to data-memory
    output [1:0]  proc2Rmem_command,
    output [63:0] proc2Rmem_addr,      // Address sent to data-memory
    output [63:0] proc2Rmem_data,
	// signals used for flushing
	output CACHE_SET_T [(`NUM_SETS - 1):0] sets_out,
	output VIC_CACHE_T [2:0] evicted_out,
	output logic [2:0] evicted_valid_out,
	output RETIRE_BUF_T [(`RETIRE_SIZE - 1):0] retire_queue_out,
	output logic [$clog2(`RETIRE_SIZE):0] retire_queue_tail_out
  );

  logic [63:0] Dcache_data_out;
  logic Dcache_valid_out;

  logic ret_buf_full;
  VIC_CACHE_T [2:0] evicted;
  logic [2:0] evicted_valid;


  // // Determine the command that must be sent to mem
  // assign proc2Dmem_command =  (mem_waiting_tag != 0) ?  BUS_NONE :
  //                             ex_mem_wr_mem  ? BUS_STORE :
  //                             ex_mem_rd_mem & ~sq_data_not_found & ~sq_data_valid  ? BUS_LOAD :
  //                             BUS_NONE;

  // Assign the result-out for next stage
  assign mem_result_out = (rd_mem) ? Dcache_data_out :
                                     rd_addr;

  assign mem_rd_stall = (rd_mem && ~Dcache_valid_out);
  assign mem_stall_out = ret_buf_full;

 
	assign evicted_out = evicted;
	assign evicted_valid_out = evicted_valid;
 
  dcache dcache0(
    .clock(clock),
    .reset(reset),
    .rd_en(rd_mem & (~sq_data_valid & ~sq_data_not_found)),
    .proc2Dcache_rd_addr(rd_addr),
    .wr_en(wr_mem),
    .proc2Dcache_wr_addr(wr_addr),
    .proc2Dcache_wr_data(wr_data),
    .Dmem2proc_response(Dmem2proc_response),
    .Dmem2proc_data(Dmem2proc_data),
    .Dmem2proc_tag(Dmem2proc_tag),

	  .sets_out(sets_out),

    .Dcache_rd_data_out(Dcache_data_out),
    .Dcache_rd_valid_out(Dcache_valid_out),
    .Dcache_rd_miss_addr_out(mem_rd_miss_addr_out),
    .Dcache_rd_miss_data_out(mem_rd_miss_data_out),
    .Dcache_rd_miss_valid_out(mem_rd_miss_valid_out),
    .proc2Dmem_command(proc2Dmem_command),
    .proc2Dmem_addr(proc2Dmem_addr),
    .proc2Dmem_data(proc2Dmem_data),
    .evicted(evicted),
    .evicted_valid(evicted_valid)
  );

  retire_buffer #(
  .NUM_WAYS(`NUM_WAYS),
  .WR_PORTS(3))
  rb0(
    // inputs
    .clock(clock), 
    .reset(reset),
    .evicted(evicted), 
    .evicted_valid(evicted_valid),
    .Rmem2proc_response(Rmem2proc_response),

    // outputs
	.retire_queue_out(retire_queue_out),
	.retire_queue_tail_out(retire_queue_tail_out),
    .proc2Rmem_command(proc2Rmem_command), 
    .proc2Rmem_addr(proc2Rmem_addr), 
    .proc2Rmem_data(proc2Rmem_data),
    .full(ret_buf_full));

endmodule // module mem_stage

