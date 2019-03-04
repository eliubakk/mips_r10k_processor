module CDB (
	input clock,    // Clock
	input reset,  // Asynchronous reset active low
	input enable, // Clock Enable

	input PHYS_REG tag_in,	// Comes from FU, during commit
	input		ex_valid, // Comes from FU, during commit

	output PHYS_REG CDB_tag_out, // Output for commit, goes to modules
	output 		CDB_en_out,  // Output for commit, goes to modules
	output 		busy
);

	always_ff @(posedge clock) begin
		if(reset) begin
			CDB_tag_out	<= 7'b1111111; // Dummy register
			CDB_en_out 	<= 1'b0;
			busy 		<= 1'b0;	
		end else if (enable) begin
			if(ex_valid) begin
				CDB_tag_out	<= tag_in;
				CDB_en_out	<= 1'b1;
				busy		<= 1'b1;
			end	
		end

	end

endmodule
