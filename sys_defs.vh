/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  sys_defs.vh                                         //
//                                                                     //
//  Description :  This file has the macro-defines for macros used in  //
//                 the pipeline design.                                //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

`ifndef __SYS_DEFS_VH__
`define __SYS_DEFS_VH__

/* Synthesis testing definition, used in DUT module instantiation */

`ifdef  SYNTH_TEST
`define DUT(mod) mod``_svsim
`else
`define DUT(mod) mod
`endif

//////////////////////////////////////////////
//
// Memory/testbench attribute definitions
//
//////////////////////////////////////////////


`define NUM_MEM_TAGS           15

`define MEM_SIZE_IN_BYTES      (64*1024)
`define MEM_64BIT_LINES        (`MEM_SIZE_IN_BYTES/8)

// probably not a good idea to change this second one
`define VIRTUAL_CLOCK_PERIOD   30.0 // Clock period from dc_shell
`define VERILOG_CLOCK_PERIOD   10.0 // Clock period from test bench

`define MEM_LATENCY_IN_CYCLES 0.001
//`define MEM_LATENCY_IN_CYCLES (100.0/`VERILOG_CLOCK_PERIOD+0.49999)
// the 0.49999 is to force ceiling(100/period).  The default behavior for
// float to integer conversion is rounding to nearest

//////////////////////////////////////////////
//
// Register Parameters
//
//////////////////////////////////////////////
`define NUM_PHYS_REG 64
`define phys_index_t ($clog2(`NUM_PHYS_REG) - 1) 
typedef logic [$clog2(`NUM_PHYS_REG):0] PHYS_REG;
`define DUMMY_REG {1'b1, {$clog2(`NUM_PHYS_REG){1'b1}}}

`define NUM_GEN_REG 32
typedef logic [$clog2(`NUM_GEN_REG)-1:0]  GEN_REG;

//////////////////////////////////////////////
//
// Branch Predictor Parameters
//
//////////////////////////////////////////////

// GSHARE
//GHT_BIT is BH_SIZE in OBQ row
`define PC_SIZE 10

// BTB
`define TAG_SIZE 10 		//Tag bit size
`define TARGET_SIZE 12		//Target address size
`define BTB_ROW	16		//BTB row size : 5~10% of I$ size


