// 4 bit global history - 4 entry per-set PHT  - 1 bit predictor bit
//
// For speculation and Roll back, we will record the BHT value (for ex, 10
// more bits of BHT) & counter, Everytime we find the misprediction, we roll
// back the GHT (How about indexing?)
//
// Also, PHT is updated only when we figure out the prediction result
//
// OBQ : 16 entry, OBQ tag is 4 bit
// OBQ length : 10 bit 
//
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
		output							prediction_out
		
	);
	// 0 : not taken, 1 : taken
	//
	// first : find the prediction value based on the GHT and PHT
	// Second : update the PHT
	// Third : update the GHT
	//


		logic		[`GHT_BIT-1:0]					ght;
		logic		[`GHT_BIT-1:0]					next_ght;
		logic		[2**(`GHT_BIT)-1:0][2**(`PHT_PC_BIT)-1:0]	pht;
		logic		[2**(`GHT_BIT)-1:0][2**(`PHT_PC_BIT)-1:0]	next_pht;
		logic		[(`PHT_PC_BIT+1):2]				pc_partial;
		logic								prediction;
		logic								next_prediction;

	`ifdef DEBUG_OUT
	assign pht_out 	= pht;
	assign ght_out	= ght;
	`endif	

	assign prediction_out	= prediction;

	assign pc_partial	=  pc_in [(`PHT_PC_BIT)+1:2]; // do not consider the byte offset

	always_comb begin
		next_pht	= pht;
		next_ght	= ght;
		next_prediction	= prediction;

		if(enable) begin

			next_prediction			= pht	[ght] [pc_partial];

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
			pht		<=  {(2**`GHT_BIT)*(2**`PHT_PC_BIT){1'b0}}; // Initialized to not taken
			ght		<=  {`GHT_BIT{1'b0}};
			prediction	<= 1'b0;;
		end else begin
			pht		<= next_pht;
			ght		<= next_ght;
			prediction	<= next_prediction;
		end

	end
endmodule