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
	logic	fetch_en;
	INST_Q	if_inst_in;
	logic	dispatch_no_hazard;
	logic	branch_incorrect;

	// output wires
	INST_Q	[`IQ_SIZE-1:0] 		inst_queue_out;
	logic	[$clog2(`IQ_SIZE):0] 	inst_queue_entry;
	logic				inst_queue_full;
	INST_Q				if_inst_out;

	
	// initialize module

	`DUT(IQ) iq0(
		// inputs
		.clock(clock),
		.reset(reset),
		.fetch_en(fetch_en),
		.if_inst_in(if_inst_in),
		.dispatch_no_hazard(dispatch_no_hazard),
		.branch_incorrect(branch_incorrect),
		
		// outputs
		`ifdef DEBUG
		.inst_queue_out(inst_queue_out),
		.inst_queue_entry(inst_queue_entry),
		`endif
		.inst_queue_full,
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
		
			$display("--------Print Instruction Queue--------");
			$display("Inst_queue_full? : %b, inst_queue_entry : %d", inst_queue_full, inst_queue_entry);
			$display("Decoded instruction valid : %b,npc : %h, IR : %h", if_inst_out.valid_inst, if_inst_out.npc, if_inst_out.ir);
			$display("--------Queue------");
			for (int i = 0; i < `IQ_SIZE; ++i) begin
				$display("Index : %d, valid : %b, npc : %h, IR : %h", i, inst_queue_out[i].valid_inst, inst_queue_out[i].npc, inst_queue_out[i].ir);
			end	
		end
	endtask


	// set clock change
	always `CLOCK_PERIOD clock = ~clock;

	initial begin

		// monitor wires
		$monitor("clock: %b, reset: %b, fetch_en: %b, if_inst_in.valid_inst :%b, if_inst_in.npc :%h, if_inst_in.ir : %h, dispatch_no_hazard : %b, branch_incorrect : %b", clock, reset, fetch_en, if_inst_in.valid_inst, if_inst_in.npc, if_inst_in.ir, dispatch_no_hazard, branch_incorrect);

		// intial values
		clock = ZERO;
		reset = ZERO;
		fetch_en = ZERO;
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
		assert((inst_queue_full == 0) & (inst_queue_entry==0)) else #1 exit_on_error;

		$display("Reset Test Passed");

		// Fetch and Decode at the same time when queue is empty


		// Fetch X 5
	
		// Decode X 3

		// Fetch and Decode

		// Do nothing	
	
		// Fetch when the queue is full
		
		// Flush when branch_prediction is incorrect
		
		// Decode when the queue is empty
		

		$display("ALL TESTS Passed");
		$finish;
	end


endmodule
