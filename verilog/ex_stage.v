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

`timescale 1ns/100ps

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
    input  [63:0]  id_ex_NPC,           // incoming instruction PC+4
    input  [31:0]  id_ex_IR,            // incoming instruction
    input  RS_ROW_T [`NUM_FU-1:0]			issue_reg,           // Input from the issue register
    

    output [63:0]  ex_alu0_result_out,   // ALU0 result
    
    output [63:0]  ex_alu1_result_out,   // ALU1 result
    
    output [63:0]  ex_alu_load_result_out,   // ALU_load result
    
    output [63:0]  ex_alu_store_result_out,   // ALU_store result
    
    output [63:0]  ex_mult_result_out,   // MULT result
		output done,
   
   
    output         ex_take_branch_out // is this a taken branch?
    
  );


  logic  [63:0] opa_mux_out, opb_mux_out;
  logic         brcond_result;

  // set up possible immediates:
  //   mem_disp: sign-extended 16-bit immediate for memory format
  //   br_disp: sign-extended 21-bit immediate * 4 for branch displacement
  //   alu_imm: zero-extended 8-bit immediate for ALU ops
  wire [63:0] mem_disp_alu0 = { {48{issue_reg[0].inst_opcode[15]}}, issue_reg[0].inst_opcode[15:0] };
  wire [63:0] br_disp_alu0  = { {41{issue_reg[0].inst_opcode[20]}}, issue_reg[0].inst_opcode[20:0], 2'b00 };
  wire [63:0] alu_imm_alu0  = { 56'b0, issue_reg[0].inst_opcode[20:13] };
   

  wire [63:0] mem_disp_alu1 = { {48{issue_reg[1].inst_opcode[15]}}, issue_reg[1].inst_opcode[15:0] };
  wire [63:0] br_disp_alu1  = { {41{issue_reg[1].inst_opcode[20]}}, issue_reg[1].inst_opcode[20:0], 2'b00 };
  wire [63:0] alu_imm_alu1  = { 56'b0, issue_reg[1].inst_opcode[20:13] };
  
  wire [63:0] mem_disp_alu_ls = { {48{issue_reg[2].inst_opcode[15]}}, issue_reg[2].inst_opcode[15:0] };
  wire [63:0] br_disp_alu_ls  = { {41{issue_reg[2].inst_opcode[20]}}, issue_reg[2].inst_opcode[20:0], 2'b00 };
  wire [63:0] alu_imm_alu_ls  = { 56'b0, issue_reg[2].inst_opcode[20:13] };
  
  // wire [63:0] mem_disp_alu_store = { {48{issue_reg[3].inst_opcode[15]}}, issue_reg[3].inst_opcode[15:0] };
  // wire [63:0] br_disp_alu_store  = { {41{issue_reg[3].inst_opcode[20]}}, issue_reg[3].inst_opcode[20:0], 2'b00 };
  // wire [63:0] alu_imm_alu_store  = { 56'b0, issue_reg[3].inst_opcode[20:13] };
   
  wire [63:0] mem_disp_mult = { {48{issue_reg[4].inst_opcode[15]}}, issue_reg[4].inst_opcode[15:0] };
  wire [63:0] br_disp_mult  = { {41{issue_reg[4].inst_opcode[20]}}, issue_reg[4].inst_opcode[20:0], 2'b00 };
  wire [63:0] alu_imm_mult  = { 56'b0, issue_reg[4].inst_opcode[20:13] };
  

  
   //
   // ALU0 opA mux
   //
  always_comb begin
    
    case (issue_reg[0].inst.opa_select)
      ALU_OPA_IS_REGA:     opa_mux_out_alu0 = T1_value[0];
      ALU_OPA_IS_MEM_DISP: opa_mux_out_alu0 = mem_disp_alu0;
      ALU_OPA_IS_NPC:      opa_mux_out_alu0 = id_ex_NPC;
      ALU_OPA_IS_NOT3:     opa_mux_out_alu0 = ~64'h3;
    endcase
  end


  // ALU1 opA mux
   //
  always_comb begin
    
    case (issue_reg[1].inst.opa_select)
      ALU_OPA_IS_REGA:     opa_mux_out_alu1 = T1_value[1];
      ALU_OPA_IS_MEM_DISP: opa_mux_out_alu1 = mem_disp_alu1;
      ALU_OPA_IS_NPC:      opa_mux_out_alu1 = id_ex_NPC;
      ALU_OPA_IS_NOT3:     opa_mux_out_alu1 = ~64'h3;
    endcase
  end

  // ALU_load_store opA mux
   //
  always_comb begin
    
    case (issue_reg[2].inst.opa_select)
      ALU_OPA_IS_REGA:     opa_mux_out_alu_ls = T1_value[2];
      ALU_OPA_IS_MEM_DISP: opa_mux_out_alu_ls = mem_disp_alu_ls;
      ALU_OPA_IS_NPC:      opa_mux_out_alu_ls = id_ex_NPC;
      ALU_OPA_IS_NOT3:     opa_mux_out_alu_ls = ~64'h3;
    endcase
  end

  // // ALU_store opA mux
  //  //
  // always_comb begin
    
  //   case (issue_reg[3].inst.opa_select)
  //     ALU_OPA_IS_REGA:     opa_mux_out_alu_store = T1_value[3];
  //     ALU_OPA_IS_MEM_DISP: opa_mux_out_alu_store = mem_disp;
  //     ALU_OPA_IS_NPC:      opa_mux_out_alu_store = id_ex_NPC;
  //     ALU_OPA_IS_NOT3:     opa_mux_out_alu_store = ~64'h3;
  //   endcase
  // end
  
//MULT opA
always_comb begin
    
    case (issue_reg[3].inst.opa_select)
      ALU_OPA_IS_REGA:     opa_mux_out_alu_mult = T1_value[3];
      ALU_OPA_IS_MEM_DISP: opa_mux_out_alu_mult = mem_disp_mult;
      ALU_OPA_IS_NPC:      opa_mux_out_alu_mult = id_ex_NPC;
      ALU_OPA_IS_NOT3:     opa_mux_out_alu_mult = ~64'h3;
    endcase
  end


   // 
   // ALU0 opB mux
   //
  always_comb begin
    // Default value, Set only because the case isnt full.  If you see this
    // value on the output of the mux you have an invalid opb_select
    opb_mux_out = 64'hbaadbeefdeadbeef;
    case (issue_reg[0].inst.opb_select)
      ALU_OPB_IS_REGB:    opb_mux_out_alu0 = T2_value[0]//id_ex_regb;
      ALU_OPB_IS_ALU_IMM: opb_mux_out_alu0 = alu_imm;
      ALU_OPB_IS_BR_DISP: opb_mux_out_alu0 = br_disp;
    endcase 
  end

  // ALU1 opB mux
   //
  always_comb begin
    // Default value, Set only because the case isnt full.  If you see this
    // value on the output of the mux you have an invalid opb_select
    opb_mux_out = 64'hbaadbeefdeadbeef;
    case (issue_reg[1].inst.opb_select)
      ALU_OPB_IS_REGB:    opb_mux_out_alu1 = T2_value[1]//id_ex_regb;
      ALU_OPB_IS_ALU_IMM: opb_mux_out_alu1 = alu_imm;
      ALU_OPB_IS_BR_DISP: opb_mux_out_alu1 = br_disp;
    endcase 
  end
  
  // ALU_load_store opB mux
   //
  always_comb begin
    // Default value, Set only because the case isnt full.  If you see this
    // value on the output of the mux you have an invalid opb_select
    opb_mux_out = 64'hbaadbeefdeadbeef;
    case (issue_reg[2].inst.opb_select)
      ALU_OPB_IS_REGB:    opb_mux_out_alu_ls = T2_value[2]//id_ex_regb;
      ALU_OPB_IS_ALU_IMM: opb_mux_out_alu_ls = alu_imm;
      ALU_OPB_IS_BR_DISP: opb_mux_out_alu_ls = br_disp;
    endcase 
  end
  
  // // ALU_store opB mux
  //  //
  // always_comb begin
  //   // Default value, Set only because the case isnt full.  If you see this
  //   // value on the output of the mux you have an invalid opb_select
  //   opb_mux_out = 64'hbaadbeefdeadbeef;
  //   case (issue_reg[3].inst.opb_select)
  //     ALU_OPB_IS_REGB:    opb_mux_out_alu1 = T2_value[3]//id_ex_regb;
  //     ALU_OPB_IS_ALU_IMM: opb_mux_out_alu1 = alu_imm;
  //     ALU_OPB_IS_BR_DISP: opb_mux_out_alu1 = br_disp;
  //   endcase 
  // end
  
  // MULT opB mux
   //
  always_comb begin
    // Default value, Set only because the case isnt full.  If you see this
    // value on the output of the mux you have an invalid opb_select
    opb_mux_out = 64'hbaadbeefdeadbeef;
    case (issue_reg[3].inst.opb_select)
      ALU_OPB_IS_REGB:    opb_mux_out_alu_mult = T2_value[3]//id_ex_regb;
      ALU_OPB_IS_ALU_IMM: opb_mux_out_alu_mult = alu_imm;
      ALU_OPB_IS_BR_DISP: opb_mux_out_alu_mult = br_disp;
    endcase 
  end
  
  //
  // instantiate the ALU
  //
  alu alu_0 (// Inputs
    .opa(opa_mux_out_alu0),
    .opb(opb_mux_out_alu0),
    .func(id_ex_alu0_func),

    // Output
    .result(ex_alu0_result_out)
  );

  alu alu_1 (// Inputs
    .opa(opa_mux_out_alu1),
    .opb(opb_mux_out_alu1),
    .func(id_ex_alu1_func),

    // Output
    .result(ex_alu1_result_out)
  );  

  alu alu_ls (// Inputs
    .opa(opa_mux_out_alu_ls),
    .opb(opb_mux_out_alu_ls),
    .func(id_ex_alu_ls_func),

    // Output
    .result(ex_alu_ls_result_out)
  );  

  // alu alu_store (// Inputs
  //   .opa(opa_mux_out_alu_store),
  //   .opb(opb_mux_out_alu_store),
  //   .func(id_ex_alu_store_func),

  //   // Output
  //   .result(ex_alu_store_result_out)
  // );  
  

  mult mult0 (// Inputs)
    .clock(clock),
    .reset(reset),
	  .mcand(mcand),
    .mplier(mplier),
	  .start(start),
	  .product(ex_mult_result_out),
		.done(done)
  );

  



   //
   // instantiate the branch condition tester
   //
  brcond brcond (// Inputs
    .opa(T1),       // always check regA value
    .func(issue_reg[4].inst_opcode[28:26]), // inst bits to determine check

    // Output
    .cond(brcond_result)
  );

   // ultimate "take branch" signal:
   //    unconditional, or conditional and the condition is true
  assign ex_take_branch_out = issue_reg[4].inst.id_uncond_branch_out
                              | (issue_reg[4].inst.id_cond_branch_out & brcond_result);

endmodule // module ex_stage
