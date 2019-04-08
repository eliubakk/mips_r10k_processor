`include "../../sys_defs.vh"
`define DELAY #2
`define CLOCK_PERIOD #10
`define DEBUG

module testbench;
    //inputs
    logic clock;
    logic reset;
    logic   [3:0] Imem2proc_response1;
    logic   [3:0] Imem2proc_response;
    logic  [63:0] Imem2proc_data1;
    logic  [63:0] Imem2proc_data;
    logic   [3:0] Imem2proc_tag1;
    logic   [3:0] Imem2proc_tag;

    logic  [63:0] proc2Icache_addr1;
    logic  [63:0] proc2Icache_addr;
    logic  [63:0] cachemem_data1;
    logic  [63:0] cachemem_data;
    logic   cachemem_valid1;
    logic   cachemem_valid;

    //outputs
    logic  [1:0] proc2Imem_command1;
    logic  [1:0] proc2Imem_command;
    logic [63:0] proc2Imem_addr1;
    logic [63:0] proc2Imem_addr;

    logic [63:0] Icache_data_out1; // value is memory[proc2Icache_addr]
    logic [63:0] Icache_data_out; // value is memory[proc2Icache_addr]
    logic  Icache_valid_out1;      // when this is high
    logic  Icache_valid_out;      // when this is high

    logic  [(`NUM_SET_BITS - 1):0] current_index1;
    logic  [(`NUM_SET_BITS - 1):0] current_index;
    logic  [(`NUM_TAG_BITS - 1):0] current_tag1;
    logic  [(`NUM_TAG_BITS - 1):0] current_tag;
    logic  [(`NUM_SET_BITS - 1):0] last_index1;
    logic  [(`NUM_SET_BITS - 1):0] last_index;
    logic  [(`NUM_TAG_BITS - 1):0] last_tag1;
    logic  [(`NUM_TAG_BITS - 1):0] last_tag;
    logic  data_write_enable1;
    logic  data_write_enable;

    `DUT(icache) icache0(
    //inputs
    .clock(clock),
    .reset(reset),
    .Imem2proc_response1(Imem2proc_response1),
    .Imem2proc_response(Imem2proc_response),
    .Imem2proc_data1(Imem2proc_data1),
    .Imem2proc_data(Imem2proc_data),
    .Imem2proc_tag1(Imem2proc_tag1),
    .Imem2proc_tag(Imem2proc_tag),
    .proc2Icache_addr1(proc2Icache_addr1),
    .proc2Icache_addr(proc2Icache_addr),
    .cachemem_data1(cachemem_data1),
    .cachemem_data(cachemem_data),
    .cachemem_valid1(cachemem_valid1),
    .cachemem_valid(cachemem_valid),
    //outputs
    .proc2Imem_command1(proc2Imem_command1),
    .proc2Imem_command(proc2Imem_command),
    .proc2Imem_addr1(proc2Imem_addr1),
    .proc2Imem_addr(proc2Imem_addr),
    .Icache_data_out1(Icache_data_out1),
    .Icache_data_out(Icache_data_out),
    .Icache_valid_out1(Icache_valid_out1),
    .Icache_valid_out(Icache_valid_out),
    .current_index1(current_index1),
    .current_index(current_index),
    .current_tag1(current_tag1),
    .current_tag(current_tag),
    .last_index1(last_index1),
    .last_index(last_index),
    .last_tag1(last_tag1),
    .last_tag(last_tag),
    .data_write_enable1(data_write_enable1),
    .data_write_enable(data_write_enable)
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
 			assert((last_index1 == {`NUM_SET_BITS{1'b1}}) & (last_index == {`NUM_SET_BITS{1'b1}})) else #1 exit_on_error;
            assert((last_tag1 == {`NUM_TAG_BITS{1'b1}}) & (last_tag == {`NUM_TAG_BITS{1'b1}})) else #1 exit_on_error;
            assert((icache0.current_mem_tag1 == 0) & (icache0.current_mem_tag == 0)) else #1 exit_on_error;
            assert((icache0.miss_outstanding1 == 0) & (icache0.miss_outstanding == 0)) else #1 exit_on_error; 
 		end
 	endtask

    always `CLOCK_PERIOD clock = ~clock;

    initial begin
        // monitor wires
        $monitor("clock: %b reset: %b Imem2proc_response1: %b Imem2proc_response: %b Imem2proc_data1: %d Imem2proc_data: %d Imem2proc_tag1: %d Imem2proc_tag: %d proc2Icache_addr1: %d proc2Icache_addr: %d cachemem_data1: %d cachemem_data: %d cachemem_valid1: %d cachemem_valid: %d", clock, reset, Imem2proc_response1, Imem2proc_response, Imem2proc_data1, Imem2proc_data, Imem2proc_tag1, Imem2proc_tag, proc2Icache_addr1, proc2Icache_addr, cachemem_data1, cachemem_data, cachemem_valid1, cachemem_valid);
        // intial values
        clock = 0;
        reset = 0;
        Imem2proc_response1 = 0;
        Imem2proc_response = 0;
        Imem2proc_data1 = 0;
        Imem2proc_data = 0;
        Imem2proc_tag1 = 0;
        Imem2proc_tag = 0;
        proc2Icache_addr1 = 0;
        proc2Icache_addr = 0;
        cachemem_data1 = 0;
        cachemem_data = 0;
        cachemem_valid1 = 0;
        cachemem_valid = 0;

        $display("Testing Reset...");
        @(negedge clock);
        reset = 1;
        Imem2proc_response1 = 0;
        Imem2proc_response = 0;
        Imem2proc_data1 = 0;
        Imem2proc_data = 0;
        Imem2proc_tag1 = 0;
        Imem2proc_tag = 0;
        proc2Icache_addr1 = 0;
        proc2Icache_addr = 0;
        cachemem_data1 = 0;
        cachemem_data = 0;
        cachemem_valid1 = 0;
        cachemem_valid = 0;
        @(posedge clock);
        `DELAY;
        check_correct_reset;
        $display("Reset Test Passed");

        $display("@@@Passed");

        $finish;
    end
endmodule