// OBQ Rows
`define BH_SIZE 4		// Need to change this to 10
`define OBQ_SIZE 16
typedef struct packed {
  logic [`BH_SIZE-1:0] branch_history;
} OBQ_ROW_T;

// RAS
`define RAS_SIZE 2**6

//////////////////////////////////////////////
//
// Error codes
//
//////////////////////////////////////////////

typedef enum logic [3:0] {
  NO_ERROR               = 4'h0,
  HALTED_ON_MEMORY_ERROR = 4'h1,
  HALTED_ON_HALT         = 4'h2,
  HALTED_ON_ILLEGAL      = 4'h3
} ERROR_CODE;

//////////////////////////////DEBUG////////////////
//
// Datapath control signals
//
//////////////////////////////////////////////

//
// ALU opA input mux selects
//
typedef enum logic [1:0] {
  ALU_OPA_IS_REGA        = 2'h0,
  ALU_OPA_IS_MEM_DISP    = 2'h1,
  ALU_OPA_IS_NPC         = 2'h2,
  ALU_OPA_IS_NOT3        = 2'h3
} ALU_OPA_SELECT;

//
// ALU opB input mux selects
//
typedef enum logic [1:0] {
  ALU_OPB_IS_REGB       = 2'h0,
  ALU_OPB_IS_ALU_IMM    = 2'h1,
  ALU_OPB_IS_BR_DISP    = 2'h2
} ALU_OPB_SELECT;

//
// Destination register select
//
typedef enum logic [1:0] {
  DEST_IS_REGC  = 2'h0,
  DEST_IS_REGA  = 2'h1,
  DEST_NONE     = 2'h2
} DEST_REG_SEL;


//
// ALU function code input
// probably want to leave these alone
//
typedef enum logic [4:0] {
  ALU_ADDQ      = 5'h00,
  ALU_SUBQ      = 5'h01,
  ALU_AND       = 5'h02,
  ALU_BIC       = 5'h03,
  ALU_BIS       = 5'h04,
  ALU_ORNOT     = 5'h05,
  ALU_XOR       = 5'h06,
  ALU_EQV       = 5'h07,
  ALU_SRL       = 5'h08,
  ALU_SLL       = 5'h09,
  ALU_SRA       = 5'h0a,
  ALU_MULQ      = 5'h0b,
  ALU_CMPEQ     = 5'h0c,
  ALU_CMPLT     = 5'h0d,
  ALU_CMPLE     = 5'h0e,
  ALU_CMPULT    = 5'h0f,
  ALU_CMPULE    = 5'h10
} ALU_FUNC;

//LUT for bit count of 4-bit numbers
//                                         0000    0001    0010    0011    0100    0101    0110    0111    1000    1001    1010    1011    1100    1101    1110    1111
const logic [0:15][2:0] BIT_COUNT_LUT = {3'b000, 3'b001, 3'b001, 3'b010, 3'b001, 3'b010, 3'b010, 3'b011, 3'b001, 3'b010, 3'b010, 3'b011, 3'b010, 3'b011, 3'b011, 3'b100};

`define NUM_FU_TOTAL 5 // total number of functional units
`define NUM_TYPE_FU 4 // number of different types of functional units
`define NUM_LD 1
`define RS_SIZE 16
`define MAX_RS_SIZE 16
`define SS_SIZE 1 // superscalar size
`define ROB_SIZE 16

typedef logic [`NUM_FU_TOTAL-1:0] FU_REG;

// the number of functional units of each specific type we instantiate.
const logic [0:(`NUM_TYPE_FU - 1)][1:0] GLOBAL_NUM_OF_FU_TYPE = {2'b10,2'b01,2'b01,2'b01};

typedef enum logic [2:0]{
  FU_ALU,
  FU_LD,
  FU_MULT,
  FU_BR
} FU_NAME;

const FU_NAME [0:(`NUM_TYPE_FU - 1)] GLOBAL_FU_NAME_VAL = {FU_ALU, FU_LD, FU_MULT, FU_BR};

typedef enum logic [3:0]{
  FU_ALU_IDX = 0,
  FU_LD_IDX = 2,
  FU_MULT_IDX = 3,
  FU_BR_IDX = 4
} FU_IDX;

const FU_IDX [0:(`NUM_TYPE_FU - 1)] GLOBAL_FU_BASE_IDX = {FU_ALU_IDX, FU_LD_IDX, FU_MULT_IDX, FU_BR_IDX};

typedef struct packed {
	PHYS_REG phys_tag;
} MAP_ROW_T;


//ROB_ROWS
typedef struct packed{
  PHYS_REG T_new_out;
  PHYS_REG T_old_out;
//  logic T_new_valid;
//  logic T_old_valid;
  logic busy;
  logic halt;
} ROB_ROW_T;

//Freelist
`define FL_SIZE `NUM_PHYS_REG



//////////////////////////////////////////////
//
// Assorted things it is not wise to change
//
//////////////////////////////////////////////

//
// actually, you might have to change this if you change VERILOG_CLOCK_PERIOD
//
`define SD #1


// the Alpha register file zero register, any read of this register always
// returns a zero value, and any write to this register is thrown away
//
`define ZERO_REG        5'd31

//
// Memory bus commands control signals
//
typedef enum logic [1:0] {
  BUS_NONE     = 2'h0,
  BUS_LOAD     = 2'h1,
  BUS_STORE    = 2'h2
} BUS_COMMAND;

//
// useful boolean single-bit definitions
//
`define FALSE	1'h0
`define TRUE	1'h1

typedef enum logic [1:0] {
  NOOP_OPCODE,
  PAL_OPCODE,
  LDA_OPCODE,
  LDAH_OPCODE
} OPCODE;

//
// Basic NOOP instruction.  Allows pipline registers to clearly be reset with
// an instruction that does nothing instead of Zero which is really a PAL_INST
//
`define NOOP_INST 32'h47ff041f

//
// top level opcodes, used by the IF stage to decode Alpha instructions
//
`define PAL_INST	6'h00
`define LDA_INST	6'h08
`define LDAH_INST	6'h09
`define LDBU_INST	6'h0a
`define LDQ_U_INST	6'h0b
`define LDWU_INST	6'h0c
`define STW_INST	6'h0d
`define STB_INST	6'h0e
`define ST	6'h0f
`define INTA_GRP	6'h10
`define INTL_GRP	6'h11
`define INTS_GRP	6'h12
`define INTM_GRP	6'h13
`define ITFP_GRP	6'h14	// unimplemented
`define FLTV_GRP	6'h15	// unimplemented
`define FLTI_GRP	6'h16	// unimplemented
`define FLTL_GRP	6'h17	// unimplemented
`define MISC_GRP	6'h18
`define JSR_GRP		6'h1a
`define FTPI_GRP	6'h1c
`define LDF_INST	6'h20
`define LDG_INST	6'h21
`define LDS_INST	6'h22
`define LDT_INST	6'h23
`define STF_INST	6'h24
`define STG_INST	6'h25
`define STS_INST	6'h26
`define STT_INST	6'h27
`define LDL_INST	6'h28
`define LDQ_INST	6'h29
`define LDL_L_INST	6'h2a
`define LDQ_L_INST	6'h2b
`define STL_INST	6'h2c
`define STQ_INST	6'h2d
`define STL_C_INST	6'h2e
`define STQ_C_INST	6'h2f
`define BR_INST		6'h30
`define FBEQ_INST	6'h31
`define FBLT_INST	6'h32
`define FBLE_INST	6'h33
`define BSR_INST	6'h34
`define FBNE_INST	6'h35
`define FBGE_INST	6'h36
`define FBGT_INST	6'h37
`define BLBC_INST	6'h38
`define BEQ_INST	6'h39
`define BLT_INST	6'h3a
`define BLE_INST	6'h3b
`define BLBS_INST	6'h3c
`define BNE_INST	6'h3d
`define BGE_INST	6'h3e
`define BGT_INST	6'h3f

// PALcode opcodes
`define PAL_HALT  26'h555
`define PAL_WHAMI 26'h3c

// INTA (10.xx) opcodes
`define ADDL_INST	7'h00
`define S4ADDL_INST	7'h02
`define SUBL_INST	7'h09
`define S4SUBL_INST	7'h0b
`define CMPBGE_INST	7'h0f
`define S8ADDL_INST	7'h12
`define S8SUBL_INST	7'h1b
`define CMPULT_INST	7'h1d
`define ADDQ_INST	7'h20
`define S4ADDQ_INST	7'h22
`define SUBQ_INST	7'h29
`define S4SUBQ_INST	7'h2b
`define CMPEQ_INST	7'h2d
`define S8ADDQ_INST	7'h32
`define S8SUBQ_INST	7'h3b
`define CMPULE_INST	7'h3d
`define ADDLV_INST	7'h40
`define SUBLV_INST	7'h49
`define CMPLT_INST	7'h4d
`define ADDQV_INST	7'h60
`define SUBQV_INST	7'h69
`define CMPLE_INST	7'h6d

// INTL (11.xx) opcodes
`define AND_INST	7'h00
`define BIC_INST	7'h08
`define CMOVLBS_INST	7'h14
`define CMOVLBC_INST	7'h16
`define BIS_INST	7'h20
`define CMOVEQ_INST	7'h24
`define CMOVNE_INST	7'h26
`define ORNOT_INST	7'h28
`define XOR_INST	7'h40
`define CMOVLT_INST	7'h44
`define CMOVGE_INST	7'h46
`define EQV_INST	7'h48
`define AMASK_INST	7'h61
`define CMOVLE_INST	7'h64
`define CMOVGT_INST	7'h66
`define IMPLVER_INST	7'h6c

// INTS (12.xx) opcodes
`define MSKBL_INST	7'h02
`define EXTBL_INST	7'h06
`define INSBL_INST	7'h0b
`define MSKWL_INST	7'h12
`define EXTWL_INST	7'h16
`define INSWL_INST	7'h1b
`define MSKLL_INST	7'h22
`define EXTLL_INST	7'h26
`define INSLL_INST	7'h2b
`define ZAP_INST	7'h30
`define ZAPNOT_INST	7'h31
`define MSKQL_INST	7'h32
`define SRL_INST	7'h34
`define EXTQL_INST	7'h36
`define SLL_INST	7'h39
`define INSQL_INST	7'h3b
`define SRA_INST	7'h3c
`define MSKWH_INST	7'h52
`define INSWH_INST	7'h57
`define EXTWH_INST	7'h5a
`define MSKLH_INST	7'h62
`define INSLH_INST	7'h67
`define EXTLH_INST	7'h6a
`define MSKQH_INST	7'h72
`define INSQH_INST	7'h77
`define EXTQH_INST	7'h7a

// INTM (13.xx) opcodes
`define MULL_INST	7'h00
`define MULQ_INST	7'h20
`define UMULH_INST	7'h30
`define MULLV_INST	7'h40
`define MULQV_INST	7'h60

// MISC (18.xx) opcodes
`define TRAPB_INST	16'h0000
`define EXCB_INST	16'h0400
`define MB_INST		16'h4000
`define WMB_INST	16'h4400
`define FETCH_INST	16'h8000
`define FETCH_M_INST	16'ha000
`define RPCC_INST	16'hc000
`define RC_INST		16'he000
`define ECB_INST	16'he800
`define RS_INST		16'hf000
`define WH64_INST	16'hf800

// JSR (1a.xx) opcodes
`define JMP_INST	2'h0
`define JSR_INST	2'h1
`define RET_INST	2'h2
`define JSR_CO_INST	2'h3

typedef struct packed {
  ALU_OPA_SELECT opa_select; // use this for T1 valid
  ALU_OPB_SELECT opb_select; // use this for T2 valid
  DEST_REG_SEL   dest_reg; // mux selects use this for T valid
  ALU_FUNC       alu_func;
  FU_NAME        fu_name;
  logic rd_mem, wr_mem, ldl_mem, stc_mem, cond_branch, uncond_branch;
  logic halt;      // non-zero on a halt
  logic cpuid;     // get CPUID instruction
  logic illegal;   // non-zero on an illegal instruction
  logic valid_inst; // for counting valid instructions executed
} DECODED_INST;

const DECODED_INST EMPTY_INST = 
{
  ALU_OPA_IS_REGA, 
  ALU_OPB_IS_REGB, 
  DEST_IS_REGC, 
  ALU_ADDQ, 
  FU_ALU, 
  1'b0, 
  1'b0, 
  1'b0,
  1'b0,
  1'b0,
  1'b0,
  1'b0,
  1'b0,
  1'b0,
  1'b0
};

// RS_ROWS
typedef struct packed{
  DECODED_INST inst;
  PHYS_REG     T;
  PHYS_REG     T1;
  PHYS_REG     T2;
  logic        busy;
  logic [31:0]  inst_opcode;
  logic [63:0]  npc;
} RS_ROW_T;

const RS_ROW_T EMPTY_ROW = 
{
  EMPTY_INST,
  `DUMMY_REG,
  `DUMMY_REG,
  `DUMMY_REG,
  1'b0,
  `NOOP_INST,
  64'b0
};

`endif
