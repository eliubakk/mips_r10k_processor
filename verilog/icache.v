`include "../../sys_defs.vh"
module icache(
    input   clock,
    input   reset,
    input   [3:0] Imem2proc_response,
    input  [63:0] Imem2proc_data,
    input   [3:0] Imem2proc_tag,

    input  [63:0] proc2Icache_addr,
    input  [63:0] cachemem_data,
    input   cachemem_valid,

    output logic  [1:0] proc2Imem_command,
    output logic [63:0] proc2Imem_addr,

    output logic [63:0] Icache_data_out, // value is memory[proc2Icache_addr]
    output logic  Icache_valid_out,      // when this is high

    output logic  [(`NUM_SET_BITS - 1):0] current_index,
    output logic  [(`NUM_TAG_BITS - 1):0] current_tag,
    output logic  [(`NUM_SET_BITS - 1):0] last_index,
    output logic  [(`NUM_TAG_BITS - 1):0] last_tag,
    output logic  data_write_enable
  
  );
  `define INST_BUFFER_LEN 4
  logic [`INST_BUFFER_LEN-1:0][63:0] addr_queue, addr_queue_next;
  logic [2:0] addr_queue_tail, addr_queue_tail_next; 
  logic [`INST_BUFFER_LEN-1:0][1:0] addr_cam_hits;
  logic [`INST_BUFFER_LEN-1:0] current_mem_tag;
  logic [63:0] addr_in, addr_in_Plus8;
  logic [`INST_BUFFER_LEN-1:0] addr_in_hits, addr_in_Plus8_hits;
  logic miss_outstanding;

  assign addr_in = {proc2Icache_addr[63:3],3'b0};
  assign addr_in_Plus8 = {proc2Icache_addr[63:3],3'b0}+8;
  assign {current_tag, current_index} = (addr_queue_tail == 0)? proc2Icache_addr[31:3] : addr_queue[0][31:3];

  wire changed_addr = (current_index != last_index) || (current_tag != last_tag);

  CAM #(.LENGTH(`INST_BUFFER_LEN),
        .WIDTH(1),
        .NUM_TAGS(2),
        .TAG_SIZE(64)) addr_queue_cam(
    .enable(2'b11),
    .tags({addr_in, addr_in_Plus8}),
    .table_in(addr_queue),
    .hits(addr_cam_hits)
  );

  genvar ig;
  for(ig = 0; ig < `INST_BUFFER_LEN; ig += 1) begin
    assign addr_in_hits[ig] = addr_cam_hits[ig][1];
    assign addr_in_Plus8_hits[ig] = addr_cam_hits[ig][0];
  end

  always_comb begin
    addr_queue_next = addr_queue;
    addr_queue_tail_next = addr_queue_tail;
    if(addr_queue_tail > 0 & ~miss_outstanding) begin
      addr_queue_next[`INST_BUFFER_LEN-1:0] = {addr_queue[`INST_BUFFER_LEN-1:1], 64'b0};
      addr_queue_tail_next -= 1;
    end
    if(addr_queue_tail_next == 0) begin
      addr_queue_next[0] = addr_in;
      addr_queue_next[1] = addr_in_Plus8;
      addr_queue_tail_next = 2;
    end else if(~(|addr_in_Plus8_hits) & (addr_queue_tail_next < `INST_BUFFER_LEN)) begin
      addr_queue_next[addr_queue_tail_next] = addr_in_Plus8;
      addr_queue_tail_next += 1;
    end    
  end
  
  wire send_request = miss_outstanding && !changed_addr;

  assign Icache_data_out = cachemem_data;

  assign Icache_valid_out = cachemem_valid; 

  assign proc2Imem_addr = (addr_queue_tail == 0)? {proc2Icache_addr[63:3],3'b0} : addr_queue[0];
  assign proc2Imem_command = send_request?  BUS_LOAD :
                                            BUS_NONE;

  assign data_write_enable =  (current_mem_tag == Imem2proc_tag) &&
                              (current_mem_tag != 0);
  //assign data_write_enable = (Imem2proc_response == Imem2proc_tag) && (Imem2proc_response != 0);

  wire update_mem_tag = changed_addr || miss_outstanding || data_write_enable;

  wire unanswered_miss = changed_addr ? !Icache_valid_out :
                                        miss_outstanding && (Imem2proc_response == 0);

  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if(reset) begin
      last_index       <= `SD -1;   // These are -1 to get ball rolling when
      last_tag         <= `SD -1;   // reset goes low because addr "changes"
      current_mem_tag  <= `SD 0;              
      miss_outstanding <= `SD 0;
      addr_queue <= `SD {4*64{1'b0}};
      addr_queue_tail <= `SD 0;
    end else begin
      last_index       <= `SD current_index;
      last_tag         <= `SD current_tag;
      miss_outstanding <= `SD unanswered_miss;
      addr_queue       <= `SD addr_queue_next;
      addr_queue_tail  <= `SD addr_queue_tail_next;

      if(update_mem_tag)
        current_mem_tag <= `SD Imem2proc_response;
    end
  end

endmodule

