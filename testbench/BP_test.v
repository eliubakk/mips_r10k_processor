`define DEBUG
`define DELAY #2

`include "../../sys_defs.vh"

	
module testbench;
	logic clock, reset, enable;
// Inputs	
	logic							if_en_branch;
	logic							if_cond_branch;
	logic							if_direct_branch;
	logic							if_return_branch;
	logic	[31:0]						if_pc_in;
	
	logic							rt_en_branch;
	logic							rt_cond_branch;
	logic							rt_direct_branch;
	logic							rt_return_branch;
	logic							rt_branch_taken;
	logic							rt_prediction_correct;
	logic	[31:0]						rt_pc;
	logic	[31:0]						rt_calculated_pc;
	logic	[$clog2(`OBQ_SIZE):0]				rt_branch_index;

// Outputs
	logic							next_pc_valid;
	logic	[$clog2(`OBQ_SIZE):0]				next_pc_index;
	logic	[31:0]						next_pc;
	logic							next_pc_prediction;

	`ifdef DEBUG
	logic		[`BH_SIZE-1:0]				gshare_ght_out;
	logic		[2**(`BH_SIZE)-1:0]			gshare_pht_out;
	OBQ_ROW_T 	[`OBQ_SIZE-1:0]				obq_out;
	logic 		[$clog2(`OBQ_SIZE)-1:0] 		obq_head_out;
	logic 		[$clog2(`OBQ_SIZE)-1:0] 		obq_tail_out;
	logic 		[`BTB_ROW-1:0]				btb_valid_out;
	logic		[`BTB_ROW-1:0]	[`TAG_SIZE-1:0]		btb_tag_out;
	logic		[`BTB_ROW-1:0]	[`TARGET_SIZE-1:0]	btb_target_address_out;
	logic 		[`RAS_SIZE - 1:0] [31:0] 		ras_stack_out;
	logic 		[$clog2(`RAS_SIZE) - 1:0] 		ras_head_out;
	logic 		[$clog2(`RAS_SIZE) - 1:0] 		ras_tail_out;
	`endif

// Testing varilables

	logic							test_next_pc_valid;
	logic	[$clog2(`OBQ_SIZE):0]				test_next_pc_index;
	logic	[31:0]						test_next_pc;
	logic							test_next_pc_prediction;

	`ifdef DEBUG
	logic		[`BH_SIZE-1:0]				test_gshare_ght_out;
	logic		[2**(`BH_SIZE)-1:0]			test_gshare_pht_out;
	OBQ_ROW_T 	[`OBQ_SIZE-1:0]				test_obq_out;
	
	logic 		[$clog2(`OBQ_SIZE)-1:0] 		test_obq_head_out;
	logic 		[$clog2(`OBQ_SIZE)-1:0] 		test_obq_tail_out;
	logic 		[`BTB_ROW-1:0]				test_btb_valid_out;
	logic		[`BTB_ROW-1:0]	[`TAG_SIZE-1:0]		test_btb_tag_out;
	logic		[`BTB_ROW-1:0]	[`TARGET_SIZE-1:0]	test_btb_target_address_out;
	logic 		[`RAS_SIZE - 1:0] [31:0] 		test_ras_stack_out;
	logic 		[$clog2(`RAS_SIZE) - 1:0] 		test_ras_head_out;
	logic 		[$clog2(`RAS_SIZE) - 1:0] 		test_ras_tail_out;
	`endif


	// RAS WIRES
	// inputs
	logic ras_reset;
	logic ras_write_en;
	logic ras_clear_en;
	logic [31:0] ras_current_pc;
	// outputs
	logic ras_next_pc;
	logic ras_valid_out;	

	// test modules
	RAS test_ras(
		// inputs
		.clock(clock),
		.reset(ras_reset),
		.write_en(ras_write_en),
		.clear_en(ras_clear_en),
		.current_pc(ras_current_pc),

		// outputs
		.next_pc(ras_next_pc),
		.valid_out(ras_valid_out)
	);
/*
	// OBQ WIRES
	// inputs
	logic obq_reset;
	logic obq_write_en;
	OBQ_ROW_T obq_bh_row;
	logic obq_clear_en;
	logic [$clog2(`OBQ_SIZE) - 1:0] obq_index;
	logic obq_shift_en;
	logic [$clog2(`OBQ_SIZE) - 1:0] obq_shift_index;
	// outputs
	logic [$clog2(`OBQ_SIZE) - 1:0] obq_row_tag;
	logic obq_bh_pred_valid;
	OBQ_ROW_T obq_bh_pred;

	OBQ test_obq(
		// inputs
		.clock(clock),
		.reset(obq_reset),
		.write_en(obq_write_en),
		.bh_row(obq_bh_row),
		.clear_en(obq_clear_en),
		.index(obq_index),
		.shift_en(obq_shift_en),
		.shift_index(obq_shift_index),
		// outputs
		.row_tag(obq_row_tag),
		.bh_pred_valid(obq_bh_pred_valid),
		.bh_pred(obq_bh_pred)
	);
*/

	BP bp(
		// inputs
		.clock(clock), 
		.reset(reset), 
		.enable(enable),
		
		.if_en_branch(if_en_branch),
		.if_cond_branch(if_cond_branch),
		.if_direct_branch(if_direct_branch),
		.if_return_branch(if_return_branch), 
		.if_pc_in(if_pc_in),
		
		.rt_en_branch(rt_en_branch),
		.rt_cond_branch(rt_cond_branch),
		.rt_direct_branch(rt_direct_branch),
		.rt_return_branch(rt_return_branch),
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
		.obq_head_out(obq_head_out),
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
/*
	task update_RAS;
		begin
			// RAS needs to be updated in the following
			// situations:
			// 1. inst is a jump
			// 	a. unconditional indirect
			// 	b. save pc + 4 to RAS
			// 2. inst is a ret
			// 	a. unconditional indirect
			// 	b. next pc should be the top of RAS
			// 	c. remove top of RAS
			if (reset) begin
				// enable bits don't matter
				ras_reset = 1;
			end else if (if_en_branch) begin // check if jump
				ras_reset = 0;
				write_en = 1;
				clear_en = 0;
				current_pc = ; // this should be the pc of the inst
			end else if () begin // check if return
				ras_reset = 0;
				write_en = 0;
				clear_en = 1;
				// current_pc doesnt matter?
			end
		end
	endtask

	task update_OBQ;
		begin
			// OBQ needs to be updated in the following
			// situations (fetch):
			// 1. Conditional and Direct Instruction
			// 2. Conditional and Indirect Instruction
			if (reset) begin
				obq_reset = 1;
			end else begin
				obq_reset = 0;
				if (rt_en_branch) begin
					obq_write_en = 0;
					if () begin // preditction incorrect
						obq_shift_en = 0;
						if (!obq_bh_pred_valid) begin // if obq not empty
							obq_clear_en = 1;
							obq_index = ; // some index tag
						end else begin
							obq_clear_en = 0;
						end
					end else begin // prediction correct
						obq_shift_en = 1;
						obq_shift_index = ; // some index tag
					end
				end
				if () begin // if stage ONLY IF RETIRE CORRECT
					if (if_en_branch) begin
						obq_write_en = 1;
						obq_bh_row.branch_history = ; // comes from gshare
						obq_clear_en = 0;
						obq_shift_en = 0;
					end
				end
			end
		end
	endtask

	task update_modules;
		begin
			// update RAS
			update_RAS;
			// update OBQ
			update_OBQ;
		end
	endtask
*/
	// Print tables
	task print_gshare;
		begin
			$display("GSHARE");
			$display("GHT: %b", gshare_ght_out);
			/*for (int i = 0; i < `BH_SIZE; ++i) begin
				$display("ght[%d] = %b", i, gshare_ght_out[i]);
			end*/
			$display("PHT");
			for (int i = 0; i < (2**(`BH_SIZE)); ++i) begin
				$display("pht[%d] = %b", i, gshare_pht_out[i]);
			end
		end
	endtask

	task print_obq;
		begin
			$display("OBQ");
			$display("head_out: %d, tail_out: %d", obq_head_out, obq_tail_out);
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
			assert((obq_tail_out == 0) & (obq_head_out == 0)  ) else #1 exit_on_error;
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

	task _check_for_correct_btb_write;
		begin
		//Check the btb is updated correctly when branch is taken
		//& not return
			if(rt_en_branch & rt_branch_taken & !rt_return_branch) begin
				assert ((btb_valid_out[rt_pc[($clog2(`BTB_ROW)+1):2]]== 1) & (btb_tag_out[rt_pc[($clog2(`BTB_ROW)+1):2]]== rt_pc[(`TAG_SIZE+$clog2(`BTB_ROW)+1):($clog2(`BTB_ROW)+2)] ) & (btb_target_address_out[rt_pc[($clog2(`BTB_ROW)+1):2]]== rt_calculated_pc[`TARGET_SIZE+1:2])) else #1 exit_on_error;
			end
		end
	endtask


	
	// Check the functionality of each module for random testing
	
	task _check_for_correct_btb;
		begin
		//Check the btb is updated correctly when branch is taken
		//except return
			if(rt_en_branch & rt_branch_taken & !rt_return_branch) begin
				test_btb_valid_out[rt_pc[($clog2(`BTB_ROW)+1):2]] = 1;
				test_btb_tag_out[rt_pc[($clog2(`BTB_ROW)+1):2]]= rt_pc[(`TAG_SIZE+$clog2(`BTB_ROW)+1):($clog2(`BTB_ROW)+2)];
				test_btb_target_address_out[rt_pc[($clog2(`BTB_ROW)+1):2]]= rt_calculated_pc[`TARGET_SIZE+1:2]; 
			end
			assert((test_btb_valid_out == btb_valid_out) & (test_btb_tag_out == btb_tag_out) & (test_btb_target_address_out == btb_target_address_out))else #1 exit_on_error; 
		end
	endtask

	task test_push_to_ras;
		begin
			if (if_en_branch & !if_cond_branch & !if_direct_branch) begin
				
			end
		end
	endtask

// Add for corner cases
	task _check_for_correct_ras;
		begin
		// Check the RAS is updated correctly when unconditional
		// indirect is fetched or return branch is fetched
			
			//Unconditional indirect : RAS updates pc+4 to its
			//next queue
			if(if_en_branch & !if_cond_branch & !if_direct_branch) begin
				test_ras_stack_out[test_ras_tail_out] 	= if_pc_in + 4;
				test_ras_head_out 			= test_ras_head_out;
				test_ras_tail_out 			= test_ras_tail_out + 1;

			end

			// return : next PC is from RAS
			if(if_en_branch & if_return_branch) begin
				test_ras_head_out = test_ras_head_out + 1;
				test_ras_tail_out = test_ras_tail_out;

			end
			assert((ras_stack_out == test_ras_stack_out) & (ras_head_out == test_ras_head_out) & (ras_tail_out == test_ras_tail_out)) else #1 exit_on_error;
	
		end
	endtask

	integer gshare_i;

	task _check_for_correct_gshare;
		// Check the gshare is updated correctly when conditional is
		// retired and prediction is wrong
/*
		begin
		// During retire
			if(rt_en_branch & rt_cond_branch & !rt_prediction_correct) begin
				if(test_obq_head_out != test_obq_tail_out) begin
					test_gshare_ght_out = test_obq_out[test_obq_head_out]; 
					test_gshare_pht_out[test_gshare_ght_out ^ rt_pc[`PC_SIZE+1:2]] = ~ test_gshare_pht_out[test_gshare_ght_out ^ rt_pc[`PC_SIZE+1:2]];
				end
			else  begin
				if (if_en_branch & if_cond_branch) begin
		// During fetch
	 				test_gshare_ght_out = {test_gshare_ght_out[`BH_SIZE-1:0],test_gshare_pht_out[if_pc_in[(`PC_SIZE+1):2]^test_gshare_ght_out]};
				end
			end
		end
*/			
	endtask

	task _check_for_correct_obq;
		// Check the obq is updated correctly when conditional is
		// retired and prediction is wrong
	endtask

	task _check_for_correct_bp;
		_check_for_correct_btb;
		//_check_for_correct_ras;
		//_check_for_correct_obq;
		//_check_for_correct_gshare;
		// Check the correct output logic
		
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
			for (i = 0; i < `OBQ_SIZE; ++i) begin$display("index: %d branch_history: %b", i, obq_out[i].branch_history);
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
		if_return_branch	= 1'b0;
		if_pc_in 		= 32'h0;
		//Input from retire
		rt_en_branch		= 1'b0;
		rt_cond_branch		= 1'b0;
		rt_direct_branch	= 1'b0;
		rt_return_branch	= 1'b0;
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

		$display("\n 1. Testing Fetch Single Condition Direct...");

		@(negedge clock);
		reset 			= 1'b0;
		enable 			= 1'b1;
		//Input from fetch
		if_en_branch		= 1'b1;
		if_cond_branch		= 1'b1;
		if_direct_branch	= 1'b1;
		if_return_branch	= 1'b0;
		if_pc_in 		= 32'h40;
		//Input from retire
		rt_en_branch		= 1'b0;
		rt_cond_branch		= 1'b0;
		rt_direct_branch	= 1'b0;
		rt_return_branch	= 1'b0;
		rt_branch_taken		= 1'b0;
		rt_prediction_correct	= 1'b0;
		rt_pc			= 32'h0;
		rt_calculated_pc	= 32'h0;
		rt_branch_index		= {$clog2(`OBQ_SIZE){1'b0}}; 

		@(posedge clock);
		`DELAY;
		assert(next_pc_valid == 1) else #1 exit_on_error;
		assert(next_pc_index == 0) else #1 exit_on_error;
		assert(next_pc == 32'h44) else #1 exit_on_error;
		assert(next_pc_prediction == 0) else #1 exit_on_error;
		// correct obq
		assert((obq_head_out == 0) & (obq_tail_out == 1)) else #1 exit_on_error;
		assert(obq_out[0] == 0) else #1 exit_on_error;
		_check_for_correct_gshare_reset;
		_check_for_correct_btb_reset;
		_check_for_correct_ras_reset;

		$display("Fetch Single Condition Direct Passed");

		$display("\n 2. Testing Fetch Single Condition Indirect...");

		// insert
		@(negedge clock);
		reset 			= 1'b0;
		enable 			= 1'b1;
		//Input from fetch
		if_en_branch		= 1'b1;
		if_cond_branch		= 1'b1;
		if_direct_branch	= 1'b0;
		if_return_branch	= 1'b0;
		if_pc_in 		= 32'h44;
		//Input from retire
		rt_en_branch		= 1'b0;
		rt_cond_branch		= 1'b0;
		rt_direct_branch	= 1'b0;
		rt_return_branch	= 1'b0;
		rt_branch_taken		= 1'b0;
		rt_prediction_correct	= 1'b0;
		rt_pc			= 32'h0;
		rt_calculated_pc	= 32'h0;
		rt_branch_index		= {$clog2(`OBQ_SIZE){1'b0}};

		@(posedge clock);
		`DELAY;
		assert(next_pc_valid == 1) else #1 exit_on_error;
		assert(next_pc_index == 1) else #1 exit_on_error;
		assert(next_pc == 32'h48) else #1 exit_on_error;
		assert(next_pc_prediction == 0) else #1 exit_on_error;
		// correct obq
		assert((obq_head_out == 0) & (obq_tail_out == 2)) else #1 exit_on_error;
		assert(obq_out[0] == 0) else #1 exit_on_error;
		assert(obq_out[1] == 0) else #1 exit_on_error;
		_check_for_correct_gshare_reset;
		_check_for_correct_btb_reset;
		_check_for_correct_ras_reset;	

		$display("Fetch Single Condition Indirect Passed");

		$display("\n 3. Testing Fetch Single Unconditional Direct...");

		@(negedge clock);
		reset 			= 1'b0;
		enable 			= 1'b1;
		//Input from fetch
		if_en_branch		= 1'b1;
		if_cond_branch		= 1'b0;
		if_direct_branch	= 1'b1;
		if_return_branch	= 1'b0;
		if_pc_in 		= 32'h60;
		//Input from retire
		rt_en_branch		= 1'b0;
		rt_cond_branch		= 1'b0;
		rt_direct_branch	= 1'b0;
		rt_return_branch	= 1'b0;
		rt_branch_taken		= 1'b0;
		rt_prediction_correct	= 1'b0;
		rt_pc			= 32'h0;
		rt_calculated_pc	= 32'h0;
		rt_branch_index		= {$clog2(`OBQ_SIZE){1'b0}};

		@(posedge clock);
		`DELAY;
		assert(next_pc_valid == 1) else #1 exit_on_error;
		assert(next_pc_index == 0) else #1 exit_on_error;
		assert(next_pc == 32'h64) else #1 exit_on_error;
		assert(next_pc_prediction == 0) else #1 exit_on_error;
		// correct obq
		assert((obq_head_out == 0) & (obq_tail_out == 2)) else #1 exit_on_error;
		assert(obq_out[0] == 0) else #1 exit_on_error;
		assert(obq_out[1] == 0) else #1 exit_on_error;
		_check_for_correct_gshare_reset;
		_check_for_correct_btb_reset;
		_check_for_correct_ras_reset;	

		$display("Fetch Single Unconditional Direct Passed");

		$display("\n 4. Testing Fetch Single Unconditional Indirect,return...");

		@(negedge clock);
		reset 			= 1'b0;
		enable 			= 1'b1;
		//Input from fetch
		if_en_branch		= 1'b1;
		if_cond_branch		= 1'b0;
		if_direct_branch	= 1'b0;
		if_return_branch	= 1'b1;
		if_pc_in 		= 32'h60;
		//Input from retire
		rt_en_branch		= 1'b0;
		rt_cond_branch		= 1'b0;
		rt_direct_branch	= 1'b0;
		rt_return_branch	= 1'b0;
		rt_branch_taken		= 1'b0;
		rt_prediction_correct	= 1'b0;
		rt_pc			= 32'h0;
		rt_calculated_pc	= 32'h0;
		rt_branch_index		= {$clog2(`OBQ_SIZE){1'b0}};

		@(posedge clock);
		`DELAY;
		assert(next_pc_valid == 1) else #1 exit_on_error;
		assert(next_pc_index == 0) else #1 exit_on_error;
		assert(next_pc == 32'h64) else #1 exit_on_error;
		assert(next_pc_prediction == 0) else #1 exit_on_error;
		// correct obq
		assert((obq_head_out == 0) & (obq_tail_out == 2)) else #1 exit_on_error;
		assert(obq_out[0] == 0) else #1 exit_on_error;
		assert(obq_out[1] == 0) else #1 exit_on_error;
		_check_for_correct_gshare_reset;
		_check_for_correct_btb_reset;
		_check_for_correct_ras_reset;	

		$display("Fetch Single Unconditional indirect, return Passed");



		$display("\n 5. Testing Fetch Single Unconditional Indirect, no return...");

		@(negedge clock);
		reset 			= 1'b0;
		enable 			= 1'b1;
		//Input from fetch
		if_en_branch		= 1'b1;
		if_cond_branch		= 1'b0;
		if_direct_branch	= 1'b0;
		if_return_branch	= 1'b0;
		if_pc_in 		= 32'h120;
		//Input from retire
		rt_en_branch		= 1'b0;
		rt_cond_branch		= 1'b0;
		rt_direct_branch	= 1'b0;
		rt_return_branch	= 1'b0;
		rt_branch_taken		= 1'b0;
		rt_prediction_correct	= 1'b0;
		rt_pc			= 32'h0;
		rt_calculated_pc	= 32'h0;
		rt_branch_index		= {$clog2(`OBQ_SIZE){1'b0}};

		@(posedge clock);
		`DELAY;
		assert(next_pc_valid == 1) else #1 exit_on_error;
		assert(next_pc_index == 0) else #1 exit_on_error;
		assert(next_pc == 32'h124) else #1 exit_on_error;
		assert(next_pc_prediction == 0) else #1 exit_on_error;
		// correct obq
		assert(( obq_head_out == 0) && (obq_tail_out == 2)) else #1 exit_on_error;
		assert(obq_out[0] == 0) else #1 exit_on_error;
		assert(obq_out[1] == 0) else #1 exit_on_error;
		_check_for_correct_gshare_reset;
		_check_for_correct_btb_reset;
		//_check_for_correct_ras_reset;	
		//RAS check
		assert((ras_stack_out[0] == 292) & (ras_head_out == 0) & (ras_tail_out == 1)) else #1 exit_on_error;

		$display("Fetch Single Unconditional Indirect, no return Passed");

		$display("\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@			Simple Fetch Test Passed 		@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");

		
		$display("\n 6. Testing Retire Branch - Update BTB only - Branch is taken but prediction is correct for unconditional and direct");
		@(negedge clock);
		reset 			= 1'b0;
		enable 			= 1'b1;
		//Input from fetch
		if_en_branch		= 1'b0;
		if_cond_branch		= 1'b0;
		if_direct_branch	= 1'b0;
		if_return_branch	= 1'b0;
		if_pc_in 		= 32'h100;
		//Input from retire
		rt_en_branch		= 1'b1;
		rt_cond_branch		= 1'b0;
		rt_direct_branch	= 1'b1;
		rt_return_branch	= 1'b0;
		rt_branch_taken		= 1'b1;
		rt_prediction_correct	= 1'b1;
		rt_pc			= 32'h40;
		rt_calculated_pc	= 32'h60;
		rt_branch_index		= 0;

		@(posedge clock);
		`DELAY;
		assert(next_pc_valid == 0) else #1 exit_on_error;
		//assert(next_pc_index == ) else #1 exit_on_error;
		//assert(next_pc == 32'bx) else #1 exit_on_error;
		//assert(next_pc_prediction == 0) else #1 exit_on_error;
		// correct obq
		assert((obq_head_out == 0) & (obq_tail_out == 2)) else #1 exit_on_error;
		assert(obq_out[0] == 0) else #1 exit_on_error;
		assert(obq_out[1] == 0) else #1 exit_on_error;
		// correct btb 
		_check_for_correct_btb_write;
		_check_for_correct_gshare_reset;
		assert((ras_stack_out[0] == 292) & (ras_head_out == 0) & (ras_tail_out == 1)) else #1 exit_on_error;
		$display("Testing Retire Branch - Update BTB only passed");


		$display("\n 7. Testing Retire Branch - Update Gshare and OBQ + BTB - Branch is taken but prediction is incorrect for conditional direct");
		@(negedge clock);
		reset 			= 1'b0;
		enable 			= 1'b1;
		//Input from fetch
		if_en_branch		= 1'b0;
		if_cond_branch		= 1'b0;
		if_direct_branch	= 1'b0;
		if_return_branch	= 1'b0;
		if_pc_in 		= 32'h100;
		//Input from retire
		rt_en_branch		= 1'b1;
		rt_cond_branch		= 1'b1;
		rt_direct_branch	= 1'b1;
		rt_return_branch	= 1'b0;
		rt_branch_taken		= 1'b1;
		rt_prediction_correct	= 1'b0;
		rt_pc			= 32'b11100;
		rt_calculated_pc	= 32'b11111100;
		rt_branch_index		= 1;
		
		print_obq;
		`DELAY;
		$display("LOOK HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
		$display("ghsare_prediction_valid (write_en): %b clear_en: %b clear_index: %d shift_en: %b shift_index: %d", bp.gshare_prediction_valid, bp.clear_en, bp.rt_branch_index, bp.shift_en, bp.rt_branch_index); 

		@(posedge clock);
		`DELAY;
		$display("LOOK HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
		$display("ghsare_prediction_valid (write_en): %b clear_en: %b clear_index: %d shift_en: %b shift_index: %d", bp.gshare_prediction_valid, bp.clear_en, bp.rt_branch_index, bp.shift_en, bp.rt_branch_index); 

	
		assert(next_pc_valid == 0) else #1 exit_on_error;
		//assert(next_pc_index == ) else #1 exit_on_error;
		//assert(next_pc == 32'bx) else #1 exit_on_error;
		//assert(next_pc_prediction == 0) else #1 exit_on_error;
		// correct obq
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ OBQ test should be done later@@@@@@@@@@@@@@@@@@@@@@@");
		print_obq;
		assert((obq_head_out == 0) & (obq_tail_out == 1)) else #1 exit_on_error;
		assert(obq_out[0] == 0) else #1 exit_on_error;
		// correct btb
		_check_for_correct_btb_write;
		// correct gshare
		assert((gshare_ght_out==0) & ( gshare_pht_out[gshare_ght_out^rt_pc[`BH_SIZE+1:2]]==1)) else #1 exit_on_error;
		// correct ras
		assert((ras_stack_out[0] == 292) & (ras_head_out == 0) & (ras_tail_out == 1)) else #1 exit_on_error;
		$display("Testing Retire Branch - Update Gshare and OBQ + BTB passed");


		$display("\n 8. Testing Retire Branch - return branch - do nothing");
		@(negedge clock);
		reset 			= 1'b0;
		enable 			= 1'b1;
		//Input from fetch
		if_en_branch		= 1'b0;
		if_cond_branch		= 1'b0;
		if_direct_branch	= 1'b0;
		if_return_branch	= 1'b0;
		if_pc_in 		= 32'h100;
		//Input from retire
		rt_en_branch		= 1'b1;
		rt_cond_branch		= 1'b0;
		rt_direct_branch	= 1'b0;
		rt_return_branch	= 1'b1;
		rt_branch_taken		= 1'b1;
		rt_prediction_correct	= 1'b0;
		rt_pc			= 32'b10101000;
		rt_calculated_pc	= 32'b11011000;
		rt_branch_index		= 0;

		@(posedge clock);
		`DELAY;
		assert((next_pc_valid == 0)) else #1 exit_on_error;
		//assert(next_pc_index == ) else #1 exit_on_error;
		//assert(next_pc == 292) else #1 exit_on_error;
		//assert(next_pc_prediction == 1) else #1 exit_on_error;
		// correct obq - need to modify obq tomorrow (head advance)
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@   OBQ test should be done later @@@@@@@@@@@@@@@@@@");
		assert((obq_head_out == 1)&(obq_tail_out == 2)) else #1 exit_on_error;
		assert(obq_out[1] == 0) else #1 exit_on_error;
		// correct btb
		_check_for_correct_btb_write;
		// correct gshare
		assert((gshare_ght_out==0)) else #1 exit_on_error;
		// correct RAS
		
		assert((ras_stack_out[0] == 292)&(ras_head_out == 0) & (ras_tail_out == 1) ) else #1 exit_on_error;	

		$display("Testing retire Branch - Read RAS and clear it passed");

		$display("\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@			Simple Retire Test Passed 		@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");

		$display("\n 9. Testing Fetch return branch - Read RAS and clear it, mark as branch taken");
		@(negedge clock);
		reset 			= 1'b0;
		enable 			= 1'b1;
		//Input from fetch
		if_en_branch		= 1'b1;
		if_cond_branch		= 1'b0;
		if_direct_branch	= 1'b0;
		if_return_branch	= 1'b1;
		if_pc_in 		= 32'h110;
		//Input from retire
		rt_en_branch		= 1'b0;
		rt_cond_branch		= 1'b1;
		rt_direct_branch	= 1'b0;
		rt_return_branch	= 1'b1;
		rt_branch_taken		= 1'b1;
		rt_prediction_correct	= 1'b0;
		rt_pc			= 32'b10101000;
		rt_calculated_pc	= 32'b11011000;
		rt_branch_index		= 0;

		@(posedge clock);
		`DELAY;
		
		assert((next_pc_valid == 1)) else #1 exit_on_error;
		//assert(next_pc_index == ) else #1 exit_on_error;
		assert(next_pc == 292) else #1 exit_on_error;
		assert(next_pc_prediction == 1) else #1 exit_on_error;
		// correct obq - need to modify obq tomorrow (head advance)
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@   OBQ test should be done later @@@@@@@@@@@@@@@@@@");
		//assert((obq_head_out == 1)&(obq_tail_out == 2)) else #1 exit_on_error;
		//assert(obq_out[1] == 0) else #1 exit_on_error;
		// correct btb
		_check_for_correct_btb_write;
		// correct gshare
		assert((gshare_ght_out==0)) else #1 exit_on_error;
		// correct RAS
		assert((ras_head_out == 0) & (ras_tail_out == 0) ) else #1 exit_on_error;	

		$display("Testing fetch return branch - read RAS and clear it  passed");

		$display("\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@			Start random testing			@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");





		// Reset
		@(negedge clock);
		$display("\n--------------------------------RESET----------------------------------\n"); 
		reset = 1'b1;
		enable = 1'b0;
		// Initialize the test value

		test_next_pc_valid = 1'b0;
		test_next_pc_index = {($clog2(`OBQ_SIZE)+1){0}};
		test_next_pc = 32'h0;
		test_next_pc_prediction = 1'b0;
		`ifdef DEBUG
		test_gshare_ght_out ={`BH_SIZE{0}};
		test_gshare_pht_out = {(2**(`BH_SIZE)){0}};
		test_obq_out = {`OBQ_SIZE{0}};
		test_obq_head_out = {($clog2(`OBQ_SIZE)){0}};
		test_obq_tail_out = {($clog2(`OBQ_SIZE)){0}};
		test_btb_valid_out = {`BTB_ROW{0}};
		test_btb_tag_out= {(`BTB_ROW*`TAG_SIZE){0}};
		test_btb_target_address_out = {(`BTB_ROW*`TARGET_SIZE){0}};
		test_ras_stack_out ={(`RAS_SIZE*32){0}};
		test_ras_head_out ={($clog2(`RAS_SIZE)){0}};
		test_ras_tail_out ={($clog2(`RAS_SIZE)){0}};
		`endif
		@(negedge clock);
		reset = 1'b0;
		enable = 1'b1;
		@(posedge clock);
		`DELAY;
		check_for_correct_reset;
		$display("Reset Passed");
		

	
		for(int counter=0; counter<10; counter++) begin
			$display("\n--------------------------------------");
			$display("%dth Random testing", counter+1);
			@(negedge clock);

			if_en_branch		= $urandom_range(1,0);
			if_cond_branch		= $urandom_range(1,0);
			if_direct_branch	= $urandom_range(1,0);
			if_return_branch	= $urandom_range(1,0);
			if_pc_in 		= $urandom;
			//Input from retire
			rt_en_branch		= $urandom_range(1,0);
			rt_cond_branch		= $urandom_range(1,0);
			rt_direct_branch	= $urandom_range(1,0);
			rt_return_branch	= $urandom_range(1,0);
			rt_branch_taken		= $urandom_range(1,0);
			rt_prediction_correct	= $urandom_range(1,0);
			rt_pc			= $urandom;
			rt_calculated_pc	= $urandom;
			rt_branch_index		= $urandom_range(`OBQ_SIZE,0);

			//update_modules;
			@(posedge clock);
			`DELAY
			_check_for_correct_bp;


		end

		$display("Random testing passed");

	
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


