`include "../../sys_defs.vh"
`define DELAY #2
`define CLOCK_PERIOD #10
`define DEBUG

module testbench;
    //inputs
    logic clock;
    logic reset;
    logic valid;
    logic valid_cam;
    CACHE_LINE_T  new_victim;
    logic [(`NUM_SET_BITS - 1):0] set_index_cam;
    logic [(`NUM_SET_BITS - 1):0] set_index;
    logic [(`NUM_TAG_BITS - 1):0] tag_cam;
    //outputs
    CACHE_LINE_T [3:0]	 vic_table_out;
    logic [3:0][`NUM_SET_BITS:0] set_index_table_out;
    CACHE_LINE_T  fired_victim;
    CACHE_LINE_T  out_victim;
    logic               fired_valid;
    logic               out_valid;

    // set clock change
    `DUT(vic_cache) vic_cache0(
    .clock(clock),
    .reset(reset),
    .valid(valid),
    .valid_cam(valid_cam),
    .new_victim(new_victim),
    .set_index_cam(set_index_cam),
    .set_index(set_index),
    .tag_cam(tag_cam),

    .vic_table_out(vic_table_out),
    .set_index_table_out(set_index_table_out),
    .fired_victim(fired_victim),
    .out_victim(out_victim),
    .fired_valid(fired_valid),
    .out_valid(out_valid)
 	);

    //intermediate signals
    CACHE_LINE_T [3:0]	 vic_table_test;
    logic [3:0][`NUM_SET_BITS:0] set_index_table_test;
    CACHE_LINE_T [7:0]	 vic_array_test;
    logic [7:0][`NUM_SET_BITS:0] set_index_array_test;

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
                assert(set_index_table_out[i][`NUM_SET_BITS] == 0) else #1 exit_on_error; 
 			end
 		end
 	endtask

    task check_correct_test;
    begin
        for (int i = 0; i < 4; ++i) begin
                assert(vic_table_out[i]==vic_table_test[i]) else #1 exit_on_error;
                assert(set_index_table_out[i]==set_index_table_test[i]) else #1 exit_on_error;
        end
    end
 	endtask

    task write_to_vic_test;
        input [1:0] entry_num;
        input valid;
        input CACHE_LINE_T  new_victim_test;
        begin
            if (valid) begin
                vic_table_test[entry_num] = new_victim_test;
            end
        end
    endtask

    task write_to_set_index_test;
            input [1:0] entry_num;
            input valid;
            input [(`NUM_SET_BITS - 1):0] set_index_test;
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
 		input CACHE_LINE_T vic_table_entry;
 		begin
 			$display("data = %d tag = %d valid = %b", vic_table_entry.data, vic_table_entry.tag, vic_table_entry.valid);
 		end
 	endtask

    task print_set_index_table_entry;
 		input [`NUM_SET_BITS:0] set_index_table_entry;
 		begin
 			$display("content = %d", set_index_table_entry);
 		end
 	endtask 

    task check_fired_output;
        input valid_test;
        input fired_valid_test;
        input CACHE_LINE_T fired_victim_test;
        begin
            assert(valid_test==fired_valid_test) else #1 exit_on_error;
            if (valid_test) begin
                assert(fired_victim_test==fired_victim) else #1 exit_on_error;
            end
        end
    endtask

    task check_cam_output;
        input valid_test;
        input cam_valid_test;
        input CACHE_LINE_T cam_victim_test;
        begin
            assert(valid_test==out_valid) else #1 exit_on_error;
            if (valid_test) begin
                assert(cam_victim_test==out_victim) else #1 exit_on_error;
            end
        end
    endtask

    always `CLOCK_PERIOD clock = ~clock;

    initial begin
        // monitor wires
        $monitor("clock: %b reset: %b valid: %b new_victim: %b set_index_cam: %d set_index: %d tag_cam: %d", clock, reset, valid, new_victim, set_index_cam, set_index, tag_cam);
        // intial values
        clock = 0;
        reset = 0;
        valid = 0;
        valid_cam = 0;
        new_victim.valid = 0;
        set_index_cam = 0;
        set_index = 0;
        tag_cam = 0;

        $display("Testing Reset...");
        @(negedge clock);
        reset = 1;
        valid = 0;
        valid_cam = 0;
        new_victim.valid = 0;
        new_victim.data = 0;
        new_victim.tag = 0;
        set_index_cam = 0;
        set_index = 0;
        tag_cam = 0;
        test_tables_reset;
        @(posedge clock);
        `DELAY;
        // display_cache;
        check_correct_reset;
        $display("Reset Test Passed");

        $display("Testing One Write...");
 		@(negedge clock);
 		reset = 0;
        valid = 1;
        valid_cam = 0;
        new_victim.valid = 1;
        new_victim.data = 5;
        new_victim.tag = 10;
        set_index_cam = 0;
        set_index = 15;
        tag_cam = 0;
        vic_array_test[0]=new_victim;
        set_index_array_test[0]=set_index;
        write_to_vic_test(2'b00,1'b1,vic_array_test[0]);
        write_to_set_index_test(2'b00,1'b1,set_index_array_test[0]);
 		@(posedge clock);
 		`DELAY;
        //display_vic_table_out;
        display_set_index_table_out;
        check_correct_test;
        check_fired_output(0,fired_valid,vic_array_test[0]);
 		$display("One Write Passed");

        $display("Testing Two Write...");
 		@(negedge clock);
 		reset = 0;
        valid = 1;
        valid_cam = 0;
        new_victim.valid = 1;
        new_victim.data = 2;
        new_victim.tag = 4;
        set_index_cam = 0;
        set_index = 13;
        tag_cam = 0;
        vic_array_test[1]=new_victim;
        set_index_array_test[1]=set_index;
        write_to_vic_test(2'b01,1'b1,vic_array_test[0]);
        write_to_set_index_test(2'b01,1'b1,set_index_array_test[0]);
        write_to_vic_test(2'b00,1'b1,vic_array_test[1]);
        write_to_set_index_test(2'b00,1'b1,set_index_array_test[1]);
 		@(posedge clock);
 		`DELAY;
        //display_vic_table_out;
        display_set_index_table_out;
        check_correct_test;
        check_fired_output(0,fired_valid,vic_array_test[0]);
 		$display("Two Write Passed");
        
        $display("Testing Three Write...");
 		@(negedge clock);
 		reset = 0;
        valid = 1;
        valid_cam = 0;
        new_victim.valid = 1;
        new_victim.data = 3;
        new_victim.tag = 6;
        set_index_cam = 0;
        set_index = 9;
        tag_cam = 0;
        vic_array_test[2]=new_victim;
        set_index_array_test[2]=set_index;
        write_to_vic_test(2'b10,1'b1,vic_array_test[0]);
        write_to_set_index_test(2'b10,1'b1,set_index_array_test[0]);
        write_to_vic_test(2'b01,1'b1,vic_array_test[1]);
        write_to_set_index_test(2'b01,1'b1,set_index_array_test[1]);
        write_to_vic_test(2'b00,1'b1,vic_array_test[2]);
        write_to_set_index_test(2'b00,1'b1,set_index_array_test[2]);
 		@(posedge clock);
 		`DELAY;
        //display_vic_table_out;
        display_set_index_table_out;
        check_correct_test;
        check_fired_output(0,fired_valid,vic_array_test[0]);
 		$display("Three Write Passed");

        $display("Testing Four Write...");
 		@(negedge clock);
 		reset = 0;
        valid = 1;
        valid_cam = 0;
        new_victim.valid = 1;
        new_victim.data = 4;
        new_victim.tag = 8;
        set_index_cam = 0;
        set_index = 12;
        tag_cam = 0;
        vic_array_test[3]=new_victim;
        set_index_array_test[3]=set_index;
        write_to_vic_test(2'b11,1'b1,vic_array_test[0]);
        write_to_set_index_test(2'b11,1'b1,set_index_array_test[0]);
        write_to_vic_test(2'b10,1'b1,vic_array_test[1]);
        write_to_set_index_test(2'b10,1'b1,set_index_array_test[1]);
        write_to_vic_test(2'b01,1'b1,vic_array_test[2]);
        write_to_set_index_test(2'b01,1'b1,set_index_array_test[2]);
        write_to_vic_test(2'b00,1'b1,vic_array_test[3]);
        write_to_set_index_test(2'b00,1'b1,set_index_array_test[3]);
 		@(posedge clock);
 		`DELAY;
        //display_vic_table_out;
        //display_set_index_table_out;
        check_correct_test;
        check_fired_output(0,fired_valid,vic_array_test[0]);
 		$display("Four Write Passed");

        //@(posedge clock);
 		//`DELAY;
        //check_fired_output(1,fired_valid,vic_array_test[0]);
 		//$display("Fired out Passed");

        $display("Testing CAM...");
 		@(negedge clock);
 		reset = 0;
        valid = 1;
        valid_cam = 1;
        new_victim.valid = 1;
        new_victim.data = 6;
        new_victim.tag = 12;
        set_index_cam = 5;
        set_index = 18;
        tag_cam = 4;
        vic_array_test[4]=new_victim;
        set_index_array_test[4]=set_index;
        write_to_vic_test(2'b11,1'b1,vic_array_test[1]);
        write_to_set_index_test(2'b11,1'b1,set_index_array_test[1]);
        write_to_vic_test(2'b10,1'b1,vic_array_test[2]);
        write_to_set_index_test(2'b10,1'b1,set_index_array_test[2]);
        write_to_vic_test(2'b01,1'b1,vic_array_test[3]);
        write_to_set_index_test(2'b01,1'b1,set_index_array_test[3]);
        write_to_vic_test(2'b00,1'b1,vic_array_test[4]);
        write_to_set_index_test(2'b00,1'b1,set_index_array_test[4]);
 		@(posedge clock);
 		`DELAY;
        display_vic_table_out;
        display_set_index_table_out;
        check_correct_test;
        check_fired_output(1,fired_valid,vic_array_test[0]);
        check_cam_output(1,out_valid,vic_array_test[1]);
 		$display("CAM Passed"); 

        @(posedge clock);
 		`DELAY;
        check_fired_output(0,fired_valid,vic_array_test[1]);
 		$display("Fired Out After CAM Passed"); 

        $display("@@@Passed");

        $finish;

    end
endmodule
