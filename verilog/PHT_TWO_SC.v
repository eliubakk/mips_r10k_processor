// multiple row - 2 bit saturation counter - Pattern history table
//
`define DEBUG
`include "../../sys_defs.vh"
module PHT_TWO_SC(
		input				clock,
		input				reset,
		input				enable,
		input				if_branch, // Branch is fetched and conditional
		input		[31:0]		if_pc_in,
		input				rt_branch, // Branch is retired and conditional
		input		[31:0]		rt_pc_in,
		input				rt_branch_taken, // Calculated branch result, 0 is not taken, 1 is taken

		`ifdef DEBUG
		output	[`PHT_ROW-1:0][1:0]	pht_out,
		`endif
		output				if_prediction_valid,    // Check whether the prediction is valid or not
		output				if_prediction		// Predicted to be taken or not
		
	);
	// 00 : strongly not taken, 01 : weakly not taken, 10 : weakly taken,
	// 11 : strongly taken 	


	logic 	[`PHT_ROW-1:0] [1:0] 	pht;
	logic 	[`PHT_ROW-1:0] [1:0] 	next_pht;
	logic	[$clog2(`PHT_ROW)-1:0]   if_pc_partial;
	logic	[$clog2(`PHT_ROW)-1:0]   rt_pc_partial;

	integer i;
	`ifdef DEBUG
	assign pht_out 	= pht;
	`endif	

	assign if_pc_partial	=  if_pc_in [$clog2(`PHT_ROW)+1:2]; // do not consider the byte offset
	assign if_prediction_valid = if_branch; 
	assign if_prediction	=  if_prediction_valid ? next_pht[if_pc_partial][1]: 0;
				


	assign rt_pc_partial	=  rt_pc_in [$clog2(`PHT_ROW)+1:2]; // do not consider the byte offset
	//assign prediction	=  pht[pc_partial][1]; 
	
	always_comb begin
		next_pht	= pht;

		if(enable) begin
			// During retire, update the prediction table first
			if(rt_branch) begin

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

  // synopsys sync_set_reset "reset"
	always_ff @(posedge clock) begin
		if(reset) begin
			for(i=0; i<`PHT_ROW;++i) begin
				pht[i]	<= `SD 2'b01; // Initialized to be weakly not taken
			end
		end else begin
			pht	<= `SD  next_pht;
		end

	end
endmodule
