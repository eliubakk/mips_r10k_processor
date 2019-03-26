/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  regfile.v                                           //
//                                                                     //
//  Description :  This module creates the Regfile used by the ID and  // 
//                 WB Stages of the Pipeline.                          //
//                                                                     //
/////////////////////////////////////////////////////////////////////////



`include "../sys_defs.vh"
`timescale 1ns/100ps
module phys_regfile(
        input   [5:0] rda_idx, rdb_idx, wr_idx,    // read/write index
        input  [63:0] wr_data,            // write data
        input         wr_en, wr_clk,

        output logic [5:0][63:0] rda_out, rdb_out    // read data
          
      );
  
  logic    [31 + `ROB_SIZE :0] [63:0] phys_registers;   // 64, 64-bit Physical Registers

  wire   [63:0] rda_reg = phys_registers[rda_idx];
  wire   [63:0] rdb_reg = phys_registers[rdb_idx];

  //
  // Read port A
  //
  always_comb
    if (rda_idx == `DUMMY_REG)
      rda_out = 0;
    else if (wr_en && (wr_idx == rda_idx))
      rda_out = wr_data;  // internal forwarding
    else
      rda_out = rda_reg;

  //
  // Read port B
  //
  always_comb
    if (rdb_idx == `DUMMY_REG)
      rdb_out = 0;
    else if (wr_en && (wr_idx == rdb_idx))
      rdb_out = wr_data;  // internal forwarding
    else
      rdb_out = rdb_reg;

  //
  // Write port
  //
  always_ff @(posedge wr_clk)
    if (wr_en) begin
      phys_registers[wr_idx] <= `SD wr_data;
    end

endmodule // regfile
