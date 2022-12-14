/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  id_stage.v                                          //
//                                                                     //
//  Description :  instruction decode (ID) stage of the pipeline;      // 
//                 decode the instruction fetch register operands, and // 
//                 compute immediate operand (if applicable)           // 
//                                                                     //
/////////////////////////////////////////////////////////////////////////


`include "../../sys_defs.vh"
  // Decode an instruction: given instruction bits IR produce the
  // appropriate datapath control signals.
  //
  // This is a *combinational* module (basically a PLA).
  //
module decoder(
    input [31:0] inst,
    input valid_inst_in,  // ignore inst when low, outputs will
                          // reflect noop (except valid_inst)

    output ALU_OPA_SELECT opa_select,
    output ALU_OPB_SELECT opb_select,
    output DEST_REG_SEL   dest_reg, // mux selects
    output ALU_FUNC       alu_func,
    output FU_NAME        fu_name,
    output logic rd_mem, wr_mem, ldl_mem, stc_mem, cond_branch, uncond_branch,
    output logic halt,      // non-zero on a halt
    output logic cpuid,     // get CPUID instruction
    output logic illegal,   // non-zero on an illegal instruction
    output logic valid_inst, // for counting valid instructions executed
                            // and for making the fetch stage die on halts/
                            // keeping track of when to allow the next
                            // instruction out of fetch
                            // 0 for HALT and illegal instructions (die on halt)
    output GEN_REG ra_idx,
    output GEN_REG rb_idx,
    output GEN_REG rdest_idx
  );
  
  assign valid_inst = valid_inst_in && !illegal;

   assign ra_idx= ((opa_select == ALU_OPA_IS_REGA)| (fu_name== FU_BR)| (fu_name== FU_ST)) ? inst[25:21] : `ZERO_REG;
  assign rb_idx= (opb_select == ALU_OPB_IS_REGB) ? inst[20:16] : `ZERO_REG;
  // assign rdest_idx= (dest_reg == DEST_IS_REGC) ? inst[4:0] :
  //                   (dest_reg == DEST_IS_REGA) ? inst[25:21]  : `ZERO_REG;
                  
  assign rdest_idx= (dest_reg == DEST_NONE) ? `ZERO_REG : 
                    (dest_reg == DEST_IS_REGC) ? inst[4:0] :
                    (dest_reg == DEST_IS_REGA) ? inst[25:21]  : `ZERO_REG;
  always_comb begin
    // default control values:
    // - valid instructions must override these defaults as necessary.
    //   opa_select, opb_select, and alu_func should be set explicitly.
    // - invalid instructions should clear valid_inst.
    // - These defaults are equivalent to a noop
    // * see sys_defs.vh for the constants used here
    opa_select = ALU_OPA_IS_REGA;
    opb_select = ALU_OPB_IS_REGB;
    alu_func = ALU_ADDQ;
    fu_name = FU_ALU;
    dest_reg = DEST_NONE;
    rd_mem = `FALSE;
    wr_mem = `FALSE;
    ldl_mem = `FALSE;
    stc_mem = `FALSE;
    cond_branch = `FALSE;
    uncond_branch = `FALSE;
    halt = `FALSE;
    cpuid = `FALSE;
    illegal = `FALSE;
    
    if(valid_inst_in) begin
      case ({inst[31:29], 3'b0})
        6'h0:
          case (inst[31:26])
            `PAL_INST: begin
             
		          fu_name = FU_ALU;
              if (inst[25:0] == `PAL_HALT)
                halt = `TRUE;
              else if (inst[25:0] == `PAL_WHAMI) begin
                cpuid = `TRUE;
                dest_reg = DEST_IS_REGA;   // get cpuid writes to r0
              end else
                illegal = `TRUE;
              end
            default: illegal = `TRUE;
          endcase // case(inst[31:26])
       
        6'h10:
        begin
          opa_select = ALU_OPA_IS_REGA;
          opb_select = inst[12] ? ALU_OPB_IS_ALU_IMM : ALU_OPB_IS_REGB;
         
          dest_reg = DEST_IS_REGC;
          case (inst[31:26])
            `INTA_GRP:
              begin
                fu_name = FU_ALU;
                case (inst[11:5])
                  `CMPULT_INST:  alu_func = ALU_CMPULT;
                 `ADDQ_INST:    alu_func = ALU_ADDQ;
                 `SUBQ_INST:    alu_func = ALU_SUBQ;
                 `CMPEQ_INST:   alu_func = ALU_CMPEQ;
                 `CMPULE_INST:  alu_func = ALU_CMPULE;
                 `CMPLT_INST:   alu_func = ALU_CMPLT;
                 `CMPLE_INST:   alu_func = ALU_CMPLE;
                 default:        illegal = `TRUE;
              endcase // case(inst[11:5])
              end
            `INTL_GRP:
              begin
                fu_name = FU_ALU;
                case (inst[11:5])
                 `AND_INST:    alu_func = ALU_AND;
                 `BIC_INST:    alu_func = ALU_BIC;
                 `BIS_INST:    alu_func = ALU_BIS;
                 `ORNOT_INST:  alu_func = ALU_ORNOT;
                 `XOR_INST:    alu_func = ALU_XOR;
                 `EQV_INST:    alu_func = ALU_EQV;
                 default:       illegal = `TRUE;
                endcase // case(inst[11:5])
              end
            `INTS_GRP:
              begin
                fu_name = FU_ALU;
                 case (inst[11:5])
                 `SRL_INST:  alu_func = ALU_SRL;
                 `SLL_INST:  alu_func = ALU_SLL;
                 `SRA_INST:  alu_func = ALU_SRA;
                 default:    illegal = `TRUE;
                 endcase // case(inst[11:5])
              end
            `INTM_GRP: begin
                fu_name = FU_MULT;
                case (inst[11:5])
                 `MULQ_INST:       alu_func = ALU_MULQ;
                 default:          illegal = `TRUE;
                endcase // case(inst[11:5])
              end
            `ITFP_GRP:       illegal = `TRUE;       // unimplemented
            `FLTV_GRP:       illegal = `TRUE;       // unimplemented
            `FLTI_GRP:       illegal = `TRUE;       // unimplemented
            `FLTL_GRP:       illegal = `TRUE;       // unimplemented
          endcase // case(inst[31:26])
        end
           
        6'h18:
          case (inst[31:26])
            `MISC_GRP:       illegal = `TRUE; // unimplemented
            `JSR_GRP:
            begin
              // JMP, JSR, RET, and JSR_CO have identical semantics
              fu_name = FU_BR;
              opa_select = ALU_OPA_IS_NOT3;
              opb_select = ALU_OPB_IS_REGB;
             
              alu_func = ALU_AND; // clear low 2 bits (word-align)
              dest_reg = DEST_IS_REGA;
              uncond_branch = `TRUE;
            end
            `FTPI_GRP:       illegal = `TRUE;       // unimplemented
          endcase // case(inst[31:26])
           
        6'h08, 6'h20, 6'h28:
        begin
          opa_select = ALU_OPA_IS_MEM_DISP;
          opb_select = ALU_OPB_IS_REGB;
          alu_func = ALU_ADDQ;
          dest_reg = DEST_IS_REGA;
         
          case (inst[31:26])
            `LDA_INST:  /* defaults are OK */
            begin
             fu_name = FU_ALU;
            end
            `LDQ_INST:
            begin
              rd_mem = `TRUE;
              dest_reg = DEST_IS_REGA;
              fu_name = FU_LD;
            end // case: `LDQ_INST
            `LDQ_L_INST:
              begin
              rd_mem = `TRUE;
              ldl_mem = `TRUE;
              dest_reg = DEST_IS_REGA;
              fu_name = FU_LD;
            end // case: `LDQ_L_INST
            `STQ_INST:
            begin
              wr_mem = `TRUE;
              dest_reg = DEST_NONE;
              fu_name = FU_ST;
            end // case: `STQ_INST
            `STQ_C_INST:
            begin
              wr_mem = `TRUE;
              stc_mem = `TRUE;
              dest_reg = DEST_IS_REGA;
              fu_name = FU_ST;
            end // case: `STQ_INST
            default:       illegal = `TRUE;
          endcase // case(inst[31:26])
        end
           
        6'h30, 6'h38:
        begin
          opa_select = ALU_OPA_IS_NPC;
          opb_select = ALU_OPB_IS_BR_DISP;
          fu_name = FU_BR;
          alu_func = ALU_ADDQ;
          case (inst[31:26])
            `FBEQ_INST, `FBLT_INST, `FBLE_INST,
            `FBNE_INST, `FBGE_INST, `FBGT_INST:
            begin
              // FP conditionals not implemented
              illegal = `TRUE;
            end

            `BR_INST, `BSR_INST:
            begin
              dest_reg = DEST_IS_REGA;
              uncond_branch = `TRUE;
              
            end

            default:
              cond_branch = `TRUE; // all others are conditional
          endcase // case(inst[31:26])
        end
      endcase // case(inst[31:29] << 3)
    end // if(~valid_inst_in)
  end // always
   
endmodule // decoder


module id_stage(
    input         clock,                // system clock
    input         reset,                // system reset
    input  [31:0] if_id_IR,             // incoming instruction
    //input         wb_reg_wr_en_out,     // Reg write enable from WB Stage
    //input   [4:0] wb_reg_wr_idx_out,    // Reg write index from WB Stage
    // input  [63:0] wb_reg_wr_data_out,   // Reg write data from WB Stage
    input         if_id_valid_inst,
    // output logic [63:0] id_ra_value_out,      // reg A value
    //output logic [63:0] id_rb_value_out,      // reg B value

    //output ALU_OPA_SELECT id_opa_select_out,    // ALU opa mux select (ALU_OPA_xxx *)
    //output ALU_OPB_SELECT id_opb_select_out,    // ALU opb mux select (ALU_OPB_xxx *)
    //output DEST_REG_SEL id_dest_reg_select_out,
    //output logic  [4:0] id_dest_reg_idx_out,  // destination (writeback) register index
    // (ZERO_REG if no writeback)
    output DECODED_INST id_inst_out,
    // output ALU_FUNC     id_alu_func_out,      // ALU function select (ALU_xxx *)
    // output FU_NAME      id_fu_name_out,           // Function unit name
    // output logic        id_rd_mem_out,        // does inst read memory?
    // output logic        id_wr_mem_out,        // does inst write memory?
    // output logic        id_ldl_mem_out,       // load-lock inst?
    // output logic        id_stc_mem_out,       // store-conditional inst?
    // output logic        id_cond_branch_out,   // is inst a conditional branch?
    // output logic        id_uncond_branch_out, // is inst an unconditional branch 
    // // or jump?
    // output logic        id_halt_out,
    // output logic        id_cpuid_out,         // get CPUID inst?
    // output logic        id_illegal_out,
    // output logic        id_valid_inst_out,     // is inst a valid instruction to be 
    output GEN_REG ra_idx, rb_idx, rdest_idx       //for giving input for the maptable                                // counted for CPI calculations?
);
   
  //DEST_REG_SEL dest_reg_select;

  // instruction fields read from IF/ID pipeline register
  // assign id_ra_idx = rda_idx;   // inst operand A register index
  // assign id_rb_idx = rb_idx;   // inst operand B register index
  //assign id_rc_idx = if_id_IR[4:0];     // inst operand C register index

  // Instantiate the register file used by this pipeline
  // regfile regf_0 (
  //   .rda_idx(ra_idx),
  //   .rda_out(id_ra_value_out), 

  //   .rdb_idx(rb_idx),
  //   .rdb_out(id_rb_value_out),

  //   .wr_clk(clock),
  //   .wr_en(wb_reg_wr_en_out),
  //   .wr_idx(wb_reg_wr_idx_out),
  //   .wr_data(wb_reg_wr_data_out)
  // );





  // instantiate the instruction decoder
  decoder decoder_0 (
    // Input
    .inst(if_id_IR),
    .valid_inst_in(if_id_valid_inst),

    // Outputs
    .opa_select(id_inst_out.opa_select),
    .opb_select(id_inst_out.opb_select),
    .dest_reg(id_inst_out.dest_reg),
    .alu_func(id_inst_out.alu_func),
    .ra_idx(ra_idx),
    .rb_idx(rb_idx),
    .rdest_idx(rdest_idx),
    .fu_name(id_inst_out.fu_name),
    //.dest_reg(dest_reg_select),
    .rd_mem(id_inst_out.rd_mem),
    .wr_mem(id_inst_out.wr_mem),
    .ldl_mem(id_inst_out.ldl_mem),
    .stc_mem(id_inst_out.stc_mem),
    .cond_branch(id_inst_out.cond_branch),
    .uncond_branch(id_inst_out.uncond_branch),
    .halt(id_inst_out.halt),
    .cpuid(id_inst_out.cpuid),
    .illegal(id_inst_out.illegal),
    .valid_inst(id_inst_out.valid_inst)
  );

  // mux to generate dest_reg_idx based on
  // the dest_reg_select output from decoder
  // always_comb begin
  //   case (dest_reg_select)
  //     DEST_IS_REGC: id_dest_reg_idx_out = rc_idx;
  //     DEST_IS_REGA: id_dest_reg_idx_out = ra_idx;
  //     DEST_NONE:    id_dest_reg_idx_out = `ZERO_REG;
  //     default:      id_dest_reg_idx_out = `ZERO_REG; 
  //   endcase
  // end

endmodule
