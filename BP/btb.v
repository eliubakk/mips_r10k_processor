`define	DEBUG_OUT

`define TAG_SIZE 10	// Tag bit size
`define TARGET_SIZE 12	// Target address size, BTB will store [TARGET_SIZE+1:2]
`define BTB_ROW	10	// BTB row size : 5~10% of I$ size
`define PC_ALIAS 10   // Tag will store pc [(PC_ALIAS+TAG_SIZE-1):PC_ALIAS]

module  BTB(
	input clock,    // Clock
	input reset,  // Asynchronous reset active low
	input enable, // Clock Enable

	input		[31:0]	current_pc, 	// During fetch, current pc value
	input	 		if_branch,	// During fetch, valid when the instruction is branch
	input		[31:0]	ex_pc,		// After execute, original PC value 
	input		[31:0]	calculated_pc,  // After execute, calculated PC value from execution unit	
	input			ex_branch_taken,// After execute, 1 when the branch is taken
	input			ex_en_branch,	// After execute, 1 when the branch is executed
	
	`ifdef DEBUG_OUT
	output logic 	[`BTB_ROW-1:0]				valid_out,
	output logic 	[$clog2(`BTB_ROW):0]			BTB_count_out,
	output logic	[`BTB_ROW-1:0]	[`TAG_SIZE-1:0]		tag_out,
	output logic	[`BTB_ROW-1:0]	[`TARGET_SIZE-1:0]	target_address_out,
	`endif


	output	logic	[31:0]	target_pc, 	// During fetch, target pc
	output	logic		valid_target  	// During fetch, 1 when the target pc is valid		
);

	// BTB table
	logic		[`BTB_ROW-1:0]				valid,next_valid;
	logic		[$clog2(`BTB_ROW):0]			BTB_count, next_BTB_count;
	logic		[`BTB_ROW-1:0]	[`TAG_SIZE-1:0]		tag, next_tag; // PC[19:10]
	logic		[`BTB_ROW-1:0]	[`TARGET_SIZE-1:0]	target_address, next_target_address; // PC[13:2]

	//BTB CAM
	logic							CAM_ex_hit, CAM_if_hit;
	logic		[($clog2(`BTB_ROW)-1):0]		CAM_ex_idx, CAM_if_idx;
	integer							i,j;


	`ifdef DEBUG_OUT
	assign valid_out		= valid;
	assign BTB_count_out		= BTB_count;
	assign tag_out			= tag;
	assign target_address_out	= target_address;
	`endif


	always_comb begin
	// After execute, update the btb when
	// 1. The predict is taken and in the btb : update the previous target_address in the BTB   
	// 2. The predict is taken but not in the btb : add new row in the BTB
	// Q3. The predict is not taken but in the btb : Remove value? or do
	// nothing? - I have implemented with do nothing
	// 4. The predict is not taken and not in the btb : nothing to do  
	// Q5. Exception : when BTB is full - I have implemented with removing
	// the first entry in the BTB    

		next_valid		= valid;
		next_BTB_count		= BTB_count;
		next_tag		= tag;
		next_target_address 	= target_address;
		
		target_pc 		= current_pc;
		valid_target		= 1'b0;


		if( enable & ex_en_branch) begin


			// CAM logic
			CAM_ex_hit		= 1'b0;
			CAM_ex_idx	= {($clog2(`BTB_ROW)-1){1'b0}};
		
			for (i=`BTB_ROW-1;i>=0;i=i-1) begin
				if(valid[i] & (ex_pc[(`PC_ALIAS+`TAG_SIZE-1):`PC_ALIAS] == tag[i])) begin
					CAM_ex_hit		= 1'b1;
					CAM_ex_idx		= i;
				end
			end
 
			if(ex_branch_taken & CAM_ex_hit) begin // 1. Predict is taken, and in the btb
				next_target_address [CAM_ex_idx]	=	calculated_pc [`TARGET_SIZE-1:2]; 
			end else if (ex_branch_taken & !CAM_ex_hit) begin // 2. Predict is taken, but not in the btb (When BTB is full?)
				if (BTB_count == `BTB_ROW) begin 
				// When BTB is full, remove the first entry in the BTB, and add new entry at the latest entry in the BTB
					next_tag		= {calculated_pc[(`PC_ALIAS+`TAG_SIZE-1):`PC_ALIAS],tag[`BTB_ROW-1:1]};
					next_target_address 	= {calculated_pc[`TARGET_SIZE+1:2],target_address[`BTB_ROW-1:1]}; 
						
				end else begin
					next_valid [BTB_count]		= 1'b1;
					next_BTB_count			= BTB_count + 1;
					next_tag [BTB_count]		= calculated_pc[(`PC_ALIAS+`TAG_SIZE-1):`PC_ALIAS];
					next_target_address[BTB_count] 	= calculated_pc[`TARGET_SIZE+1:2]; 
											
				end	

			end else begin // No need to update the btb table
				next_valid		= valid;
				next_BTB_count		= BTB_count;
				next_tag		= tag;
				next_target_address 	= target_address;
			end
		end



	// Fetch : CAM
	// Update the target_PC when there is a match and the instruction is
	// branch
	//
	

		if(enable & if_branch) begin
			// CAM the current_pc
			CAM_if_hit		= 1'b0;
			CAM_if_idx	= {($clog2(`BTB_ROW)-1){1'b0}};
		
			for (i=`BTB_ROW-1;i>=0;i=i-1) begin
				if(valid[i] & (current_pc[(`PC_ALIAS+`TAG_SIZE-1):`PC_ALIAS] == tag[i])) begin
					CAM_if_hit		= 1'b1;
					CAM_if_idx		= i;
				end
			end
 
			// update the target_pc and valid_target 
			if(CAM_if_hit) begin
				target_pc = {current_pc[31:`TARGET_SIZE+2],target_address[CAM_if_idx],current_pc[1:0]}; 
				valid_target = 1'b1;
			end else begin
				valid_target = 1'b0;
			end
			
		end 
	end


	always_ff @(posedge clock) begin
		if(reset) begin
			valid		<= `BTB_ROW'b0;
			BTB_count	<= {($clog2(`BTB_ROW)+1){1'b0}};	
			tag		<= {(`BTB_ROW*`TAG_SIZE){1'b0}}; 
			target_address  <= {(`BTB_ROW*`TARGET_SIZE){1'b0}}; 
		
		end else begin
			valid		<= next_valid;
			BTB_count	<= next_BTB_count;
			tag		<= next_tag;
			target_address  <= next_target_address;
		end	

	end

endmodule
