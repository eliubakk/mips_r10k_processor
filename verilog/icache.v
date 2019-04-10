`include "../../sys_defs.vh"
`define DEBUG

module icache(
    input   clock,
    input   reset,
    input   [3:0] Imem2proc_response1,//what is this
    input   [3:0] Imem2proc_response,
    input  [63:0] Imem2proc_data1,
    input  [63:0] Imem2proc_data,
    input   [3:0] Imem2proc_tag1,
    input   [3:0] Imem2proc_tag,

    input  [63:0] proc2Icache_addr1,
    input  [63:0] proc2Icache_addr,
    input  [63:0] cachemem_data1,
    input  [63:0] cachemem_data,
    input   cachemem_valid1,
    input   cachemem_valid,

    input que_valid1;
    input que_valid;

    output logic  [1:0] proc2Imem_command ,
    output logic [63:0] proc2Imem_addr,
    `ifdef DEBUG
    output logic [3:0] current_mem_tag,
    output logic miss_outstanding, 
    `endif
    output logic [63:0] Icache_data_out, // value is memory[proc2Icache_addr]
    output logic  Icache_valid_out,      // when this is high

    output logic  [(`NUM_SET_BITS - 1):0] current_index,
    output logic  [(`NUM_TAG_BITS - 1):0] current_tag,
    output logic  [(`NUM_SET_BITS - 1):0] last_index,
    output logic  [(`NUM_TAG_BITS - 1):0] last_tag,
    output logic  data_write_enable//write to where
  
  );

  logic [1:0] [128:0] que_table;
  logic [1:0] [128:0] que_table_next;
  logic que_out_valid;
  logic que_out_valid_next;
  logic [128:0] que_out;
  logic [128:0] que_out_next;

  assign que_out_next = que_table[1]
  
  always_comb begin
    que_out_valid_next = 0;
    que_table_next = que_table;

    if (que_table[1][128])
      que_out_valid_next = 1'b1;

    que_table_next[1] =  que_table[0];
    que_table_next[0] = 0;

    case({que_valid, que_valid1, que_table[0][128], que_table[1][128]})
      4'b0100, 4'b0101:
        que_table_next[0] = {1'b1,cachemem_data1,proc2Icache_addr1};
      4'b0110:
        que_table_next[1] = {1'b1,cachemem_data1,proc2Icache_addr1};
      4'b1000, 4'b1001:
        que_table_next[0] = {1'b1,cachemem_data,proc2Icache_addr};
      4'b1010:
        que_table_next[1] = {1'b1,cachemem_data,proc2Icache_addr};
      4'b1100:begin
        que_table_next[0] = {1'b1,cachemem_data,proc2Icache_addr};
        que_table_next[1] = {1'b1,cachemem_data1,proc2Icache_addr1};
        end
      4'b1101:
        que_table_next[0] = {1'b1,cachemem_data,proc2Icache_addr};
      4'b1110:
        que_table_next[1] = {1'b1,cachemem_data,proc2Icache_addr};
    endcase
  end

  assign {current_tag , current_index } = que_out[31:3];

  wire changed_addr  = (current_index  != last_index ) || (current_tag  != last_tag );

  wire send_request  = miss_outstanding  && !changed_addr ;

  assign Icache_data_out  = que_out[127:63] ;

  assign Icache_valid_out  = cachemem_valid ; 

  assign proc2Imem_addr  = {que_out[63:3],3'b0};
  
  assign proc2Imem_command  = (miss_outstanding  && !changed_addr ) ?  BUS_LOAD :
                                                                    BUS_NONE;                                                                  

  assign data_write_enable  = (Imem2proc_response  == Imem2proc_tag ) && (Imem2proc_response  != 0);

  wire update_mem_tag  = changed_addr  || miss_outstanding  || data_write_enable ;

  wire unanswered_miss  = changed_addr  ? !Icache_valid_out  :
                                        miss_outstanding  && (Imem2proc_response  == 0);                                      

  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if(reset) begin
      last_index        <= `SD -1;   // These are -1 to get ball rolling when
      last_tag          <= `SD -1;   // reset goes low because addr "changes"
      current_mem_tag   <= `SD 0;              
      miss_outstanding  <= `SD 0;
      que_table         <= `SD 0;
      que_out_valid     <= `SD 0;
      que_out           <= `SD 0;  
    end else begin
      last_index        <= `SD current_index ;
      last_tag          <= `SD current_tag ;
      miss_outstanding  <= `SD unanswered_miss ;
      que_out_valid     <= `SD que_out_valid_next;
      que_out           <= `SD que_out_next;
      if(update_mem_tag )
        current_mem_tag  <= `SD Imem2proc_response ;
    end
  end

endmodule

