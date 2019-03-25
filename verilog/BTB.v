// [5:2] is used for indexing, [15:6] is used for tag, [13:2] is stored as
// a target PC
`include "sys_defs.vh"
`define	DEBUG_OUT

module  BTB(
	input clock,    // Clock
	input reset,  // Asynchronous reset active low
	input enable, // Clock Enable

	input		[31:0]	pc_in, 	// During fetch, current pc value
	input	 		if_branch,	// During fetch, valid when the instruction is branch
	input		[31:0]	ex_pc,		// After execute, original PC value 
	input		[31:0]	calculated_pc,  // After execute, calculated PC value from execution unit	
	input			ex_branch_taken,// After execute, 1 when the branch is taken
	input			ex_en_branch,	// After execute, 1 when the branch is executed
	
	`ifdef DEBUG_OUT
	output logic 	[`BTB_ROW-1:0]				valid_out,
	output logic	[`BTB_ROW-1:0]	[`TAG_SIZE-1:0]		tag_out,
	output logic	[`BTB_ROW-1:0]	[`TARGET_SIZE-1:0]	target_address_out,
	`endif


	output	logic	[31:0]	target_pc, 	// During fetch, target pc
	output	logic		valid_target  	// During fetch, 1 when the target pc is valid		
);

	// BTB table

	
	logic		[`BTB_ROW-1:0]				valid,next_valid;
	logic		[`BTB_ROW-1:0]	[`TAG_SIZE-1:0]		tag, next_tag; // PC[16:6], The index of each tag is pc[5:2]
	logic		[`BTB_ROW-1:0]	[`TARGET_SIZE-1:0]	target_address, next_target_address; // PC[13:2]


	`ifdef DEBUG_OUT
	assign valid_out		= valid;
	assign tag_out			= tag;
	assign target_address_out	= target_address;
	`endif


	always_comb begin
	// After execute, update the btb when
	// 1. The branch is taken and in the btb : update the previous target_address in the BTB   
	// 2. The branch is taken but not in the btb : add new row in the BTB
	// Q3. The predict is not taken but in the btb : Remove value? or do
	// nothing? - I have implemented with do nothing
	// 4. The predict is not taken and not in the btb : nothing to do  
	//  

		next_valid		= valid;
		next_tag		= tag;
		next_target_address 	= target_address;
		
		target_pc 		= pc_in;
		valid_target		= 1'b0;


		//1,2 The branch is taken : update the BTB table regardless
		//of it is in the btb or not
		if( enable & ex_en_branch & ex_branch_taken) begin


				next_valid[ex_pc[$clog2(`BTB_ROW)+1:2]] 		= 1'b1;
				next_tag[ex_pc[$clog2(`BTB_ROW)+1:2]]			= ex_pc[(`TAG_SIZE+$clog2(`BTB_ROW)+1):($clog2(`BTB_ROW)+2)];
				next_target_address[ex_pc[$clog2(`BTB_ROW)+1:2]]	= calculated_pc[`TARGET_SIZE+1:2];
				
		end else begin			// No need to update BTB table
			next_valid		= valid;
			next_tag		= tag;
			next_target_address 	= target_address;

		end
				



	// Fetch
	// Update the target_PC when there is a match and the instruction is
	// branch
	//
	

		if (enable & if_branch & next_valid[pc_in[$clog2(`BTB_ROW)+1:2]] & ( pc_in[(`TAG_SIZE+$clog2(`BTB_ROW)+1):($clog2(`BTB_ROW)+2)] == next_tag[pc_in[$clog2(`BTB_ROW)+1:2]]  )) begin
			valid_target			= 1'b1;
			target_pc[`TARGET_SIZE+1:2]	= next_target_address[pc_in[$clog2(`BTB_ROW)+1:2]];  		
		end else begin
			target_pc 		= pc_in;
			valid_target		= 1'b0;

		end
	end


	always_ff @(posedge clock) begin
		if(reset) begin
			valid		<= `BTB_ROW'b0;
			tag		<= {(`BTB_ROW*`TAG_SIZE){1'b0}}; 
			target_address  <= {(`BTB_ROW*`TARGET_SIZE){1'b0}}; 
		
		end else begin
			valid		<= next_valid;
			tag		<= next_tag;
			target_address  <= next_target_address;
		end	

	end

endmodule
