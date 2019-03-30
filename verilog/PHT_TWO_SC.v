// multiple row - 2 bit saturation counter - Pattern history table
//
`define DEBUG
`define PHT_ROW 8
`timescale 1ns/100ps
module PHT_TWO_SC(
		input				clock,
		input				reset,
		input				enable,
		input				if_branch,
		input		[31:0]		if_pc_in,
		input				if_cond_branch,
		input				if_direct_branch,
		input				if_return_branch,
		input				rt_branch,
		input		[31:0]		rt_pc_in,
		input				rt_cond_branch,
		input				rt_direct_branch,
		input				rt_return_branch,
		input				rt_branch_taken, // Calculated branch result, 0 is not taken, 1 is taken

		`ifdef DEBUG
		output	[`PHT_ROW-1:0][1:0]	pht_out,
		`endif
		output				if_prediction,
		output				if_prediction_valid
		
	);
	// 00 : strongly not taken, 01 : weakly not taken, 10 : weakly taken,
	// 11 : strongly taken 	


	logic 	[`PHT_ROW-1:0] [1:0] 	pht;
	logic 	[`PHT_ROW-1:0] [1:0] 	next_pht;
	logic	[$clog2(`PHT_ROW)-1:0]   if_pc_partial;
	logic	[$clog2(`PHT_ROW)-1:0]   rt_pc_partial;

	`ifdef DEBUG
	assign pht_out 	= pht;
	`endif	

	assign if_pc_partial	=  if_pc_in [$clog2(`PHT_ROW)+1:2]; // do not consider the byte offset
	assign if_prediction_valid = if_branch & if_cond_branch & !if_return_branch; 
	assign if_prediction	=  if_prediction_valid? next_pht[if_pc_partial][1]: 0;
				


	assign rt_pc_partial	=  rt_pc_in [$clog2(`PHT_ROW)+1:2]; // do not consider the byte offset
	//assign prediction	=  pht[pc_partial][1]; 
	
	always_comb begin
		next_pht	= pht;

		if(enable) begin
			// During retire, update the prediction table first
			if(rt_branch & rt_cond_branch & !rt_return_branch) begin

				case(pht[rt_pc_partial][1:0])
					2'b00: begin
							if(rt_branch_taken) begin
								next_pht[rt_pc_partial][1:0] = 2'b01;
							end else begin
								next_pht[rt_pc_partial][1:0] = 2'b00;
							end
						end
					2'b01: begin
							if(rt_branch_taken) begin
								next_pht[rt_pc_partial][1:0] = 2'b10;
							end else begin
								next_pht[rt_pc_partial][1:0] = 2'b00;
							end
	
						end
					2'b10: begin
							if(rt_branch_taken) begin
								next_pht[rt_pc_partial][1:0] = 2'b11;
							end else begin
								next_pht[rt_pc_partial][1:0] = 2'b01;
							end
						end
					2'b11: begin
							if(rt_branch_taken) begin
								next_pht[rt_pc_partial][1:0] = 2'b11;
							end else begin
								next_pht[rt_pc_partial][1:0] = 2'b10;
							end
						end
				endcase
			end

		end
	end


	always_ff @(posedge clock) begin
		if(reset) begin
			pht	<=  {(2*`PHT_ROW){0}}; // Initialized to strongly not taken
		end else begin
			pht	<= #1 next_pht;
		end

	end
endmodule
