`define DEBUG_OUT
`define DELAY #2


`define TAG_SIZE 10	
`define TARGET_SIZE 12	
`define BTB_ROW	10	
`define PC_ALIAS 10   



module testbench;
	logic clock, reset, enable;

	logic		[31:0]	current_pc; 
	logic	 		if_branch; 
	logic		[31:0]	ex_pc;		
	logic		[31:0]	calculated_pc;  	
	logic			ex_branch_taken;
	logic			ex_en_branch;	
	
	`ifdef DEBUG_OUT
	logic 	[`BTB_ROW-1:0]				valid;
	logic 	[$clog2(`BTB_ROW):0]			BTB_count;
	logic	[`BTB_ROW-1:0]	[`TAG_SIZE-1:0]		tag;
	logic	[`BTB_ROW-1:0]	[`TARGET_SIZE-1:0]	target_address;
	`endif


	logic	[31:0]	target_pc; 	
	logic		valid_target;  

	integer i;	



	BTB btb(
		// inputs
		.clock(clock), 
		.reset(reset), 
		.enable(enable), 
		.current_pc(current_pc),
		.if_branch(if_branch),	
		.ex_pc(ex_pc),
		.calculated_pc(calculated_pc),
		.ex_branch_taken(ex_branch_taken),
		.ex_en_branch(ex_en_branch),
		
		// outputs 
		`ifdef DEBUG_OUT
		.valid_out(valid),
		.BTB_count_out(BTB_count),
		.tag_out(tag),
		.target_address_out(target_address),
		`endif	
		
		.target_pc(target_pc),
		.valid_target(valid_target)
	);


	
	always #10 clock = ~clock;



	// TASKS
	task exit_on_error;
		begin
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	task display_table;
		begin
			$display("--------------------------BTB-----------------------------------");
			$display("BTB_count : %d // valid_target : %b, target_pc : %h", BTB_count, valid_target, target_pc);
			$display("---------------------------------------------------------");
			$display("index			valid		tag		target_address");
			for(i=0;i<`BTB_ROW;i=i+1) begin
			$display("%d		 %1.0b		%h		%h",i,valid[i], tag[i], target_address[i] );
			end
			$display("-------------------------------------------\n");
		end
	endtask

	
	initial begin
		
		$monitor("Clock: %4.0f, reset: %b, enable: %b, current_pc : %h, if_branch : %b, ex_pc : %h, calculated_pc : %h, ex_branch_taken : %b, ex_en_branch : %b, target_pc : %h, valid_target : %b",clock, reset, enable,current_pc, if_branch, ex_pc, calculated_pc, ex_branch_taken, ex_en_branch, target_pc, valid_target);   



		// Initial value
		clock 			= 1'b0;
		reset 			= 1'b0;
		enable 			= 1'b0;
		current_pc		= 32'h0;
		if_branch		= 1'b0;
		ex_pc			= 32'h0;
		calculated_pc		= 32'h0;
		ex_branch_taken		= 1'b0;
		ex_en_branch		= 1'b0;


		// Reset
		@(negedge clock);
		$display("--------------------------------RESET----------------------------------"); 
		reset = 1'b1;
		enable = 1'b0;

		@(negedge clock);
		reset = 1'b0;
		enable = 1'b1;
		@(posedge clock);
		`DELAY;
		display_table;

	

		// Execute (When BTB adds value)
		// 1. Predict is taken and in the btb
		// 2. Predict is taken but not in the btb
		// 3. Predict is not taken but in the btb
		// 4. Predict is not taken and not in the btb
		// 5. When the entry is full
		
		$display("--------------------------------Execute Check----------------------------------"); 
		
		$display("--------------------Predict is taken but not in the btb------------------------");
		@(negedge clock);
		ex_pc		= 32'h4;
		calculated_pc	= 32'h8;
		ex_branch_taken	= 1'b1;
		ex_en_branch	=1'b1;
		@(posedge clock);
		`DELAY;
		display_table;
		assert (!valid_target & (target_pc==32'h0) & valid[0] & (tag[0]==`TAG_SIZE'b0) & (target_address[0]==`TARGET_SIZE'b10) & (BTB_count == 1) ) else #1 exit_on_error;

		
		@(negedge clock);
		ex_pc		= 32'h8;
		calculated_pc	= 32'h10;
		ex_branch_taken	= 1'b1;
		ex_en_branch	=1'b1;
		@(posedge clock);
		`DELAY;
		display_table;
		assert (!valid_target & (target_pc==32'h0) & valid[0] & valid[1] & (tag[1]==`TAG_SIZE'b0) & (target_address[0]==`TARGET_SIZE'b100) & (BTB_count == 2) ) else #1 exit_on_error;


		$display("------------------------Predict is taken and in the btb------------------------");
		@(negedge clock);
		ex_pc		= 32'h4;
		calculated_pc	= 32'hc;
		ex_branch_taken	= 1'b1;
		ex_en_branch	=1'b1;
		@(posedge clock);
		`DELAY;
		display_table;
		assert (!valid_target & (target_pc==32'h0) & valid[0] & (tag[0]==`TAG_SIZE'b0) & (target_address[0]==`TARGET_SIZE'b11) & (BTB_count == 2) ) else #1 exit_on_error;



		// Fetch (When BTB reads value)
		//
		//
		// Fetch and Execute at the same time	
		//
		$display("@@@passed");
		$finish;

	end
	
endmodule


