`include "../../sys_defs.vh"
module icache(clock, reset,
              proc2Icache_addr,
              Imem2proc_response, Imem2proc_data, Imem2proc_tag,
              Icache_data_out, Icache_valid_out,
              proc2Imem_command, proc2Imem_addr);
  parameter NUM_WAYS = 4;
  parameter RD_PORTS = 1;

  `define NUM_SET_BITS $clog2(32/NUM_WAYS)
  `define NUM_TAG_BITS (13-`NUM_SET_BITS)

  typedef struct packed {
    logic [63:0] data;
    logic [(`NUM_TAG_BITS-1):0] tag;
    logic valid;
    logic dirty;
  } CACHE_LINE_T;

  typedef struct packed {
    CACHE_LINE_T [(NUM_WAYS-1):0] cache_lines;
  } CACHE_SET_T;

  input clock, reset;

  //////////////
  //  INPUTS  //
  //////////////
  //from if_stage
  input [(RD_PORTS-1):0][63:0] proc2Icache_addr;

  //from main memory
  input [3:0]  Imem2proc_response;
  input [63:0] Imem2proc_data;
  input [3:0]  Imem2proc_tag;

  ///////////////
  //  OUTPUTS  //
  ///////////////
  //to if_stage
  output logic [(RD_PORTS-1):0][63:0] Icache_data_out; // value is memory[proc2Icache_addr]
  output logic [(RD_PORTS-1):0] Icache_valid_out; // when this is high

  //to main memory
  output logic [1:0]  proc2Imem_command;
  output logic [63:0] proc2Imem_addr;

  //instantiate cachemem module
  //cache memory inputs    
  logic [(RD_PORTS+1):0] cache_rd_en;
  logic [(RD_PORTS+1):0][(`NUM_SET_BITS-1):0] cache_rd_idx;
  logic [(RD_PORTS+1):0][(`NUM_TAG_BITS-1):0] cache_rd_tag;

  logic cache_wr_en;
  logic [(`NUM_SET_BITS-1):0] cache_wr_idx;
  logic [(`NUM_TAG_BITS-1):0] cache_wr_tag;
  logic [63:0] cache_wr_data;
  
  //cache memory outputs
  logic [(RD_PORTS+1):0][63:0] cache_rd_data;
  logic [(RD_PORTS+1):0] cache_rd_valid;
  logic [(RD_PORTS+1):0][(`NUM_SET_BITS-1):0] cache_rd_miss_idx;
  logic [(RD_PORTS+1):0][(`NUM_TAG_BITS-1):0] cache_rd_miss_tag;
  logic [(RD_PORTS+1):0] cache_rd_miss_valid;

  logic [(`NUM_SET_BITS-1):0] cache_wr_miss_idx;
  logic [(`NUM_TAG_BITS-1):0] cache_wr_miss_tag;
  logic cache_wr_miss_valid;

  cachemem #(
    .NUM_WAYS_MEM(4),
    .RD_PORTS_MEM(RD_PORTS+2),
    .WR_PORTS_MEM(1)) 
  memory(
    .clock(clock),
    .reset(reset),

    //inputs
    .rd_en(cache_rd_en),
    .rd_idx(cache_rd_idx),
    .rd_tag(cache_rd_tag),

    .wr_en(cache_wr_en),
    .wr_idx(cache_wr_idx),
    .wr_tag(cache_wr_tag),
    .wr_data(cache_wr_data),
    .wr_dirty(1'b0),

    //outputs
    .rd_data(cache_rd_data),
    .rd_valid(cache_rd_valid),
    .rd_miss_idx(cache_rd_miss_idx),
    .rd_miss_tag(cache_rd_miss_tag),
    .rd_miss_valid(cache_rd_miss_valid),

    .wr_miss_idx(cache_wr_miss_idx),
    .wr_miss_tag(cache_wr_miss_tag),
    .wr_miss_valid(cache_wr_miss_valid),

    .vic_idx(),
    .victim(),
    .victim_valid()
  );

  MEM_REQ_T [(`INST_BUFFER_LEN-1):0] PC_queue, PC_queue_next;
  logic [($clog2(`INST_BUFFER_LEN)-1):0] PC_queue_tail, PC_queue_tail_next;
  logic [($clog2(`INST_BUFFER_LEN)-1):0] send_req_ptr, send_req_ptr_next;
  logic [($clog2(`INST_BUFFER_LEN)-1):0] mem_waiting_ptr, mem_waiting_ptr_next;

  //fetch address variables
  logic [(RD_PORTS-1):0][63:0] PC_in;
  logic [(`NUM_INST_PREFETCH-1):0][63:0] PC_in_Plus;
  logic [(RD_PORTS-1):0][63:0] last_PC_in;
  logic [(`NUM_SET_BITS-1):0] current_index;
  logic [(`NUM_TAG_BITS-1):0] current_tag;

  //CAM variables
  logic [(RD_PORTS+`NUM_INST_PREFETCH-1):0][63:0] cam_tags_in;
  logic [(`INST_BUFFER_LEN-1):0][0:0][63:0] cam_table_in;
  logic [(`INST_BUFFER_LEN-1):0][0:0][(RD_PORTS+`NUM_INST_PREFETCH-1):0] PC_cam_hits;
  logic [(RD_PORTS-1):0][(`INST_BUFFER_LEN-1):0] PC_in_hits;
  logic [(`NUM_INST_PREFETCH-1):0][(`INST_BUFFER_LEN-1):0] PC_in_Plus_hits;

  //control variables
  logic send_request;
  logic changed_addr;
  logic unanswered_miss;
  logic update_mem_tag;
  logic mem_done;

  //Instantiate CAM to check for requested address in queue
  genvar ig, jg;
  for(ig = 0; ig < RD_PORTS; ig += 1) begin
    assign cam_tags_in[ig] = PC_in[ig];
  end
  for(ig = RD_PORTS; ig < (RD_PORTS+`NUM_INST_PREFETCH); ig += 1) begin
    assign cam_tags_in[ig] = PC_in_Plus[ig-RD_PORTS];
  end

  for(ig = 0; ig < `INST_BUFFER_LEN; ig += 1) begin
    assign cam_table_in[ig][0] = PC_queue[ig].address;
    for(jg = 0; jg < RD_PORTS; jg += 1) begin
      assign PC_in_hits[jg][ig] = PC_cam_hits[ig][0][jg] & (ig < PC_queue_tail);
    end
    for(jg = 0; jg < `NUM_INST_PREFETCH; jg += 1) begin
      assign PC_in_Plus_hits[jg][ig] = PC_cam_hits[ig][0][jg+RD_PORTS] & (ig < PC_queue_tail);
    end
  end

  CAM #(.LENGTH(`INST_BUFFER_LEN),
        .WIDTH(1),
        .NUM_TAGS(RD_PORTS+`NUM_INST_PREFETCH),
        .TAG_SIZE(64)) PC_queue_cam(
    .enable({(RD_PORTS + `NUM_INST_PREFETCH){1'b1}}),
    .tags(cam_tags_in),
    .table_in(cam_table_in),
    .hits(PC_cam_hits)
  );

  assign PC_in = proc2Icache_addr;
  for(ig = 0; ig < `NUM_INST_PREFETCH; ig += 1) begin
    assign PC_in_Plus[ig] = {proc2Icache_addr[RD_PORTS-1][63:3],3'b0}+(8*(ig+1));
  end

  assign changed_addr = (PC_in != last_PC_in);

  //cache rd PC_in
  for(ig = 0; ig < RD_PORTS; ig += 1) begin
    assign cache_rd_en[ig] = 1'b1;
    assign {cache_rd_tag[ig], cache_rd_idx[ig]} = PC_in[ig][31:3];
    assign Icache_data_out[ig] = cache_rd_data[ig];
    assign Icache_valid_out[ig] = cache_rd_valid[ig];
  end

  //cache rd front of queue
  assign cache_rd_en[RD_PORTS] = (PC_queue_tail != 0)? 1'b1 : 1'b0;
  assign {cache_rd_tag[RD_PORTS], cache_rd_idx[RD_PORTS]} = PC_queue[0].address[31:3];

  //cache rd PC_queue entry to send to main memory
  assign cache_rd_en[RD_PORTS+1] = (send_req_ptr < PC_queue_tail)? 1'b1 : 1'b0;
  assign {cache_rd_tag[RD_PORTS+1], cache_rd_idx[RD_PORTS+1]} = PC_queue[send_req_ptr].address[31:3];

  assign unanswered_miss = send_request? (Imem2proc_response == 0) :
                           (PC_queue_tail == 0) & changed_addr? cache_rd_en[0] & ~cache_rd_valid[0] : 
                                                              PC_queue_tail > send_req_ptr;//cache_rd_en[RD_PORTS+1] & ~cache_rd_valid[RD_PORTS+1];

  assign proc2Imem_addr = send_request? PC_queue[send_req_ptr].address :
                                        64'b0;
  assign proc2Imem_command = send_request? BUS_LOAD :
                                           BUS_NONE;

  assign mem_done = (PC_queue[mem_waiting_ptr].mem_tag == Imem2proc_tag) &&
                              (PC_queue[mem_waiting_ptr].mem_tag != 0);

  assign {cache_wr_tag, cache_wr_idx} = PC_queue[mem_waiting_ptr-1].address[31:3];

  assign update_mem_tag = send_request? (Imem2proc_response != 0) : 1'b0; 

  always_comb begin
    PC_queue_next = PC_queue;
    PC_queue_tail_next = PC_queue_tail;
    send_req_ptr_next = send_req_ptr;
    mem_waiting_ptr_next = mem_waiting_ptr;

    if(mem_done) begin
      mem_waiting_ptr_next += 1;
    end

    if(cache_rd_valid[RD_PORTS]) begin
      PC_queue_next[`INST_BUFFER_LEN-1:0] = {EMPTY_MEM_REQ, PC_queue[`INST_BUFFER_LEN-1:1]};
      PC_queue_tail_next -= 1;
      if(send_req_ptr > 0) begin
        send_req_ptr_next -= 1;
      end
      if(mem_waiting_ptr > 0) begin
        mem_waiting_ptr_next -= 1;
      end
    end

    if(update_mem_tag) begin
      PC_queue_next[send_req_ptr_next].mem_tag = Imem2proc_response;
      send_req_ptr_next += 1;
    end

    for(int i = 0; i < RD_PORTS; i += 1) begin
      if(~(|PC_in_hits[i]) & ~cache_rd_valid[i] & ~send_request) begin
	PC_queue_tail_next = 0;
	send_req_ptr_next = 0;
	mem_waiting_ptr_next = 0;
        PC_queue_next[PC_queue_tail_next].address = {PC_in[i][63:3], 3'b0};
        PC_queue_next[PC_queue_tail_next].valid = 1'b1;
        PC_queue_tail_next += 1;
      end
    end
    for(int i = 0; i < `NUM_INST_PREFETCH; i += 1) begin
      if(~(|PC_in_Plus_hits[i]) & changed_addr & (PC_queue_tail_next < `INST_BUFFER_LEN)) begin
        PC_queue_next[PC_queue_tail_next].address = PC_in_Plus[i];
        PC_queue_next[PC_queue_tail_next].valid = 1'b1;
        PC_queue_tail_next += 1;
      end
    end
  end

  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if(reset) begin
      last_PC_in   <= `SD -1;     
      send_request <= `SD 1'b0;
      for(int i = 0; i < `INST_BUFFER_LEN; i += 1) begin
        PC_queue[i] <= `SD EMPTY_MEM_REQ;
      end
      PC_queue_tail   <= `SD 0;
      send_req_ptr    <= `SD 0;
      mem_waiting_ptr <= `SD 0;
      cache_wr_en     <= `SD 1'b0;
      cache_wr_data   <= `SD 64'b0;
    end else begin
      last_PC_in      <= `SD PC_in;
      send_request    <= `SD unanswered_miss;
      PC_queue        <= `SD PC_queue_next;
      PC_queue_tail   <= `SD PC_queue_tail_next;
      send_req_ptr    <= `SD send_req_ptr_next;
      mem_waiting_ptr <= `SD mem_waiting_ptr_next;
      if(mem_done) begin
        cache_wr_en   <= `SD 1'b1;
        cache_wr_data <= `SD Imem2proc_data;
      end else begin
        cache_wr_en   <= `SD 1'b0;
        cache_wr_data <= `SD 64'b0;
      end
    end
  end

endmodule

