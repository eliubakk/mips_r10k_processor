`include "../../sys_defs.vh"

`define DEBUG

module vic_cache(clock, reset,
              vic_idx, vic, vic_valid, 
              rd_en, rd_idx, rd_tag,
              evicted_vic, evicted_valid,
              rd_vic, rd_valid, vic_queue_out);
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

    const CACHE_LINE_T EMPTY_CACHE_LINE = 
    {
        64'b0,
        {`NUM_TAG_BITS{1'b0}},
        1'b0,
        1'b0
    };

    typedef struct packed {
        CACHE_LINE_T line;
        logic [(`NUM_SET_BITS-1):0] idx;
    } VIC_CACHE_T;

    const VIC_CACHE_T EMPTY_VIC_CACHE = 
    {
        EMPTY_CACHE_LINE,
        {`NUM_SET_BITS{1'b0}}
    };

    input clock;
    input reset;
    input [(WR_PORTS-1):0][(`NUM_SET_BITS-1):0] vic_idx;
    input CACHE_LINE_T [(WR_PORTS-1):0] vic;
    input [(WR_PORTS-1):0] vic_valid;
    input [(RD_PORTS-1):0] rd_en;
    input [(RD_PORTS-1):0][(`NUM_SET_BITS-1):0] rd_idx;
    input [(RD_PORTS-1):0][(`NUM_TAG_BITS-1):0] rd_tag;


    output VIC_CACHE_T [(WR_PORTS-1):0] evicted_vic;
    output logic [(WR_PORTS-1):0] evicted_valid;
    output VIC_CACHE_T [(RD_PORTS-1):0] rd_vic;
    output logic [(RD_PORTS-1):0] rd_valid;
    output VIC_CACHE_T [(`VIC_SIZE-1):0] vic_queue_out;

    //internal storage variables
    VIC_CACHE_T [(`VIC_SIZE-1):0] vic_queue, vic_queue_next;
    logic [`NUM_VIC_BITS:0] vic_queue_tail, vic_queue_tail_next;
    
    //rd cam variables
    logic [(`VIC_SIZE-1):0][0:0][(`NUM_SET_BITS+`NUM_TAG_BITS-1):0] vic_queue_cam_table_in;
    logic [(RD_PORTS-1):0][(`NUM_SET_BITS+`NUM_TAG_BITS-1):0] vic_queue_cam_tags;
    logic [(`VIC_SIZE-1):0][0:0][(RD_PORTS-1):0] vic_cam_hits;
    logic [(RD_PORTS-1):0][(`VIC_SIZE-1):0] rd_vic_hits;
    wor   [(`VIC_SIZE-1):0] vic_queue_hits;
    logic [(RD_PORTS-1):0][`NUM_VIC_BITS:0] rd_vic_idx;
    logic [(RD_PORTS-1):0] rd_vic_idx_valid;

    //update logic variables
    logic [(`VIC_SIZE-1):0][`NUM_VIC_BITS:0] vic_num_shift;
    logic [`NUM_VIC_BITS:0] num_evict;

    //assign rd CAM variables
    genvar ig, jg;
    for(ig = 0; ig < RD_PORTS; ig += 1) begin
        assign vic_queue_cam_tags[ig] = {rd_tag[ig], rd_idx[ig]};
    end
	for (ig = 0; ig < `VIC_SIZE; ++ig) begin
		assign vic_queue_cam_table_in[ig][0] = {vic_queue[ig].line.tag, vic_queue[ig].idx};
        for (jg = 0; jg < RD_PORTS; ++jg) begin
            assign rd_vic_hits[jg][ig] = vic_cam_hits[ig][jg] & vic_queue[ig].line.valid;
        end
	end

    CAM #(
        .LENGTH(`VIC_SIZE),
        .WIDTH(1),
        .NUM_TAGS(RD_PORTS),
        .TAG_SIZE(`NUM_SET_BITS+`NUM_TAG_BITS))
    rd_vic_cam(
        .enable(rd_en),
        .tags(vic_queue_cam_tags),
        .table_in(vic_queue_cam_table_in),
        .hits(vic_cam_hits));
    
    //rd vic CAM hit encoder
    for(ig = 0; ig < RD_PORTS; ++ig) begin
        assign vic_queue_hits = rd_vic_hits[ig]; 
        encoder #(.WIDTH(`VIC_SIZE)) enc0(
            .in(rd_vic_hits[ig]),
            .out(rd_vic_idx[ig]),
            .valid(rd_vic_idx_valid[ig]));

        assign rd_vic[ig] = vic_queue[rd_vic_idx[ig]];
    end
    assign rd_valid = rd_vic_idx_valid;

    //update logic
    always_comb begin
        vic_queue_next = vic_queue;
        vic_queue_tail_next = vic_queue_tail;
        num_evict = 0;
        for(int i = 0; i < WR_PORTS; ++i) begin
            evicted_vic[i] = EMPTY_VIC_CACHE;
            evicted_valid[i] = 1'b0;
        end
       
        //calculate shift values based on rd hits (remove from vic_queue)
        //for(int i = `VIC_SIZE-1; i > 0; --i) begin
        //    vic_num_shift[i] = BIT_COUNT_LUT[vic_queue_hits[i:0]];       
        //end
        vic_num_shift[3] = BIT_COUNT_LUT[vic_queue_hits[3:0]];
        vic_num_shift[2] = BIT_COUNT_LUT[vic_queue_hits[2:0]];
        vic_num_shift[1] = BIT_COUNT_LUT[vic_queue_hits[1:0]];
        vic_num_shift[0] = vic_queue_hits[0];
        vic_queue_tail_next -= vic_num_shift[`VIC_SIZE-1];

        //removed rd hits from queue
        for(int i = `VIC_SIZE-1; i >= 0; --i) begin
            if(vic_num_shift[i] != 0 & ~vic_queue_hits[i]) begin
                vic_queue_next[i-vic_num_shift[i]] = vic_queue[i]; 
            end
            if(i >= vic_queue_tail_next) begin
                vic_queue_next[i] = EMPTY_VIC_CACHE;
            end
        end
        
        //calculate number to evict based on num wr
        num_evict = (BIT_COUNT_LUT[vic_valid] > (`VIC_SIZE - vic_queue_tail_next))? BIT_COUNT_LUT[vic_valid] - (`VIC_SIZE - vic_queue_tail_next) :
                                                                                    0;
        
        //send evicted out
        for(int i = 0; i < WR_PORTS; ++i) begin
            evicted_vic[i] = vic_queue_next[i];
            evicted_valid[i] = (num_evict > i);
        end

        //wr vic to queue
        for(int i = 0; i < WR_PORTS; ++i) begin
            if(i < num_evict) begin
                vic_queue_next[i] = vic_queue_next[i+num_evict];
                vic_queue_next[WR_PORTS+i].line = vic[i];
                vic_queue_next[WR_PORTS+i].idx = vic_idx[i];
            end else if(vic_valid[i]) begin
                vic_queue_next[vic_queue_tail_next+i].line = vic[i];
                vic_queue_next[vic_queue_tail_next+i].idx = vic_idx[i];
            end
        end
        vic_queue_tail_next = (num_evict > 0)? `VIC_SIZE : vic_queue_tail_next + BIT_COUNT_LUT[vic_valid];
    end

        
    always_ff @(posedge clock) begin
        if (reset) begin
            for(int i = 0; i < `VIC_SIZE; ++i) begin
                vic_queue[i] <= `SD EMPTY_VIC_CACHE;
            end
            vic_queue_tail <= `SD 0;
        end else begin
            vic_queue       <= `SD vic_queue_next;
            vic_queue_tail  <= `SD vic_queue_tail_next;
        end
    end
endmodule
