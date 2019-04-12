`include "../../sys_defs.vh"
module icache(
  input   clock,
  input   reset,

  //////////////
  //  INPUTS  //
  //////////////
  //from if_stage
  input [63:0] proc2Icache_addr,

  //from main memory
  input [3:0]  Imem2proc_response,
  input [63:0] Imem2proc_data,
  input [3:0]  Imem2proc_tag,

  ///////////////
  //  OUTPUTS  //
  ///////////////
  //to if_stage
  output logic [63:0] Icache_data_out, // value is memory[proc2Icache_PC]
  output logic        Icache_valid_out,      // when this is high

  //to main memory
  output logic [1:0]  proc2Imem_command,
  output logic [63:0] proc2Imem_addr  
); 
  //instantiate cachemem module
  //cache memory inputs    
  logic cache_wr_en;
  logic [(`NUM_SET_BITS - 1):0] cache_wr_idx;
  logic [(`NUM_TAG_BITS - 1):0] cache_wr_tag;
  logic [63:0]                  cache_wr_data;
  logic cache_rd_en;
  logic [(`NUM_SET_BITS - 1):0] cache_rd_idx;
  logic [(`NUM_TAG_BITS - 1):0] cache_rd_tag;

  //cache memory outputs
  logic cache_miss_valid_rd;
  logic [(`NUM_SET_BITS - 1):0] cache_miss_idx_rd;
  logic [(`NUM_TAG_BITS - 1):0] cache_miss_tag_rd;
  logic cache_miss_valid_wr;
  logic [(`NUM_SET_BITS - 1):0] cache_miss_idx_wr;
  logic [(`NUM_TAG_BITS - 1):0] cache_miss_tag_wr;
  logic [63:0]                  cache_rd_data;
  logic cache_rd_valid;

  cachemem memory(
    .clock(clock),
    .reset(reset),

    .wr1_en(cache_wr_en),
    .wr1_idx(cache_wr_idx),
    .wr1_tag(cache_wr_tag),
    .wr1_data(cache_wr_data),
    .wr1_dirty(1'b0),

    .rd1_en(cache_rd_en),
    .rd1_idx(cache_rd_idx),
    .rd1_tag(cache_rd_tag),

    .victim_valid(),
    .victim(),
    .vic_idx(),

    .miss_valid_rd(cache_miss_valid_rd),
    .miss_idx_rd(cache_miss_idx_rd),
    .miss_tag_rd(cache_miss_tag_rd),

    .miss_valid_wr(cache_miss_valid_wr),
    .miss_idx_wr(cache_miss_idx_wr),
    .miss_tag_wr(cache_miss_tag_wr),

    .rd1_data(cache_rd_data),
    .rd1_valid(cache_rd_valid)
  );

  logic  [(`NUM_SET_BITS - 1):0] current_index;
  logic  [(`NUM_TAG_BITS - 1):0] current_tag;
  ICACHE_BUFFER_T [`INST_BUFFER_LEN-1:0] PC_queue, PC_queue_next;
  logic [2:0] PC_queue_tail, PC_queue_tail_next;
  logic [2:0] send_req_ptr, send_req_ptr_next;
  logic [`INST_BUFFER_LEN-1:0][0:0][1:0] PC_cam_hits;
  logic [63:0] PC_in, PC_in_Plus8;
  logic [63:0] last_PC_in;
  logic [`INST_BUFFER_LEN-1:0] PC_in_hits, PC_in_Plus8_hits;
  logic miss_outstanding;

  assign PC_in = proc2Icache_addr;//{proc2Icache_addr[63:3],3'b0};
  assign PC_in_Plus8 = {proc2Icache_addr[63:3],3'b0}+8;
  assign {current_tag, current_index} = PC_queue[0].address[31:3];//(PC_queue_tail == 0)? proc2Icache_addr[31:3] : PC_queue[0].address[31:3];

  wire changed_addr = (PC_in != last_PC_in);//(current_index != last_index) || (current_tag != last_tag);

  CAM #(.LENGTH(`INST_BUFFER_LEN),
        .WIDTH(1),
        .NUM_TAGS(2),
        .TAG_SIZE(64)) PC_queue_cam(
    .enable(2'b11),
    .tags({PC_in, PC_in_Plus8}),
    .table_in(PC_queue),
    .hits(PC_cam_hits)
  );

  genvar ig;
  for(ig = 0; ig < `INST_BUFFER_LEN; ig += 1) begin
    assign PC_in_hits[ig] = PC_cam_hits[ig][0][1];
    assign PC_in_Plus8_hits[ig] = PC_cam_hits[ig][0][0];
  end

  wire send_request = miss_outstanding;

  assign Icache_data_out = cache_rd_data;
  assign Icache_valid_out = cache_rd_valid;

  assign proc2Imem_addr = (PC_queue_tail == 0)? {PC_in[63:3], 3'b0} : 
                          (send_request)? PC_queue[send_req_ptr] : 64'b0;
  assign proc2Imem_command = send_request?  BUS_LOAD :
                                            BUS_NONE;

  assign cache_wr_en = (PC_queue[0].Imem_tag == Imem2proc_tag) &&
                              (PC_queue[0].Imem_tag != 0);
  assign cache_wr_idx = current_index;
  assign cache_wr_tag = current_tag;
  assign cache_wr_data = Imem2proc_data;

  wire update_mem_tag = send_request? (Imem2proc_response != 0) : 1'b0; 

  wire unanswered_miss = changed_addr ? ~cache_rd_valid :
                                        miss_outstanding && (Imem2proc_response == 0);

  always_comb begin
    PC_queue_next = PC_queue;
    PC_queue_tail_next = PC_queue_tail;
    send_req_ptr_next = send_req_ptr;
    cache_rd_en = 1'b0;
    cache_rd_tag = 0;
    cache_rd_idx = 0;

    if(cache_wr_en) begin
      PC_queue_next[`INST_BUFFER_LEN-1:0] = {EMPTY_ICACHE, PC_queue[`INST_BUFFER_LEN-1:1]};
      PC_queue_tail_next -= 1;
      send_req_ptr_next -= 1;
    end

    if(changed_addr) begin
      cache_rd_en = 1'b1;
      {cache_rd_tag, cache_rd_idx} = PC_in[31:3];
    end else if(send_req_ptr < PC_queue_tail & ~send_request) begin
      cache_rd_en = 1'b1;
      {cache_rd_tag, cache_rd_idx} = PC_queue[send_req_ptr].address[31:3];
    end

    if(update_mem_tag) begin
      PC_queue_next[send_req_ptr].Imem_tag = Imem2proc_response;
      send_req_ptr_next += 1;
    end
    if(PC_queue_tail_next == 0 & changed_addr) begin
      PC_queue_next[0].address = {PC_in[63:3], 3'b0};
      PC_queue_next[1].address = PC_in_Plus8;
      PC_queue_tail_next = 2;
    end else if(~(|PC_in_Plus8_hits) & (PC_queue_tail_next < `INST_BUFFER_LEN)) begin
      PC_queue_next[PC_queue_tail_next].address = PC_in_Plus8;
      PC_queue_tail_next += 1;
    end    
  end

  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if(reset) begin
      last_PC_in       <= `SD -1;     
      miss_outstanding <= `SD 0;
      for(int i = 0; i < `INST_BUFFER_LEN; i += 1) begin
        PC_queue[i] <= `SD EMPTY_ICACHE;
      end
      PC_queue_tail <= `SD 0;
      send_req_ptr <= `SD 0;
    end else begin
      last_PC_in       <= `SD PC_in;
      miss_outstanding <= `SD unanswered_miss;
      PC_queue       <= `SD PC_queue_next;
      PC_queue_tail  <= `SD PC_queue_tail_next;
      send_req_ptr   <= `SD send_req_ptr_next;
    end
  end

endmodule

