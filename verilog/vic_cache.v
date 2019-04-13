 `include "../../sys_defs.vh"

 `define DEBUG
module vic_cache(
    input clock,
    input reset,
    input valid,//cacheline input
    input valid_cam1,//for camming
    input valid_cam2,//for camming
    input CACHE_LINE_T  new_victim,// i don't do anything with new_victim.valid
    input [(`NUM_SET_BITS - 1):0] set_index_cam1,
    input [(`NUM_SET_BITS - 1):0] set_index_cam2,
    input [(`NUM_SET_BITS - 1):0] set_index,
    input [(`NUM_TAG_BITS - 1):0] tag_cam1,
    input [(`NUM_TAG_BITS - 1):0] tag_cam2,

    output CACHE_LINE_T [3:0]	 vic_table_out,
    output logic [3:0][`NUM_SET_BITS:0] set_index_table_out,//index + 1bit for busy
    output CACHE_LINE_T  fired_victim,
    output CACHE_LINE_T  out_victim1,
    output CACHE_LINE_T  out_victim2,
    output logic              fired_valid,
    output logic              out_valid1,
    output logic              out_valid2
    );

    CACHE_LINE_T [3:0]	         vic_table_next;
    logic [3:0][`NUM_SET_BITS:0] set_index_table_next;
    logic [3:0]                  vic_table_hits1; 
    logic [3:0]                  vic_table_hits2;                       
    logic [3:0]                  set_index_table_hits1;
    logic [3:0]                  set_index_table_hits2;
    logic [1:0]                  index_table1;
    logic [1:0]                  index_table2;
    logic [3:0][`NUM_SET_BITS-1:0] set_index_table_temp;
    logic [3:0][`NUM_TAG_BITS-1:0] vic_table_out_temp;
    CACHE_LINE_T  fired_victim_next;
    logic              fired_valid_next;

    assign fired_victim_next = vic_table_out[3];
    assign out_victim1 = vic_table_out[index_table1];
    assign out_victim2 = vic_table_out[index_table2];

    always_comb begin
        fired_valid_next = 1'b0;
        out_valid1 = 1'b0;
        out_valid2 = 1'b0;
        set_index_table_next = set_index_table_out;
        vic_table_next = vic_table_out;

        for (int i = 0; i<4; i+=1) begin
            set_index_table_temp[i]=set_index_table_out[i][`NUM_SET_BITS-1:0];
            vic_table_out_temp[i] = vic_table_out[i].tag;
        end

        if (valid_cam1 & (vic_table_hits1 == set_index_table_hits1) & (|vic_table_hits1)) begin
            out_valid1 = 1'b1;
            set_index_table_next[index_table1]=0;
            vic_table_next[index_table1]=0;
        end

        if (valid_cam2 & (vic_table_hits2 == set_index_table_hits2) & (|vic_table_hits2)) begin
            out_valid2 = 1'b1;
            set_index_table_next[index_table2]=0;
            vic_table_next[index_table2]=0;
        end

        if (set_index_table_out[3][`NUM_SET_BITS] & ~((out_valid1 & (index_table1==2'b11)) | (out_valid2 & (index_table2==2'b11)))) begin
            fired_valid_next = 1'b1;
            set_index_table_next[3][`NUM_SET_BITS] = 1'b0;
        end

        for (int i=2; i>=0; i-=1) begin
            //if (!set_index_table_out[i+1][`NUM_SET_BITS])begin
            set_index_table_next[i+1] = set_index_table_out[i];
            vic_table_next[i+1] = vic_table_out[i];
            //end
        end

        vic_table_next[0] = 0;
        set_index_table_next[0] = 0;

        if (valid) begin
            vic_table_next[0] = new_victim;
            set_index_table_next[0] = {1'b1,set_index};
        end

    end

    CAM #(
        .LENGTH(4),
        .WIDTH(1),
        .NUM_TAGS(1),
        .TAG_SIZE(`NUM_TAG_BITS))

    cam0(
        .enable(1'b1),
        .tags(tag_cam1),
        .table_in(vic_table_out_temp),
        .hits(vic_table_hits1));


    CAM #(
        .LENGTH(4),
        .WIDTH(1),
        .NUM_TAGS(1),
        .TAG_SIZE(`NUM_TAG_BITS))

    cam1(
        .enable(1'b1),
        .tags(tag_cam2),
        .table_in(vic_table_out_temp),
        .hits(vic_table_hits2));


    CAM #(
        .LENGTH(4),
        .WIDTH(1),
        .NUM_TAGS(1),
        .TAG_SIZE(`NUM_SET_BITS))
        
    cam2(
        .enable(1'b1),
        .tags(set_index_cam1),
        .table_in(set_index_table_temp),
        .hits(set_index_table_hits1));


    CAM #(
        .LENGTH(4),
        .WIDTH(1),
        .NUM_TAGS(1),
        .TAG_SIZE(`NUM_SET_BITS))
        
    cam3(
        .enable(1'b1),
        .tags(set_index_cam2),
        .table_in(set_index_table_temp),
        .hits(set_index_table_hits2));


    encoder #(.WIDTH(4)) enc0(
        .in(vic_table_hits1),
        .out(index_table1));

    encoder #(.WIDTH(4)) enc1(
        .in(vic_table_hits2),
        .out(index_table2));

    always_ff @(posedge clock) begin
        if (reset) begin
            for (int i = 0; i < 4; i += 1) begin
                set_index_table_out[i] <= `SD 0;
                vic_table_out[i].valid <= `SD 0;
                vic_table_out[i].data <= `SD 0;
                vic_table_out[i].tag <= `SD 0;
                fired_valid <= `SD 1'b0;
                fired_victim <= `SD 0;
            end
        end else begin
            vic_table_out <= `SD vic_table_next;
            set_index_table_out <= `SD set_index_table_next;
            fired_valid <= `SD fired_valid_next;
            fired_victim <= `SD fired_victim_next;
        end
    end
endmodule
