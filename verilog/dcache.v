`include "../../sys_defs.vh"
`define DEBUG

module dcache(clock, reset,
              rd_en, proc2Dcache_rd_addr,
              wr_en, proc2Dcache_wr_addr, proc2Dcache_wr_data,
              Dmem2proc_response, Dmem2proc_data, Dmem2proc_tag,
              Dcache_rd_data_out, Dcache_rd_valid_out,
              Dcache_rd_miss_addr_out, Dcache_rd_miss_data_out, Dcache_rd_miss_valid_out,
              proc2Dmem_command, proc2Dmem_addr, proc2Dmem_data);
  parameter NUM_WAYS = 4;
  parameter RD_PORTS = 1;
  parameter WR_PORTS = 1;

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

  typedef struct packed {
    logic [`NUM_TAG_BITS-1:0] tag;
    logic [`NUM_SET_BITS-1:0] idx;
    logic [63:0] data;
    logic valid;
  } DCACHE_FIFO_T;

  const DCACHE_FIFO_T EMPTY_DCACHE =
  {
    {`NUM_TAG_BITS{1'b0}},
    {`NUM_SET_BITS{1'b0}},
    64'b0,
    1'b0
  };

  input clock, reset;

  //////////////
  //  INPUTS  //
  //////////////
  //from mem_stage
  input [(RD_PORTS-1):0] rd_en;
  input [(RD_PORTS-1):0][63:0] proc2Dcache_rd_addr;
  input [(WR_PORTS-1):0] wr_en;
  input [(WR_PORTS-1):0][63:0] proc2Dcache_wr_addr;
  input [(WR_PORTS-1):0][63:0] proc2Dcache_wr_data;

  //from main memory
  input [3:0]  Dmem2proc_response;
  input [63:0] Dmem2proc_data;
  input [3:0]  Dmem2proc_tag;

  ///////////////
  //  OUTPUTS  //
  ///////////////
  //to mem_stage
  output logic [(RD_PORTS-1):0][63:0] Dcache_rd_data_out; // value is memory[proc2Dcache_rd_addr]
  output logic [(RD_PORTS-1):0] Dcache_rd_valid_out; // when this is high
  output logic [63:0] Dcache_rd_miss_addr_out;
  output logic [63:0] Dcache_rd_miss_data_out; // value is memory[proc2Dcache_rd_addr]
  output logic Dcache_rd_miss_valid_out; 

  //to main memory
  output logic [1:0]  proc2Dmem_command;
  output logic [63:0] proc2Dmem_addr;
  output logic [63:0] proc2Dmem_data;

  ///////////////////////////////////////////////////
  //***********************************************//
  ///////////////////////////////////////////////////

  //////////////
  //  MODULE  //
  //////////////
  //instantiate cachemem module
  //cache memory inputs    
  logic [RD_PORTS:0] cache_rd_en;
  logic [RD_PORTS:0][(`NUM_SET_BITS-1):0] cache_rd_idx;
  logic [RD_PORTS:0][(`NUM_TAG_BITS-1):0] cache_rd_tag;

  logic [(WR_PORTS+RD_PORTS):0] cache_wr_en;
  logic [(WR_PORTS+RD_PORTS):0][(`NUM_SET_BITS-1):0] cache_wr_idx;
  logic [(WR_PORTS+RD_PORTS):0][(`NUM_TAG_BITS-1):0] cache_wr_tag;
  logic [(WR_PORTS+RD_PORTS):0][63:0] cache_wr_data;
  logic [(WR_PORTS+RD_PORTS):0] cache_wr_dirty;

  //cache memory outputs
  logic [RD_PORTS:0][63:0] cache_rd_data;
  logic [RD_PORTS:0] cache_rd_valid;
  logic [RD_PORTS:0][(`NUM_SET_BITS-1):0] cache_rd_miss_idx;
  logic [RD_PORTS:0][(`NUM_TAG_BITS-1):0] cache_rd_miss_tag;
  logic [RD_PORTS:0] cache_rd_miss_valid;

  logic [(WR_PORTS+RD_PORTS):0][(`NUM_SET_BITS-1):0] cache_wr_miss_idx;
  logic [(WR_PORTS+RD_PORTS):0][(`NUM_TAG_BITS-1):0] cache_wr_miss_tag;
  logic [(WR_PORTS+RD_PORTS):0] cache_wr_miss_valid;

  cachemem #(
    .NUM_WAYS(NUM_WAYS),
    .RD_PORTS(RD_PORTS+1),
    .WR_PORTS(WR_PORTS+RD_PORTS+1)) 
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
    .wr_dirty(cache_wr_dirty),

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
  
  //Internal variables
  DCACHE_FIFO_T [(`NUM_FIFO-1):0][(`FIFO_SIZE-1):0] fifo, fifo_next;
  logic [(`NUM_FIFO-1):0][5:0] fetch_stride, fetch_stride_next;
  logic [(`NUM_FIFO-1):0][(`NUM_FIFO_SIZE_BITS-1):0] fifo_tail, fifo_tail_next;
  logic [(`NUM_FIFO-1):0] fifo_busy, fifo_busy_next;
  logic [(`NUM_FIFO-1):0] fifo_sel_req, fifo_sel_gnt;
  logic [(`NUM_FIFO_BITS-1):0] fifo_sel_num;
  logic fifo_sel_num_valid;
  logic [(`NUM_FIFO-2):0] fifo_lru, fifo_lru_next;
  logic [($clog2(`NUM_FIFO-1)-1):0] next_lru_idx;
  logic [(`NUM_FIFO_BITS-1):0] fill_fifo_idx;
  logic [(`NUM_FIFO_BITS-1):0] temp_lru_idx;
  logic [(`NUM_FIFO_BITS-1):0] acc;
  logic [63:0] next_rd_addr;

  DCACHE_MEM_REQ_T [(`MEM_BUFFER_SIZE-1):0] mem_req_queue, mem_req_queue_next;
  logic [$clog2(`MEM_BUFFER_SIZE):0] mem_req_queue_tail, mem_req_queue_tail_next;
  logic [$clog2(`MEM_BUFFER_SIZE):0] send_req_ptr, send_req_ptr_next;
  logic [$clog2(`MEM_BUFFER_SIZE):0] mem_waiting_ptr, mem_waiting_ptr_next;

  logic [(`MEM_BUFFER_SIZE-1):0][0:0][63:0] mem_queue_cam_table_in;
  logic [(RD_PORTS-1):0][63:0] mem_queue_cam_tags;
  logic [(`MEM_BUFFER_SIZE-1):0][0:0][(RD_PORTS-1):0] mem_queue_cam_hits;
  logic [(RD_PORTS-1):0][(`MEM_BUFFER_SIZE-1):0] mem_queue_hits;

  logic [(`NUM_FIFO-1):0][(`FIFO_SIZE-1):0][(`NUM_SET_BITS+`NUM_TAG_BITS-1):0] fifo_addr_table_in;
  logic [(RD_PORTS-1):0][(`NUM_SET_BITS+`NUM_TAG_BITS-1):0] fifo_cam_tags;
  logic [(`NUM_FIFO-1):0][(`FIFO_SIZE-1):0][(RD_PORTS-1):0] fifo_cam_hits;
  wor   [(RD_PORTS-1):0][(`NUM_FIFO-1):0] fifo_num_to_encode;
  logic [(RD_PORTS-1):0][(`NUM_FIFO_BITS-1):0] fifo_hit_num;
  logic [(RD_PORTS-1):0] fifo_hit_num_valid;
  logic [(RD_PORTS-1):0][(`FIFO_SIZE-1):0] fifo_idx_to_encode;
  logic [(RD_PORTS-1):0][(`NUM_FIFO_SIZE_BITS-1):0] fifo_hit_idx;
  logic [(RD_PORTS-1):0] fifo_hit_idx_valid;

  //Control variables
  logic send_request;
  logic unanswered_miss;
  logic update_mem_tag;
  logic mem_done;
  logic [63:0] mem_rd_data;

  //Instantiate CAM to check for rd address in fifo
  genvar ig, jg, kg;
  for(ig = 0; ig < `NUM_FIFO; ig += 1) begin
    for(jg = 0; jg < `FIFO_SIZE; jg += 1) begin
      assign fifo_addr_table_in[ig][jg] = {fifo[ig][jg].tag, fifo[ig][jg].idx};
      for(kg = 0; kg < RD_PORTS; kg += 1) begin
        assign fifo_num_to_encode[kg][ig] = (fifo_cam_hits[ig][jg][kg] & fifo[ig][jg].valid);
      end
    end
    assign fifo_sel_req[ig] = fifo_busy[ig] & (fifo_tail[ig] < `FIFO_SIZE); 
  end

  for(ig = 0; ig < `MEM_BUFFER_SIZE; ig += 1) begin
    assign mem_queue_cam_table_in[ig][0] = mem_req_queue[ig].req.address;
    for(jg = 0; jg < RD_PORTS; jg += 1) begin
      assign mem_queue_hits[jg][ig] = mem_queue_cam_hits[ig][0][jg] & mem_req_queue[ig].req.valid;
    end
  end

  for(ig = 0; ig < RD_PORTS; ig += 1) begin
    assign fifo_cam_tags[ig] = {cache_rd_miss_tag[ig], cache_rd_miss_idx[ig]};
    assign mem_queue_cam_tags[ig] = proc2Dcache_rd_addr[ig];
  end

  CAM #(.LENGTH(`NUM_FIFO),
      .WIDTH(`FIFO_SIZE),
      .NUM_TAGS(RD_PORTS),
      .TAG_SIZE((`NUM_SET_BITS+`NUM_TAG_BITS))) 
   fifo_cam(
    .enable(cache_rd_miss_valid),
    .tags(fifo_cam_tags),
    .table_in(fifo_addr_table_in),
    .hits(fifo_cam_hits)
  );

  CAM #(.LENGTH(`MEM_BUFFER_SIZE),
      .WIDTH(1),
      .NUM_TAGS(RD_PORTS),
      .TAG_SIZE(64)) 
  mem_queue_cam(
    .enable(rd_en),
    .tags(mem_queue_cam_tags),
    .table_in(mem_queue_cam_table_in),
    .hits(mem_queue_cam_hits)
  );

  psel_rotating #(.WIDTH(`NUM_FIFO)) 
  fifo_psel(
    .clock(clock),
    .reset(reset),
    .req(fifo_sel_req),
    .en((mem_req_queue_tail < `MEM_BUFFER_SIZE)),
    .gnt(fifo_sel_gnt)
  );

  encoder #(.WIDTH(`NUM_FIFO)) 
  fifo_sel_enc(
    .in(fifo_sel_gnt),
    .out(fifo_sel_num),
    .valid(fifo_sel_num_valid)
  );

  for(ig = 0; ig < RD_PORTS; ig += 1) begin
    encoder #(.WIDTH(`NUM_FIFO)) 
    fifo_num_enc(
      .in(fifo_num_to_encode[ig]),
      .out(fifo_hit_num[ig]),
      .valid(fifo_hit_num_valid[ig])
    );
  end

  for(ig = 0; ig < RD_PORTS; ig += 1) begin
    for(jg = 0; jg < `FIFO_SIZE; jg += 1) begin
      assign fifo_idx_to_encode[ig][jg] = (fifo_cam_hits[fifo_hit_num[ig]][jg][ig] & fifo[fifo_hit_num[ig]][jg].valid);
    end

    encoder #(.WIDTH(`FIFO_SIZE)) 
    fifo_idx_enc(
      .in(fifo_idx_to_encode[ig]),
      .out(fifo_hit_idx[ig]),
      .valid(fifo_hit_idx_valid[ig])
    );
  end

  //cache input logic
  for(ig = 0; ig < WR_PORTS; ig += 1) begin
    //requested wr
    assign cache_wr_en[ig] = wr_en[ig];
    assign {cache_wr_tag[ig], cache_wr_idx[ig]} = proc2Dcache_wr_addr[ig][31:3];
    assign cache_wr_data[ig] = proc2Dcache_wr_data[ig];
    assign cache_wr_dirty[ig] = 1'b1;
  end

  for(ig = 0; ig < RD_PORTS; ig += 1) begin
    //wr from fifo if rd miss found
    assign cache_wr_en[WR_PORTS+ig] = fifo_hit_idx_valid[ig];
    assign cache_wr_idx[WR_PORTS+ig] = fifo[fifo_hit_num[ig]][fifo_hit_idx[ig]].idx;
    assign cache_wr_tag[WR_PORTS+ig] = fifo[fifo_hit_num[ig]][fifo_hit_idx[ig]].tag;
    assign cache_wr_data[WR_PORTS+ig] = fifo[fifo_hit_num[ig]][fifo_hit_idx[ig]].data;
    assign cache_wr_dirty[WR_PORTS+ig] = 1'b0;

    //requested rd
    assign cache_rd_en[ig] = rd_en[ig];
    assign {cache_rd_tag[ig], cache_rd_idx[ig]} = proc2Dcache_rd_addr[ig][31:3];
    assign Dcache_rd_data_out[ig] = cache_rd_data[ig];
    assign Dcache_rd_valid_out[ig] = cache_rd_valid[ig];
  end

  assign unanswered_miss = send_request? (Dmem2proc_response == 0) :
                                      !fifo_hit_num_valid[0] & cache_rd_miss_valid[0];

  assign proc2Dmem_addr = send_request? mem_req_queue[send_req_ptr].req.address : 64'b0;
  assign proc2Dmem_command = send_request? BUS_LOAD :
                                           BUS_NONE;
  
  assign mem_done = (mem_req_queue[mem_waiting_ptr].req.mem_tag == Dmem2proc_tag) &&
                              (mem_req_queue[mem_waiting_ptr].req.mem_tag  != 0);

  assign {cache_wr_tag[RD_PORTS+WR_PORTS], cache_wr_idx[RD_PORTS+WR_PORTS]} = mem_req_queue[mem_waiting_ptr-1].req.address[31:3];
  assign cache_wr_dirty[RD_PORTS+WR_PORTS] = 1'b0;
  assign cache_wr_data[RD_PORTS+WR_PORTS] = mem_rd_data;
  assign Dcache_rd_miss_addr_out = mem_req_queue[mem_waiting_ptr-1].req.address;
  assign Dcache_rd_miss_data_out = mem_rd_data;

  assign update_mem_tag = send_request? (Dmem2proc_response != 0) : 1'b0;

  always_comb begin
    mem_req_queue_next = mem_req_queue;
    mem_req_queue_tail_next = mem_req_queue_tail;
    send_req_ptr_next = send_req_ptr;
    mem_waiting_ptr_next = mem_waiting_ptr;
    fifo_next = fifo;
    fetch_stride_next = fetch_stride;
    fifo_tail_next = fifo_tail;
    fifo_busy_next = fifo_busy;
    fifo_lru_next = fifo_lru;

    if(mem_done) begin
      mem_req_queue_next[mem_waiting_ptr_next].req_done = 1'b1;
      mem_waiting_ptr_next += 1;
    end

    if(mem_req_queue[0].req_done) begin
      if(mem_req_queue[0].wr_to_fifo) begin
        {fifo_next[mem_req_queue[0].fifo_num][mem_req_queue[0].fifo_idx].tag,
         fifo_next[mem_req_queue[0].fifo_num][mem_req_queue[0].fifo_idx].idx} = mem_req_queue[0].req.address;
         fifo_next[mem_req_queue[0].fifo_num][mem_req_queue[0].fifo_idx].data = mem_rd_data;
         fifo_next[mem_req_queue[0].fifo_num][mem_req_queue[0].fifo_idx].valid = 1'b1;
      end
      mem_req_queue_next[`MEM_BUFFER_SIZE-1:0] = {EMPTY_DCACHE_MEM_REQ, mem_req_queue_next[`MEM_BUFFER_SIZE-1:1]};
      mem_req_queue_tail_next -= 1;
      if(send_req_ptr > 0) begin
        send_req_ptr_next -= 1;
      end
      if(mem_waiting_ptr > 0) begin
        mem_waiting_ptr_next -= 1;
      end
    end

    if(update_mem_tag) begin
      mem_req_queue_next[send_req_ptr_next].req.mem_tag = Dmem2proc_response;
      send_req_ptr_next += 1;
    end

    //allocate new fifo
    for(int i = 0; i < RD_PORTS; i += 1) begin
      if(!fifo_hit_num_valid[i] & ~(|mem_queue_hits[i]) & cache_rd_miss_valid[i] & (mem_req_queue_tail_next < `MEM_BUFFER_SIZE)) begin
        mem_req_queue_next[mem_req_queue_tail_next].req.address = {proc2Dcache_rd_addr[i][63:3], 3'b0};
        mem_req_queue_next[mem_req_queue_tail_next].req.mem_tag = 4'b0;
        mem_req_queue_next[mem_req_queue_tail_next].req.valid = 1'b1;
        mem_req_queue_next[mem_req_queue_tail_next].req_done = 1'b0;
        mem_req_queue_next[mem_req_queue_tail_next].wr_to_cache = 1'b1;
        mem_req_queue_next[mem_req_queue_tail_next].wr_to_fifo = 1'b0;
        mem_req_queue_tail_next += 1;

        // find position based on lru
        fill_fifo_idx = 0;
        next_lru_idx = 0;
        acc = `NUM_FIFO / 2;

        for (int i = 0; i < `NUM_FIFO_BITS; ++i) begin
          fifo_lru_next[next_lru_idx] = ~fifo_lru_next[next_lru_idx];
          if (~fifo_lru_next[next_lru_idx]) begin
            fill_fifo_idx += acc;
            next_lru_idx = (2 * next_lru_idx) + 2;
          end else begin
            next_lru_idx = (2 * next_lru_idx) + 1;
          end
          acc /= 2;
        end

        next_rd_addr = {proc2Dcache_rd_addr[i][63:3], 3'b0} + 8;

        {fifo_next[fill_fifo_idx][0].tag, fifo_next[fill_fifo_idx][0].idx} = next_rd_addr[31:3];
        fifo_next[fill_fifo_idx][0].data = 64'b0;
        fifo_next[fill_fifo_idx][0].valid = 1'b0;
        fifo_next[fill_fifo_idx][`FIFO_SIZE-1:1] = {(`FIFO_SIZE-1){EMPTY_DCACHE}};
        fetch_stride_next[fill_fifo_idx] = 1;
        fifo_tail_next[fill_fifo_idx] = 0;
        fifo_busy_next[fill_fifo_idx] = 1'b1;
      //update fifo after data is written to cache
      end else if (fifo_hit_num_valid[i] & cache_rd_miss_valid[i]) begin
        //update lru
        next_lru_idx = 0;
        acc = `NUM_FIFO / 2;
        temp_lru_idx = `NUM_FIFO / 2;

        for (int i = 0; i < `NUM_FIFO_BITS; ++i) begin
          if (fifo_hit_num[i] >= temp_lru_idx) begin
            fifo_lru_next[next_lru_idx] = 1'b0;
            next_lru_idx = (2 * next_lru_idx) + 2;
            temp_lru_idx += (acc / 2);
          end else begin
            fifo_lru_next[next_lru_idx] = 1'b1;
            next_lru_idx = (2 * next_lru_idx) + 1;
            temp_lru_idx -= (acc / 2);
          end
          acc /= 2;
        end
      end

      //update fifo
      if(fifo_hit_idx_valid[i]) begin
        fetch_stride_next[fifo_hit_num[i]] += (fetch_stride[fifo_hit_num[i]] * fifo_hit_idx[i]);
        fifo_next[fifo_hit_num[i]] = fifo[fifo_hit_num[i]] >> ((fifo_hit_idx[i]+1)*$bits(DCACHE_FIFO_T));
        fifo_tail_next[fifo_hit_num[i]] -= (fifo_hit_idx[i] + 1);
        //fifo_next[fifo_hit_num][`FIFO_SIZE-1:0] = {{(fifo_hit_idx+1){EMPTY_DCACHE}}, fifo[fifo_hit_num][`FIFO_SIZE-1:(fifo_hit_idx+1)]};
      end
    end

    //send prefetch request to mem_req_queue
    if(!fifo_sel_num_valid & (mem_req_queue_tail_next < `MEM_BUFFER_SIZE)) begin
      next_rd_addr = {32'b0, 
                      fifo_next[fifo_sel_num][fifo_tail_next[fifo_sel_num]].tag, 
                      fifo_next[fifo_sel_num][fifo_tail_next[fifo_sel_num]].idx, 
                      3'b0};
      mem_req_queue_next[mem_req_queue_tail_next].req.address = next_rd_addr;
      mem_req_queue_next[mem_req_queue_tail_next].req.mem_tag = 4'b0;
      mem_req_queue_next[mem_req_queue_tail_next].req.valid = 1'b1;
      mem_req_queue_next[mem_req_queue_tail_next].req_done = 1'b0;
      mem_req_queue_next[mem_req_queue_tail_next].wr_to_cache = 1'b0;
      mem_req_queue_next[mem_req_queue_tail_next].wr_to_fifo = 1'b1;
      mem_req_queue_next[mem_req_queue_tail_next].fifo_num = fifo_sel_num;
      mem_req_queue_next[mem_req_queue_tail_next].fifo_idx = fifo_tail_next[fifo_sel_num];
      mem_req_queue_tail_next += 1;

      fifo_tail_next[fifo_sel_num] += 1;
      if(fifo_tail_next[fifo_sel_num] < `FIFO_SIZE) begin
        next_rd_addr += (fetch_stride_next[fifo_sel_num] << 3);
        {fifo_next[fifo_sel_num][fifo_tail_next[fifo_sel_num]].tag, fifo_next[fifo_sel_num][fifo_tail_next[fifo_sel_num]].idx} = next_rd_addr[31:3];
        fifo_next[fifo_sel_num][fifo_tail_next[fifo_sel_num]].data = 64'b0;
        fifo_next[fifo_sel_num][fifo_tail_next[fifo_sel_num]].valid = 1'b0;
      end
    end

  end

  always_ff @(posedge clock) begin
    if(reset) begin
      for(int i = 0; i < `NUM_FIFO; i += 1) begin
        for(int j = 0; j < `FIFO_SIZE; j += 1) begin
          fifo[i][j] <= `SD EMPTY_DCACHE;
        end
        fifo_tail[i] <= `SD 0;
        fetch_stride[i] <= `SD 0;
      end
      fifo_busy <= `SD 0;
      fifo_lru <= `SD 0;
      //last_PC_in   <= `SD -1;     
      send_request <= `SD 1'b0;
      for(int i = 0; i < `MEM_BUFFER_SIZE; i += 1) begin
        mem_req_queue[i] <= `SD EMPTY_MEM_REQ;
      end
      mem_req_queue_tail   <= `SD 0;
      send_req_ptr    <= `SD 0;
      mem_waiting_ptr <= `SD 0;
      cache_wr_en[RD_PORTS+WR_PORTS] <= `SD 1'b0;
      mem_rd_data <= `SD 64'b0;
    end else begin
      fifo <= `SD fifo_next;
      fifo_tail <= `SD fifo_tail_next;
      fetch_stride <= `SD fetch_stride_next;
      fifo_busy <= `SD fifo_busy_next;
      fifo_lru <= `SD fifo_lru_next;
      //last_PC_in      <= `SD PC_in;
      send_request    <= `SD unanswered_miss;
      mem_req_queue   <= `SD mem_req_queue_next;
      mem_req_queue_tail   <= `SD mem_req_queue_tail_next;
      send_req_ptr    <= `SD send_req_ptr_next;
      mem_waiting_ptr <= `SD mem_waiting_ptr_next;

      if(mem_done) begin
        mem_rd_data <= `SD Dmem2proc_data;
        cache_wr_en[RD_PORTS+WR_PORTS] <= `SD mem_req_queue[mem_waiting_ptr].wr_to_cache;
        Dcache_rd_miss_valid_out <= `SD mem_req_queue[mem_waiting_ptr].wr_to_cache;
      end else begin
        mem_rd_data <= `SD 64'b0;
        cache_wr_en[RD_PORTS+WR_PORTS] <= `SD 1'b0;
        Dcache_rd_miss_valid_out <= `SD 1'b0;
      end
    end
  end

endmodule // dcache