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

    logic [3:0] current_mem_tag1;
    logic [3:0] current_mem_tag;
    logic miss_outstanding1;
    logic miss_outstanding; 

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
    .current_mem_tag1(current_mem_tag1),
    .current_mem_tag(current_mem_tag),
    .miss_outstanding1(miss_outstanding1),
    .miss_outstanding(miss_outstanding),
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

    //internal signals
    // logic icache0_current_mem_tag1;
    // logic icache0_current_mem_tag;
    // logic icache0_miss_outstanding1;
    // logic icache0_miss_outstanding;

    // assign icache0_current_mem_tag1 = icache0.current_mem_tag1;
    // assign icache0_current_mem_tag = icache0.current_mem_tag;
    // assign icache0_miss_outstanding1 = icache0.miss_outstanding1;
    // assign icache0_miss_outstanding = icache0.miss_outstanding;

    task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

    task check_correct_reset;
 		begin
            //$display("@@@@@here@@@@");
 			assert((last_index1 == {`NUM_SET_BITS{1'b1}}) & (last_index == {`NUM_SET_BITS{1'b1}})) else #1 exit_on_error;
            assert((last_tag1 == {`NUM_TAG_BITS{1'b1}}) & (last_tag == {`NUM_TAG_BITS{1'b1}})) else #1 exit_on_error;
            assert((current_mem_tag1 == 0) & (current_mem_tag == 0)) else #1 exit_on_error;
            assert((miss_outstanding1 == 0) & (miss_outstanding == 0)) else #1 exit_on_error; 
 		end
 	endtask

    always `CLOCK_PERIOD clock = ~clock;

    initial begin
        // monitor wires
        //$monitor("clock: %b reset: %b Imem2proc_response1: %b Imem2proc_response: %b Imem2proc_data1: %b Imem2proc_data: %b Imem2proc_tag1: %b Imem2proc_tag: %b proc2Icache_addr1: %b proc2Icache_addr: %b cachemem_data1: %b cachemem_data: %b cachemem_valid1: %b cachemem_valid: %b", clock, reset, Imem2proc_response1, Imem2proc_response, Imem2proc_data1, Imem2proc_data, Imem2proc_tag1, Imem2proc_tag, proc2Icache_addr1, proc2Icache_addr, cachemem_data1, cachemem_data, cachemem_valid1, cachemem_valid);
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

        $display("Testing current_index, current_tag, last_index, last_tag...");
        @(negedge clock);
        reset = 0;
        Imem2proc_response1 = 0;
        Imem2proc_response = 0;
        Imem2proc_data1 = 0;
        Imem2proc_data = 0;
        Imem2proc_tag1 = 0;
        Imem2proc_tag = 0;
        proc2Icache_addr1 = {{48{1'b0}},{10{1'b1}},3'b010,3'b111};
        proc2Icache_addr =  {{48{1'b1}},{10{1'b0}},3'b101,3'b000};
        cachemem_data1 = 0;
        cachemem_data = 0;
        cachemem_valid1 = 0;
        cachemem_valid = 0;
        `DELAY;
        //$display("before posedge current_index1: %b, current_index: %b, current_tag1: %b, current_tag: %b", current_index1, current_index, current_tag1, current_tag);
        //$display("before posedge last_index1: %b, last_index: %b, last_tag1: %b, last_tag: %b", last_index1, last_index, last_tag1, last_tag);
        assert((last_index1 == {`NUM_SET_BITS{1'b1}}) & (last_index == {`NUM_SET_BITS{1'b1}})) else #1 exit_on_error;
        assert((last_tag1 == {`NUM_TAG_BITS{1'b1}}) & (last_tag == {`NUM_TAG_BITS{1'b1}})) else #1 exit_on_error;
        assert((current_index1 == 3'b010) & (current_index == 3'b101)) else #1 exit_on_error;
        assert((current_tag1 == {10{1'b1}}) & (current_tag == 0)) else #1 exit_on_error;
        @(posedge clock);
        `DELAY;
        assert((last_index1 == 3'b010) & (last_index == 3'b101)) else #1 exit_on_error;
        assert((last_tag1 == {10{1'b1}}) & (last_tag == 0)) else #1 exit_on_error;
        assert((current_index1 == 3'b010) & (current_index == 3'b101)) else #1 exit_on_error;
        assert((current_tag1 == {10{1'b1}}) & (current_tag == 0)) else #1 exit_on_error;
        $display("current_index, current_tag, last_index, last_tag test passed");

        $display("Testing data_write_enable...");
        @(negedge clock);
        reset = 0;
        Imem2proc_response1 = 5;
        Imem2proc_response = 0;
        Imem2proc_data1 = 0;
        Imem2proc_data = 0;
        Imem2proc_tag1 = 5;
        Imem2proc_tag = 10;
        proc2Icache_addr1 = {{48{1'b0}},{10{1'b1}},3'b010,3'b111};
        proc2Icache_addr =  {{48{1'b1}},{10{1'b0}},3'b101,3'b000};
        cachemem_data1 = 0;
        cachemem_data = 0;
        cachemem_valid1 = 0;
        cachemem_valid = 0;
        @(posedge clock);
        `DELAY;
        //$display("data_write_enable1: %b data_write_enable: %b", data_write_enable1, data_write_enable);
        assert((data_write_enable1 == 1'b1) & (data_write_enable == 1'b0)) else #1 exit_on_error;
        $display("Data_write_enable test passed");

        $display("Testing Icache_data_out1, Icache_valid_out1...");
        @(negedge clock);
        reset = 0;
        Imem2proc_response1 = 5;
        Imem2proc_response = 0;
        Imem2proc_data1 = 0;
        Imem2proc_data = 0;
        Imem2proc_tag1 = 5;
        Imem2proc_tag = 10;
        proc2Icache_addr1 = {{48{1'b0}},{10{1'b1}},3'b010,3'b111};
        proc2Icache_addr =  {{48{1'b1}},{10{1'b0}},3'b101,3'b000};
        cachemem_data1 = 64'b01;
        cachemem_data = 64'b11;
        cachemem_valid1 = 1;
        cachemem_valid = 0;
        @(posedge clock);
        `DELAY;
        //$display("Icache_data_out1: %b Icache_data_out: %b Icache_valid_out1: %b Icache_valid_out: %b", Icache_data_out1, Icache_data_out, Icache_valid_out1, Icache_valid_out);
        assert((Icache_data_out1 == 64'b01) & (Icache_data_out == 64'b11)) else #1 exit_on_error;
        assert((Icache_valid_out1 == 1'b1) & (Icache_valid_out == 1'b0)) else #1 exit_on_error;
        //$display("Icache_data_out1, Icache_valid_out1 test passed");

        $display("Testing proc2Imem_command1...");
        @(negedge clock);
        reset = 0;
        Imem2proc_response1 = 5;
        Imem2proc_response = 0;
        Imem2proc_data1 = 0;
        Imem2proc_data = 0;
        Imem2proc_tag1 = 5;
        Imem2proc_tag = 10;
        proc2Icache_addr1 = {{48{1'b0}},{10{1'b0}},3'b010,3'b111};
        proc2Icache_addr =  {{48{1'b1}},{10{1'b0}},3'b101,3'b000};
        cachemem_data1 = 64'b01;
        cachemem_data = 64'b11;
        cachemem_valid1 = 0;
        cachemem_valid = 0;
        `DELAY;
        //$display("proc2Imem_command1: %b proc2Imem_command: %b", proc2Imem_command1, proc2Imem_command);
        assert(proc2Imem_command1 == 2'b00) else #1 exit_on_error;//change address = 1
        @(posedge clock);
        `DELAY;
        //$display("proc2Imem_command1: %b proc2Imem_command: %b", proc2Imem_command1, proc2Imem_command);
        assert(proc2Imem_command1 == 2'b01) else #1 exit_on_error;//change address = 0 and miss_outstanding = 1
        $display("proc2Imem_command1 test passed");

        $display("Testing proc2Imem_addr1...");
        @(negedge clock);
        reset = 0;
        Imem2proc_response1 = 5;
        Imem2proc_response = 0;
        Imem2proc_data1 = 0;
        Imem2proc_data = 0;
        Imem2proc_tag1 = 5;
        Imem2proc_tag = 10;
        proc2Icache_addr1 = {{64{1'b1}}};
        proc2Icache_addr =  {{60{1'b1}},{1{1'b0}},3'b111};
        cachemem_data1 = 64'b01;
        cachemem_data = 64'b11;
        cachemem_valid1 = 0;
        cachemem_valid = 0;
        `DELAY;
        @(posedge clock);
        `DELAY;
        //$display("proc2Imem_addr1: %b proc2Imem_addr: %b", proc2Imem_addr1, proc2Imem_addr);
        assert(proc2Imem_addr1 == {{61{1'b1}},3'b0}) else #1 exit_on_error;
        assert(proc2Imem_addr  == {{60{1'b1}},4'b0}) else #1 exit_on_error;
        $display("proc2Imem_addr1 test passed");

        $display("@@@Passed");

        $finish;
    end
endmodule