`include "../../sys_defs.vh"
`define DELAY #2
`define CLOCK_PERIOD #10
`define DEBUG
`define NUM_RAND_ITER 500

module testbench;

	initial
	begin
		$finish;
	end


endmodule

/*module testbench;
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
    logic  [1:0] proc2Imem_command;
    logic [63:0] proc2Imem_addr;

    logic [3:0] current_mem_tag;
    logic miss_outstanding; 
    logic [63:0] Icache_data_out; // value is memory[proc2Icache_addr]
    logic  Icache_valid_out;      // when this is high

    logic  [(`NUM_SET_BITS - 1):0] current_index;
    logic  [(`NUM_TAG_BITS - 1):0] current_tag;
    logic  [(`NUM_SET_BITS - 1):0] last_index;
    logic  [(`NUM_TAG_BITS - 1):0] last_tag;
    logic  data_write_enable;
    logic [1:0] [128:0] que_table;
    logic que_out_valid;
    logic [128:0] que_out;
    logic que_last_valid;

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
    .proc2Imem_command(proc2Imem_command),
    .proc2Imem_addr(proc2Imem_addr),
    .current_mem_tag(current_mem_tag),
    .miss_outstanding(miss_outstanding),
    .Icache_data_out(Icache_data_out),
    .Icache_valid_out(Icache_valid_out),
    .current_index(current_index),
    .current_tag(current_tag),
    .last_index(last_index),
    .last_tag(last_tag),
    .data_write_enable(data_write_enable),
    .que_table(que_table),
    .que_out_valid(que_out_valid),
    .que_out(que_out),
    .que_last_valid(que_last_valid)
    );

    //internal signals
    logic [1:0] [128:0] que_table_test;
    logic [7:0] [128:0] que_array_test;

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
 			// assert((last_index1 == {`NUM_SET_BITS{1'b1}}) & (last_index == {`NUM_SET_BITS{1'b1}})) else #1 exit_on_error;
            // assert((last_tag1 == {`NUM_TAG_BITS{1'b1}}) & (last_tag == {`NUM_TAG_BITS{1'b1}})) else #1 exit_on_error;
            // assert((current_mem_tag1 == 0) & (current_mem_tag == 0)) else #1 exit_on_error;
            // assert((miss_outstanding1 == 0) & (miss_outstanding == 0)) else #1 exit_on_error; 
            assert(last_index == {`NUM_SET_BITS{1'b1}}) else #1 exit_on_error;
            assert(last_tag == {`NUM_TAG_BITS{1'b1}}) else #1 exit_on_error;
            assert(current_mem_tag == 0) else #1 exit_on_error;
            assert(miss_outstanding == 0) else #1 exit_on_error;
            assert(que_table == 0) else #1 exit_on_error;
            assert(que_out_valid == 0) else #1 exit_on_error;
            assert(que_out == 0) else #1 exit_on_error; 
 		end
 	endtask
    
    task test_tables_reset;
        begin
            for (int i = 0; i < 2; i += 1) begin
                que_table_test[i] = 0;
            end
        end
    endtask

    task check_correct_que_table;
    begin
        for (int i = 0; i < 2; ++i) begin
            assert(que_table[i]==que_table_test[i]) else #1 exit_on_error;
        end
    end
 	endtask

    task write_to_que_test;
        input entry_num;
        input valid;
        input [128:0] new_entry_test;
        begin
            if (valid) begin
                que_table_test[entry_num] = new_entry_test;
            end
        end
    endtask
    
    task display_que_table;
 		begin
 			$display("------------------------------------------------ que_table------------------------------------------");
 			for (int i = 0; i < 2; ++i) begin
 				$display("entry: %d", i);
 				print_que_table_entry(que_table[i]);
 			end
 			$display("------------------------------------------------ que_table_test------------------------------------------");
 			for (int i = 0; i < 2; ++i) begin
 				$display("entry: %d", i);
 				print_que_table_entry(que_table_test[i]);
 			end
 		end
 	endtask

    task print_que_table_entry;
 		input [128:0] que_table_entry;
 		begin
 			$display("valid= %b data = %b address = %b", que_table_entry[128], que_table_entry[127:64], que_table_entry[63:0]);
 		end
 	endtask

    task check_que_output;
        input valid;
        input valid_test;
        input [128:0] que_out_test;
        begin
            assert(valid==valid_test) else #1 exit_on_error;
            if (valid) begin
                assert(que_out_test==que_out) else #1 exit_on_error;
            end
        end
    endtask

    always `CLOCK_PERIOD clock = ~clock;

    initial begin
        // monitor wires
        //$monitor("clock: %b reset: %b Imem2proc_response1: %b Imem2proc_response: %b Imem2proc_data1: %b Imem2proc_data: %b Imem2proc_tag1: %b Imem2proc_tag: %b proc2Icache_addr1: %b proc2Icache_addr: %b cachemem_data1: %b cachemem_data: %b cachemem_valid1: %b cachemem_valid: %b que_valid1: %b que_valid: %b", clock, reset, Imem2proc_response1, Imem2proc_response, Imem2proc_data1, Imem2proc_data, Imem2proc_tag1, Imem2proc_tag, proc2Icache_addr1, proc2Icache_addr, cachemem_data1, cachemem_data, cachemem_valid1, cachemem_valid, que_valid1, que_valid);
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
        test_tables_reset;
        @(posedge clock);
        `DELAY;
        check_correct_reset;
        check_que_output(que_out_valid,0,0);
        $display("Reset Test Passed");

        $display("Testing que_table");
        @(negedge clock);
        reset = 0;
        Imem2proc_response1 = 5;
        Imem2proc_response = 10;
        Imem2proc_data1 = 0;
        Imem2proc_data = 0;
        Imem2proc_tag1 = 5;
        Imem2proc_tag = 10;
        proc2Icache_addr1 = {{48{1'b0}},{10{1'b1}},3'b010,3'b111};
        proc2Icache_addr =  {{48{1'b1}},{10{1'b0}},3'b101,3'b000};
        cachemem_data1 = {{62{1'b0}},2'b11};
        cachemem_data = {{60{1'b0}},4'b1111};
        cachemem_valid1 = 0;
        cachemem_valid = 0;
        que_array_test[0] = {1'b1,cachemem_data,proc2Icache_addr};
        que_array_test[1] = {1'b1,cachemem_data1,proc2Icache_addr1};
        write_to_que_test(1'b0,1'b1,que_array_test[0]);
        write_to_que_test(1'b1,1'b1,que_array_test[1]);
        @(posedge clock);
        `DELAY;
        display_que_table;
        check_correct_que_table;
        check_que_output(que_out_valid,0,que_array_test[1]);
        assert(que_last_valid == 0) else #1 exit_on_error;
        $display("que_table Testing  passed");

        $display("Testing current_index, current_tag, Icache_data_out, proc2Imem_addr");
        @(negedge clock);
        reset = 0;
        Imem2proc_response1 = 5;
        Imem2proc_response = 10;
        Imem2proc_data1 = 0;
        Imem2proc_data = 0;
        Imem2proc_tag1 = 5;
        Imem2proc_tag = 10;
        proc2Icache_addr1 = {{48{1'b0}},{5{1'b1}},{5{1'b0}},3'b110,3'b111};
        proc2Icache_addr =  {{48{1'b1}},{5{1'b0}},{5{1'b1}},3'b111,3'b000};
        cachemem_data1 = {{61{1'b0}},3'b111};
        cachemem_data = {{63{1'b0}},1'b1};
        cachemem_valid1 = 0;
        cachemem_valid = 0;
        que_array_test[2] = {1'b1,cachemem_data,proc2Icache_addr};
        write_to_que_test(1'b1,1'b1,que_array_test[0]);
        write_to_que_test(1'b0,1'b1,que_array_test[2]);
        @(posedge clock);
        `DELAY;
        display_que_table;
        check_correct_que_table;
        check_que_output(que_out_valid,1,que_array_test[1]);
        assert(que_last_valid == 0) else #1 exit_on_error;
        assert(current_index == 3'b010) else #1 exit_on_error;
        assert(current_tag == {10{1'b1}}) else #1 exit_on_error;
        assert(Icache_data_out == {{62{1'b0}},2'b11}) else #1 exit_on_error;
        assert(proc2Imem_addr == {{48{1'b0}},{10{1'b1}},3'b010,3'b000}) else #1 exit_on_error;
        $display("current_index, current_tag, Icache_data_out, proc2Imem_addr test passed");

        $display("Testing last_index, last_tag, data_write_enable");
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
        write_to_que_test(1'b0,1'b1,0);
        write_to_que_test(1'b1,1'b1,que_array_test[2]);
        @(posedge clock);
        `DELAY;
        display_que_table;
        check_correct_que_table;
        check_que_output(que_out_valid,1,que_array_test[0]);
        assert(que_last_valid == 1'b1) else #1 exit_on_error;
        assert(current_index == 3'b101) else #1 exit_on_error;
        assert(last_index == 3'b010) else #1 exit_on_error;
        assert(last_tag == {10{1'b1}}) else #1 exit_on_error;
        assert(data_write_enable == 1'b1) else #1 exit_on_error;
        $display("last_index, last_tag, data_write_enable test passed");


        // $display("Testing proc2Imem_command1...");
        // @(negedge clock);
        // reset = 0;
        // Imem2proc_response1 = 5;
        // Imem2proc_response = 0;
        // Imem2proc_data1 = 0;
        // Imem2proc_data = 0;
        // Imem2proc_tag1 = 5;
        // Imem2proc_tag = 10;
        // proc2Icache_addr1 = {{48{1'b0}},{10{1'b0}},3'b010,3'b111};
        // proc2Icache_addr =  {{48{1'b1}},{10{1'b0}},3'b101,3'b000};
        // cachemem_data1 = 64'b01;
        // cachemem_data = 64'b11;
        // cachemem_valid1 = 0;
        // cachemem_valid = 0;
        // `DELAY;
        // //$display("proc2Imem_command1: %b proc2Imem_command: %b", proc2Imem_command1, proc2Imem_command);
        // assert(proc2Imem_command1 == 2'b00) else #1 exit_on_error;//change address = 1
        // @(posedge clock);
        // `DELAY;
        // //$display("proc2Imem_command1: %b proc2Imem_command: %b", proc2Imem_command1, proc2Imem_command);
        // assert(proc2Imem_command1 == 2'b01) else #1 exit_on_error;//change address = 0 and miss_outstanding = 1
        // $display("proc2Imem_command1 test passed");


        $display("@@@Passed");

        $finish;
    end
endmodule*/
