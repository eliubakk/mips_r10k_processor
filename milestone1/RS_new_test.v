`include "sys_defs.vh"
`define DEBUG

module testbench;
	logic clock, reset, enable;
	logic    		CAM_en;
	PHYS_REG 		CDB_in;
	logic			dispatch_valid;
	RS_ROW_T		inst_in;
	logic	 [1:0]		LSQ_busy;
	

	RS_ROW_T   		rs_table_out [(`RS_SIZE - 1):0] ;
	logic [`RS_SIZE-1:0] 	issue_idx;
	RS_ROW_T 		issue_out   [(`NUM_FU -1 ):0]; 
	logic				rs_full;
	logic [$clog2(`NUM_FU) - 1:0]	issue_cnt;
	RS_ROW_T   		rs_table_test [(`RS_SIZE - 1):0] ;
	RS_ROW_T 		issue_out_test   [(`NUM_FU -1 ):0]; 

	
	RS RS0(
		// inputs
		.clock(clock), 
		.reset(reset), 
		.enable(enable), 
		.CAM_en(CAM_en), 
		.CDB_in(CDB_in), 
		.dispatch_valid(dispatch_valid),
		.inst_in(inst_in), 
		.LSQ_busy(LSQ_busy),

		// outputs
		.rs_table_out(rs_table_out),
		.issue_idx(issue_idx), 
		.issue_out(issue_out), 
		.issue_cnt(issue_cnt), 
		.rs_full(rs_full)
	 );

	
	always #5 clock = ~clock;

	// need to update this

	// TASKS
	task exit_on_error;
		begin
			@(posedge clock);
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	task table_out;
		begin
			@(posedge clock);
			#1;
				$display("**********************************************************\n");
				$display("------------------------RS TABLE----------------------------\n");

			for(integer i=0;i<`RS_SIZE;i=i+1) begin
				$display("RS_Row = %d, issue_idx = %b, busy = %d, Function = %d, T = %7.0b T1 = %7.0b, T2 = %7.0b ", i, issue_idx[i],rs_table_out[i].busy, rs_table_out[i].inst.fu_name,rs_table_out[i].T, rs_table_out[i].T1, rs_table_out[i].T2);
			end
				$display("RS full = %d",rs_full);
				$display("-----------------------Issue table-----------------------------------\n");
			for(integer i=0;i<`NUM_FU;i=i+1) begin
				$display("Issue_row = %d, busy = %d, T = %7.0b T1 = %7.0b, T2 = %7.0b ",i, issue_out[i].busy, issue_out[i].T, issue_out[i].T1, issue_out[i].T2 );
			
			end
			$display("*******************************************************************\n");

		end
	endtask
	
	initial begin
		
	/*	$monitor("Clock: %4.0f, reset: $b, enable:%b, CAM_en:%b, CDB_in:%h, .dispatch_valid:%b, inst_in:%h, LSQ_busy : %b, \n rs_table_out:%h", clock, reset, enable, CAM_en, CDB_in,dispatch_valid, inst_in, LSQ_busy, rs_table_out);	
 	*/
		$monitor("Clock: %4.0f, reset: %b, enable:%b, ", clock, reset, enable);	

		// Initial value
		clock = 0;
		reset = 0;
		enable = 0;
		CAM_en = 0;
		CDB_in = 0;
		dispatch_valid = 0;
	
		inst_in.inst.opa_select = ALU_OPA_IS_REGA;
		inst_in.inst.opb_select = ALU_OPB_IS_REGB;
		inst_in.inst.dest_reg = DEST_IS_REGC;
		inst_in.inst.alu_func = ALU_ADDQ;
		inst_in.inst.fu_name = FU_ALU;
		inst_in.inst.rd_mem = 1'b0;
		inst_in.inst.wr_mem = 1'b0;
		inst_in.inst.ldl_mem = 1'b0;
		inst_in.inst.stc_mem = 1'b0;
		inst_in.inst.cond_branch = 1'b0;
		inst_in.inst.uncond_branch = 1'b0;
		inst_in.inst.halt = 1'b0;
		inst_in.inst.cpuid = 1'b0;
		inst_in.inst.illegal = 1'b0;
		inst_in.inst.valid_inst = 1'b1;
		inst_in.T = 7'b1111111;
		inst_in.T1 = 7'b1111111;
		inst_in.T2 = 7'b1111111;
		inst_in.busy = 1'b0;

		LSQ_busy = 0;	
	
	///Things to do
	//For 1-way superscalar, multiple issue
	//1. Makefile and testbench : make it for synthesizable (for ex,
	//define DEBUG only for testing)
	//2. How can we printout, see, and compare the rs_table values? (It is
	//kind of 2 dimensional matrix structure)
	//3. Testing for functionality (enable, reset, dispatch_valid,
	//LSQ_busy, CAM_en, commit, issue, dispatch) and corner cases (Issue 2 branches at
	//a same cycle?, input is invalid instruction, etc...)    
		table_out();

	@(negedge clock);
//Check reset
		reset = 1;
		table_out();
	@(negedge  clock);
//Check enable
		enable = 1;
		table_out();
	@(negedge clock);
//Dispatch
		reset = 0;
		enable = 1;
		dispatch_valid = 1;
		LSQ_busy = 0;	
		$display("****************************************DISPATCH MULT R1 R2 R3************************************************");

			inst_in.inst.opa_select = ALU_OPA_IS_REGA;
			inst_in.inst.opb_select = ALU_OPB_IS_REGB;
			inst_in.inst.dest_reg = DEST_IS_REGC;
			inst_in.inst.alu_func = ALU_MULQ;
			inst_in.inst.fu_name = FU_MULT;
			inst_in.inst.rd_mem = 1'b0;
			inst_in.inst.wr_mem = 1'b0;
			inst_in.inst.ldl_mem = 1'b0;
			inst_in.inst.stc_mem = 1'b0;
			inst_in.inst.cond_branch = 1'b0;
			inst_in.inst.uncond_branch = 1'b0;
			inst_in.inst.halt = 1'b0;
			inst_in.inst.cpuid = 1'b0;
			inst_in.inst.illegal = 1'b0;
			inst_in.inst.valid_inst = 1'b1;
			inst_in.T = 7'd3;
			inst_in.T1 = 7'b1000001;
			inst_in.T2 = 7'b1000010;
			inst_in.busy = 1'b0;
		
		table_out();

		@(negedge clock);
		

		$display("**********************************************DISPATCH ADD R1 R2 R4, Issue MULT R1 R2 R3****************************");	
			inst_in.inst.opa_select = ALU_OPA_IS_REGA;
			inst_in.inst.opb_select = ALU_OPB_IS_REGB;
			inst_in.inst.dest_reg = DEST_IS_REGC;
			inst_in.inst.alu_func = ALU_ADDQ;
			inst_in.inst.fu_name = FU_BR; // Branch
			inst_in.inst.rd_mem = 1'b0;
			inst_in.inst.wr_mem = 1'b0;
			inst_in.inst.ldl_mem = 1'b0;
			inst_in.inst.stc_mem = 1'b0;
			inst_in.inst.cond_branch = 1'b0;
			inst_in.inst.uncond_branch = 1'b0;
			inst_in.inst.halt = 1'b0;
			inst_in.inst.cpuid = 1'b0;
			inst_in.inst.illegal = 1'b0;
			inst_in.inst.valid_inst = 1'b1;
			inst_in.T = 7'd4;
			inst_in.T1 = 7'b1000001;
			inst_in.T2 = 7'b1000010;
			inst_in.busy = 1'b0;


		table_out();

		@(negedge clock);
		$display("*******************************************DISPATCH LD R1 DISP R5, ISSUE ADD R1 R2 R4,EXECUTE MULT R1 R2 R3************************");	
			inst_in.inst.opa_select = ALU_OPA_IS_MEM_DISP;
			inst_in.inst.opb_select = ALU_OPB_IS_REGB;
			inst_in.inst.dest_reg = DEST_IS_REGA;
			inst_in.inst.alu_func = ALU_ADDQ;
			inst_in.inst.fu_name = FU_LD;
			inst_in.inst.rd_mem = 1'b1;
			inst_in.inst.wr_mem = 1'b0;
			inst_in.inst.ldl_mem = 1'b1;
			inst_in.inst.stc_mem = 1'b0;
			inst_in.inst.cond_branch = 1'b0;
			inst_in.inst.uncond_branch = 1'b0;
			inst_in.inst.halt = 1'b0;
			inst_in.inst.cpuid = 1'b0;
			inst_in.inst.illegal = 1'b0;
			inst_in.inst.valid_inst = 1'b1;
			inst_in.T = 7'd5;
			inst_in.T1 = 7'b1111111;
			inst_in.T2 = 7'b1000001;
			inst_in.busy = 1'b0;


		table_out();

		@(negedge clock);
			$display("*******************************************DISPATCH ST R1 DISP R6, ISSUE LD R1 DISP R5, EXECUTE ADD R1 R2 R4************************");	
			inst_in.inst.opa_select = ALU_OPA_IS_MEM_DISP;
			inst_in.inst.opb_select = ALU_OPB_IS_REGB;
			inst_in.inst.dest_reg = DEST_IS_REGA;
			inst_in.inst.alu_func = ALU_ADDQ;
			inst_in.inst.fu_name = FU_ST;
			inst_in.inst.rd_mem = 1'b0;
			inst_in.inst.wr_mem = 1'b1;
			inst_in.inst.ldl_mem = 1'b0;
			inst_in.inst.stc_mem = 1'b1;
			inst_in.inst.cond_branch = 1'b0;
			inst_in.inst.uncond_branch = 1'b0;
			inst_in.inst.halt = 1'b0;
			inst_in.inst.cpuid = 1'b0;
			inst_in.inst.illegal = 1'b0;
			inst_in.inst.valid_inst = 1'b1;
			inst_in.T = 7'b1111111;
			inst_in.T1 = 7'b0000001;
			inst_in.T2 = 7'b0000110;
			inst_in.busy = 1'b0;



table_out();

		@(negedge clock);
			$display("*************************************DISPATCH nothing, Issue nothing, EXECUTE LD R1 DISP R5 *********************************");	
			dispatch_valid = 1'b0;
			table_out();

		@(negedge clock);
			$display("*************************************RESET *********************************");	
			reset = 1'b1;
			table_out();




		@(negedge clock);

		
		
		$display("@@@Passed");
			




		$finish;
		
	end
	
endmodule
