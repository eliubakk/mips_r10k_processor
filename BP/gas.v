// 4 bit global history - 4 entry per-set PHT  - 1 bit predictor bit
//
`define DEBUG_OUT
`define GHT_BIT		4
`define PHT_PC_BIT	2


module GAS(
		input							clock,
		input							reset,
		input							enable,
		input							branch_taken, // Calculated branch result, 0 is not taken, 1 is taken
		input	[32:0]						pc_in,		

		`ifdef DEBUG_OUT
		output	[`GHT_BIT-1:0]					ght_out,
		output	[2**(`GHT_BIT)-1:0][2**(`PHT_PC_BIT)-1:0]	pht_out,
		`endif
		output		prediction
		
	);
	// 0 : not taken, 1 : taken
	//
	// ght is updated in this cycle, but ght finds its value from pht by
	// indexing previous ght value


		logic		[`GHT_BIT-1:0]					ght;
		logic		[`GHT_BIT-1:0]					next_ght;
		logic		[2**(`GHT_BIT)-1:0][2**(`PHT_PC_BIT)-1:0]	pht;
		logic		[2**(`GHT_BIT)-1:0][2**(`PHT_PC_BIT)-1:0]	next_pht;
		logic		[(`PHT_PC_BIT+1):2]				pc_partial;

	`ifdef DEBUG_OUT
	assign pht_out 	= pht;
	assign ght_out	= ght;
	`endif	

	assign pc_partial	=  pc_in [(`PHT_PC_BIT)+1:2]; // do not consider the byte offset
	assign prediction	=  pht[ght][pc_partial]; 
	
	always_comb begin
		next_pht	= pht;
		next_ght	= ght;
		
				
		if(enable) begin

			if(branch_taken) begin
				next_pht[ght][pc_partial] = 1'b1;
				next_ght		  = {ght[`GHT_BIT-2:0],1'b1};
			end else begin
				next_pht[ght][pc_partial] = 1'b0;
				next_ght		  = {ght[`GHT_BIT-2:0],1'b0};
			end
		end
	end

	// Should also add the speculatively update ght and roll back if the
	// prediction was wrong


	always_ff @(posedge clock) begin
		if(reset) begin
			pht	<=  {(2**`GHT_BIT)*(2**`PHT_PC_BIT){1'b0}}; // Initialized to not taken
			ght	<=  {`GHT_BIT{1'b0}};
		end else begin
			pht	<= next_pht;
			ght	<= next_ght;
		end

	end
endmodule
