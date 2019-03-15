// 2 bit saturation counter
//
`define DEBUG_OUT
module TWO_BIT_SC(
		input		clock,
		input		reset,
		input		enable,
		input		branch_taken, // Calculated branch result, 0 is not taken, 1 is taken		

		`ifdef DEBUG_OUT
		output	[1:0]	state_out,
		`endif
		output		prediction
		
	);
	// 00 : strongly not taken, 01 : weakly not taken, 10 : weakly taken,
	// 11 : strongly taken 	

	logic [1:0] state;
	logic [1:0] next_state; 

	`ifdef DEBUG_OUT
	assign state_out 	= state;
	`endif	

	assign prediction	= state[1]; 
	
	always_comb begin
		if(!enable) begin
			next_state = state;
		end else begin

			case(state)
				2'b00: begin
						if(branch_taken) begin
							next_state = 2'b01;
						end else begin
							next_state = 2'b00;
						end
					end
				2'b01: begin
						if(branch_taken) begin
							next_state = 2'b10;
						end else begin
							next_state = 2'b00;
						end

					end
				2'b10: begin
						if(branch_taken) begin
							next_state = 2'b11;
						end else begin
							next_state = 2'b01;
						end
					end
				2'b11: begin
						if(branch_taken) begin
							next_state = 2'b11;
						end else begin
							next_state = 2'b10;
						end
					end
		endcase

		end
	end


	always_ff @(posedge clock) begin
		if(reset) begin
			state	<= #1 2'b00; // Initialized to strongly not taken
		end else begin
			state	<= #1 next_state;
		end

	end
endmodule
