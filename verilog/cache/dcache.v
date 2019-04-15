`include "../../sys_defs.vh"
`define DEBUG

module dcache(
  input clock,
  input reset,

  //////////////
  //  INPUTS  //
  //////////////
  //from mem_stage
  input rd_en,
  input [63:0] proc2Dcache_rd_addr,
  input wr_en,
  input [63:0] proc2Dcache_wr_addr,
  input [63:0] proc2Dcache_wr_data,

  //from main memory
  input [3:0]  Dmem2proc_response,
  input [63:0] Dmem2proc_data,
  input [3:0]  Dmem2proc_tag,

  ///////////////
  //  OUTPUTS  //
  ///////////////
  //to mem_stage
  output logic [63:0] Dcache_data_out, // value is memory[proc2Dcache_addr]
  output logic        Dcache_valid_out, // when this is high

  //to main memory
  output logic [1:0]  proc2Dmem_command,
  output logic [63:0] proc2Dmem_addr,
  output logic [63:0] proc2Dmem_data
);

  //instantiate cachemem module
  //cache memory inputs    
  logic cache_wr_en;
  logic [(`NUM_SET_BITS - 1):0] cache_wr_idx;
  logic [(`NUM_TAG_BITS - 1):0] cache_wr_tag;
  logic [63:0]                  cache_wr_data;
  logic cache_wr_dirty;
  logic cache_rd_addr_en, cache_rd_fifo_en;
  logic [(`NUM_SET_BITS - 1):0] cache_rd_addr_idx, cache_rd_fifo_idx;
  logic [(`NUM_TAG_BITS - 1):0] cache_rd_addr_tag, cache_rd_fifo_tag;

  //cache memory outputs
  logic cache_miss_addr_valid_rd, cache_miss_fifo_valid_rd;
  logic [(`NUM_SET_BITS - 1):0] cache_miss_addr_idx_rd, cache_miss_fifo_idx_rd;
  logic [(`NUM_TAG_BITS - 1):0] cache_miss_addr_tag_rd, cache_miss_fifo_tag_rd;
  logic cache_miss_valid_wr;
  logic [(`NUM_SET_BITS - 1):0] cache_miss_idx_wr;
  logic [(`NUM_TAG_BITS - 1):0] cache_miss_tag_wr;
  logic [63:0]                  cache_rd_addr_data, cache_rd_fifo_data;
  logic cache_rd_addr_valid, cache_rd_fifo_valid;

  assign cache_wr_en = wr_en;
  assign {cache_wr_tag, cache_wr_idx} = wr_en? proc2Dcache_wr_addr[31:3];
  assign cache_wr_data = wr_en? proc2Dcache_wr_data;
  assign cache_wr_dirty = wr_en;

  cachemem memory(
    .clock(clock),
    .reset(reset),

    .wr1_en(cache_wr_en),
    .wr1_idx(cache_wr_idx),
    .wr1_tag(cache_wr_tag),
    .wr1_data(cache_wr_data),
    .wr1_dirty(cache_wr_dirty),

    .rd1_en(cache_rd_addr_en),
    .rd1_idx(cache_rd_addr_idx),
    .rd1_tag(cache_rd_addr_tag),
    .rd2_en(cache_rd_fifo_en),
    .rd2_idx(cache_rd_fifo_idx),
    .rd2_tag(cache_rd_fifo_tag),

    .victim_valid(),
    .victim(),
    .vic_idx(),

    .miss_valid_rd1(cache_miss_addr_valid_rd),
    .miss_idx_rd1(cache_miss_addr_idx_rd),
    .miss_tag_rd1(cache_miss_addr_tag_rd),
    .miss_valid_rd2(cache_miss_fifo_valid_rd),
    .miss_idx_rd2(cache_miss_fifo_idx_rd),
    .miss_tag_rd2(cache_miss_fifo_tag_rd),

    .miss_valid_wr(cache_miss_valid_wr),
    .miss_idx_wr(cache_miss_idx_wr),
    .miss_tag_wr(cache_miss_tag_wr),

    .rd1_data(cache_rd_addr_data),
    .rd1_valid(cache_rd_addr_valid),
    .rd2_data(cache_rd_fifo_data),
    .rd2_valid(cache_rd_fifo_valid)
  );

  //Internal variables
  // logic [(`NUM_DATA_PREFETCH*2):0][63:0] wr_tags;
  // logic [(`NUM_WR_FIFO - 1):0][(`FIFO_SIZE -1):0][63:0] wr_fifo;
  // logic [(`NUM_WR_FIFO - 1):0][(`NUM_SET_BITS - 1):0] wr_index_table;
  // logic [(`NUM_WR_FIFO - 1):0] wr_fifo_hits;
  // logic [(`NUM_WR_FIFO_BITS -1):0] wr_fifo_index;
  // logic [(`NUM_DATA_PREFETCH*2):0][63:0] rd_tags;
  // logic [(`NUM_RD_FIFO - 1):0][(`FIFO_SIZE -1):0] fifo;
  // logic [(`NUM_RD_FIFO - 1):0][(`NUM_SET_BITS - 1):0] rd_index_table;
  // logic [(`NUM_RD_FIFO - 1):0] rd_fifo_hits;
  // logic [(`NUM_RD_FIFO_BITS -1):0] rd_fifo_index;
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


  logic [(`NUM_FIFO-1):0][(`FIFO_SIZE-1):0][[(`NUM_SET_BITS+`NUM_TAG_BITS-1):0] fifo_addr_table_in;
  logic [(`NUM_SET_BITS+`NUM_TAG_BITS-1):0] fifo_cam_tag;
  logic [(`NUM_FIFO-1):0][(`FIFO_SIZE-1):0] fifo_cam_hits;
  wor   [(`NUM_FIFO-1):0] fifo_num_to_encode;
  logic [(`NUM_FIFO_BITS-1):0] fifo_hit_num;
  logic fifo_hit_num_valid;
  logic [(`FIFO_SIZE-1):0] fifo_idx_to_encode;
  logic [(`NUM_FIFO_SIZE_BITS-1):0] fifo_hit_idx;
  logic fifo_hit_idx_valid;

  //Control variables
  logic send_request;

  genvar ig,jg;
  for (ig = 0; ig < `NUM_FIFO; ig += 1) begin
    for (jg = 0; jg < `FIFO_SIZE; jg += 1) begin
      assign fifo_addr_table_in[ig][jg] = {fifo[ig][jg].tag, fifo[ig][jg].idx};
      assign fifo_num_to_encode[ig] = (fifo_cam_hits[ig][ij] & fifo[ig][jg].valid);
    end
  end

  assign fifo_cam_tag = {cache_miss_addr_tag_rd, cache_miss_addr_idx_rd};

  CAM #(.LENGTH(`NUM_FIFO),
      .WIDTH(`FIFO_SIZE),
      .NUM_TAGS(1),
      .TAG_SIZE((`NUM_SET_BITS+`NUM_TAG_BITS))) 
  cam0(
    .enable(cache_miss_addr_valid_rd),
    .tags(fifo_cam_tag),
    .table_in(fifo_addr_table_in),
    .hits(fifo_cam_hits)
  );

  encoder #(.WIDTH(`NUM_FIFO)) 
  fifo_num_enc(
    .in(fifo_num_to_encode),
    .out(fifo_hit_num),
    .valid(fifo_hit_num_valid)
  );

  for(ig = 0; ig < `FIFO_SIZE; ig += 1) begin
    assign fifo_idx_to_encode[ig] = (fifo_cam_hits[fifo_hit_num][ig] & fifo[fifo_hit_num][ig].valid);
  end

  encoder #(.WIDTH(`FIFO_SIZE)) 
  fifo_idx_enc(
    .in(fifo_idx_to_encode),
    .out(fifo_hit_idx),
    .valid(fifo_hit_idx_valid)
  );

  assign cache_wr_en = fifo_hit_idx_valid;
  assign cache_wr_idx = fifo_hit_idx_valid? fifo[fifo_hit_num][fifo_hit_idx].idx : 0;
  assign cache_wr_tag = fifo_hit_idx_valid? fifo[fifo_hit_num][fifo_hit_idx].tag : 0;
  assign cache_wr_data = fifo_hit_idx_valid? fifo[fifo_hit_num][fifo_hit_idx].data : 0;
  assign cache_wr_dirty = 1'b0;

  assign cache_rd_addr_en = rd_en;
  assign {cache_rd_addr_tag, cache_rd_addr_idx} = proc2Dcache_rd_addr[31:3];
  assign Dcache_data_out = cache_rd_addr_data;
  assign Dcache_valid_out = cache_rd_addr_valid;

  assign send_request = send_request? (Dmem2proc_response == 0) :
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
