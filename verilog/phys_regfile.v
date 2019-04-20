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
  input [`NUM_FU_TOTAL-1:0][1:0][$clog2(`NUM_PHYS_REG)-1:0] rd_idx, 
  input [`NUM_FU_TOTAL-1:0][$clog2(`NUM_PHYS_REG)-1:0] wr_idx,    // read/write index 
  input [`NUM_FU_TOTAL-1:0][63:0] wr_data,            // write data
  input [`NUM_FU_TOTAL-1:0]       wr_en, 
  input wr_clk,

    output logic [`NUM_PHYS_REG-1:0][63:0] phys_registers_out,
  output logic [`NUM_FU_TOTAL-1:0][1:0][63:0] rd_out  // read data
);
  
  logic[`NUM_PHYS_REG-1:0][63:0] phys_registers;   // 64, 64-bit Physical Registers

  `ifdef DEBUG
  	assign phys_registers_out = phys_registers;
  `endif

  genvar ig, jg;
  for(ig = 0; ig < `NUM_FU_TOTAL; ig += 1) begin
    for(jg = 0; jg < 2; jg += 1) begin
      assign rd_out[ig][jg] = (rd_idx[ig][jg] == {$clog2(`NUM_PHYS_REG){1'b1}})? 64'b0 :
               (wr_en[ig] && (wr_idx[ig] == rd_idx[ig][jg]))? wr_data[ig] :
                                                              phys_registers[rd_idx[ig][jg]];
    end
  end

  //
  // Write port
  //
  //
  //

  always_ff @(posedge wr_clk) begin
    for(int i = 0; i < `NUM_FU_TOTAL; i += 1) begin
      if (wr_en[i]) begin
        phys_registers[wr_idx[i]] <= `SD wr_data[i];
      end
    end
  end

endmodule // regfile
