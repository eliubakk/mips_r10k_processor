/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  regfile.v                                           //
//                                                                     //
//  Description :  This module creates the Regfile used by the ID and  // 
//                 WB Stages of the Pipeline.                          //
//                                                                     //
/////////////////////////////////////////////////////////////////////////



`include "../../sys_defs.vh"
module phys_regfile(
        input   [4:0][5:0] rda_idx, rdb_idx, wr_idx,    // read/write index
        input  [4:0][63:0] wr_data,            // write data
        input   [4:0]      wr_en, 
        input               wr_clk,

        output logic [5:0][63:0] rda_out, rdb_out    // read data
          
      );
  
  logic    [31 + `ROB_SIZE :0] [63:0] phys_registers;   // 64, 64-bit Physical Registers

  wire   [4:0][63:0] rda_reg = phys_registers[rda_idx];
  wire   [4:0][63:0] rdb_reg = phys_registers[rdb_idx];

  //
  // Read port A
  //
  always_comb
   for(integer i=0; i<5; i=i+1) begin
      if (rda_idx[i] == `DUMMY_REG)
        rda_out[i] = 0;
      else if (wr_en[i] && (wr_idx[i] == rda_idx[i]))
        rda_out[i] = wr_data[i];  // internal forwarding
      else
        rda_out[i] = rda_reg[i];
    end

  //
  // Read port B
  //
  always_comb
    for(integer i=0; i<5; i=i+1) begin 
      if (rdb_idx[i] == `DUMMY_REG)
        rdb_out[i] = 0;
      else if (wr_en[i] && (wr_idx[i] == rdb_idx[i]))
        rdb_out[i] = wr_data[i];  // internal forwarding
      else
        rdb_out[i] = rdb_reg[i];
    end

  //
  // Write port
  //
  
  always_ff @(posedge wr_clk) begin
      for(integer i=0; i<5; i=i+1) begin
        if (wr_en[i]) begin
          phys_registers[wr_idx[i]] <= `SD wr_data[i];
        end
      end
    end
  

endmodule // regfile
