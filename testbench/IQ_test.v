`include "../../sys_defs.vh"

`define DELAY #2
`define CLOCK_PERIOD #10

module testbench;

	// parameters

	parameter ONE = 1'b1;
	parameter ZERO = 1'b0;

	// initialize wires

	// input wires
	logic	clock;
	logic	reset;
	logic	fetch_valid;
	INST_Q	if_inst_in;
	logic	dispatch_no_hazard;
	logic	branch_incorrect;

	// output wires
	INST_Q	[`IQ_SIZE-1:0] 		inst_queue_out;
	logic	[$clog2(`IQ_SIZE):0] 	inst_queue_entry;
	logic				inst_queue_full;
	INST_Q				if_inst_out;


	integer i,j,k,l;
	
	// initialize module

	`DUT(IQ) iq0(
		// inputs
		.clock(clock),
		.reset(reset),
		.fetch_valid(fetch_valid),
		.if_inst_in(if_inst_in),
		.dispatch_no_hazard(dispatch_no_hazard),
		.branch_incorrect(branch_incorrect),
		
		// outputs
		`ifdef DEBUG
		.inst_queue_out(inst_queue_out),
		.inst_queue_entry(inst_queue_entry),
		`endif
		.inst_queue_full_out(inst_queue_full),
		.if_inst_out(if_inst_out)
	);


	// TASKS
	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask


	task print_IQ;
		begin
		
			$display("\n--------Print Instruction Queue--------");
			$display("Inst_queue_full? : %b, inst_queue_entry : %d", inst_queue_full, inst_queue_entry);
			$display("Decoded instruction valid : %b,npc : %h, IR : %h", if_inst_out.valid_inst, if_inst_out.npc, if_inst_out.ir);
			$display("--------Queue------");
			for (int i = 0; i < `IQ_SIZE; ++i) begin
				$display("Index : %d, valid : %b, npc : %h, IR : %h", i, inst_queue_out[i].valid_inst, inst_queue_out[i].npc, inst_queue_out[i].ir);
			end	
		end
	endtask

	task reset_test;
		begin
			assert((inst_queue_full == 0) & (inst_queue_entry==0)) else #1 exit_on_error;
			assert((inst_queue_out[0].valid_inst == 0) & (inst_queue_out[0].npc == 64'h0) & (inst_queue_out[0].ir == `NOOP_INST)) else #1 exit_on_error;
			assert((if_inst_out.valid_inst == 0) & (if_inst_out.npc == 64'h0) & (if_inst_out.ir == `NOOP_INST))else #1 exit_on_error;


		end
	endtask


	// set clock change
	always `CLOCK_PERIOD clock = ~clock;

	initial begin

		// monitor wires
		$monitor("clock: %b, reset: %b, fetch_valid: %b, if_inst_in.valid_inst :%b, if_inst_in.npc :%h, if_inst_in.ir : %h, dispatch_no_hazard : %b, branch_incorrect : %b", clock, reset, fetch_valid, if_inst_in.valid_inst, if_inst_in.npc, if_inst_in.ir, dispatch_no_hazard, branch_incorrect);

		// intial values
		clock = ZERO;
		reset = ZERO;
		fetch_valid = ZERO;
		dispatch_no_hazard = ZERO;
		branch_incorrect = ZERO;
		if_inst_in.valid_inst 			= 1'b0;
		if_inst_in.npc				= 64'h0;
		if_inst_in.ir				= `NOOP_INST;
		if_inst_in.branch_inst.en			= 1'b0; 
		if_inst_in.branch_inst.cond			= 1'b0;    		
		if_inst_in.branch_inst.direct		= 1'b0;
		if_inst_in.branch_inst.ret			= 1'b0;
		if_inst_in.branch_inst.pc			= 64'h0;
		if_inst_in.branch_inst.pred_pc		= 64'h0;
		if_inst_in.branch_inst.br_idx		= {($clog2(`OBQ_SIZE)){0}};
		if_inst_in.branch_inst.prediction		= 1'b0;


		// RESET

		$display("Testing Reset...");
		@(negedge clock);
		reset = ONE;
		@(posedge clock);
		`DELAY;
		print_IQ;
		reset_test;
		$display("@@@ Reset Test Passed");

		// Fetch and Decode at the same time when queue is empty

		$display("Testing Fetch and Decode sametime when queue is empty");
		@(negedge clock);
		reset 			= ZERO;
		fetch_valid 		= ONE;
		dispatch_no_hazard 	= ONE;
		branch_incorrect 	= ZERO;
		if_inst_in.valid_inst 	= ONE;
		if_inst_in.npc		= 64'hff;
		if_inst_in.ir		= 64'hfff;
		
		@(posedge clock);
		`DELAY;
		print_IQ;
			assert((inst_queue_full == 0) & (inst_queue_entry==0) ) else #1 exit_on_error;
			assert((inst_queue_out[0].valid_inst == 0) & (inst_queue_out[0].npc == 64'h0) & (inst_queue_out[0].ir == `NOOP_INST)) else #1 exit_on_error;
			assert((if_inst_out.valid_inst == 1) & (if_inst_out.npc == 64'hff) & (if_inst_out.ir == 64'hfff))else #1 exit_on_error;


		$display("@@@ Fetch and Decode sametime when queue is empty Passed");
	

		// Fetch X 5

		$display("Testing Fetch five times");
		for(i=0; i<5; ++i) begin
			@(negedge clock);
			fetch_valid 		= ONE;
			dispatch_no_hazard 	= ZERO;
			branch_incorrect 	= ZERO;
			if_inst_in.valid_inst 	= ONE;
			if_inst_in.npc		= 4*(i+1);
			if_inst_in.ir		= 4*256*(i+1);
			
			@(posedge clock);
			`DELAY;
			print_IQ;
			
			assert((inst_queue_full == 0) & (inst_queue_entry==(i+1))) else #1 exit_on_error;
			assert((inst_queue_out[i].valid_inst == 1) & (inst_queue_out[i].npc == 4*(i+1)) & (inst_queue_out[i].ir == 4*256*(i+1))) else #1 exit_on_error;
			assert((if_inst_out.valid_inst == 0) & (if_inst_out.npc == 64'h0) & (if_inst_out.ir == `NOOP_INST))else #1 exit_on_error;


		end
		$display("@@@ Fetch five times Passed");
	
		// Decode X 3

		$display("Testing Decode three times");
		for(i=0; i<3; ++i) begin
			@(negedge clock);
			fetch_valid 		= ZERO;
			dispatch_no_hazard 	= ONE;
			branch_incorrect 	= ZERO;
			if_inst_in.valid_inst 	= ONE;
			if_inst_in.npc		= 4*(i+1);
			if_inst_in.ir		= 4*256*(i+1);
			
			@(posedge clock);
			`DELAY;
			print_IQ;
		
		assert((inst_queue_full == 0) & (inst_queue_entry==(4-i))) else #1 exit_on_error;
		assert((inst_queue_out[3-i].valid_inst == 1) & (inst_queue_out[3-i].npc == 20) & (inst_queue_out[3-i].ir == 20*256)) else #1 exit_on_error;
		assert((if_inst_out.valid_inst == 1) & (if_inst_out.npc == 4*(i+1)) & (if_inst_out.ir == 4*256*(i+1))) else #1 exit_on_error;



		end
		$display("@@@ Decode three times Passed");
	


		// Fetch and Decode
		
		$display("Testing Fetch and Decode sametime when queue is not empty");
		@(negedge clock);
		fetch_valid 		= ONE;
		dispatch_no_hazard 	= ONE;
		branch_incorrect 	= ZERO;
		if_inst_in.valid_inst 	= ONE;
		if_inst_in.npc		= 64'hfff;
		if_inst_in.ir		= 64'hffff;
		
		@(posedge clock);
		`DELAY;
		print_IQ;
		assert((inst_queue_full == 0) & (inst_queue_entry==2)) else #1 exit_on_error;
		assert((inst_queue_out[1].valid_inst == 1) & (inst_queue_out[1].npc == 64'hfff) & (inst_queue_out[1].ir == 64'hffff)) else #1 exit_on_error;
		assert((if_inst_out.valid_inst == 1) & (if_inst_out.npc == 16) & (if_inst_out.ir == 16*256)) else #1 exit_on_error;

		$display("@@@ Fetch and Decode sametime when queue is not empty Passed");
	

		// Do nothing	

		$display("Testing do nothing");
		@(negedge clock);
		fetch_valid 		= ZERO;
		dispatch_no_hazard 	= ZERO;
		branch_incorrect 	= ZERO;
		if_inst_in.valid_inst 	= ONE;
		if_inst_in.npc		= 64'hfff;
		if_inst_in.ir		= 64'hffff;
		
		@(posedge clock);
		`DELAY;
		print_IQ;
		assert((inst_queue_full == 0) & (inst_queue_entry==2)) else #1 exit_on_error;
		assert((inst_queue_out[1].valid_inst == 1) & (inst_queue_out[1].npc == 64'hfff) & (inst_queue_out[1].ir == 64'hffff)) else #1 exit_on_error;
		assert((if_inst_out.valid_inst == 0) & (if_inst_out.npc == 64'h0) & (if_inst_out.ir == `NOOP_INST)) else #1 exit_on_error;

		$display("@@@ Do nothing Passed");
	

		// Flush when branch_prediction is incorrect

		$display("Testing FLUSH");
		@(negedge clock);
		fetch_valid 		= ONE;
		dispatch_no_hazard 	= ONE;
		branch_incorrect 	= ONE;
		if_inst_in.valid_inst 	= ONE;
		if_inst_in.npc		= 64'hffff;
		if_inst_in.ir		= 64'hfffff;
		
		@(posedge clock);
		`DELAY;
		print_IQ;
		reset_test;		
		$display("@@@ FLUSH Passed");
	

		// Fetch when the queue is full
/*	
		$display("Testing Fetch when the queue is full");
		for(i=0; i<`IQ_SIZE-2; ++i) begin
			@(negedge clock);
			fetch_valid 		= ONE;
			dispatch_no_hazard 	= ZERO;
			branch_incorrect 	= ZERO;
			if_inst_in.valid_inst 	= ONE;
			if_inst_in.npc		= 4*(i+1);
			if_inst_in.ir		= 4*256*(i+1);
			
			@(posedge clock);
			`DELAY;
			print_IQ;
			
			assert((inst_queue_full == 0) & (inst_queue_entry==(i+1))) else #1 exit_on_error;
			assert((inst_queue_out[i].valid_inst == 1) & (inst_queue_out[i].npc == 4*(i+1)) & (inst_queue_out[i].ir == 4*256*(i+1))) else #1 exit_on_error;
			assert((if_inst_out.valid_inst == 0) & (if_inst_out.npc == 64'h0) & (if_inst_out.ir == `NOOP_INST))else #1 exit_on_error;


		end
		
			@(negedge clock);
			fetch_valid 		= ONE;
			dispatch_no_hazard 	= ZERO;
			branch_incorrect 	= ZERO;
			if_inst_in.valid_inst 	= ONE;
			if_inst_in.npc		= 4*(`IQ_SIZE);
			if_inst_in.ir		= 4*256*(`IQ_SIZE);
			
			@(posedge clock);
			`DELAY;
			print_IQ;
			
			assert((inst_queue_full == 1) & (inst_queue_entry==(`IQ_SIZE))) else #1 exit_on_error;
			assert((inst_queue_out[i].valid_inst == 1) & (inst_queue_out[i].npc == 4*(`IQ_SIZE)) & (inst_queue_out[i].ir == 4*256*(`IQ_SIZE))) else #1 exit_on_error;
			assert((if_inst_out.valid_inst == 0) & (if_inst_out.npc == 64'h0) & (if_inst_out.ir == `NOOP_INST))else #1 exit_on_error;

			@(negedge clock);
			fetch_valid 		= ONE;
			dispatch_no_hazard 	= ZERO;
			branch_incorrect 	= ZERO;
			if_inst_in.valid_inst 	= ONE;
			if_inst_in.npc		= 4*(`IQ_SIZE+2);
			if_inst_in.ir		= 4*256*(`IQ_SIZE+2);
			
			@(posedge clock);
			`DELAY;
			print_IQ;
			
			assert((inst_queue_full == 1) & (inst_queue_entry==(`IQ_SIZE))) else #1 exit_on_error;
			assert((inst_queue_out[i].valid_inst == 1) & (inst_queue_out[i].npc == 4*(`IQ_SIZE)) & (inst_queue_out[i].ir == 4*256*(`IQ_SIZE))) else #1 exit_on_error;
			assert((if_inst_out.valid_inst == 0) & (if_inst_out.npc == 64'h0) & (if_inst_out.ir == `NOOP_INST))else #1 exit_on_error;


			

		$display("@@@ Fetch when the queue is full Passed");
	
		// Fetch and Decode at the same time when the queue is full

			$display("Testing Fetch and Decode sametime when queue is full");
			@(negedge clock);
			fetch_valid 		= ONE;
			dispatch_no_hazard 	= ONE;
			branch_incorrect 	= ZERO;
			if_inst_in.valid_inst 	= ONE;
			if_inst_in.npc		= 64'hf00;
			if_inst_in.ir		= 64'hf000;
			
			@(posedge clock);
			`DELAY;
			print_IQ;
			assert((inst_queue_full == 1) & (inst_queue_entry==`IQ_SIZE)) else #1 exit_on_error;
			assert((inst_queue_out[`IQ_SIZE-1].valid_inst == 1) & (inst_queue_out[`IQ_SIZE-1].npc == 64'hf00) & (inst_queue_out[`IQ_SIZE-1].ir == 64'hf000)) else #1 exit_on_error;
			assert((if_inst_out.valid_inst == 1) & (if_inst_out.npc == 4) & (if_inst_out.ir == 4*256)) else #1 exit_on_error;

		$display("@@@ Fetch and Decode sametime when queue is full Passed");
