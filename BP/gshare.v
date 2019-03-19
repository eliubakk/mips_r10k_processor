// Gshare
//
//
`define DEBUG_OUT
`define GHT_BIT	4
`define PC_BIT	4


module GSHARE(
		input							clock,
		input							reset,
		input							enable,
		input							if_branch,	   // Enable when the instruction is branch 
		input	[32:0]						pc_in,
		input							obq_bh_pred_valid, // Enabled when obq is not empty(OBQ.bh_pred_valid),
		input	[`GHT_BIT-1:0]					obq_gh_in,	   // roll back global history bits from obq (OBQ.bh_pred.branch_history
		input							clear_en,	   // When branch prediction is wrong, flip the PHT bit of obq_gh_in

		`ifdef DEBUG_OUT
		output	[`GHT_BIT-1:0]					ght_out,
		output	[2**(`GHT_BIT)-1:0]				pht_out,
		`endif
		output							prediction_valid, // Prediction is not valid when the instruction is not branch or during the roll back 
		output							prediction_out
		
	);
	// 0 : not taken, 1 : taken
	//
	
		logic		[`GHT_BIT-1:0]					hash_idx;

		logic		[`GHT_BIT-1:0]					ght;
		logic		[`GHT_BIT-1:0]					next_ght;
		logic		[2**(`GHT_BIT)-1:0]				pht;
		logic		[2**(`GHT_BIT)-1:0]				next_pht;
		logic		[(`PC_BIT+1):2]					pc_partial;
		logic								prediction;
		logic								next_prediction;

	`ifdef DEBUG_OUT
	assign pht_out 	= pht;
	assign ght_out	= ght;
	`endif	

	assign prediction_out	= prediction;
	assign prediction_valid = if_branch & !(clear_en & obq_bh_pred_valid); 

	assign pc_partial	=  pc_in [(`PC_BIT)+1:2]; // do not consider the byte offset

	always_comb begin
		next_pht	= pht;
		next_ght	= ght;
		next_prediction	= prediction;

	// First : when clear_en (branch prediction is wrong) and obq is not empty, we need to update the prediction result(flip the bit)
	// & roll back the GHT value
	//
	

		if(clear_en & obq_bh_pred_valid) begin
			next_ght		= obq_gh_in;
			next_pht[obq_gh_in]	= ~pht[obq_gh_in];
		end
	 
	// Second : xor the ght and pc, and find the prediction, this is done
	// independently with roll back, since roll back itself takes one
	// cycle
	// Thired : update ght
	//


		if(enable & if_branch & !clear_en) begin

			hash_idx		= ght ^ pc_partial;
			next_prediction		= pht	[hash_idx];

			if(next_prediction) begin
				next_ght		  = {ght[`GHT_BIT-2:0],1'b1};
			end else begin
				next_ght		  = {ght[`GHT_BIT-2:0],1'b0};
			end
		end
	end



	always_ff @(posedge clock) begin
		if(reset) begin
			pht		<=  {(2**`GHT_BIT){1'b0}}; // Initialized to not taken
			ght		<=  {`GHT_BIT{1'b0}};
			prediction	<= 1'b0;;
		end else begin
			pht		<= next_pht;
			ght		<= next_ght;
			prediction	<= next_prediction;
		end

	end
endmodule
