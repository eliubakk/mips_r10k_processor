 `include "../../sys_defs.vh"

 `define DEBUG
module vic_cache(
    input clock,
    input reset,
    input valid,//cacheline input
    input CACHE_LINE_T  new_victim,
    input [(`NUM_SET_BITS - 1):0] set_index_cam,
    input [(`NUM_SET_BITS - 1):0] set_index,
    input [(`NUM_TAG_BITS - 1):0] tag_cam,

    output CACHE_LINE_T [3:0]	 vic_table_out,
    output logic [3:0][`NUM_SET_BITS:0] set_index_table_out,//index + 1bit for busy
    output CACHE_LINE_T  fired_victim,
    output CACHE_LINE_T  out_victim,
    output logic              fired_valid,
    output logic              out_valid
    );

    CACHE_LINE_T [3:0]	         vic_table_next;
    logic [3:0][`NUM_SET_BITS:0] set_index_table_next;
    logic [3:0]                  vic_table_hits;                       
    logic [3:0]                  set_index_table_hits;
    logic [1:0]                  index_table;
    logic [3:0][`NUM_SET_BITS-1:0] set_index_table_temp;
    logic [3:0][`NUM_TAG_BITS-1:0] vic_table_out_temp;

    assign fired_victim = vic_table_out[3];
    assign out_victim = vic_table_out[index_table];

    always_comb begin
        fired_valid = 1'b0;
        out_valid = 1'b0;
        set_index_table_next = set_index_table_out;
        vic_table_next = vic_table_out;

        if (set_index_table_out[3][`NUM_SET_BITS]) begin
            fired_valid = 1'b1;
            set_index_table_next[3][`NUM_SET_BITS] = 1'b0;
        end

        for (int i=2; i>=0; i-=1) begin
            if (!set_index_table_out[i+1][`NUM_SET_BITS])begin
                set_index_table_next[i+1] = set_index_table_out[i];
                vic_table_next[i+1] = vic_table_out[i];
            end
        end

        if (!set_index_table_out[0][`NUM_SET_BITS] & valid) begin
            vic_table_next[0] = new_victim;
            set_index_table_next[0] = {1'b1,set_index};
        end

        for (int i; i<4; i+=1) begin
            set_index_table_temp[i]=set_index_table_out[i][`NUM_SET_BITS-1:0];
            vic_table_out_temp[i] = vic_table_out[i].tag;
        end

        if (vic_table_hits == set_index_table_hits & (|vic_table_hits)) begin
            out_valid = 1'b1;
        end
    end

    CAM #(
        .LENGTH(4),
        .WIDTH(1),
        .NUM_TAGS(1),
        .TAG_SIZE(`NUM_TAG_BITS))

    cam0(
        .enable(1),
        .tags(tag_cam),
        .table_in(vic_table_out_temp),
        .hits(vic_table_hits));

    CAM #(
        .LENGTH(4),
        .WIDTH(1),
        .NUM_TAGS(1),
        .TAG_SIZE(`NUM_SET_BITS))
        
    cam1(
        .enable(1),
        .tags(index_cam),
        .table_in(set_index_table_temp),
        .hits(set_index_table_hits));

    encoder #(.WIDTH(4)) enc(
        .in(vic_table_hits),
        .out(index_table));

    always_ff @(posedge clock) begin
        if (reset) begin
            for (int i = 0; i < 4; i += 1) begin
                set_index_table_out[i][`NUM_SET_BITS] <= `SD 1'b0;
                vic_table_out[i].valid <= `SD 1'b0;
            end
        end else begin
            vic_table_out <= `SD vic_table_next;
            set_index_table_out <= `SD set_index_table_next;
        end
    end
endmodule