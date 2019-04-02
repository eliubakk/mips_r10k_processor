`include "../../sys_defs.vh"
`define DEBUG

`define DELAY #2

module testbench;
	logic clock, reset, enable;
	PHYS_REG 		                T_old_in; // Comes from Map Table During Dispatch
	PHYS_REG		                T_new_in; // Comes from Free List During Dispatch
	PHYS_REG 		                CDB_tag_in; // Comes from CDB during complete
	logic			                CAM_en; // Comes from CDB during complete
	logic			                dispatch_en; // Structural Hazard detection during Dispatch
	logic			                branch_not_taken;
    //Outputs
	PHYS_REG 	                    T_free; // Output for Retire Stage goes to Free List
	PHYS_REG                        T_arch; // Output for Retire Stage goes to Arch Map
	logic 				            T_out_valid;
	logic [$clog2(`ROB_SIZE):0] rob_free_entries;
    logic                           rob_full;
    ROB_ROW_T [`ROB_SIZE:1]		ROB_table_out;
	logic [$clog2(`ROB_SIZE):0] tail_reg, head_reg;


    ROB g1(
        //inputs
        .clock(clock),
        .reset(reset),
        .enable(enable),
        .T_old_in(T_old_in),
        .T_new_in(T_new_in),
        .CDB_tag_in(CDB_tag_in),
        .CAM_en(CAM_en),
        .dispatch_en(dispatch_en),
        .branch_not_taken(branch_not_taken),

        //outputs
        .T_free(T_free),
        .T_arch(T_arch),
        .T_out_valid(T_out_valid),
        .rob_free_entries(rob_free_entries),
        .rob_full(rob_full),
        .ROB_table_out(ROB_table_out),
		.tail_reg(tail_reg),
		.head_reg(head_reg)
		
    );

    always #10 clock = ~clock;

    // need to update this

	// TASKS
	task exit_on_error;
		begin
			@(posedge clock);
			#2;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	task table_out;
		begin
			@(posedge clock);
			#2;
				$display("**********************************************************\n");
				$display("------------------------ROB TABLE----------------------------\n");

			for(integer i=1;i<=`ROB_SIZE;i=i+1) begin
				$display("ROB_Row = %d,  busy = %d, T_new_out = %7.0b T_old_out = %7.0b ", i, ROB_table_out[i].busy, ROB_table_out[i].T_new_out, ROB_table_out[i].T_old_out);
			end
				$display("T free = %7.0b T arch = %7.0b tail= %d head= %d T_out_valid = %b ROB full = %b, ROB free entries = %d",T_free, T_arch, tail_reg, head_reg, T_out_valid, rob_full, rob_free_entries);
			
			
			$display("*******************************************************************\n");

		end
	endtask
initial begin
	

$monitor("Clock: %4.0f, reset: %b, enable:%b, ", clock, reset, enable);	

		// Initial value
        clock = 0;
		reset = 0;
		enable = 0;
		CAM_en = 0;
		CDB_tag_in = 0;
		dispatch_en = 0;
		branch_not_taken= 0;
        T_old_in= 7'b1111111;
        T_new_in= 7'b1111111;
        @(negedge clock);
//Check reset
		reset = 1;
		enable = 1;
	@(negedge  clock);
		table_out();
//Check enable
		
	
//Dispatch
		reset = 0;
		enable = 1;
		dispatch_en = 1;
		
		$display("****************************************DISPATCH MULT R1 R2 R3************************************************");

        T_old_in= 7'b1000011;
        T_new_in= 7'b0100011;

        

		@(negedge clock);
		table_out();

		
			
$display("****************************************DISPATCH R1 R2 R4  ISSUE MULT R1 R2 R3************************************************");

        T_old_in= 7'b1000100;
        T_new_in= 7'b0100100;

        

		@(negedge clock);
		table_out();

		



		

$display("****************************************DISPATCH R1 R2 R5 ISSUE R1 R2 R4  EXECUTE MULT R1 R2 R3************************************************");

        T_old_in= 7'b1000101;
        T_new_in= 7'b0100101;

        

		@(negedge clock);
		table_out();

		


$display("**************************************** DISPATCH R1 R2 R6 ISSUE R1 R2 R5 EXECUTE R1 R2 R4  complete MULT R1 R2 R3************************************************");

        T_old_in= 7'b1000110;
        T_new_in= 7'b0100110;
		CAM_en = 1;
		CDB_tag_in = 7'b0100011; 

        

		@(negedge clock);
		table_out();

		
$display("**************************************** DISPATCH R1 R2 R7 ISSUE R1 R2 R6 EXECUTE R1 R2 R5 EXECUTE R1 R2 R4  RETIRE MULT R1 R2 R3************************************************");

        T_old_in= 7'b1000111;
        T_new_in= 7'b0100111;
		CAM_en = 0;
		CDB_tag_in = 7'b0100011; 

        

		@(negedge clock);
		table_out();

// older inst gets completeed before .
$display("**************************************** DISPATCH R1 R2 R8 ISSUE R1 R2 R7 EXECUTE R1 R2 R6 complete R1 R2 R5 EXECUTE R1 R2 R4  ************************************************");

        T_old_in= 7'b1001000;
        T_new_in= 7'b0101000;
		CAM_en = 1;
		CDB_tag_in = 7'b0100101; 

        

		@(negedge clock);
		table_out();

		
$display("**************************************** DISPATCH R1 R2 R8 ISSUE R1 R2 R7 EXECUTE R1 R2 R6 complete R1 R2 R5 complete R1 R2 R4  ************************************************");

        T_old_in= 7'b1001000;
        T_new_in= 7'b0101000;
		CAM_en = 1;
		CDB_tag_in = 7'b0100100; 

        

		@(negedge clock);
		table_out();

@(negedge clock);
		table_out();
		@(negedge clock);
		table_out();

// ROB FULL		
$display("****************************************  ROB FULL  ************************************************");
		for (integer i=0; i< 13; i=i+1) begin
			dispatch_en= 1;
			CAM_en = 0;
			CDB_tag_in = 7'b0100100; 
		    @(negedge clock);
		end
		table_out();


// //DISPATCH COMMAND WITH ROB BEING FULL

$display("****************************************  complete ROB HEAD  ************************************************");
		
		dispatch_en= 0;
		CAM_en = 1;
		CDB_tag_in = 7'b0100110; 

		    @(negedge clock);
	
		table_out();

$display("**************************************** DISPATCH AND EMPTY AT THE SAME LAST SPOT IN ROB  ************************************************");
		
		dispatch_en= 1;
		CAM_en = 0;
		T_old_in= 7'b1001111;
        T_new_in= 7'b0101111;
		

		    @(negedge clock);
	
		table_out();
		$display("@@@Passed");
		$finish;

		
	end
	
endmodule
