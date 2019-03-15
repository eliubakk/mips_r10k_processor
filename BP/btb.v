`include "sys_defs.vh"
module BTB_CAM(
		input				enable,
		input 				CAM_en, 
		input [31:0]	  		PC_in,
		input RS_ROW_T  [`RS_SIZE-1:0] ,
		output 	 logic  [`RS_SIZE-1:0] T1_hit,
		output 	 logic  [`RS_SIZE-1:0] T2_hit
		
	);
		
	always_comb begin
		T1_hit = {`RS_SIZE{1'b0}};
		T2_hit = {`RS_SIZE{1'b0}};	
		if(CAM_en & enable) begin
			for(integer i=0;i<`RS_SIZE;i=i+1) begin
				T1_hit[i] = (rs_table[i].T1[5:0] == CDB_tag[5:0]);
			 	T2_hit[i] = (rs_table[i].T2[5:0] == CDB_tag[5:0]);
			end		
		end else begin
			T1_hit = {`RS_SIZE{1'b0}};
			T2_hit = {`RS_SIZE{1'b0}};	
		end	
	end	
endmodule

module  BTB(
	input clock,    // Clock
	input reset,  // Asynchronous reset active low
	input enable, // Clock Enable

	input		[31:0]	current_pc, 	// During fetch, current pc value
	input	 		if_branch,	// During fetch, valid when the instruction is branch 
	input		[31:0]	calculated_pc,  // After execute, calculated PC value from execution unit	
	input			ex_branch_taken,// After execute, 1 when the branch is taken
	input			ex_en_branch,	// After execute, 1 when the branch is executed
	

	output		[31:0]	target_pc, 	// During fetch, target pc
	output			valid_target  	// During fetch, 1 when the target pc is valid		
);

	parameter	TAG_SIZE	= 10;	// Tag bit size
	parameter	TARGET_SIZE	= 12;	// Target address size
	parameter	BTB_ROW		= 10;	// BTB row size : 5~10% of I$ size
	

	logic		[BTB_ROW-1:0]				valid;
	logic		[BTB_ROW-1:0]	[TAG_SIZE-1:0]		tag;
	logic		[BTB_ROW-1:0]	[TARGET_SIZE-1:0]	target_address;


	//BTB_CAM ex_btb_cam (.enable(enable), .CAM_en(), .CDB_tag(), );

	always_comb begin
	// After execute, update the btb when
	// 1. The predict is in the btb but not taken (CAM)
		if( enable & ex_en_branch & !ex_branch_taken & CAM_result) begin
			
		end

	// 2. The predict is taken but not on the btb (CAM) 
		if( enable & ex_en_branch & ex_branch_taken) begin

		end



	// Fetch : CAM
	end


	always_ff @(posedge clock) begin
		if(reset) begin
			valid		<= BTB_ROW'b0;
			tag		<= {BTB_ROW{TAG_SIZE{0}}}; // Need to figure out later
			target_address  <= {BTB_ROW{TARGET_SIZE{0}}}; // Need to figure out later	

		end else if (enable ) begin
		end	

	end

endmodule
