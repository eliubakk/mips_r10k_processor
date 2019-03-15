// multiple row - 2 bit saturation counter - Pattern history table
//
`define DEBUG_OUT
`define PHT_ROW	8

module PHT_TWO_SC(
		input				clock,
		input				reset,
		input				enable,
		input				branch_taken, // Calculated branch result, 0 is not taken, 1 is taken
		input	[32:0]			pc_in,		

		`ifdef DEBUG_OUT
		output	[`PHT_ROW-1:0][1:0]	pht_out,
		`endif
		output		prediction
		
	);
	// 00 : strongly not taken, 01 : weakly not taken, 10 : weakly taken,
	// 11 : strongly taken 	

	parameter	PHT_ROW		= 8;

	logic 	[`PHT_ROW-1:0] [1:0] 	pht;
	logic 	[`PHT_ROW-1:0] [1:0] 	next_pht;
	logic	[$clog2(`PHT_ROW)-1:0]   pc_partial;

	`ifdef DEBUG_OUT
	assign pht_out 	= pht;
	`endif	

	assign pc_partial	=  pc_in [$clog2(`PHT_ROW)+1:2]; // do not consider the byte offset
	assign prediction	=  pht[pc_partial][1]; 
	
	always_comb begin
		next_pht	= pht;
		

		if(enable) begin
			
			case(pht[pc_partial][1:0])
				2'b00: begin
						if(branch_taken) begin
							next_pht[pc_partial][1:0] = 2'b01;
						end else begin
							next_pht[pc_partial][1:0] = 2'b00;
						end
					end
				2'b01: begin
						if(branch_taken) begin
							next_pht[pc_partial][1:0] = 2'b10;
						end else begin
							next_pht[pc_partial][1:0] = 2'b00;
						end

					end
				2'b10: begin
						if(branch_taken) begin
							next_pht[pc_partial][1:0] = 2'b11;
						end else begin
							next_pht[pc_partial][1:0] = 2'b01;
						end
					end
				2'b11: begin
						if(branch_taken) begin
							next_pht[pc_partial][1:0] = 2'b11;
						end else begin
							next_pht[pc_partial][1:0] = 2'b10;
						end
					end
		endcase

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
