`include "../../sys_defs.vh"

typedef enum logic [1:0] {IDLE, IMEM, DMEM} ts_state;

module mem_controller(clock, reset, 
                        proc2Dmem_command, proc2Dmem_addr, proc2Dmem_data,
                        proc2Imem_command, proc2Imem_addr, proc2Imem_data,
                        mem2proc_response, mem2proc_data, mem2proc_tag,
                        Dmem2proc_response, Dmem2proc_data, Dmem2proc_tag,
                       // `ifdef DEBUG state, next_state, `endif
                        Imem2proc_response, Imem2proc_data, Imem2proc_tag,
                        proc2mem_command, proc2mem_addr, proc2mem_data);

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
    output logic [1:0] proc2mem_command;
    output logic [63:0] proc2mem_addr;
    output logic [63:0] proc2mem_data;
    // `ifdef DEBUG
    // output    ts_state state;
    // output    ts_state next_state;
    // `endif

    // internal data
    logic  [1:0]  Dmem2proc_response_next;
    logic  [63:0] Dmem2proc_data_next;
    logic  [63:0] Dmem2proc_tag_next;

    logic  [1:0]  Imem2proc_response_next;
    logic  [63:0] Imem2proc_data_next;
    logic  [63:0] Imem2proc_tag_next;

    //logic  [3:0]  proc2mem_command_next;
    //logic  [63:0] proc2mem_addr_next;       
    //logic  [3:0]  proc2mem_data_next;    

    ts_state state;
    ts_state next_state;

    // assign statements

    assign Dmem2proc_data_next = mem2proc_data;
    assign Dmem2proc_tag_next = mem2proc_tag;
    assign Imem2proc_data_next = mem2proc_data;
    assign Imem2proc_tag_next = mem2proc_tag;

    always_comb begin 
        next_state 	= state;
        Dmem2proc_response_next = Dmem2proc_response;
        Imem2proc_response_next = Imem2proc_response;

        //proc2mem_command_next = proc2mem_command;
        //proc2mem_addr_next = proc2mem_addr;
        //proc2mem_data_next = proc2mem_data;

        case(state)
            IDLE: begin
                next_state = (proc2Dmem_command != BUS_NONE) ? DMEM :
                             (proc2Imem_command != BUS_NONE) ? IMEM : IDLE;
                proc2mem_command = BUS_NONE;
                proc2mem_addr = 64'b0;
                proc2mem_data = 64'b0;

                Dmem2proc_response_next = 0;
                Imem2proc_response_next = 0;
            end
            IMEM:begin
                next_state = (mem2proc_response == 0) & (proc2Imem_command != BUS_NONE)? IMEM : 
                             (proc2Dmem_command != BUS_NONE) ? DMEM : IDLE;

                proc2mem_command = proc2Imem_command;
                proc2mem_addr = proc2Imem_addr;
                proc2mem_data = proc2Imem_data;

                Imem2proc_response_next = mem2proc_response;
                Dmem2proc_response_next = 0;
            end
            DMEM:begin
                next_state = (mem2proc_response == 0) & (proc2Dmem_command != BUS_NONE) ? DMEM :
                             (proc2Imem_command != BUS_NONE) ? IMEM : IDLE;

                proc2mem_command = proc2Dmem_command;
                proc2mem_addr = proc2Dmem_addr;
                proc2mem_data = proc2Dmem_data;

                Dmem2proc_response_next = mem2proc_response;
                Imem2proc_response_next = 0;
            end
        endcase
    end

    always_ff @(posedge clock) begin
        if(reset) begin
            state 	   <= `SD IDLE;
            Dmem2proc_response <= `SD 0;
            Dmem2proc_data <= `SD 0;
            Dmem2proc_tag <= `SD 0;
            Imem2proc_response <= `SD 0;
            Imem2proc_data <= `SD 0;
            Imem2proc_tag <= `SD 0;
            //proc2mem_command <= `SD 0;
            //proc2mem_addr <= `SD 0;
            //proc2mem_data <= `SD 0;
        end else begin
            state 	   <= `SD next_state;
            Dmem2proc_response <= `SD Dmem2proc_response_next;
            Dmem2proc_data <= `SD Dmem2proc_data_next;
            Dmem2proc_tag <= `SD Dmem2proc_tag_next;
            Imem2proc_response <= `SD Imem2proc_response_next;
            Imem2proc_data <= `SD Imem2proc_data_next;
            Imem2proc_tag <= `SD Imem2proc_tag_next;
            //proc2mem_command <= `SD proc2mem_command_next;
            //proc2mem_addr <= `SD proc2mem_addr_next;
            //proc2mem_data <= `SD proc2mem_data_next;
        end
    end

endmodule