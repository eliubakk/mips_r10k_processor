`define DEBUG
`define DELAY #2

`include "../../sys_defs.vh"

	
module testbench;
	logic clock, reset, enable;
	
	logic							if_en_branch;
	logic							if_cond_branch;
	logic							if_direct_branch;
	logic	[31:0]						if_pc_in;
	
	logic							rt_en_branch;
	logic							rt_cond_branch;
	logic							rt_direct_branch;
	logic							rt_branch_taken;
	logic							rt_prediction_correct;
	logic	[31:0]						rt_pc;
	logic	[31:0]						rt_calculated_pc;
	logic	[$clog2(`OBQ_SIZE):0]				rt_branch_index;


	logic							next_pc_valid;
	logic	[$clog2(`OBQ_SIZE):0]				next_pc_index;
	logic	[31:0]						next_pc;
	logic							next_pc_prediction;

	`ifdef DEBUG
	logic		[`BH_SIZE-1:0]				gshare_ght_out;
	logic		[2**(`BH_SIZE)-1:0]			gshare_pht_out;
	OBQ_ROW_T 	[`OBQ_SIZE-1:0]				obq_out;
	logic 		[$clog2(`OBQ_SIZE):0] 			obq_tail_out;
	logic 		[`BTB_ROW-1:0]				btb_valid_out;
	logic		[`BTB_ROW-1:0]	[`TAG_SIZE-1:0]		btb_tag_out;
	logic		[`BTB_ROW-1:0]	[`TARGET_SIZE-1:0]	btb_target_address_out;
	logic 		[`RAS_SIZE - 1:0] [31:0] 		ras_stack_out;
	logic 		[$clog2(`RAS_SIZE) - 1:0] 		ras_head_out;
	logic 		[$clog2(`RAS_SIZE) - 1:0] 		ras_tail_out;
	`endif

	// test wires

	logic							next_pc_valid_test;
	logic	[$clog2(`OBQ_SIZE):0]				next_pc_index_test;
	logic	[31:0]						next_pc_test;
	logic							next_pc_prediction_test;

	logic		[`BH_SIZE-1:0]				gshare_ght_test;
	logic		[2**(`BH_SIZE)-1:0]			gshare_pht_test;
	OBQ_ROW_T 	[`OBQ_SIZE-1:0]				obq_test;
	logic 		[$clog2(`OBQ_SIZE):0] 			obq_tail_test;
	logic 		[`BTB_ROW-1:0]				btb_valid_test;
	logic		[`BTB_ROW-1:0]	[`TAG_SIZE-1:0]		btb_tag_test;
	logic		[`BTB_ROW-1:0]	[`TARGET_SIZE-1:0]	btb_target_address_test;
	logic 		[`RAS_SIZE - 1:0] [31:0] 		ras_stack_test;
	logic 		[$clog2(`RAS_SIZE) - 1:0] 		ras_head_test;
	logic 		[$clog2(`RAS_SIZE) - 1:0] 		ras_tail_test;

	// parameters
	parameter ONE = 1'b1;
	parameter ZERO = 1'b0;


	BP bp(
		// inputs
		.clock(clock), 
		.reset(reset), 
		.enable(enable),
		
		.if_en_branch(if_en_branch),
		.if_cond_branch(if_cond_branch),
		.if_direct_branch(if_direct_branch), 
		.if_pc_in(if_pc_in),
		
		.rt_en_branch(rt_en_branch),
		.rt_cond_branch(rt_cond_branch),
		.rt_direct_branch(rt_direct_branch),
		.rt_branch_taken(rt_branch_taken),
		.rt_prediction_correct(rt_prediction_correct),
		.rt_pc(rt_pc),
		.rt_calculated_pc(rt_calculated_pc),
		.rt_branch_index(rt_branch_index),		

		// outputs 
		`ifdef DEBUG
		.gshare_ght_out(gshare_ght_out),
		.gshare_pht_out(gshare_pht_out),		
		.obq_out(obq_out),
		.obq_tail_out(obq_tail_out),
		.btb_valid_out(btb_valid_out),
		.btb_tag_out(btb_tag_out),
		.btb_target_address_out(btb_target_address_out),
		.ras_stack_out(ras_stack_out),
		.ras_head_out(ras_head_out),
		.ras_tail_out(ras_tail_out),
		`endif
		.next_pc_valid(next_pc_valid),
		.next_pc_index(next_pc_index),
		.next_pc(next_pc),
		.next_pc_prediction(next_pc_prediction)

	);


	
	always #10 clock = ~clock;



	// TASKS
	task exit_on_error;
		begin
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	task print_gshare;
		begin
			$display("GSHARE");
			$display("GHT");
			for (int i = 0; i < `BH_SIZE; ++i) begin
				$display("ght[%d] = %b", i, gshare_ght_out[i]);
			end
			$display("PHT");
			for (int i = 0; i < (2**(`BH_SIZE)); ++i) begin
				$display("pht[%d] = %b", i, gshare_pht_out[i]);
			end
		end
	endtask

	task print_obq;
		begin
			$display("OBQ");
			$display("tail_out: %d", obq_tail_out);
			for (int i = 0; i < `OBQ_SIZE; ++i) begin
				$display("obq[%d] = %b", i, obq_out[i].branch_history);
			end
		end
	endtask

	task print_btb;
		begin
			$display("BTB");
			$display("btb_valid_out: %b", btb_valid_out);
			$display("BTB Tag Out");
			for (int i = 0; i < `BTB_ROW; ++i) begin
				$display("btb_tag[%d] = %b", i, btb_tag_out[i]);
			end
			$display("BTB Target Address Out");
			for (int i = 0; i < `BTB_ROW; ++i) begin
				$display("btb_target[%d] = %d", i, btb_target_address_out[i]);
			end
		end
	endtask

	task print_ras;
		begin
			$display("RAS");
			$display("head: %d tail: %d", ras_head_out, ras_tail_out);
			for (int i = 0; i < `RAS_SIZE; ++i) begin
				$display("ras[%d] = %d", i, ras_stack_out[i]);
			end
		end
	endtask

	task print_bp;
		begin
			$display("BP");
			print_gshare;
			print_obq;
			print_btb;
			print_ras;
		end
	endtask

	task _check_for_correct_gshare_reset;
		begin
			for (int i = 0; i < `BH_SIZE; ++i) begin
				assert(gshare_ght_out[i] == 0) else #1 exit_on_error;
			end
			for (int i = 0; i < (2**(`BH_SIZE)); ++i) begin
				assert(gshare_pht_out[i] == 0) else #1 exit_on_error;
			end
		end
	endtask

	task _check_for_correct_obq_reset;
		begin
			assert(obq_tail_out == 0) else #1 exit_on_error;
			for (int i = 0; i < `OBQ_SIZE; ++i) begin
				assert(obq_out[i].branch_history == 0) else #1 exit_on_error;
			end
		end
	endtask

	task _check_for_correct_btb_reset;
		begin
			assert(btb_valid_out == 0) else #1 exit_on_error;
			assert(btb_tag_out == 0) else #1 exit_on_error;
			for (int i = 0; i < `BTB_ROW; ++i) begin
				assert(btb_tag_out[i] == 0) else #1 exit_on_error;
				assert(btb_target_address_out[i] == 0) else #1 exit_on_error;
			end
		end
	endtask

	task _check_for_correct_ras_reset;
		begin
			assert(ras_head_out == 0) else #1 exit_on_error;
			assert(ras_tail_out == 0) else #1 exit_on_error;
			for (int i = 0; i < `RAS_SIZE; ++i) begin
				assert(ras_stack_out[i] == 0) else #1 exit_on_error;
			end
		end
	endtask

	task check_for_correct_reset;
		begin
			_check_for_correct_gshare_reset;
			_check_for_correct_obq_reset;
			_check_for_correct_btb_reset;
			_check_for_correct_ras_reset;
		end
	endtask

/*	task display_table;
		begin
			$display("*******************************************************************************");
			$display("*******************************************************************************");
		
			$display("FETCH_IN  @@@ if_branch : %d, if_pc_in : %h", if_branch, if_pc_in);
			$display("RETIRE_IN @@@ rt_en_branch : %b, rt_branch_taken : %b, rt_prediction_correct : %b", rt_en_branch, rt_branch_taken, rt_prediction_correct);
			$display("	    @@@ rt_pc : %h, rt_calculated_pc : %h, rt_branch_index : %5.0b", rt_pc, rt_calculated_pc, rt_branch_index);
			$display("FETCH_OUT @@@ next_pc_valid : %b, next_pc_index : %5.0b, next_pc : %h", next_pc_valid, next_pc_index, next_pc);
			$display("--------------------------BTB-----------------------------------");
			$display("index(pc[%2.0d:2]		valid		tag(pc[%2.0d,%2.0d])	target_address(pc[%2.0d,2])",$clog2(`BTB_ROW)+1, `TAG_SIZE+$clog2(`BTB_ROW)+2, $clog2(`BTB_ROW)+2, `TARGET_SIZE+1 );
			for(i=0;i<`BTB_ROW;i=i+1) begin
			$display("%d		 %1.0b		%h		%h",i,valid_out[i], tag_out[i], target_address_out[i] );
			end
			$display("*******************************************************************************");
			$display("--------------------------GSHARE PHT-----------------------------------");
			$display("GHT : %b",ght_out[`BH_SIZE-1:0]);
			$display("GHT idx           PHT");
			for(i=0;i<(2**`BH_SIZE);i=i+1) begin
				$display("Idx %b : Prediction %b", i[`BH_SIZE-1:0], pht_out[i]);
			end
			
			$display("*******************************************************************************");
			$display("---------------------------OBQ-----------------------------------------");
			
			// From Ash
			$display("tail_out: %d", tail_out);
			for (i = 0; i < `OBQ_SIZE; ++i) begin
				$display("index: %d branch_history: %b", i, obq_out[i].branch_history);
			end	
			
			$display("*******************************************************************************");
			$display("*******************************************************************************");


		end
	endtask

	task insert_through_fetch;
		input int pc;

		begin
			@(negedge clock);
			if_branch = 1'b1;
			if_pc_in = pc;
			rt_en_branch = 1'b0;

			@(posedge clock);
			`DELAY;
			rt_branch_index = next_pc_index;
			
			$display("AFTER FETCH!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
			display_table;
			// assert statements for correctness
		end
	endtask

	task fix_through_retire;
		input int pc;
		input int calc_pc;

		begin
			@(negedge clock);
			if_branch = 1'b0;
			rt_en_branch = 1'b1;
			rt_branch_taken = 1'b1;
			rt_prediction_correct = 1'b0;
			rt_pc = pc;
			rt_calculated_pc = calc_pc;

			@(posedge clock);
			`DELAY;
			// at this point should be inserted`
		end
	endtask

	task insert_branch_into_bp;
		input int pc;
		input int calc_pc;

		begin
			//$display("BEFORE FETCH!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
			//display_table;
			insert_through_fetch(pc);
			

			fix_through_retire(pc, calc_pc);
			$display("AFTER RETIRE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
			display_table;
			
		end
	endtask
*/

	
	initial begin
		
		$monitor("Clock: %4.0f, reset: %b, enable: %b, if_en_branch: %b, if_cond_branch: %b, if_direct_branch: %b, if_pc_in: %h. rt_en_branch: %b, rt_cond_branch: %b, rt_direct_branch: %b, rt_branch_taken: %b, rt_prediction_correct: %b, rt_pc: %h, rt_calculated_pc: %h, rt_branch_index: %5.0b, next_pc_valid : %b, next_pc_index : %b, next_pc : %h, next_pc_prediction : %b", clock, reset, enable, if_en_branch, if_cond_branch, if_direct_branch, if_pc_in, rt_en_branch, rt_cond_branch, rt_direct_branch, rt_branch_taken, rt_prediction_correct, rt_pc, rt_calculated_pc, rt_branch_index, next_pc_valid, next_pc_index, next_pc, next_pc_prediction);	

		// Initial value
		clock 			= 1'b0;
		reset 			= 1'b0;
		enable 			= 1'b0;
		//Input from fetch
		if_en_branch		= 1'b0;
		if_cond_branch		= 1'b0;
		if_direct_branch	= 1'b0;
		if_pc_in 		= 32'h0;
		//Input from retire
		rt_en_branch		= 1'b0;
		rt_cond_branch		= 1'b0;
		rt_direct_branch	= 1'b0;
		rt_branch_taken		= 1'b0;
		rt_prediction_correct	= 1'b0;
		rt_pc			= 32'h0;
		rt_calculated_pc	= 32'h0;
		rt_branch_index		= {$clog2(`OBQ_SIZE){1'b0}}; 



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
		check_for_correct_reset;
		$display("Reset Passed");
		$display("--------START FROM HERE-----");

		$display("Testing Single Conditional Direct Branch Fetch...");

		@(negedge clock);
		reset = ZERO;
		enable = ONE;
		if_en_branch = ONE;
		if_cond_branch = ONE;
		if_direct_branch = ONE;
		if_pc_in = 80;

		@(posedge clock);
		`DELAY;
		print_bp;

		$display("Single Conditional Direct Branch Fetch Passed");

		// Need to do : How do we know whether the instruction is
		// branch or not before decode?

	
		// Fetch Input : branch but not in BTB, branch and in BTB, not
		// branch
		// Retire Input : branch prediction correct, branch prediction
		// incorrect
		//
		// -------------------------------------------What we have done :----------------------------------------
		// Reset, Update BTB and OBQ, roll back, predict the address
		// and prediction based on the BP   

	/*	@(negedge clock);
		$display("--------------------------------Testing when the instruction is branch but not in BTB ----------------------------------"); 
		if_branch		= 1'b1;
		if_pc_in 		= 32'h20;
		rt_en_branch		= 1'b0;
		rt_branch_taken		= 1'b0;
		rt_prediction_correct	= 1'b0;
		rt_pc			= 32'h0;
		rt_calculated_pc	= 32'h0;
		rt_branch_index		= {$clog2(`OBQ_SIZE){1'b0}};

		@(posedge clock);
		`DELAY;
		display_table;
		// assert () else #1 exit_on_error;
		//
		@(negedge clock);
		$display("--------------------------------Update the BTB and OBQ ----------------------------------"); 
		if_branch		= 1'b0;
		if_pc_in 		= 32'h20;
		rt_en_branch		= 1'b1;
		rt_branch_taken		= 1'b1;
		rt_prediction_correct	= 1'b0;
		rt_pc			= 32'h20;
		rt_calculated_pc	= 32'h30;
		rt_branch_index		= {$clog2(`OBQ_SIZE){1'b0}};

		@(posedge clock);
		`DELAY;
		display_table;
		// assert () else #1 exit_on_error;
		//
		//
		@(negedge clock);
		$display("--------------------------------Fetch the updated PC address ----------------------------------"); 
		if_branch		= 1'b1;
		if_pc_in 		= 32'h20;
		rt_en_branch		= 1'b0;
		rt_branch_taken		= 1'b0;
		rt_prediction_correct	= 1'b0;
		rt_pc			= 32'h20;
		rt_calculated_pc	= 32'h30;
		rt_branch_index		= {$clog2(`OBQ_SIZE){1'b0}};

		@(posedge clock);
		`DELAY;
		display_table;
		//$display("look here");
		//$display("prediction_valid: %b prediction: %b valid_target: %b target_pc: %b", bp.prediction_valid, bp.prediction, bp.valid_target, bp.target_pc);
		// assert () else #1 exit_on_error;

	*/
	/*	@(negedge clock);
		$display("--------------------------------RESET----------------------------------"); 
		reset = 1'b1;
		enable = 1'b0;

	//	@(negedge clock);
	//	reset = 1'b0;
	//	enable = 1'b1;
		@(posedge clock);
		`DELAY;
		display_table;*/
	
		//@(negedge clock);
		//$display("--------------------------------Check the roll back ----------------------------------"); 
		//insert_branch_into_bp(12, 160);
		//insert_branch_into_bp(20, 28);
		//insert_branch_into_bp(24, 32);
		// insert_branch_into_bp(16, 36);
		//insert_through_fetch(20);
		//insert_through_fetch(20);
		//insert_through_fetch(20);
		//
		/*temp_pc = 48;
		//for (int i = 0; i < 6; ++i) begin
			$display("temp_pc = %d", temp_pc);
			insert_branch_into_bp(temp_pc, 3*temp_pc);
			temp_pc += 4;
		end*/
		
		//$display("\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n");
		//insert_through_fetch(16);

	//	insert_branch_into_bp(8, 12);
	
	//	insert_branch_into_bp(4, 32);
		//insert_branch_into_bp(20, 100);
		//insert_branch_into_bp(32, 40);
		//insert_branch_into_bp(36,44);

		/*@(posedge clock);
		`DELAY;
		display_table;*/



		$display("@@@passed");
		$finish;		
	end

	
	
endmodule


