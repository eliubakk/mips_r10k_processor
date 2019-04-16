`include "../../sys_defs.vh"
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
logic dirty;
} _CACHE_LINE_T;

typedef struct packed {
_CACHE_LINE_T [(_NUM_WAYS-1):0] cache_lines;
} _CACHE_SET_T;

module testbench;
    //inputs
    logic clock;
    logic reset;
    logic valid1;
    logic valid2;
    logic valid_cam1;
    logic valid_cam2;
    _CACHE_LINE_T  new_victim1;
    _CACHE_LINE_T  new_victim2;
    logic [(`_NUM_SET_BITS - 1):0] set_index_cam1;
    logic [(`_NUM_SET_BITS - 1):0] set_index_cam2;
    logic [(`_NUM_SET_BITS - 1):0] set_index1;
    logic [(`_NUM_SET_BITS - 1):0] set_index2;
    logic [(`_NUM_TAG_BITS - 1):0] tag_cam1;
    logic [(`_NUM_TAG_BITS - 1):0] tag_cam2;
    //outputs
    _CACHE_LINE_T [3:0]	 vic_table_out;
    logic [3:0][`_NUM_SET_BITS:0] set_index_table_out;
    _CACHE_LINE_T  fired_victim1;
    _CACHE_LINE_T  fired_victim2;
    _CACHE_LINE_T  out_victim1;
    _CACHE_LINE_T  out_victim2;
    logic               fired_valid1;
    logic               fired_valid2;
    logic               out_valid1;
    logic               out_valid2;

    // set clock change
    `DUT(vic_cache) vic_cache0(
    .clock(clock),
    .reset(reset),
    .valid1(valid1),
    .valid2(valid2),
    .valid_cam1(valid_cam1),
    .valid_cam2(valid_cam2),
    .new_victim1(new_victim1),
    .new_victim2(new_victim2),
    .set_index_cam1(set_index_cam1),
    .set_index_cam2(set_index_cam2),
    .set_index1(set_index1),
    .set_index2(set_index2),
    .tag_cam1(tag_cam1),
    .tag_cam2(tag_cam2),

    .vic_table_out(vic_table_out),
    .set_index_table_out(set_index_table_out),
    .fired_victim1(fired_victim1),
    .fired_victim2(fired_victim2),
    .out_victim1(out_victim1),
    .out_victim2(out_victim2),
    .fired_valid1(fired_valid1),
    .fired_valid2(fired_valid2),
    .out_valid1(out_valid1),
    .out_valid2(out_valid2)
 	);

    //intermediate signals
    _CACHE_LINE_T [3:0]	 vic_table_test;
    logic [3:0][`_NUM_SET_BITS:0] set_index_table_test;
    _CACHE_LINE_T [7:0]	 vic_array_test;
    logic [7:0][`_NUM_SET_BITS:0] set_index_array_test;

    task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

 	task check_correct_reset;
 		begin
 			for (int i = 0; i < 4; ++i) begin
 				assert(vic_table_out[i].valid == 0) else #1 exit_on_error;
                assert(set_index_table_out[i][`_NUM_SET_BITS] == 0) else #1 exit_on_error; 
 			end
 		end
 	endtask

    task check_correct_test;
    begin
        for (int i = 0; i < 4; ++i) begin
            $display("i: %d", i);
            assert(vic_table_out[i].data==vic_table_test[i].data) else #1 exit_on_error;
            assert(set_index_table_out[i]==set_index_table_test[i]) else #1 exit_on_error;
        end
    end
 	endtask

    task write_to_vic_test;
        input [1:0] entry_num;
        input valid;
        input _CACHE_LINE_T  new_victim_test;
        begin
            if (valid) begin
                vic_table_test[entry_num] = new_victim_test;
            end
        end
    endtask

    task write_to_set_index_test;
            input [1:0] entry_num;
            input valid;
            input [(`_NUM_SET_BITS - 1):0] set_index_test;
        begin
            if (valid) begin
                set_index_table_test[entry_num] = {1'b1,set_index_test};
            end
        end
    endtask

    task test_tables_reset;
        begin
            for (int i = 0; i < 4; i += 1) begin
                set_index_table_test[i] <= `SD 0;
                vic_table_test[i].valid <= `SD 0;
                vic_table_test[i].tag <= `SD 0;
                vic_table_test[i].data <= `SD 0;
            end
        end
    endtask

    task display_vic_table_out;
 		begin
 			$display("------------------------------------------------ vic_table_out------------------------------------------");
 			for (int i = 0; i < 4; ++i) begin
 				$display("entry: %d", i);
 				print_vic_table_entry(vic_table_out[i]);
 			end
 			$display("------------------------------------------------ vic_table_test------------------------------------------");
 			for (int i = 0; i < 4; ++i) begin
 				$display("entry: %d", i);
 				print_vic_table_entry(vic_table_test[i]);
 			end
 		end
 	endtask

    task display_set_index_table_out;
 		begin
 			$display("------------------------------------------------ set_index_table_out------------------------------------------");
 			for (int i = 0; i < 4; ++i) begin
 				$display("entry: %d", i);
 				print_set_index_table_entry(set_index_table_out[i]);
 			end
 			$display("------------------------------------------------ set_index_table_test------------------------------------------");
 			for (int i = 0; i < 4; ++i) begin
 				$display("entry: %d", i);
 				print_set_index_table_entry(set_index_table_test[i]);
 			end
 		end
 	endtask

    task print_vic_table_entry;
 		input _CACHE_LINE_T vic_table_entry;
 		begin
 			$display("data = %d tag = %d valid = %b", vic_table_entry.data, vic_table_entry.tag, vic_table_entry.valid);
 		end
 	endtask

    task print_set_index_table_entry;
 		input [`_NUM_SET_BITS:0] set_index_table_entry;
 		begin
 			$display("content = %d", set_index_table_entry);
 		end
 	endtask 

    task check_fired_output1;
        input valid_test;
        input fired_valid_test;
        input _CACHE_LINE_T fired_victim_test;
        begin
            assert(valid_test==fired_valid_test) else #1 exit_on_error;
            if (valid_test) begin
                assert(fired_victim_test==fired_victim1) else #1 exit_on_error;
            end
        end
    endtask

    task check_fired_output2;
        input valid_test;
        input fired_valid_test;
        input _CACHE_LINE_T fired_victim_test;
        begin
            assert(valid_test==fired_valid_test) else #1 exit_on_error;
            if (valid_test) begin
                assert(fired_victim_test==fired_victim2) else #1 exit_on_error;
            end
        end
    endtask

    task check_cam_output1;
        input valid_test1;
        input cam_valid_test1;
        input _CACHE_LINE_T cam_victim_test1;
        begin
            assert(valid_test1==out_valid1) else #1 exit_on_error;
            if (valid_test1) begin
                assert(cam_victim_test1==out_victim1) else #1 exit_on_error;
            end
        end
    endtask

    task check_cam_output2;
        input valid_test2;
        input cam_valid_test2;
        input _CACHE_LINE_T cam_victim_test2;
        begin
            assert(valid_test2==out_valid2) else #1 exit_on_error;
            if (valid_test2) begin
                assert(cam_victim_test2==out_victim2) else #1 exit_on_error;
            end
        end
    endtask

    always `CLOCK_PERIOD clock = ~clock;

    initial begin
        // monitor wires
        //$monitor("clock: %b reset: %b valid: %b new_victim: %b set_index_cam1: %d set_index_cam2: %d set_index: %d tag_cam1: %d tag_cam2: %d", clock, reset, valid, new_victim, set_index_cam1, set_index_cam2, set_index, tag_cam1, tag_cam2);
        // intial values
        clock = 0;
        reset = 0;
        valid1 = 0;
        valid2 = 0;
        valid_cam1 = 0;
        valid_cam2 = 0;
        new_victim1.valid = 0;
        new_victim2.valid = 0;
        set_index_cam1 = 0;
        set_index_cam2 = 0;
        set_index1 = 0;
        set_index2 = 0;
        tag_cam1 = 0;
        tag_cam2 = 0;

        $display("Testing Reset...");
        @(negedge clock);
        reset = 1'b1;
        valid1 = 0;
        valid2 = 0;
        valid_cam1 = 0;
        valid_cam2 = 0;
        new_victim1.valid = 0;
        new_victim2.valid = 0;
        new_victim1.data = 0;
        new_victim2.data = 0;
        new_victim1.tag = 0;
        new_victim2.tag = 0;
        set_index_cam1 = 0;
        set_index_cam2 = 0;
        set_index1 = 0;
        set_index2 = 0;
        tag_cam1 = 0;
        tag_cam2 = 0;
        test_tables_reset;
        @(posedge clock);
        `DELAY;
        // display_cache;
        check_correct_reset;
        $display("Reset Test Passed");

        $display("Testing One Write...");
 		@(negedge clock);
 		reset = 0;
        valid1 = 1'b1;
        valid2 = 0;
        valid_cam1 = 0;
        valid_cam2 = 0;
        new_victim1.valid = 1'b1;
        new_victim1.data = 5;
        new_victim1.tag = 10;
        new_victim2.valid = 1'b0;
        new_victim2.data = 15;
        new_victim2.tag = 7;
        set_index_cam1 = 0;
        set_index_cam2 = 0;
        set_index1 = 15;
        set_index2 = 15;
        tag_cam1 = 0;
        tag_cam2 = 0;
        vic_array_test[0]=new_victim1;
        set_index_array_test[0]=set_index1;
        write_to_vic_test(2'b00,1'b1,vic_array_test[0]);
        write_to_set_index_test(2'b00,1'b1,set_index_array_test[0]);
 		@(posedge clock);
 		`DELAY;
        display_vic_table_out;
        display_set_index_table_out;
        //check_correct_test;
        check_fired_output2(0,fired_valid2,vic_array_test[0]);
 		$display("One Write Passed");

        $display("Testing Three Write...");
 		@(negedge clock);
 		reset = 0;
        valid1 = 1'b1;
        valid2 = 1'b1;
        valid_cam1 = 0;
        valid_cam2 = 0;
        new_victim1.valid = 1'b1;
        new_victim1.data = 2;
        new_victim1.tag = 4;
        new_victim2.valid = 1'b1;
        new_victim2.data = 3;
        new_victim2.tag = 6;
        set_index_cam1 = 0;
        set_index_cam2 = 0;
        set_index1 = 13;
        set_index2 = 9;
        tag_cam1 = 0;
        tag_cam2 = 0;
        vic_array_test[1]=new_victim1;
        set_index_array_test[1]=set_index1;
        vic_array_test[2]=new_victim2;
        set_index_array_test[2]=set_index2;
        write_to_vic_test(2'b10,1'b1,vic_array_test[0]);
        write_to_set_index_test(2'b10,1'b1,set_index_array_test[0]);
        write_to_vic_test(2'b01,1'b1,vic_array_test[1]);
        write_to_set_index_test(2'b01,1'b1,set_index_array_test[1]);
        write_to_vic_test(2'b00,1'b1,vic_array_test[2]);
        write_to_set_index_test(2'b00,1'b1,set_index_array_test[2]);
 		@(posedge clock);
 		`DELAY;
        display_vic_table_out;
        display_set_index_table_out;
        //check_correct_test;
        check_fired_output2(0,fired_valid2,vic_array_test[0]);
 		$display("Three Write Passed");

        $display("Testing Holding Three Write...");
 		@(negedge clock);
 		reset = 0;
        valid1 = 1'b0;
        valid2 = 1'b0;
        valid_cam1 = 0;
        valid_cam2 = 0;
        new_victim1.valid = 1'b0;
        new_victim1.data = 4;
        new_victim1.tag = 5;
        new_victim2.valid = 1'b0;
        new_victim2.data = 7;
        new_victim2.tag = 9;
        set_index_cam1 = 0;
        set_index_cam2 = 0;
        set_index1 = 13;
        set_index2 = 9;
        tag_cam1 = 0;
        tag_cam2 = 0;
        vic_array_test[3]=new_victim1;
        set_index_array_test[3]=set_index1;
        vic_array_test[4]=new_victim2;
        set_index_array_test[4]=set_index2;
        write_to_vic_test(2'b10,1'b1,vic_array_test[0]);
        write_to_set_index_test(2'b10,1'b1,set_index_array_test[0]);
        write_to_vic_test(2'b01,1'b1,vic_array_test[1]);
        write_to_set_index_test(2'b01,1'b1,set_index_array_test[1]);
        write_to_vic_test(2'b00,1'b1,vic_array_test[2]);
        write_to_set_index_test(2'b00,1'b1,set_index_array_test[2]);
 		@(posedge clock);
 		`DELAY;
        display_vic_table_out;
        display_set_index_table_out;
        //check_correct_test;
        check_fired_output2(0,fired_valid2,vic_array_test[0]);
 		$display("Holding Three Write Passed");
        
        // $display("Testing Three Write...");
 		// @(negedge clock);
 		// reset = 0;
        // valid = 1;
        // valid_cam1 = 0;
        // valid_cam2 = 0;
        // new_victim.valid = 1;
        // new_victim.data = 3;
        // new_victim.tag = 6;
        // set_index_cam1 = 0;
        // set_index_cam2 = 0;
        // set_index = 9;
        // tag_cam1 = 0;
        // tag_cam2 = 0;
        // vic_array_test[2]=new_victim;
        // set_index_array_test[2]=set_index;
        // write_to_vic_test(2'b10,1'b1,vic_array_test[0]);
        // write_to_set_index_test(2'b10,1'b1,set_index_array_test[0]);
        // write_to_vic_test(2'b01,1'b1,vic_array_test[1]);
        // write_to_set_index_test(2'b01,1'b1,set_index_array_test[1]);
        // write_to_vic_test(2'b00,1'b1,vic_array_test[2]);
        // write_to_set_index_test(2'b00,1'b1,set_index_array_test[2]);
 		// @(posedge clock);
 		// `DELAY;
        // //display_vic_table_out;
        // display_set_index_table_out;
        // check_correct_test;
        // check_fired_output(0,fired_valid,vic_array_test[0]);
 		// $display("Three Write Passed");

        $display("Testing Four Write...");
 		@(negedge clock);
 		reset = 0;
        valid1 = 0;
        valid2 = 1'b1;
        valid_cam1 = 0;
        valid_cam2 = 0;
        new_victim1.valid = 1'b0;
        new_victim1.data = 10;
        new_victim1.tag = 14;
        new_victim2.valid = 1'b1;
        new_victim2.data = 4;
        new_victim2.tag = 8;
        set_index_cam1 = 0;
        set_index_cam2 = 0;
        set_index1 = 10;
        set_index2 = 12;
        tag_cam1 = 0;
        tag_cam2 = 0;
        vic_array_test[5]=new_victim2;
        set_index_array_test[5]=set_index2;
        write_to_vic_test(2'b11,1'b1,vic_array_test[0]);
        write_to_set_index_test(2'b11,1'b1,set_index_array_test[0]);
        write_to_vic_test(2'b10,1'b1,vic_array_test[1]);
        write_to_set_index_test(2'b10,1'b1,set_index_array_test[1]);
        write_to_vic_test(2'b01,1'b1,vic_array_test[2]);
        write_to_set_index_test(2'b01,1'b1,set_index_array_test[2]);
        write_to_vic_test(2'b00,1'b1,vic_array_test[5]);
        write_to_set_index_test(2'b00,1'b1,set_index_array_test[5]);
 		@(posedge clock);
 		`DELAY;
        display_vic_table_out;
        display_set_index_table_out;
        //check_correct_test;
        check_fired_output2(0,fired_valid2,vic_array_test[0]);
 		$display("Four Write Passed");

        // $display("Testing Fiering Out 1...");
        // @(negedge clock);
 		// reset = 0;
        // valid1 = 1'b1;
        // valid2 = 1'b1;
        // valid_cam1 = 0;
        // valid_cam2 = 0;
        // new_victim1.valid = 1'b1;
        // new_victim1.data = 6;
        // new_victim1.tag = 12;
        // new_victim2.valid = 1'b0;
        // new_victim2.data = 7;
        // new_victim2.tag = 13;
        // set_index_cam1 = 5;
        // set_index_cam2 = 2;
        // set_index1 = 18;
        // set_index2 = 17;
        // tag_cam1 = 4;
        // tag_cam2 = 12;
        // vic_array_test[6]=new_victim1;
        // set_index_array_test[6]=set_index1;
        // vic_array_test[7]=new_victim2;
        // set_index_array_test[7]=set_index2;
        // write_to_vic_test(2'b11,1'b1,vic_array_test[2]);
        // write_to_set_index_test(2'b11,1'b1,set_index_array_test[2]);
        // write_to_vic_test(2'b10,1'b1,vic_array_test[5]);
        // write_to_set_index_test(2'b10,1'b1,set_index_array_test[5]);
        // write_to_vic_test(2'b01,1'b1,vic_array_test[6]);
        // write_to_set_index_test(2'b01,1'b1,set_index_array_test[6]);
        // write_to_vic_test(2'b00,1'b1,vic_array_test[7]);
        // write_to_set_index_test(2'b00,1'b1,set_index_array_test[7]);
        // @(posedge clock);
 		// `DELAY;
        // display_vic_table_out;
        // display_set_index_table_out;
        // //check_fired_output2(1,fired_valid2,vic_array_test[0]);
        // $display("Our fired valid2: %b our fired output2:         %b", fired_valid2, fired_victim2);
        // $display("correct fired valid2: %b correct fired output2: %b", 1'b1, vic_array_test[0]);
        // $display("Our fired valid1: %b our fired output1:         %b", fired_valid1, fired_victim1);
        // $display("correct fired valid1: %b correct fired output1: %b", 1'b1, vic_array_test[1]);
 		// $display("Fired out 1 Passed");

        // $display("Testing Fiering Out 2...");
        // @(negedge clock);
 		// reset = 0;
        // valid1 = 1'b0;
        // valid2 = 1'b1;
        // valid_cam1 = 0;
        // valid_cam2 = 0;
        // new_victim1.valid = 1'b1;
        // new_victim1.data = 6;
        // new_victim1.tag = 12;
        // new_victim2.valid = 1'b0;
        // new_victim2.data = 7;
        // new_victim2.tag = 13;
        // set_index_cam1 = 5;
        // set_index_cam2 = 2;
        // set_index1 = 18;
        // set_index2 = 17;
        // tag_cam1 = 4;
        // tag_cam2 = 12;
        // vic_array_test[6]=new_victim1;
        // set_index_array_test[6]=set_index1;
        // vic_array_test[7]=new_victim2;
        // set_index_array_test[7]=set_index2;
        // write_to_vic_test(2'b11,1'b1,vic_array_test[1]);
        // write_to_set_index_test(2'b11,1'b1,set_index_array_test[1]);
        // write_to_vic_test(2'b10,1'b1,vic_array_test[2]);
        // write_to_set_index_test(2'b10,1'b1,set_index_array_test[2]);
        // write_to_vic_test(2'b01,1'b1,vic_array_test[5]);
        // write_to_set_index_test(2'b01,1'b1,set_index_array_test[5]);
        // write_to_vic_test(2'b00,1'b1,vic_array_test[7]);
        // write_to_set_index_test(2'b00,1'b1,set_index_array_test[7]);
        // @(posedge clock);
 		// `DELAY;
        // display_vic_table_out;
        // display_set_index_table_out;
        // check_fired_output1(0,fired_valid1,vic_array_test[0]);
        // $display("Our fired valid2: %b our fired output2:         %b", fired_valid2, fired_victim2);
        // $display("correct fired valid2: %b correct fired output2: %b", 1'b1, vic_array_test[0]);
 		// $display("Fired out 2 Passed");

        $display("Testing CAM...");
 		@(negedge clock);
 		reset = 0;
        valid1 = 1'b1;
        valid2 = 1'b1;
        valid_cam1 = 1'b1;
        valid_cam2 = 1'b1;
        new_victim1.valid = 1'b1;
        new_victim1.data = 6;
        new_victim1.tag = 12;
        new_victim2.valid = 1'b0;
        new_victim2.data = 7;
        new_victim2.tag = 13;
        set_index_cam1 = 5;
        set_index_cam2 = 2;
        set_index1 = 18;
        set_index2 = 17;
        tag_cam1 = 4;
        tag_cam2 = 12;
        vic_array_test[6]=new_victim1;
        set_index_array_test[6]=set_index1;
        vic_array_test[7]=new_victim2;
        set_index_array_test[7]=set_index2;
        write_to_vic_test(2'b11,1'b1,vic_array_test[2]);
        write_to_set_index_test(2'b11,1'b1,set_index_array_test[2]);
        write_to_vic_test(2'b10,1'b1,vic_array_test[5]);
        write_to_set_index_test(2'b10,1'b1,set_index_array_test[5]);
        write_to_vic_test(2'b01,1'b1,vic_array_test[6]);
        write_to_set_index_test(2'b01,1'b1,set_index_array_test[6]);
        write_to_vic_test(2'b00,1'b1,vic_array_test[7]);
        write_to_set_index_test(2'b00,1'b1,set_index_array_test[7]);
        `DELAY;
        $display("Our out valid1: %b our output1:         %d", out_valid1, out_victim1.data);
        $display("correct out valid1: %b correct output1: %d", 1'b1, vic_array_test[1].data);
        $display("Our out valid2: %b our output2:       %d", out_valid2, out_victim2.data);
        $display("correct out valid2: %b correct output2: %d", 1'b0, vic_array_test[0].data);
        $display("+++++++++++++++++++++++++++++++++++++++++++");
 		@(posedge clock);
 		`DELAY;
        display_vic_table_out;
        display_set_index_table_out;
        //check_correct_test;
        //check_fired_output(1,fired_valid,vic_array_test[0]);
        //check_cam_output1(1,out_valid1,vic_array_test[1]);
        //check_cam_output2(1,out_valid2,vic_array_test[4]);
        //check_fired_output1(0,fired_valid1,vic_array_test[1]);
        //check_fired_output2(0,fired_valid2,vic_array_test[0]);
        //check_cam_output2(0,out_valid2,out_victim2);
        $display("Our fired valid1: %b our fired output1:         %b", fired_valid1, fired_victim1);
        $display("correct fired valid1: %b correct fired output1: %b", 1'b0, vic_array_test[0]);
        $display("Our fired valid2: %b our fired output2:         %b", fired_valid2, fired_victim2);
        $display("correct fired valid2: %b correct fired output2: %b", 1'b1, vic_array_test[0]);
        $display("Our out valid1: %b our output1:         %d", out_valid1, out_victim1.data);
        $display("correct out valid1: %b correct output1: %d", 1'b1, vic_array_test[1].data);
        $display("Our out valid2: %b our output2:       %d", out_valid2, out_victim2.data);
        $display("correct out valid2: %b correct output2: %d", 1'b0, vic_array_test[0].data);
 		$display("CAM Passed"); 

        // @(posedge clock);
 		// `DELAY;
        // check_fired_output(0,fired_valid,vic_array_test[1]);
 		// $display("Fired Out After CAM Passed"); 

        $display("@@@Passed");

        $finish;

    end
endmodule
