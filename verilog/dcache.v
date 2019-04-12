`include "../../sys_defs.vh"
`define DEBUG

module dcache(
    input clock,
    input reset,
    input [(`NUM_SET_BITS - 1):0] search_index,
    input [(`NUM_TAG_BITS - 1):0] search_tag,
    input [(`NUM_FIFO - 1):0][(`FIFO_SIZE -1):0][(`NUM_SET_BITS + `NUM_TAG_BITS + 64 -1):0] FIFO,

    output logic valid_data,
    output logic [63:0] data_out);

    logic [(`NUM_FIFO - 1):0] [(`NUM_SET_BITS - 1):0] index_table;
    logic [(`NUM_FIFO - 1):0] targ_FIFO_hits;
    logic [(`NUM_FIFO_BITS -1):0] FIFO_index;
    logic [(`FIFO_SIZE - 1):0] [(`NUM_TAG_BITS - 1):0] tag_table;
    logic [(`FIFO_SIZE - 1):0] FIFO_entry_hits;
    logic [(`NUM_FIFO_SIZE_BITS -1):0] entry_index;
    logic test;

    always_comb begin
        valid_data = 0;
        data_out = 0;

        for (int i = 0; i<`NUM_FIFO; i+=1) begin
            index_table[i] = FIFO[i][0][`NUM_SET_BITS + `NUM_TAG_BITS + 64 -1:`NUM_TAG_BITS + 64];
        end

        if (|targ_FIFO_hits) begin
            for (int i = 0; i<`FIFO_SIZE; i+=1) begin
                tag_table[i] = FIFO[FIFO_index][i][`NUM_TAG_BITS + 64 -1:64];
            end
            if (|FIFO_entry_hits) begin
                valid_data = 1'b1;
                data_out = FIFO[FIFO_index][entry_index][63:0];
            end else begin
                valid_data = 0;
            end
        end else begin
            valid_data = 0;
            //Ash part
        end

    end

    CAM #(
        .LENGTH(`NUM_FIFO),
        .WIDTH(1),
        .NUM_TAGS(1),
        .TAG_SIZE(`NUM_SET_BITS))

    cam0(
        .enable(1'b1),
        .tags(search_index),
        .table_in(index_table),
        .hits(targ_FIFO_hits));

    encoder #(.WIDTH(`NUM_FIFO)) enc0(
        .in(targ_FIFO_hits),
        .out(FIFO_index));
    

    CAM #(
        .LENGTH(`FIFO_SIZE),
        .WIDTH(1),
        .NUM_TAGS(1),
        .TAG_SIZE(`NUM_TAG_BITS))

    cam1(
        .enable(1'b1),
        .tags(search_tag),
        .table_in(tag_table),
        .hits(FIFO_entry_hits));

    encoder #(.WIDTH(`FIFO_SIZE)) enc1(
        .in(FIFO_entry_hits),
        .out(entry_index));

     always_ff @(posedge clock) begin
        if (reset) begin
            test <= `SD 0;
        end
    end
endmodule