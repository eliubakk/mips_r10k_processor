//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  ex_stage.v                                           //
//                                                                      //
//  Description :  instruction execute (EX) stage of the pipeline;      //
//                 given the instruction command code CMD, select the   //
//                 proper input A and B for the ALU, compute the result,// 
//                 and compute the condition for branches, and pass all //
//                 the results down the pipeline. MWB                   // 
//                                                                      //
//                                                                      //
//////////////////////////////////////////////////////////////////////////
`include "../../sys_defs.vh"

//
// The ALU
//
// given the command code CMD and proper operands A and B, compute the
// result of the instruction
//
// This module is purely combinational
//
module alu(
    input [63:0] opa,
    input [63:0] opb,
    ALU_FUNC     func,

    output logic [63:0] result
  );

    // This function computes a signed less-than operation
  function signed_lt;
    input [63:0] a, b;

    if (a[63] == b[63]) 
      signed_lt = (a < b); // signs match: signed compare same as unsigned
    else
      signed_lt = a[63];   // signs differ: a is smaller if neg, larger if pos
  endfunction

  always_comb begin
    case (func)
      ALU_ADDQ:      result = opa + opb;
      ALU_SUBQ:      result = opa - opb;
      ALU_AND:      result = opa & opb;
      ALU_BIC:      result = opa & ~opb;
      ALU_BIS:      result = opa | opb;
      ALU_ORNOT:    result = opa | ~opb;
      ALU_XOR:      result = opa ^ opb;
      ALU_EQV:      result = opa ^ ~opb;
      ALU_SRL:      result = opa >> opb[5:0];
      ALU_SLL:      result = opa << opb[5:0];
      ALU_SRA:      result = (opa >> opb[5:0]) | ({64{opa[63]}} << (64 -
                              opb[5:0])); // arithmetic from logical shift
    //  ALU_MULQ:      result = opa * opb;
      ALU_CMPULT:    result = { 63'd0, (opa < opb) };
      ALU_CMPEQ:    result = { 63'd0, (opa == opb) };
      ALU_CMPULE:    result = { 63'd0, (opa <= opb) };
      ALU_CMPLT:    result = { 63'd0, signed_lt(opa, opb) };
      ALU_CMPLE:    result = { 63'd0, (signed_lt(opa, opb) || (opa == opb)) };
      default:      result = 64'hdeadbeefbaadbeef;  // here only to force
                              // a combinational solution
                              // a casex would be better
    endcase
  end
endmodule // alu

//
// BrCond module
//
// Given the instruction code, compute the proper condition for the
// instruction; for branches this condition will indicate whether the
// target is taken.
//
// This module is purely combinational
//
module brcond(// Inputs
    input [63:0] opa,    // Value to check against condition
    input  [2:0] func,  // Specifies which condition to check

    output logic cond    // 0/1 condition result (False/True)
  );

  always_comb begin
  case (func[1:0])                              // 'full-case'  All cases covered, no need for a default
    2'b00: cond = (opa[0] == 0);                // LBC: (lsb(opa) == 0) ?
    2'b01: cond = (opa == 0);                    // EQ: (opa == 0) ?
    2'b10: cond = (opa[63] == 1);                // LT: (signed(opa) < 0) : check sign bit
    2'b11: cond = (opa[63] == 1) || (opa == 0);  // LE: (signed(opa) <= 0)
  endcase
  
     // negate cond if func[2] is set
    if (func[2])
      cond = ~cond;
  end
endmodule // brcond


module ex_stage(
    input          clock,               // system clock
    input          reset,               // system reset
    
    //input  [31:0]  id_ex_IR,            // incoming instruction
    input RS_ROW_T [`NUM_FU_TOTAL-1:0]  issue_reg,           // Input from the issue register
    input [`NUM_FU_TOTAL-1:0][63:0]     T1_value,
    input [`NUM_FU_TOTAL-1:0][63:0]     T2_value,
    
    output logic [`NUM_FU_TOTAL-1:0][63:0]  ex_alu_result_out,   // ALU0 result
		output logic done,
    output logic ex_take_branch_out // is this a taken branch?
  );

  logic [`NUM_FU_TOTAL-1:0][63:0] mem_disp;
  logic [`NUM_FU_TOTAL-1:0][63:0] br_disp;
  logic [`NUM_FU_TOTAL-1:0][63:0] alu_imm;

  logic [`NUM_FU_TOTAL-1:0][63:0] opa_mux_out, opb_mux_out;
  logic brcond_result;

  // set up possible immediates:
  //   mem_disp: sign-extended 16-bit immediate for memory format
  //   br_disp: sign-extended 21-bit immediate * 4 for branch displacement
  //   alu_imm: zero-extended 8-bit immediate for ALU ops

  assign  mem_disp[FU_ALU_IDX] = { {48{issue_reg[FU_ALU_IDX].ir[15]}}, issue_reg[FU_ALU_IDX].ir[15:0] };
  assign  br_disp[FU_ALU_IDX]  = { {41{issue_reg[FU_ALU_IDX].ir[20]}}, issue_reg[FU_ALU_IDX].ir[20:0], 2'b00 };
  assign  alu_imm[FU_ALU_IDX]  = { 56'b0, issue_reg[FU_ALU_IDX].ir[20:13] };
   

  assign  mem_disp[FU_ALU_IDX+1] = { {48{issue_reg[FU_ALU_IDX+1].ir[15]}}, issue_reg[FU_ALU_IDX+1].ir[15:0]};           // incoming instruction PC+4reg[1].ir[15:0] };
  assign  br_disp[FU_ALU_IDX+1]  = { {41{issue_reg[FU_ALU_IDX+1].ir[20]}}, issue_reg[FU_ALU_IDX+1].ir[20:0], 2'b00 };
  assign  alu_imm[FU_ALU_IDX+1]  = { 56'b0, issue_reg[FU_ALU_IDX+1].ir[20:13] };
  
  assign  mem_disp[FU_LD_IDX] = { {48{issue_reg[FU_LD_IDX].ir[15]}}, issue_reg[FU_LD_IDX].ir[15:0] };
  assign  br_disp[FU_LD_IDX]  = { {41{issue_reg[FU_LD_IDX].ir[20]}}, issue_reg[FU_LD_IDX].ir[20:0], 2'b00 };
  assign  alu_imm[FU_LD_IDX]  = { 56'b0, issue_reg[FU_LD_IDX].ir[20:13] };
  
  assign  mem_disp[FU_MULT_IDX] = { {48{issue_reg[FU_MULT_IDX].ir[15]}}, issue_reg[FU_MULT_IDX].ir[15:0] };
  assign  br_disp[FU_MULT_IDX]  = { {41{issue_reg[FU_MULT_IDX].ir[20]}}, issue_reg[FU_MULT_IDX].ir[20:0], 2'b00 };
  assign  alu_imm[FU_MULT_IDX]  = { 56'b0, issue_reg[FU_MULT_IDX].ir[20:13] };
   
  assign  mem_disp[FU_BR_IDX] = { {48{issue_reg[FU_BR_IDX].ir[15]}}, issue_reg[FU_BR_IDX].ir[15:0] };
  assign  br_disp[FU_BR_IDX]  = { {41{issue_reg[FU_BR_IDX].ir[20]}}, issue_reg[FU_BR_IDX].ir[20:0], 2'b00 };
  assign  alu_imm[FU_BR_IDX]  = { 56'b0, issue_reg[FU_BR_IDX].ir[20:13] };

  assign  mem_disp[FU_ST_IDX] = { {48{issue_reg[FU_ST_IDX].ir[15]}}, issue_reg[FU_ST_IDX].ir[15:0] };
  assign  br_disp[FU_ST_IDX]  = { {41{issue_reg[FU_ST_IDX].ir[20]}}, issue_reg[FU_ST_IDX].ir[20:0], 2'b00 };
  assign  alu_imm[FU_ST_IDX]  = { 56'b0, issue_reg[FU_ST_IDX].ir[20:13] };
  
  //opA mux
  always_comb begin
    for (integer i=0; i<`NUM_FU_TOTAL; i=i+1) begin
      case (issue_reg[i].inst.opa_select)
        ALU_OPA_IS_REGA:     opa_mux_out[i] = T1_value[i];
        ALU_OPA_IS_MEM_DISP: opa_mux_out[i] = mem_disp[i];
        ALU_OPA_IS_NPC:      opa_mux_out[i] = issue_reg[i].npc;
        ALU_OPA_IS_NOT3:     opa_mux_out[i] = ~64'h3;
      endcase
    end
  end

  //opB mux
  always_comb begin
    opb_mux_out = 64'hbaadbeefdeadbeef;
    for (integer i=0; i<`NUM_FU_TOTAL; i=i+1) begin
      case (issue_reg[i].inst.opb_select)
      ALU_OPB_IS_REGB:     opb_mux_out[i] = T2_value[i];//id_ex_regb;
      ALU_OPB_IS_ALU_IMM:  opb_mux_out[i] = alu_imm[i];
      ALU_OPB_IS_BR_DISP:  opb_mux_out[i] = br_disp[i];
      endcase 
    end
    
  end

  //
  // instantiate the ALU
  //
  alu alu_0 (// Inputs                //    *******ALU_0**********
    .opa(opa_mux_out[FU_ALU_IDX]),
    .opb(opb_mux_out[FU_ALU_IDX]),
    .func(issue_reg[FU_ALU_IDX].inst.alu_func),

    // Output
    .result(ex_alu_result_out[FU_ALU_IDX])
  );

  alu alu_1 (// Inputs                //    *******ALU_1**********
    .opa(opa_mux_out[FU_ALU_IDX+1]),
    .opb(opb_mux_out[FU_ALU_IDX+1]),
    .func(issue_reg[FU_ALU_IDX+1].inst.alu_func),

    // Output
    .result(ex_alu_result_out[FU_ALU_IDX+1])
  );  

  alu alu_ls (// Inputs                //    *******LOAD AND STORE**********
    .opa(opa_mux_out[FU_LD_IDX]),
    .opb(opb_mux_out[FU_LD_IDX]),
    .func(issue_reg[FU_LD_IDX].inst.alu_func),

    // Output
    .result(ex_alu_result_out[FU_LD_IDX])
  );  

  alu alu_st (// Inputs                //    *******LOAD AND STORE**********
    .opa(opa_mux_out[FU_ST_IDX]),
    .opb(opb_mux_out[FU_ST_IDX]),
    .func(issue_reg[FU_ST_IDX].inst.alu_func),

    // Output
    .result(ex_alu_result_out[FU_ST_IDX])
  );  
  // alu alu_store (// Inputs
  //   .opa(opa_mux_out_alu_store),
  //   .opb(opb_mux_out_alu_store),
  //   .func(id_ex_alu_store_func),

  //   // Output
  //   .result(ex_alu_store_result_out)
  // );  
  

  pipe_mult mult0 (// Inputs)                 //********MULT************
    .clock(clock),
    .reset(reset),
	  .mcand(opa_mux_out[FU_MULT_IDX]),
    .mplier(opb_mux_out[FU_MULT_IDX]),
	  .start(issue_reg[FU_MULT_IDX].inst.valid_inst),
	  .product(ex_alu_result_out[FU_MULT_IDX]),
		.done(done)
  );

  
    alu alu_branch (// Inputs                //    *******BRANCH**********
    .opa(opa_mux_out[FU_BR_IDX]),
    .opb(opb_mux_out[FU_BR_IDX]),
    .func(issue_reg[FU_BR_IDX].inst.alu_func),

    // Output
    .result(ex_alu_result_out[FU_BR_IDX])
  ); 
  

   //
   // instantiate the branch condition tester
   //
  brcond brcond (// Inputs
    .opa(T1_value[FU_BR_IDX]),       // always check regA value
    .func(issue_reg[FU_BR_IDX].ir[28:26]), // inst bits to determine check

    // Output
    .cond(brcond_result)
  );

   // ultimate "take branch" signal:
   //    unconditional, or conditional and the condition is true
  assign ex_take_branch_out = issue_reg[FU_BR_IDX].busy & (issue_reg[FU_BR_IDX].inst.uncond_branch
                              | (issue_reg[FU_BR_IDX].inst.cond_branch & brcond_result));

endmodule // module ex_stage
