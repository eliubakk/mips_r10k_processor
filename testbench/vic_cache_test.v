`define DELAY #2
`define CLOCK_PERIOD #10
`define DEBUG

module testbench;

    logic clock;
    logic reset;
    logic valid;
    CACHE_LINE_T  new_victim;
    logic [(`NUM_SET_BITS - 1):0] set_index_cam;
    logic [(`NUM_SET_BITS - 1):0] set_index;
    logic [(`NUM_TAG_BITS - 1):0] tag_cam;

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

 
    always `CLOCK_PERIOD clock = ~clock;

    initial begin
        // monitor wires
        $monitor("clock: %b reset: %b valid: %b new_victim: %b set_index_cam: %d set_index: %d tag_cam: %d", clock, reset, valid, new_victim, set_index_cam, set_index, tag_cam);
        // intial values
        clock = 0;
        reset = 0;
        valid = 0;
        new_victim.valid = 0;
        set_index_cam = 0;
        set_index = 0;
        tag_cam = 0;
        $display("Testing Reset...");
        @(negedge clock);
        reset = 1;
        valid = 0;
        new_victim.valid = 0;
        set_index_cam = 0;
        set_index = 0;
        tag_cam = 0;
        @(posedge clock);
        `DELAY;
        // display_cache;
        check_correct_reset;
        $display("Reset Test Passed");
        $display("@@@Passed");

        $finish;

    end
endmodule