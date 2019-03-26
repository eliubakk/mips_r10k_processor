`include "../../sys_defs.vh"
`timescale 1ns/100ps

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

	assign CDB_en_out	= !reset & enable & ex_valid;
	assign busy 		= !reset & enable & ex_valid;

	always_ff @(posedge clock) begin
		if(reset) begin
			CDB_tag_out	<= 7'b0; 
		end else if (enable & ex_valid) begin
			CDB_tag_out	<= tag_in;
		end	

	end

endmodule
