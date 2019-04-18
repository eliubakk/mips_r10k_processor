`include "../../sys_defs.vh"

typedef enum logic [1:0] {IDLE, IMEM, DMEM} ts_state;

`define DEBUG
parameter NUM_WAYS = 4;
parameter NUM_SETS = (32/NUM_WAYS);
parameter RD_PORTS = 1;
`define NUM_SET_BITS $clog2(NUM_SETS)
`define NUM_TAG_BITS (13-`NUM_SET_BITS)

typedef struct packed {
logic [63:0] data;
logic [(`NUM_TAG_BITS-1):0] tag;
logic valid;
//logic dirty;
} CACHE_LINE_T;

typedef struct packed {
CACHE_LINE_T [(NUM_WAYS-1):0] cache_lines;
} CACHE_SET_T;

module mem_controller(clock, reset, 
                        proc2Dmem_command, proc2Dmem_addr, proc2Dmem_data,
                        proc2Imem_command, proc2Imem_addr, proc2Imem_data,
                        mem2proc_response, mem2proc_data, mem2proc_tag,
                        Dmem2proc_response, Dmem2proc_data, Dmem2proc_tag,
                       // `ifdef DEBUG state, next_state, `endif
                        Imem2proc_response, Imem2proc_data, Imem2proc_tag);

    input clock;
    input reset;
    input [1:0]  proc2Dmem_command;
    input [63:0] proc2Dmem_addr;
    input [63:0] proc2Dmem_data;

    input [1:0]  proc2Imem_command;
    input [63:0] proc2Imem_addr;
    input [63:0] proc2Imem_data;//imem has not this

    input [3:0]  mem2proc_response;
    input [63:0] mem2proc_data;       
    input [3:0]  mem2proc_tag;

    output logic [3:0]  Dmem2proc_response;
    output logic [63:0] Dmem2proc_data;       
    output logic [3:0]  Dmem2proc_tag;
    output logic [3:0]  Imem2proc_response;
    output logic [63:0] Imem2proc_data;       
    output logic [3:0]  Imem2proc_tag;
    // `ifdef DEBUG
    // output    ts_state state;
    // output    ts_state next_state;
    // `endif

    ts_state state;
    ts_state next_state;

    always_comb begin 
        next_state 	= state;

        case(state)
            IDLE: begin
                next_state = (proc2Dmem_command != BUS_NONE) ? DMEM :
                             (proc2Imem_command != BUS_NONE) ? IMEM : IDLE;
            end
            IMEM:begin
                next_state = (proc2Dmem_command == BUS_NONE & proc2Imem_command == BUS_NONE) ? IDLE : IMEM;
            end
            DMEM:begin
                next_state = (proc2Dmem_command == BUS_NONE & proc2Imem_command == BUS_NONE) ? IDLE : DMEM;
            end
        endcase
    end

    always_ff @(posedge clock) begin
        if(reset)
            begin
                state 	   <= `SD IDLE;
            end
        else
            begin
                state 	   <= `SD next_state;
            end
    end

endmodule