*/	
	
			
		// Flush when branch_prediction is incorrect
			$display("Testing FLUSH");
			@(negedge clock);
			fetch_valid 		= ONE;
			dispatch_no_hazard 	= ONE;
			branch_incorrect 	= ONE;
			if_inst_in.valid_inst 	= ONE;
			if_inst_in.npc		= 64'hffff;
			if_inst_in.ir		= 64'hfffff;
			
			@(posedge clock);
			`DELAY;
			print_IQ;
			reset_test;		
			$display("@@@ FLUSH Passed");
	

		// Decode when the queue is empty
			$display("Testing decode when the queue is empty");
			@(negedge clock);
			fetch_valid 		= ZERO;
			dispatch_no_hazard 	= ONE;
			branch_incorrect 	= ZERO;
			if_inst_in.valid_inst 	= ONE;
			if_inst_in.npc		= 64'hffff;
			if_inst_in.ir		= 64'hfffff;
			
			@(posedge clock);
			`DELAY;
			print_IQ;
			reset_test;
			$display("@@@ Decode when the queue is empty Passed");
/*				
		// Check the duplicate fetch when the queue is empty and
		// fetch&decode at the same time
			$display("Testing duplicate fetch &decode when the queue is empty");
		
			@(negedge clock);
			fetch_valid 		= ONE;
			dispatch_no_hazard 	= ONE;
			branch_incorrect 	= ZERO;
			if_inst_in.valid_inst 	= ONE;
			if_inst_in.npc		= 64'h11;
			if_inst_in.ir		= 32'h111;
			
			@(posedge clock);
			`DELAY;
			print_IQ;
			
			assert((inst_queue_full == 0) & (inst_queue_entry==0)) else #1 exit_on_error;
			assert((inst_queue_out[0].valid_inst == 0) & (inst_queue_out[0].npc == 64'h0) & (inst_queue_out[i].ir == `NOOP_INST)) else #1 exit_on_error;
			assert((if_inst_out.valid_inst == 1) & (if_inst_out.npc == 64'h11) & (if_inst_out.ir == 32'h111))else #1 exit_on_error;
		
			@(negedge clock);
			fetch_valid 		= ONE;
			dispatch_no_hazard 	= ONE;
			branch_incorrect 	= ZERO;
			if_inst_in.valid_inst 	= ONE;
			if_inst_in.npc		= 64'h11;
			if_inst_in.ir		= 32'h111;
			
			@(posedge clock);
			`DELAY;
			print_IQ;
			
			assert((inst_queue_full == 0) & (inst_queue_entry==0)) else #1 exit_on_error;
			assert((inst_queue_out[0].valid_inst == 0) & (inst_queue_out[0].npc == 64'h0) & (inst_queue_out[i].ir == `NOOP_INST)) else #1 exit_on_error;
			assert((if_inst_out.valid_inst == 0) & (if_inst_out.npc == 64'h0) & (if_inst_out.ir == `NOOP_INST))else #1 exit_on_error;

			$display("@@@ Duplicate fetch & decode when the queue is empty Passed");
	



		// Check the duplicate fetch when the queue is not empty
			$display("Testing duplicate fetch  when the queue is not empty");
			@(negedge clock);
			fetch_valid 		= ONE;
			dispatch_no_hazard 	= ZERO;
			branch_incorrect 	= ZERO;
			if_inst_in.valid_inst 	= ONE;
			if_inst_in.npc		= 64'h110;
			if_inst_in.ir		= 32'h1010;
			
			@(posedge clock);
			`DELAY;
			print_IQ;
			
			assert((inst_queue_full == 0) & (inst_queue_entry==1)) else #1 exit_on_error;
			assert((inst_queue_out[0].valid_inst == 1) & (inst_queue_out[0].npc == 64'h110) & (inst_queue_out[0].ir == 32'h1010)) else #1 exit_on_error;
			assert((if_inst_out.valid_inst == 0) & (if_inst_out.npc == 64'h0) & (if_inst_out.ir == `NOOP_INST))else #1 exit_on_error;



			for(i=0; i<10; ++i) begin
			@(negedge clock);
			fetch_valid 		= ONE;
			dispatch_no_hazard 	= ZERO;
			branch_incorrect 	= ZERO;
			if_inst_in.valid_inst 	= ONE;
			if_inst_in.npc		= 64'h110;
			if_inst_in.ir		= 32'h1010;
			
			@(posedge clock);
			`DELAY;
			print_IQ;
			
			assert((inst_queue_full == 0) & (inst_queue_entry==1)) else #1 exit_on_error;
		
			assert((inst_queue_out[0].valid_inst == 1) & (inst_queue_out[0].npc == 64'h110) & (inst_queue_out[0].ir == 32'h1010)) else #1 exit_on_error;
			assert((inst_queue_out[1].valid_inst == 0) & (inst_queue_out[1].npc == 64'h0) & (inst_queue_out[1].ir == `NOOP_INST)) else #1 exit_on_error;
			assert((if_inst_out.valid_inst == 0) & (if_inst_out.npc == 64'h0) & (if_inst_out.ir == `NOOP_INST))else #1 exit_on_error;


			end
			$display("@@@ Duplicate fetch  when the queue is not empty Passed");
	
*/

		// Synthesize

		$display("@@@ ALL TESTS Passed");
		$finish;
	end


endmodule
