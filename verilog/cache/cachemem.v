// cachemem32x64

`timescale 1ns/100ps

module cache(
        input clock, reset, wr1_en,//comes from data_write_enable of Icache
        input  [4:0] wr1_idx, rd1_idx,//comes from current_index Icache
        input  [7:0] wr1_tag, rd1_tag,//
        input [63:0] wr1_data,//comes from Icache_data_out of Icache 

        output [63:0] rd1_data,//goes to cachemem_data of Icache
        output rd1_valid//goes to cachemem_valid of Icache
        
      );



  logic [31:0] [63:0] data ;
  logic [31:0]  [7:0] tags; 
  logic [31:0]        valids;

  assign rd1_data = data[rd1_idx];
  assign rd1_valid = valids[rd1_idx] && (tags[rd1_idx] == rd1_tag);

  always_ff @(posedge clock) begin
    if(reset)
      valids <= `SD 31'b0;
    else if(wr1_en) 
      valids[wr1_idx] <= `SD 1;
  end
  
  always_ff @(posedge clock) begin
    if(wr1_en) begin
      data[wr1_idx] <= `SD wr1_data;
      tags[wr1_idx] <= `SD wr1_tag;
    end
  end

endmodule
