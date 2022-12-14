`include "../../sys_defs.vh"
`define DEBUG

module dcache(clock, reset,
              rd_en, proc2Dcache_rd_addr,
              wr_en, proc2Dcache_wr_addr, proc2Dcache_wr_data,
              Dmem2proc_response, Dmem2proc_data, Dmem2proc_tag,
              //send_request_out, unanswered_miss_out,
              Dcache_rd_data_out, Dcache_rd_valid_out,
              Dcache_rd_miss_addr_out, Dcache_rd_miss_data_out, Dcache_rd_miss_valid_out,
              proc2Dmem_command, proc2Dmem_addr, proc2Dmem_data,
              evicted, evicted_valid, sets_out);
  parameter RD_PORTS = 1;
  parameter WR_PORTS = 1;
  
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
  input MEM_TAG_T  Dmem2proc_response;
  input [63:0] Dmem2proc_data;
  input MEM_TAG_T  Dmem2proc_tag;

  ///////////////
  //  OUTPUTS  //
  ///////////////
  // for synthesis debugging
  //output logic		send_request_out;
  //output logic		unanswered_miss_out;  


  //to mem_stage
  output logic [(RD_PORTS-1):0][63:0] Dcache_rd_data_out; // value is memory[proc2Dcache_rd_addr]
  output logic [(RD_PORTS-1):0] Dcache_rd_valid_out; // when this is high
  output logic [63:0] Dcache_rd_miss_addr_out;
  output logic [63:0] Dcache_rd_miss_data_out; // value is memory[proc2Dcache_rd_addr]
  output logic Dcache_rd_miss_valid_out; 

  //to main memory
  output BUS_COMMAND  proc2Dmem_command;
  output logic [63:0] proc2Dmem_addr;
  output logic [63:0] proc2Dmem_data;

	output CACHE_SET_T [(`NUM_SETS-1):0] sets_out;

  //to retirement buffer
  output VIC_CACHE_T [(WR_PORTS):0] evicted;
  output logic [(WR_PORTS):0] evicted_valid;

  ///////////////////////////////////////////////////
  //***********************************************//
  ///////////////////////////////////////////////////

  //////////////
  //  MODULE  //
  //////////////
  //instantiate cachemem module
  //cache memory inputs    
  logic [(RD_PORTS-1):0] cache_rd_en;
  SET_IDX_T [(RD_PORTS-1):0] cache_rd_idx;
  TAG_T     [(RD_PORTS-1):0] cache_rd_tag;

  logic [(WR_PORTS):0] cache_wr_en;
  SET_IDX_T [(WR_PORTS):0] cache_wr_idx;
  TAG_T     [(WR_PORTS):0] cache_wr_tag;
  logic [(WR_PORTS):0][63:0] cache_wr_data;
  logic [(WR_PORTS):0] cache_wr_dirty;

  //cache memory outputs
  logic [(RD_PORTS-1):0][63:0] cache_rd_data;
  logic [(RD_PORTS-1):0] cache_rd_valid;
  SET_IDX_T [(RD_PORTS-1):0] cache_rd_miss_idx;
  TAG_T     [(RD_PORTS-1):0] cache_rd_miss_tag;
  logic [(RD_PORTS-1):0] cache_rd_miss_valid;

  SET_IDX_T [(WR_PORTS):0] cache_wr_miss_idx;
  TAG_T     [(WR_PORTS):0] cache_wr_miss_tag;
  logic [(WR_PORTS):0] cache_wr_miss_valid;

  //victim cache inputs
  SET_IDX_T [(WR_PORTS):0] victim_idx;
  CACHE_LINE_T [(WR_PORTS):0] victim;
  logic [(WR_PORTS):0] victim_valid;
  //logic [(WR_PORTS+RD_PORTS-1):0] vic_rd_en;
  //logic [(WR_PORTS+RD_PORTS-1):0][(`NUM_SET_BITS-1):0] vic_rd_idx;
  //logic [(WR_PORTS+RD_PORTS-1):0][(`NUM_TAG_BITS-1):0] vic_rd_tag;

  //victim cache outputs
  //VIC_CACHE_T [(WR_PORTS):0] vic_rd_out;
  //logic [(WR_PORTS):0] vic_rd_valid;

  cachemem #(
    .RD_PORTS(RD_PORTS),
    .WR_PORTS(WR_PORTS+1)) 
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

	  .sets_out(sets_out),

    .rd_data(cache_rd_data),
    .rd_valid(cache_rd_valid),
    .rd_miss_idx(cache_rd_miss_idx),
    .rd_miss_tag(cache_rd_miss_tag),
    .rd_miss_valid(cache_rd_miss_valid),

    .wr_miss_idx(cache_wr_miss_idx),
    .wr_miss_tag(cache_wr_miss_tag),
    .wr_miss_valid(cache_wr_miss_valid),

    .vic_idx(victim_idx),
    .victim(victim),
    .victim_valid(victim_valid)
  );



  // vic_cache #(
  //   .NUM_WAYS(NUM_WAYS),
  //   .RD_PORTS(WR_PORTS+RD_PORTS),
  //   .WR_PORTS(WR_PORTS+RD_PORTS+1))
  // victim_memory(
  //   .clock(clock),
  //   .reset(reset),

  //   //inputsc
  //   .vic_idx      (victim_idx),
  //   .vic          (victim),
  //   .vic_valid    (victim_valid),
  //   .rd_en        (vic_rd_en),
  //   .rd_idx       (vic_rd_idx),
  //   .rd_tag       (vic_rd_tag),

  //   //outputs
  //   .evicted_vic  (evicted),
  //   .evicted_valid(evicted_valid),
  //   .rd_vic       (vic_rd_out),
  //   .rd_valid     (vic_rd_valid)
  // );
  
  //Internal variables

  //fifo state variables
  // DCACHE_FIFO_T [(`NUM_FIFO-1):0][(`FIFO_SIZE-1):0] fifo, fifo_next;
  // logic [(`NUM_FIFO-1):0][2:0] fetch_stride, fetch_stride_next;
  // logic [(`NUM_FIFO-1):0][63:0] fifo_fetch_addr, fifo_fetch_addr_next;
  // logic [(`NUM_FIFO-1):0][`NUM_FIFO_SIZE_BITS:0] fifo_tail, fifo_tail_next;
  // logic [(`NUM_FIFO-1):0][`NUM_FIFO_SIZE_BITS:0] fifo_filled, fifo_filled_next;
  // logic [(`NUM_FIFO-1):0] fifo_busy, fifo_busy_next;

  //fifo fill logic variables
  // logic [(`NUM_FIFO-1):0] fifo_sel_req, fifo_sel_gnt;
  // logic [(`NUM_FIFO_BITS-1):0] fifo_sel_num;
  // logic fifo_sel_num_valid;

  //fifo lru update logic variables
  // logic [(`NUM_FIFO-2):0] fifo_lru, fifo_lru_next;
  // logic [($clog2(`NUM_FIFO-1)-1):0] next_lru_idx;
  // logic [(`NUM_FIFO_BITS-1):0] fill_fifo_idx;
  // logic [(`NUM_FIFO_BITS-1):0] temp_lru_idx;
  // logic [(`NUM_FIFO_BITS-1):0] acc;
  //logic [63:0] next_rd_addr;

  //memory request buffer variables
  DCACHE_MEM_REQ_T [(`MEM_BUFFER_SIZE-1):0] mem_req_queue, mem_req_queue_next;
  logic [`MEM_BUFFER_SIZE_BITS:0] mem_req_queue_tail, mem_req_queue_tail_next;
  logic [`MEM_BUFFER_SIZE_BITS:0] send_req_ptr, send_req_ptr_next;
  logic [`MEM_BUFFER_SIZE_BITS:0] mem_waiting_ptr, mem_waiting_ptr_next;

  //memory buffer search variables
  logic [(`MEM_BUFFER_SIZE-1):0][0:0][63:0] mem_queue_cam_table_in;
  logic [(RD_PORTS-1):0][63:0] mem_queue_cam_tags;
  logic [(`MEM_BUFFER_SIZE-1):0][0:0][(RD_PORTS-1):0] mem_queue_cam_hits;
  logic [(RD_PORTS-1):0][(`MEM_BUFFER_SIZE-1):0] mem_queue_hits;
  logic [(RD_PORTS-1):0][(`MEM_BUFFER_SIZE_BITS-1):0] mem_queue_hit_num;
  logic [(RD_PORTS-1):0] mem_queue_hit_num_valid;

  //fifo next fetch address search variables
  // logic [(`NUM_FIFO-1):0][0:0][63:0] fetch_addr_cam_table_in;
  // logic [(RD_PORTS+WR_PORTS-1):0][63:0] fetch_addr_cam_tags;
  // logic [(`NUM_FIFO-1):0][0:0][(RD_PORTS+WR_PORTS-1):0] fetch_addr_cam_hits;
  // logic [(RD_PORTS+WR_PORTS-1):0][(`NUM_FIFO-1):0] fetch_addr_hits;
  // logic [(RD_PORTS+WR_PORTS-1):0][(`NUM_FIFO_SIZE_BITS-1):0] fetch_addr_hit_num;
  // logic [(RD_PORTS+WR_PORTS-1):0] fetch_addr_hit_num_valid;

  //fifo search variables
  // logic [(`NUM_FIFO-1):0][(`FIFO_SIZE-1):0][(`NUM_SET_BITS+`NUM_TAG_BITS-1):0] fifo_addr_table_in;
  // logic [(RD_PORTS+WR_PORTS-1):0][(`NUM_SET_BITS+`NUM_TAG_BITS-1):0] fifo_cam_tags;
  // logic [(`NUM_FIFO-1):0][(`FIFO_SIZE-1):0][(RD_PORTS+WR_PORTS-1):0] fifo_cam_hits;
  // wor   [(RD_PORTS+WR_PORTS-1):0][(`NUM_FIFO-1):0] fifo_num_hits;
  // logic [(RD_PORTS+WR_PORTS-1):0][(`NUM_FIFO_BITS-1):0] fifo_hit_num;
  // logic [(RD_PORTS+WR_PORTS-1):0] fifo_hit_num_valid;
  // logic [(RD_PORTS+WR_PORTS-1):0][(`FIFO_SIZE-1):0] fifo_idx_hits;
  // logic [(RD_PORTS+WR_PORTS-1):0][(`NUM_FIFO_SIZE_BITS-1):0] fifo_hit_idx;
  // logic [(RD_PORTS+WR_PORTS-1):0] fifo_hit_idx_valid;

  //Control variables
  logic send_request;
  logic unanswered_miss;
  logic update_mem_tag;
  logic mem_done;
  logic [63:0] mem_rd_data;
  logic [(RD_PORTS-1):0] add_rd_to_queue;
  //wor [(`NUM_FIFO-1):0] update_fifo_lru;
  //wor [(`NUM_FIFO-1):0] update_fifo_fetch_addr;


  // Debugging for synth
  assign send_request_out = send_request;
  assign unanswered_miss_out = unanswered_miss;
  logic sendreq_miss;


  //Instantiate CAM to check for rd address in fifo
  genvar ig, jg, kg;
  // for(ig = 0; ig < `NUM_FIFO; ig += 1) begin
  //   //fifo CAM
  //   for(jg = 0; jg < `FIFO_SIZE; jg += 1) begin
  //     assign fifo_addr_table_in[ig][jg] = {fifo[ig][jg].tag, fifo[ig][jg].idx};
  //     for(kg = 0; kg < RD_PORTS+WR_PORTS; kg += 1) begin
  //       assign fifo_num_hits[kg][ig] = (fifo_cam_hits[ig][jg][kg] & fifo[ig][jg].valid);
  //       //update lru if any address was found
  //       assign update_fifo_lru[ig] = (fifo_cam_hits[ig][jg][kg] & fifo[ig][jg].valid);
  //     end
  //   end

  //   //fetch addr CAM
  //   assign fetch_addr_cam_table_in[ig][0] = fifo_fetch_addr[ig];
  //   for(jg = 0; jg < RD_PORTS+WR_PORTS; jg += 1) begin
  //     assign fetch_addr_hits[jg][ig] = (fetch_addr_cam_hits[ig][0][jg] & fifo_busy[ig]);
  //     //update lru and fetch addr if any address was found
  //     assign update_fifo_lru[ig] = (fetch_addr_cam_hits[ig][0][jg] & fifo_busy[ig]);
  //     assign update_fifo_fetch_addr[ig] = (fetch_addr_cam_hits[ig][0][jg] & fifo_busy[ig]);
  //   end

  //   //if fifo not full and allocated, request send to memory
  //   assign fifo_sel_req[ig] = fifo_busy[ig] & (fifo_tail[ig] < `FIFO_SIZE); 
  // end

  //mem queue CAM
  for(ig = 0; ig < `MEM_BUFFER_SIZE; ig += 1) begin
    assign mem_queue_cam_table_in[ig][0] = mem_req_queue[ig].req.address;
    for(jg = 0; jg < RD_PORTS; jg += 1) begin
      assign mem_queue_hits[jg][ig] = (mem_queue_cam_hits[ig][0][jg] & mem_req_queue[ig].req.valid);
    end
  end

  //search for rd address
  for(ig = 0; ig < RD_PORTS; ++ig) begin
    //assign fifo_cam_tags[ig] = {cache_rd_tag[ig], cache_rd_idx[ig]};
    //assign fetch_addr_cam_tags[ig] = {proc2Dcache_rd_addr[ig][63:3], 3'b0};
    assign mem_queue_cam_tags[ig] = {proc2Dcache_rd_addr[ig][63:3], 3'b0};
  end

  //search for wr address in fifo
  // for(ig = 0; ig < WR_PORTS; ++ig) begin
  //   assign fifo_cam_tags[ig+RD_PORTS] = {cache_wr_tag[ig], cache_wr_idx[ig]};
  //   assign fetch_addr_cam_tags[ig+RD_PORTS] = {proc2Dcache_wr_addr[ig][63:3], 3'b0};
  // end

  // CAM #(.LENGTH(`NUM_FIFO),
  //     .WIDTH(`FIFO_SIZE),
  //     .NUM_TAGS(RD_PORTS+WR_PORTS),
  //     .TAG_SIZE((`NUM_SET_BITS+`NUM_TAG_BITS))) 
  //  fifo_cam(
  //   .enable({wr_en, rd_en}),
  //   .tags(fifo_cam_tags),
  //   .table_in(fifo_addr_table_in),
  //   .hits(fifo_cam_hits)
  // );

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

  // CAM #(.LENGTH(`NUM_FIFO),
  //     .WIDTH(1),
  //     .NUM_TAGS(RD_PORTS+WR_PORTS),
  //     .TAG_SIZE(64)) 
  // fetch_addr_cam(
  //   .enable({wr_en, rd_en}),
  //   .tags(fetch_addr_cam_tags),
  //   .table_in(fetch_addr_cam_table_in),
  //   .hits(fetch_addr_cam_hits)
  // );

  // //priority selector and encoder for prefetching
  // psel_rotating #(.WIDTH(`NUM_FIFO)) 
  // fifo_psel(
  //   .clock(clock),
  //   .reset(reset),
  //   .req(fifo_sel_req),
  //   .en((mem_req_queue_tail < `MEM_BUFFER_SIZE)),
  //   .gnt(fifo_sel_gnt)
  // );

  // encoder #(.WIDTH(`NUM_FIFO)) 
  // fifo_sel_enc(
  //   .in(fifo_sel_gnt),
  //   .out(fifo_sel_num),
  //   .valid(fifo_sel_num_valid)
  // );

  //fifo search encoders
  // for(ig = 0; ig < RD_PORTS+WR_PORTS; ig += 1) begin
  //   encoder #(.WIDTH(`NUM_FIFO)) 
  //   fifo_num_enc(
  //     .in(fifo_num_hits[ig]),
  //     .out(fifo_hit_num[ig]),
  //     .valid(fifo_hit_num_valid[ig])
  //   );

  //   for(jg = 0; jg < `FIFO_SIZE; jg += 1) begin
  //     assign fifo_idx_hits[ig][jg] = (fifo_cam_hits[fifo_hit_num[ig]][jg][ig] & fifo[fifo_hit_num[ig]][jg].valid);
  //   end
  //   encoder #(.WIDTH(`FIFO_SIZE)) 
  //   fifo_idx_enc(
  //     .in(fifo_idx_hits[ig]),
  //     .out(fifo_hit_idx[ig]),
  //     .valid(fifo_hit_idx_valid[ig])
  //   );

  //   encoder #(.WIDTH(`NUM_FIFO))
  //   fetch_addr_enc(
  //     .in(fetch_addr_hits[ig]),
  //     .out(fetch_addr_hit_num[ig]),
  //     .valid(fetch_addr_hit_num_valid[ig])
  //   );
  // end

  //mem queue search encoders
  for(ig = 0; ig < RD_PORTS; ++ig) begin
    encoder #(.WIDTH(`MEM_BUFFER_SIZE)) 
    mem_queue_num_enc(
      .in(mem_queue_hits[ig]),
      .out(mem_queue_hit_num[ig]),
      .valid(mem_queue_hit_num_valid[ig])
    );
  end

  //cache input logic
  for(ig = 0; ig < WR_PORTS; ig += 1) begin
    //requested wr
    assign cache_wr_en[1+ig] = wr_en[ig];
    assign {cache_wr_tag[1+ig], cache_wr_idx[1+ig]} = proc2Dcache_wr_addr[ig][(`MEM_ADDR_BITS-1):3];
    assign cache_wr_data[1+ig] = proc2Dcache_wr_data[ig];
    assign cache_wr_dirty[1+ig] = 1'b1;

    //remove wr's from vic cache
    //assign vic_rd_en[RD_PORTS+ig] = wr_en[ig];
    //assign {vic_rd_tag[RD_PORTS+ig], vic_rd_idx[RD_PORTS+ig]} = proc2Dcache_wr_addr[ig][31:3];
  end

  for(ig = 0; ig < RD_PORTS; ig += 1) begin
    //wr from victim cache or fifo if rd miss found
    // assign cache_wr_en[1+ig]     = vic_rd_valid[ig] | fifo_hit_idx_valid[ig];
    // assign cache_wr_idx[1+ig]    = vic_rd_valid[ig]? vic_rd_out[ig].idx :
    //                                                         fifo[fifo_hit_num[ig]][fifo_hit_idx[ig]].idx;
    // assign cache_wr_tag[1+ig]    = vic_rd_valid[ig]? vic_rd_out[ig].line.tag :
    //                                                         fifo[fifo_hit_num[ig]][fifo_hit_idx[ig]].tag;
    // assign cache_wr_data[1+ig]   = vic_rd_valid[ig]? vic_rd_out[ig].line.data :
    //                                                         fifo[fifo_hit_num[ig]][fifo_hit_idx[ig]].data;
    // assign cache_wr_dirty[1+ig]  = vic_rd_valid[ig]? vic_rd_out[ig].line.dirty :
    //                                                         fifo[fifo_hit_num[ig]][fifo_hit_idx[ig]].dirty;

    //requested rd
    assign cache_rd_en[ig] = rd_en[ig];
    assign {cache_rd_tag[ig], cache_rd_idx[ig]} = proc2Dcache_rd_addr[ig][(`MEM_ADDR_BITS-1):3];
    assign Dcache_rd_data_out[ig] = cache_rd_data[ig];
    assign Dcache_rd_valid_out[ig] = cache_rd_valid[ig];

    //check vic cache for rd's
    //assign vic_rd_en[ig]  = rd_en[ig];
    //assign {vic_rd_tag[ig], vic_rd_idx[ig]} = proc2Dcache_rd_addr[ig][31:3];
  end

  for(ig = 0; ig <= WR_PORTS; ++ig) begin
    assign evicted[ig].line = victim[ig];
    assign evicted[ig].idx = victim_idx[ig];
    assign evicted_valid[ig] = victim_valid[ig];
  end

  //send rd request from queue to memory
  assign unanswered_miss = send_request? (Dmem2proc_response == 0) :
                                         (send_req_ptr < mem_req_queue_tail);// | 
                                          //(~(|cache_wr_en[(WR_PORTS+RD_PORTS-1)-:RD_PORTS]) & (|cache_rd_miss_valid));

  assign proc2Dmem_addr = send_request? mem_req_queue[send_req_ptr].req.address :
                                        64'b0;
  assign proc2Dmem_command = send_request? BUS_LOAD :
                                           BUS_NONE;
  
  assign mem_done = (mem_req_queue[mem_waiting_ptr].req.mem_tag == Dmem2proc_tag) &&
                    (mem_req_queue[mem_waiting_ptr].req.mem_tag != 0);

  //write from memory
  assign {cache_wr_tag[0], cache_wr_idx[0]} = mem_req_queue[0].req.address[(`MEM_ADDR_BITS-1):3];
  assign cache_wr_dirty[0] = 1'b0;
  assign cache_wr_data[0] = mem_rd_data;

  //send rd data from memory to LQ
  //not valid if we fetched from memory for fifo buffers 
  assign Dcache_rd_miss_addr_out = mem_req_queue[0].req.address;
  assign Dcache_rd_miss_data_out = mem_rd_data;

  //request accepted by main memory
  assign update_mem_tag = send_request? (Dmem2proc_response != 0) : 1'b0;

  always_comb begin
    mem_req_queue_next = mem_req_queue;
    mem_req_queue_tail_next = mem_req_queue_tail;
    send_req_ptr_next = send_req_ptr;
    mem_waiting_ptr_next = mem_waiting_ptr;
    // fifo_next = fifo;
    // fetch_stride_next = fetch_stride;
    // fifo_fetch_addr_next = fifo_fetch_addr;
    // fifo_tail_next = fifo_tail;
    // fifo_filled_next = fifo_filled;
    // fifo_busy_next = fifo_busy;
    // fifo_lru_next = fifo_lru;

    //read already in mem_queue, if it was to be written to fifo, change it to cache
    // for(int i = 0; i < RD_PORTS; i += 1) begin
    //   if(mem_queue_hit_num_valid[i]) begin
    //     //was going to write to fifo, write to cache instead, and update fifo
    //     if(mem_req_queue_next[mem_queue_hit_num[i]].wr_to_fifo) begin
    //       mem_req_queue_next[mem_queue_hit_num[i]].wr_to_cache = 1'b1;
    //       mem_req_queue_next[mem_queue_hit_num[i]].wr_to_fifo = 1'b0;
    //       fifo_tail_next[mem_req_queue_next[mem_queue_hit_num[i]].fifo_num] -= 1;
    //     end
    //   end
    // end

    //update values in request queue
    if(mem_done) begin
      mem_req_queue_next[mem_waiting_ptr_next].req_done = 1'b1;
      mem_waiting_ptr_next += 1;
    end

    if(update_mem_tag) begin
      mem_req_queue_next[send_req_ptr_next].req.mem_tag = Dmem2proc_response;
      send_req_ptr_next += 1;
    end

    //remove from queue and write to fifo if selected
    if(mem_req_queue[0].req_done) begin
      // if(mem_req_queue[0].wr_to_fifo) begin
      //   {fifo_next[mem_req_queue[0].fifo_num][fifo_filled_next[mem_req_queue[0].fifo_num]].tag,
      //    fifo_next[mem_req_queue[0].fifo_num][fifo_filled_next[mem_req_queue[0].fifo_num]].idx} = mem_req_queue[0].req.address[63:3];
      //    fifo_next[mem_req_queue[0].fifo_num][fifo_filled_next[mem_req_queue[0].fifo_num]].data = mem_rd_data;
      //    fifo_next[mem_req_queue[0].fifo_num][fifo_filled_next[mem_req_queue[0].fifo_num]].valid = 1'b1;
      //    fifo_filled_next[mem_req_queue[0].fifo_num] += 1;
      // end
      mem_req_queue_next[`MEM_BUFFER_SIZE-1:0] = {EMPTY_DCACHE_MEM_REQ, mem_req_queue_next[`MEM_BUFFER_SIZE-1:1]};
      mem_req_queue_tail_next -= 1;
      if(send_req_ptr_next > 0) begin
        send_req_ptr_next -= 1;
      end
      //if(mem_waiting_ptr > 0) begin
        mem_waiting_ptr_next -= 1;
      //end
    end

    //check for rd/wr address that were found in the fifo's
    // for(int i = 0; i < `NUM_FIFO; ++i) begin
    //   //update lru if fifo is used
    //   if(update_fifo_lru[i]) begin
    //     next_lru_idx = 0;
    //     acc = `NUM_FIFO / 2;
    //     temp_lru_idx = `NUM_FIFO / 2;

    //     for (int j = 0; j < `NUM_FIFO_BITS; ++j) begin
    //       if (i >= temp_lru_idx) begin
    //         fifo_lru_next[next_lru_idx] = 1'b0;
    //         next_lru_idx = (2 * next_lru_idx) + 2;
    //         temp_lru_idx += (acc / 2);
    //       end else begin
    //         fifo_lru_next[next_lru_idx] = 1'b1;
    //         next_lru_idx = (2 * next_lru_idx) + 1;
    //         temp_lru_idx -= (acc / 2);
    //       end
    //       acc /= 2;
    //     end
    //   end

    //   //update fetch addr if address to be fetched was rd/wr
    //   if(update_fifo_fetch_addr[i]) begin
    //     fifo_fetch_addr_next[i] += (fetch_stride_next[i] << 3);
    //   end
    // end

    //add rd miss to mem_req_queue if not already in it
    for(int i = 0; i < RD_PORTS; i += 1) begin
      //add_rd_to_queue[i] = cache_rd_miss_valid[i] & ~vic_rd_valid[i] & ~fifo_hit_num_valid[i] & ~(|mem_queue_hits[i]);
      add_rd_to_queue[i] = cache_rd_miss_valid[i] & ~(|mem_queue_hits[i]);
      //add rd miss to req_queue
      if(add_rd_to_queue[i] & (mem_req_queue_tail_next < `MEM_BUFFER_SIZE)) begin
        mem_req_queue_next[mem_req_queue_tail_next].req.address = {proc2Dcache_rd_addr[i][63:3], 3'b0};
        mem_req_queue_next[mem_req_queue_tail_next].req.mem_tag = `EMPTY_MEM_TAG;
        mem_req_queue_next[mem_req_queue_tail_next].req.valid = 1'b1;
        mem_req_queue_next[mem_req_queue_tail_next].req_done = 1'b0;
        mem_req_queue_next[mem_req_queue_tail_next].wr_to_cache = 1'b1;
        mem_req_queue_next[mem_req_queue_tail_next].wr_to_fifo = 1'b0;
        mem_req_queue_tail_next += 1;

        //if address was not about to be fetched by fifo, allocate new fifo
      //   if(~fetch_addr_hit_num_valid[i]) begin
      //     // find position based on lru
      //     fill_fifo_idx = 0;
      //     next_lru_idx = 0;
      //     acc = `NUM_FIFO / 2;

      //     for (int i = 0; i < `NUM_FIFO_BITS; ++i) begin
      //       fifo_lru_next[next_lru_idx] = ~fifo_lru_next[next_lru_idx];
      //       if (~fifo_lru_next[next_lru_idx]) begin
      //         fill_fifo_idx += acc;
      //         next_lru_idx = (2 * next_lru_idx) + 2;
      //       end else begin
      //         next_lru_idx = (2 * next_lru_idx) + 1;
      //       end
      //       acc /= 2;
      //     end

      //     fifo_next[fill_fifo_idx][`FIFO_SIZE-1:0] = {(`FIFO_SIZE){EMPTY_DCACHE}};
      //     fetch_stride_next[fill_fifo_idx] = 1;
      //     fifo_fetch_addr_next[fill_fifo_idx] = {proc2Dcache_rd_addr[i][63:3], 3'b0} + 8;
      //     fifo_tail_next[fill_fifo_idx] = 0;
      //     fifo_filled_next[fill_fifo_idx] = 0;
      //     fifo_busy_next[fill_fifo_idx] = 1'b1;
      //   end
      end
    end

    //update data in fifo if written to cache
    // for(int i = RD_PORTS; i < RD_PORTS+WR_PORTS; ++i) begin
    //   if(fifo_hit_idx_valid[i]) begin
    //     fifo_next[fifo_hit_num[i]][fifo_hit_idx[i]].dirty = 1'b1;
    //     fifo_next[fifo_hit_num[i]][fifo_hit_idx[i]].data = proc2Dcache_wr_data[i-RD_PORTS];
    //     //fifo_tail_next[fifo_hit_num[i]] -= (fifo_hit_idx[i] + 1);
    //     //fifo_filled_next[fifo_hit_num[i]] -= (fifo_hit_idx[i] + 1);
    //     //fifo_next[fifo_hit_num][`FIFO_SIZE-1:0] = {{(fifo_hit_idx+1){EMPTY_DCACHE}}, fifo[fifo_hit_num][`FIFO_SIZE-1:(fifo_hit_idx+1)]};
    //   end
    // end

    // for(int i = 0; i < RD_PORTS; ++i) begin
    //   //remove rd addr if it was in fifo
    //   if(fifo_hit_idx_valid[i]) begin
    //     fetch_stride_next[fifo_hit_num[i]] += (fetch_stride[fifo_hit_num[i]] * fifo_hit_idx[i]);
    //     fifo_next[fifo_hit_num[i]] = fifo_next[fifo_hit_num[i]] >> ((fifo_hit_idx[i]+1)*$bits(DCACHE_FIFO_T));
    //     fifo_tail_next[fifo_hit_num[i]] -= (fifo_hit_idx[i] + 1);
    //     fifo_filled_next[fifo_hit_num[i]] -= (fifo_hit_idx[i] + 1);
    //     //fifo_next[fifo_hit_num][`FIFO_SIZE-1:0] = {{(fifo_hit_idx+1){EMPTY_DCACHE}}, fifo[fifo_hit_num][`FIFO_SIZE-1:(fifo_hit_idx+1)]};
    //   end
    // end

    //send prefetch request to mem_req_queue
    // if(~update_fifo_fetch_addr[fifo_sel_num] & (fifo_tail[fifo_sel_num] < `FIFO_SIZE) & fifo_sel_num_valid & (mem_req_queue_tail_next < `MEM_BUFFER_SIZE)) begin
    //   // fifo_fetch_addr[fifo_sel_num]
    //   // next_rd_addr = {32'b0, 
    //   //                 fifo_next[fifo_sel_num][fifo_tail_next[fifo_sel_num]].tag, 
    //   //                 fifo_next[fifo_sel_num][fifo_tail_next[fifo_sel_num]].idx, 
    //   //                 3'b0};
    //   mem_req_queue_next[mem_req_queue_tail_next].req.address = fifo_fetch_addr[fifo_sel_num];//next_rd_addr;
    //   mem_req_queue_next[mem_req_queue_tail_next].req.mem_tag = 4'b0;
    //   mem_req_queue_next[mem_req_queue_tail_next].req.valid = 1'b1;
    //   mem_req_queue_next[mem_req_queue_tail_next].req_done = 1'b0;
    //   mem_req_queue_next[mem_req_queue_tail_next].wr_to_cache = 1'b0;
    //   mem_req_queue_next[mem_req_queue_tail_next].wr_to_fifo = 1'b1;
    //   mem_req_queue_next[mem_req_queue_tail_next].fifo_num = fifo_sel_num;
    //   //mem_req_queue_next[mem_req_queue_tail_next].fifo_idx = fifo_tail_next[fifo_sel_num];
    //   mem_req_queue_tail_next += 1;

    //   fifo_tail_next[fifo_sel_num] += 1;
    //   //if(fifo_tail_next[fifo_sel_num] < `FIFO_SIZE) begin
    //   fifo_fetch_addr_next[fifo_sel_num] += (fetch_stride_next[fifo_sel_num] << 3);
    //     //{fifo_next[fifo_sel_num][fifo_tail_next[fifo_sel_num]].tag, fifo_next[fifo_sel_num][fifo_tail_next[fifo_sel_num]].idx} = next_rd_addr[31:3];
    //     //fifo_next[fifo_sel_num][fifo_tail_next[fifo_sel_num]].data = 64'b0;
    //     //fifo_next[fifo_sel_num][fifo_tail_next[fifo_sel_num]].valid = 1'b0;
    //   //end
    // end

  end
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if(reset) begin
      // for(int i = 0; i < `NUM_FIFO; i += 1) begin
      //   for(int j = 0; j < `FIFO_SIZE; j += 1) begin
      //     fifo[i][j] <= `SD EMPTY_DCACHE;
      //   end
      //   fifo_tail[i] <= `SD 0;
      //   fifo_filled[i] <= `SD 0;
      //   fetch_stride[i] <= `SD 0;
      //   fifo_fetch_addr[i] <= `SD 64'b0;
      // end
      // fifo_busy <= `SD 0;
      // fifo_lru <= `SD 0;
      //last_PC_in   <= `SD -1;     
      send_request <= `SD 1'b0;
      for(int i = 0; i < `MEM_BUFFER_SIZE; i += 1) begin
        mem_req_queue[i] <= `SD EMPTY_MEM_REQ;
      end
      mem_req_queue_tail   <= `SD 0;
      send_req_ptr    <= `SD 0;
      mem_waiting_ptr <= `SD 0;
      mem_rd_data <= `SD 64'b0;
      cache_wr_en[0] <= `SD 1'b0;
      Dcache_rd_miss_valid_out <= `SD 1'b0;
    end else begin
      // fifo <= `SD fifo_next;
      // fifo_tail <= `SD fifo_tail_next;
      // fifo_filled <= `SD fifo_filled_next;
      // fetch_stride <= `SD fetch_stride_next;
      // fifo_fetch_addr <= `SD fifo_fetch_addr_next;
      // fifo_busy <= `SD fifo_busy_next;
      // fifo_lru <= `SD fifo_lru_next;
      //last_PC_in      <= `SD PC_in;
      send_request    <= `SD unanswered_miss;
      mem_req_queue   <= `SD mem_req_queue_next;
      mem_req_queue_tail   <= `SD mem_req_queue_tail_next;
      send_req_ptr    <= `SD send_req_ptr_next;
      mem_waiting_ptr <= `SD mem_waiting_ptr_next;

      if(mem_done) begin
        mem_rd_data <= `SD Dmem2proc_data;
        cache_wr_en[0] <= `SD mem_req_queue_next[mem_waiting_ptr].wr_to_cache;
        Dcache_rd_miss_valid_out <= `SD mem_req_queue_next[mem_waiting_ptr].wr_to_cache;
      end else begin
        mem_rd_data <= `SD 64'b0;
        cache_wr_en[0] <= `SD 1'b0;
        Dcache_rd_miss_valid_out <= `SD 1'b0;
      end
    end
  end

endmodule // dcache
