`include "../../sys_defs.vh"

`define lq_index_t $clog2(`LQ_SIZE) 

module LQ(
    input clock,
    input reset,

    input LQ_ROW_T load_in,
    input write_en,
    input pop_en,

    input [3:0] mem_tag, // tag to search for in lq

    output logic tag_found,
    output LQ_ROW_T load_out,
    output logic read_valid,
    output logic full
);

    // internal data
    LQ_ROW_T [`LQ_SIZE - 1:0] load_queue, load_queue_next;
    logic [`lq_index_t - 1:0] head, head_next;
    logic [`lq_index_t - 1:0] tail, tail_next;
    logic [`LQ_SIZE - 1:0] mem_tag_hits;

    // assign statements
    assign load_out = load_queue[head];
    assign full = (tail + 1'b1) == head;
    assign read_valid = load_queue[head].valid_inst;

    for (genvar i = 0; i < `LQ_SIZE; ++i) begin
      assign mem_tag_hits[i] = (load_queue[i].mem_response == mem_tag) & (load_queue[i].valid_inst);
    end

    assign tag_found = |mem_tag_hits;

    // combinational logic
    always_comb begin
        load_queue_next = load_queue;
        head_next = head;
        tail_next = tail;

        if (write_en) begin
          load_queue_next[tail_next] = load_in;
          ++tail_next;
        end

        if (pop_en) begin
            load_queue_next[head_next].valid_inst = 1'b0;
            ++head_next;
        end
    end

    // sequential logic
    always_ff @(posedge clock) begin
      if (reset) begin
        for (int i = 0; i < `LQ_SIZE; ++i) begin
            load_queue[i].valid_inst <= `SD 1'b0;
            load_queue[i].NPC <= `SD 32'b0;
            load_queue[i].IR <= `SD 32'b0;
            load_queue[i].halt <= `SD 1'b0;
            load_queue[i].illegal <= `SD 1'b0;
            load_queue[i].dest_reg <= `SD `DUMMY_REG;
            load_queue[i].alu_result <= `SD 64'b0;
            load_queue[i].mem_response <= `SD 4'b0;
        end 
        head <= {`lq_index_t{0}};
        tail <= {`lq_index_t{0}};
      end else begin
        load_queue <= `SD load_queue_next;
        head <= `SD head_next;
        tail <= `SD tail_next;
      end
    end

endmodule