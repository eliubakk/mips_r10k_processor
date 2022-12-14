`define DEBUG
`define DELAY #2

`include "../../sys_defs.vh"
/*`include "../../verilog/BTB.v"
`include "../../verilog/OBQ.v"
`include "../../verilog/GSHARE.v"
`include "../../verilog/RAS.v"
`timescale 1ns/100ps
*/	
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

/*	logic		[`BH_SIZE-1:0]				gshare_ght_out;
	logic		[2**(`BH_SIZE)-1:0]			gshare_pht_out;
	OBQ_ROW_T 	[`OBQ_SIZE-1:0]				obq_out;
	logic 		[$clog2(`OBQ_SIZE)-1:0] 		obq_head_out;
	logic 		[$clog2(`OBQ_SIZE)-1:0] 		obq_tail_out;*/
	logic		[`PHT_ROW-1:0][1:0]			pht_out;
	logic 		[`BTB_ROW-1:0]				btb_valid_out;
	logic		[`BTB_ROW-1:0]	[`TAG_SIZE-1:0]		btb_tag_out;
	logic		[`BTB_ROW-1:0]	[`TARGET_SIZE-1:0]	btb_target_address_out;
	logic 		[`RAS_SIZE - 1:0] [31:0] 		ras_stack_out;
	logic 		[$clog2(`RAS_SIZE) - 1:0] 		ras_head_out;
	logic 		[$clog2(`RAS_SIZE) - 1:0] 		ras_tail_out;

	// Testing varilables for BP

	logic							test_next_pc_valid;
	logic	[$clog2(`OBQ_SIZE):0]				test_next_pc_index;
	logic	[31:0]						test_next_pc;
	logic							test_next_pc_prediction;
	// Branch predictor module

	integer i,j,k,l;

	BP2 bp2(
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
		/*.gshare_ght_out(gshare_ght_out),
		.gshare_pht_out(gshare_pht_out),		
		.obq_out(obq_out),
		.obq_head_out(obq_head_out),
		.obq_tail_out(obq_tail_out),*/
		.pht_out(pht_out),
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

	task reset_test;
		begin
			check_for_correct_bp_reset;
			check_for_correct_btb_reset;
			check_for_correct_ras_reset;
			assert(!next_pc_valid) else #1 exit_on_error;
		end
	endtask

	task check_for_correct_bp_reset;
		begin
			for(i=0;i<`PHT_ROW;++i) begin
				assert( pht_out[i] == 2'b01 ) else #1 exit_on_error;
			end
		end
	endtask

	task check_for_correct_btb_reset;
		begin
			assert(btb_valid_out == 0) else #1 exit_on_error;
			assert(btb_tag_out == 0) else #1 exit_on_error;
			for ( i = 0; i < `BTB_ROW; ++i) begin
				assert(btb_tag_out[i] == 0) else #1 exit_on_error;
				assert(btb_target_address_out[i] == 0) else #1 exit_on_error;
			end
		end
	endtask

	task check_for_correct_ras_reset;
		begin
			assert(ras_head_out == 0) else #1 exit_on_error;
			assert(ras_tail_out == 0) else #1 exit_on_error;
			for ( i = 0; i < `RAS_SIZE; ++i) begin
				assert(ras_stack_out[i] == 0) else #1 exit_on_error;
			end
		end
	endtask

	task print_pht;
		begin
			$display("-------------------PHT--------------------");
			for(j=0;j<`PHT_ROW;j=j+1) begin
				$display("Idx %1.0d : Prediction %2.0b", j, pht_out[j][1:0]);	
			end

		end
	endtask

	task print_btb;
		begin
			$display("---------------------BTB-------------------------");
			$display("btb_valid_out: %b", btb_valid_out);
			$display("BTB Tag Out");
			for ( i = 0; i < `BTB_ROW; ++i) begin
				$display("btb_tag[%d] = %b", i, btb_tag_out[i]);
			end
			$display("BTB Target Address Out");
			for ( i = 0; i < `BTB_ROW; ++i) begin
				$display("btb_target[%d] = %d", i, btb_target_address_out[i]);
			end
		end
	endtask

	task print_ras;
		begin
			$display("----------------------RAS-----------------------");
			$display("head: %d tail: %d", ras_head_out, ras_tail_out);
			for ( i = 0; i < `RAS_SIZE; ++i) begin
				$display("ras[%d] = %d", i, ras_stack_out[i]);
			end
		end
	endtask

	task print_bp;
		begin
			$display("--------------BP--------------------------");
			$display(" Fetch : if_en_branch : %b, if_cond_branch : %b, if_direct_branch : %b, if_return_branch : %b, if_pc_in : %h", if_en_branch, if_cond_branch, if_direct_branch, if_return_branch, if_pc_in);
			$display(" Retire : rt_en_branch : %b, rt_cond_branch : %b, rt_direct_branch : %b, rt_return_branch : %b, rt_pc : %h", rt_en_branch, rt_cond_branch, rt_direct_branch, rt_return_branch, rt_pc);
			$display(" Retire : rt_branch_taken : %b, rt_prediction_correct : %b, rt_calculated_pc : %h, rt_branch_index : %b", rt_branch_taken, rt_prediction_correct, rt_calculated_pc, rt_branch_index);
			$display(" Result : next_pc_valid : %b, next_pc_index : %d, next_pc : %h, next_pc_prediction : %b", next_pc_valid, next_pc_index,next_pc, next_pc_prediction);
			print_pht;
			print_btb;
			print_ras;
		end
	endtask


	
	initial begin
		
		$monitor("Clock: %4.0f, reset: %b, enable: %b", clock, reset, enable);
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



		// --------Reset test
		//
		$display("\nReset test");		
		@(negedge clock);
		reset = 1'b1;
		@(posedge clock);
		`DELAY;
		reset_test;	
		$display("@@@Reset test passed\n");



		// -------- Retire some instructions
		$display("\n Retire some instructions");
		@(negedge clock);
		reset 			= 1'b0;
		enable 			= 1'b1;
		//Input from retire
		rt_en_branch		= 1'b1;
		rt_cond_branch		= 1'b1;
		rt_direct_branch	= 1'b1;
		rt_return_branch	= 1'b0;
		rt_branch_taken		= 1'b1;
		rt_prediction_correct	= 1'b0;
		rt_pc			= 32'h4;
		rt_calculated_pc	= 32'hfff;
		rt_branch_index		= 3;
		
		@(posedge clock);
		`DELAY;
		print_bp;

		@(negedge clock);
		@(posedge clock);
		`DELAY;
		print_bp;
		

		//----------Fetch some instructions
		@(negedge clock);
		//Input from fetch
		if_en_branch		= 1'b1;
		if_cond_branch		= 1'b1;
		if_direct_branch	= 1'b1;
		if_return_branch	= 1'b0;
		if_pc_in 		= 32'h8;
		//Input from retire
		rt_en_branch		= 1'b0;

		@(posedge clock);
		`DELAY;
		print_bp;	

		@(negedge clock);
		//Input from fetch
		if_en_branch		= 1'b1;
		if_cond_branch		= 1'b1;
		if_direct_branch	= 1'b1;
		if_return_branch	= 1'b0;
		if_pc_in 		= 32'h4;
		//Input from retire
		rt_en_branch		= 1'b0;

		@(posedge clock);
		`DELAY;
		print_bp;	


		// -------Retire test

		$display("@@@passed");
		$finish;		
	end

	
	
endmodule


