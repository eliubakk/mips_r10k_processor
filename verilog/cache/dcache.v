`include "../../sys_defs.vh"
`define DEBUG

module dcache(clock, reset,
              rd_en, proc2Dcache_rd_addr,
              wr_en, proc2Dcache_wr_addr, proc2Dcache_wr_data,
              Dmem2proc_response, Dmem2proc_data, Dmem2proc_tag,
              Dcache_data_out, Dcache_valid_out,
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
    logic [3:0] Dmem_tag;
    logic valid;
  } DCACHE_FIFO_T;

  const DCACHE_FIFO_T EMPTY_DCACHE =
  {
    {`NUM_TAG_BITS{1'b0}},
    {`NUM_SET_BITS{1'b0}},
    64'b0,
    4'b0,
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
  output logic [(RD_PORTS-1):0][63:0] Dcache_data_out; // value is memory[proc2Dcache_addr]
  output logic [(RD_PORTS-1):0] Dcache_valid_out; // when this is high

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

  logic [(WR_PORTS+RD_PORTS-1):0] cache_wr_en;
  logic [(WR_PORTS+RD_PORTS-1):0][(`NUM_SET_BITS-1):0] cache_wr_idx;
  logic [(WR_PORTS+RD_PORTS-1):0][(`NUM_TAG_BITS-1):0] cache_wr_tag;
  logic [(WR_PORTS+RD_PORTS-1):0][63:0] cache_wr_data;
  logic [(WR_PORTS+RD_PORTS-1):0] cache_wr_dirty;

  //cache memory outputs
  logic [RD_PORTS:0][63:0] cache_rd_data;
  logic [RD_PORTS:0] cache_rd_valid;
  logic [RD_PORTS:0][(`NUM_SET_BITS-1):0] cache_rd_miss_idx;
  logic [RD_PORTS:0][(`NUM_TAG_BITS-1):0] cache_rd_miss_tag;
  logic [RD_PORTS:0] cache_rd_miss_valid;

  logic [(WR_PORTS+RD_PORTS-1):0][(`NUM_SET_BITS-1):0] cache_wr_miss_idx;
  logic [(WR_PORTS+RD_PORTS-1):0][(`NUM_TAG_BITS-1):0] cache_wr_miss_tag;
  logic [(WR_PORTS+RD_PORTS-1):0] cache_wr_miss_valid;

  cachemem #(
    .NUM_WAYS(NUM_WAYS),
    .RD_PORTS(RD_PORTS+1),
    .WR_PORTS(WR_PORTS+RD_PORTS)) 
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
  logic [(`NUM_FIFO-2):0] fifo_lru, fifo_lru_next;
  logic [($clog(`NUM_FIFO-1)-1):0] next_lru_idx;
  logic [(`NUM_FIFO_BITS-1):0] fill_fifo_idx;
  logic [(`NUM_FIFO_BITS-1):0] temp_lru_idx;
  logic [(`NUM_FIFO_BITS-1):0] acc;
  logic [63:0] next_rd_addr;

  DCACHE_MEM_REQ_T [] mem_req_queue;




  logic [(`NUM_FIFO-1):0][(`FIFO_SIZE-1):0][[(`NUM_SET_BITS+`NUM_TAG_BITS-1):0] fifo_addr_table_in;
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

  //Instantiate CAM to check for rd address in fifo
  genvar ig, jg, kg;
  for(ig = 0; ig < `NUM_FIFO; ig += 1) begin
    for(jg = 0; jg < `FIFO_SIZE; jg += 1) begin
      assign fifo_addr_table_in[ig][jg] = {fifo[ig][jg].tag, fifo[ig][jg].idx};
      for(kg = 0; kg < RD_PORTS; kg += 1) begin
        assign fifo_num_to_encode[kg][ig] = (fifo_cam_hits[ig][jg][kg] & fifo[ig][jg].valid);
      end
    end
  end

  for(ig = 0; ig < RD_PORTS; ig += 1) begin
    assign fifo_cam_tags[ig] = {cache_rd_miss_tag[ig], cache_rd_miss_idx[ig]};
  end

  CAM #(.LENGTH(`NUM_FIFO),
      .WIDTH(`FIFO_SIZE),
      .NUM_TAGS(RD_PORTS),
      .TAG_SIZE((`NUM_SET_BITS+`NUM_TAG_BITS))) 
  cam0(
    .enable(cache_rd_miss_valid),
    .tags(fifo_cam_tags),
    .table_in(fifo_addr_table_in),
    .hits(fifo_cam_hits)
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
    assign Dcache_data_out[ig] = cache_rd_data[ig];
    assign Dcache_valid_out[ig] = cache_rd_valid[ig];
  end

  assign unanswered_miss = send_request? (Dmem2proc_response == 0) :
                                      !fifo_hit_num_valid & cache_miss_addr_valid_rd;

  assign proc2Dmem_command = send_request? BUS_LOAD :
                                           BUS_NONE;
  assign proc2Dmem_addr = send_request? proc2Dcache_rd_addr : 64'b0;

  always_comb begin
    fifo_next = fifo;
    fetch_stride_next = fetch_stride;
    fifo_tail_next = fifo_tail;
    fifo_busy_next = fifo_busy;
    fifo_lru_next = fifo_lru;

    //allocate new fifo
    if(!fifo_hit_num_valid & cache_miss_addr_valid_rd) begin
      // find position based on lru
      fill_fifo_idx = 0;
      next_lru_idx = 0;
      acc = `NUM_FIFO / 2;

      for (int i = 0; i < NUM_FIFO_BITS; ++i) begin
        fifo_lru_next[next_lru_idx] = ~fifo_lru_next[next_lru_idx];
        if (~fifo_lru_next[next_lru_idx]) begin
          fill_fifo_idx += acc;
          next_lru_idx = (2 * next_lru_idx) + 2;
        end else begin
          next_lru_idx = (2 * next_lru_idx) + 1;
        end
        acc /= 2;
      end

      next_rd_addr = {proc2Dcache_rd_addr[63:3], 3'b0} + 8;

      {fifo_next[fill_fifo_idx][0].tag, fifo_next[fill_fifo_idx][0].idx} = next_rd_addr[31:3];
      fifo_next[fill_fifo_idx][0].data = 64'b0;
      fifo_next[fill_fifo_idx][0].Dmem_tag = 4'b0;
      fifo_next[fill_fifo_idx][0].valid = 1'b0;
      fifo_next[fill_fifo_idx][`FIFO_SIZE-1:1] = {(`FIFO_SIZE-1){EMPTY_DCACHE}};
      fetch_stride_next[fill_fifo_idx] = 1;
      fifo_tail_next[fill_fifo_idx] = 0;
      fifo_busy_next[fill_fifo_idx] = 1'b1;
    //update fifo after data is written to cache
    end else if (fifo_hit_num_valid & cache_miss_addr_valid_rd) begin
      //update lru
      next_lru_idx = 0;
      acc = `NUM_FIFO / 2;
      temp_lru_idx = `NUM_FIFO / 2;

      for (int i = 0; i < NUM_FIFO_BITS; ++i) begin
        if (fifo_hit_num >= temp_lru_idx) begin
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

      //update fifo
      if(fifo_hit_idx_valid) begin
        fetch_stride_next[fifo_hit_num] += (fetch_stride[fifo_hit_num] * fifo_hit_idx);
        fifo_next[fifo_hit_num] = fifo[fifo_hit_num] >> ((fifo_hit_idx+1)*$bits(DCACHE_FIFO_T));
        fifo_tail_next[fifo_hit_num] -= (fifo_hit_idx + 1);
        //fifo_next[fifo_hit_num][`FIFO_SIZE-1:0] = {{(fifo_hit_idx+1){EMPTY_DCACHE}}, fifo[fifo_hit_num][`FIFO_SIZE-1:(fifo_hit_idx+1)]};
      end
    end

    if()
  end



  always_ff @(posedge clock) begin
    if (reset) begin
      test <= `SD 0;
    end
  end

endmodule // dcache