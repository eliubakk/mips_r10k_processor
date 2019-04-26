`include "../../sys_defs.vh"
//`include "../../cache_defs.vh"
/*`define DEBUG
`define DELAY #2
`define CLOCK_PERIOD #10
`define NUM_RAND_ITER 500

module testbench;

	initial
	begin
		$finish;
	end


endmodule
*/
`define DELAY #2
`define CLOCK_PERIOD #10
`define DEBUG
`define NUM_SET_BITS $clog2(32/NUM_WAYS)
`define NUM_TAG_BITS (13-`NUM_SET_BITS)


module testbench;
    //inputs
    logic clock;
    logic reset;
	logic rd_en;
	logic [63:0] proc2Dcache_rd_addr;
	logic wr_en;
	logic [63:0] proc2Dcache_wr_addr;
	logic [63:0] proc2Dcache_wr_data;
	logic [3:0] Dmem2proc_response;
	logic [63:0] Dmem2proc_data;
	logic [3:0] Dmem2proc_tag;

	// outputs
	logic [63:0] Dcache_rd_data_out;
	logic Dcache_rd_valid_out;
	logic [63:0] Dcache_rd_miss_addr_out;
	logic [63:0] Dcache_rd_miss_data_out;
	logic Dcache_rd_miss_valid_out;
	logic [1:0] proc2Dmem_command;
	logic [63:0] proc2Dmem_addr;
	logic [63:0] proc2Dmem_data;
	CACHE_SET_T [(`NUM_SETS - 1):0] sets_out;
	VIC_CACHE_T [2:0] evicted;
	logic [2:0] evicted_valid;



/*
    logic [(`NUM_SET_BITS - 1):0] search_index;
    logic [(`NUM_TAG_BITS - 1):0] search_tag;
    logic [(`NUM_FIFO - 1):0][(`FIFO_SIZE -1):0][(`NUM_SET_BITS + `NUM_TAG_BITS + 64 -1):0] FIFO;
    //outputs
    logic valid_data;
    logic [63:0] data_out;
*/

/*
    `DUT(dcache) dcache0(
    .clock(clock),
    .reset(reset),
    .search_index(search_index),
    .search_tag(search_tag),
    .FIFO(FIFO),
    .valid_data(valid_data),
    .data_out(data_out)
    );
*/

	`DUT(dcache) dcache0(
		.clock(clock),
		.reset(reset),
		.rd_en(rd_en),
		.proc2Dcache_rd_addr(proc2Dcache_rd_addr),
		.wr_en(wr_en),
		.proc2Dcache_wr_addr(proc2Dcache_wr_addr),
		.proc2Dcache_wr_data(proc2Dcache_wr_data),
		.Dmem2proc_response(Dmem2proc_response),
		.Dmem2proc_data(Dmem2proc_data),
		.Dmem2proc_tag(Dmem2proc_tag),
		.Dcache_rd_data_out(Dcache_rd_data_out),
		.Dcache_rd_valid_out(Dcache_rd_valid_out),
		.Dcache_rd_miss_addr_out(Dcache_rd_miss_addr_out),
		.Dcache_rd_miss_data_out(Dcache_rd_miss_data_out),
		.Dcache_rd_miss_valid_out(Dcache_rd_miss_valid_out),
		.proc2Dmem_command(proc2Dmem_command),
		.proc2Dmem_addr(proc2Dmem_addr),
		.proc2Dmem_data(proc2Dmem_data),
		.evicted(evicted),
		.evicted_valid(evicted_valid),
		.sets_out(sets_out)
	);

    task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	/*
    task write_to_FIFO;
        begin
            FIFO[0][0]={{3'b010},{10'b0000000000},{{61{1'b1}},3'b000}};
            FIFO[0][1]={{3'b010},{10'b0000000001},{{61{1'b1}},3'b001}};
            FIFO[0][2]={{3'b010},{10'b0000000010},{{61{1'b1}},3'b010}};
            FIFO[0][3]={{3'b010},{10'b0000000011},{{61{1'b1}},3'b011}};
            FIFO[0][4]={{3'b010},{10'b0000000100},{{61{1'b1}},3'b100}};
            FIFO[0][5]={{3'b010},{10'b0000000101},{{61{1'b1}},3'b101}};
            FIFO[0][6]={{3'b010},{10'b0000000110},{{61{1'b1}},3'b110}};
            FIFO[0][7]={{3'b010},{10'b0000000111},{{61{1'b1}},3'b111}};

            FIFO[1][0]={{3'b110},{10'b0000001000},{{60{1'b1}},4'b0000}};
            FIFO[1][1]={{3'b110},{10'b0000001001},{{60{1'b1}},4'b0001}};
            FIFO[1][2]={{3'b110},{10'b0000001010},{{60{1'b1}},4'b0010}};
            FIFO[1][3]={{3'b110},{10'b0000001011},{{60{1'b1}},4'b0011}};
            FIFO[1][4]={{3'b110},{10'b0000001100},{{60{1'b1}},4'b0100}};
            FIFO[1][5]={{3'b110},{10'b0000001101},{{60{1'b1}},4'b0101}};
            FIFO[1][6]={{3'b110},{10'b0000001110},{{60{1'b1}},4'b0110}};
            FIFO[1][7]={{3'b110},{10'b0000001111},{{60{1'b1}},4'b0111}};

            for (int i=2;i<8;i+=1) begin
                FIFO[i]=0;
            end
        end
    endtask

    task display_FIFO;
 		begin
 			$display("------------------------------------------------ FIFO------------------------------------------");
 			for (int i = 0; i < 2; ++i) begin
                for (int j = 0; j < 8; ++j) begin
 				    $display("entry: %d index : %b tag:%b data: %b", i, FIFO[i][j][`NUM_SET_BITS + `NUM_TAG_BITS + 64 -1:`NUM_TAG_BITS + 64], FIFO[i][j][`NUM_TAG_BITS + 64 -1:64], FIFO[i][j][63:0]);
                end
 			end
 		end
 	endtask
	
    task check_correctenss;
        input valid_test;
        input [63:0] data_out_test;
        begin
            $display("valid_data: %b data_out: %b",valid_data,data_out);
            assert(valid_test==valid_data) else #1 exit_on_error;
            if(valid_test) begin
                assert(data_out_test==data_out) else #1 exit_on_error;
            end
        end
    endtask
	*/

	task check_correct_reset;
		begin
			assert(Dcache_rd_data_out == 0) else #1 exit_on_error;
			assert(Dcache_rd_valid_out == 0) else #1 exit_on_error;
			assert(Dcache_rd_miss_addr_out == 0) else #1 exit_on_error;
			assert(Dcache_rd_miss_data_out == 0) else #1 exit_on_error;
			assert(Dcache_rd_miss_valid_out == 0) else #1 exit_on_error;
			assert(proc2Dmem_command == 0) else #1 exit_on_error;
			assert(proc2Dmem_addr == 0) else #1 exit_on_error;
			assert(proc2Dmem_data == 0) else #1 exit_on_error;
			assert(sets_out == 0) else #1 exit_on_error;
			assert(evicted == 0) else #1 exit_on_error;
			assert(evicted_valid == 0) else #1 exit_on_error;
		end
	endtask

    always `CLOCK_PERIOD clock = ~clock;

    initial begin
        // monitor wires
        // $monitor("clock: %b reset: %b search_index: %b search_tag: %b", clock, reset, search_index, search_tag);
	$monitor("clock: %b reset: %b",clock, reset);

        // intial values
        clock = 0;
        reset = 0;
	/*
        search_index = 3'b111;
        search_tag = 10'b1111111111;
        write_to_FIFO;
	*/
	rd_en = 0;
	proc2Dcache_rd_addr = 0;
	wr_en = 0;
	proc2Dcache_wr_addr = 0;
	proc2Dcache_wr_data = 0;
	Dmem2proc_response = 0;
	Dmem2proc_data = 0;
	Dmem2proc_tag = 0;

	$display("Testing Reset...");
	@(negedge clock);
	reset = 1;

	@(posedge clock);
	`DELAY;
	check_correct_reset;	


	$display("Reset Passed");

	/*
        $display("Testing initial conditions");
        @(negedge clock);
        reset = 0;
        search_index = 3'b111;
        search_tag = 10'b1111111111;
        write_to_FIFO;
        @(posedge clock);
        `DELAY;
        check_correctenss(0,0);
        $display("Initial conditions test passed");

        $display("Testing cache");
        @(negedge clock);
        reset = 0;
        search_index = 3'b110;
        search_tag = 10'b0000001001;
        write_to_FIFO;
        @(posedge clock);
        `DELAY;
        display_FIFO;
        //  $display("-------------tag_table-----------");
        //  for (int i= 0; i<`FIFO_SIZE; i+=1) begin
        //      $display("entry: %d = [%b]", i, dcache0.tag_table[i]);
        //  end
        // //$display("FIFO_index: %b",dcache0.FIFO_index);
         check_correctenss(1'b1,{{60{1'b1}},4'b0001});
        $display("Cache test passed");
	*/
        $display("@@@Passed");

        $finish;
    end     
endmodule
