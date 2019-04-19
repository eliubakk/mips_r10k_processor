`include "../../sys_defs.vh"

//typedef enum logic [1:0] {_IDLE, _IMEM, _DMEM} _ts_state;

`define DELAY #2
`define CLOCK_PERIOD #10
`define DEBUG
parameter _NUM_WAYS = 4;
parameter _NUM_SETS = (32/_NUM_WAYS);
parameter _RD_PORTS = 1;
`define _NUM_SET_BITS $clog2(_NUM_SETS)
`define _NUM_TAG_BITS (13-`_NUM_SET_BITS)

typedef struct packed {
logic [63:0] data;
logic [(`_NUM_TAG_BITS-1):0] tag;
logic valid;
//logic dirty;
} _CACHE_LINE_T;

typedef struct packed {
_CACHE_LINE_T [(_NUM_WAYS-1):0] cache_lines;
} _CACHE_SET_T;

module testbench;
    logic clock;
    logic reset;
    logic [1:0]  proc2Dmem_command;
    logic [63:0] proc2Dmem_addr;
    logic [63:0] proc2Dmem_data;

    logic [1:0]  proc2Imem_command;
    logic [63:0] proc2Imem_addr;
    logic [63:0] proc2Imem_data;//imem has not this

    logic [3:0]  mem2proc_response;
    logic [63:0] mem2proc_data;       
    logic [3:0]  mem2proc_tag;

    logic [3:0]  Dmem2proc_response;
    logic [63:0] Dmem2proc_data;       
    logic [3:0]  Dmem2proc_tag;
    logic [3:0]  Imem2proc_response;
    logic [63:0] Imem2proc_data;       
    logic [3:0]  Imem2proc_tag;

    // ts_state state;
    // ts_state next_state;

    `DUT(mem_controller) mem_controller0(
    .clock(clock),
    .reset(reset),
    .proc2Dmem_command(proc2Dmem_command),
    .proc2Dmem_addr(proc2Dmem_addr),
    .proc2Dmem_data(proc2Dmem_data),
    .proc2Imem_command(proc2Imem_command),
    .proc2Imem_addr(proc2Imem_addr),
    .proc2Imem_data(proc2Imem_data),
    .mem2proc_response(mem2proc_response),
    .mem2proc_data(mem2proc_data),     
    .mem2proc_tag(mem2proc_tag),

    .Dmem2proc_response(Dmem2proc_response),
    .Dmem2proc_data(Dmem2proc_data),     
    .Dmem2proc_tag(Dmem2proc_tag),
    .Imem2proc_response(Imem2proc_response),
    .Imem2proc_data(Imem2proc_data),     
    .Imem2proc_tag(Imem2proc_tag)
    // .state(state),
    // .next_state(next_state)
 	);

    task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

 	task check_correct_reset;
 		begin
            $display("state: %b", mem_controller0.state);
            assert(mem_controller0.state == IDLE) else #1 exit_on_error;
 		end
 	endtask

    always `CLOCK_PERIOD clock = ~clock;

    initial begin
        // monitor wires
        //$monitor("clock: %b reset: %b valid: %b new_victim: %b set_index_cam1: %d set_index_cam2: %d set_index: %d tag_cam1: %d tag_cam2: %d", clock, reset, valid, new_victim, set_index_cam1, set_index_cam2, set_index, tag_cam1, tag_cam2);
        // intial values
        clock = 0;
        reset = 0;
        proc2Dmem_command = 0;
        proc2Dmem_addr = 0;
        proc2Dmem_data = 0;
        proc2Imem_command = 0;
        proc2Imem_addr = 0;
        proc2Imem_data = 0;
        mem2proc_response = 0;
        mem2proc_data = 0;
        mem2proc_tag = 0;

        $display("Testing Reset...");
        @(negedge clock);
        reset = 1'b1;
        proc2Dmem_command = 0;
        proc2Dmem_addr = 0;
        proc2Dmem_data = 0;
        proc2Imem_command = 0;
        proc2Imem_addr = 0;
        proc2Imem_data = 0;
        mem2proc_response = 0;
        mem2proc_data = 0;
        mem2proc_tag = 0;
        @(posedge clock);
        `DELAY;
        // display_cache;
        check_correct_reset;
        $display("Reset Test Passed");
        
        $display("@@@Passed");

        $finish;

    end
endmodule