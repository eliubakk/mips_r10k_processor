`include "../../sys_defs.vh"
module icache(
    input   clock,
    input   reset,
    input   [3:0] Imem2proc_response1,
    input   [3:0] Imem2proc_response2,
    input  [63:0] Imem2proc_data1,
    input  [63:0] Imem2proc_data2,
    input   [3:0] Imem2proc_tag1,
    input   [3:0] Imem2proc_tag2,

    input  [63:0] proc2Icache_addr1,
    input  [63:0] proc2Icache_addr2,
    input  [63:0] cachemem_data1,
    input  [63:0] cachemem_data2,
    input   cachemem_valid1,
    input   cachemem_valid2,

    output logic  [1:0] proc2Imem_command1,
    output logic  [1:0] proc2Imem_command2,
    output logic [63:0] proc2Imem_addr1,
    output logic [63:0] proc2Imem_addr2,

    output logic [63:0] Icache_data_out1, // value is memory[proc2Icache_addr]
    output logic [63:0] Icache_data_out2, // value is memory[proc2Icache_addr]
    output logic  Icache_valid_out1,      // when this is high
    output logic  Icache_valid_out2,      // when this is high

    output logic  [(`NUM_SET_BITS - 1):0] current_index1,
    output logic  [(`NUM_SET_BITS - 1):0] current_index2,
    output logic  [(`NUM_TAG_BITS - 1):0] current_tag1,
    output logic  [(`NUM_TAG_BITS - 1):0] current_tag2,
    output logic  [(`NUM_SET_BITS - 1):0] last_index1,
    output logic  [(`NUM_SET_BITS - 1):0] last_index2,
    output logic  [(`NUM_TAG_BITS - 1):0] last_tag1,
    output logic  [(`NUM_TAG_BITS - 1):0] last_tag2,
    output logic  data_write_enable1,
    output logic  data_write_enable2
  
  );

  logic [3:0] current_mem_tag1;
  logic [3:0] current_mem_tag2;

  logic miss_outstanding1;
  logic miss_outstanding2;

  assign {current_tag1, current_index1} = proc2Icache_addr1[31:3];
  assign {current_tag2, current_index2} = proc2Icache_addr2[31:3];

  wire changed_addr1 = (current_index1 != last_index1) || (current_tag1 != last_tag1);
  wire changed_addr2 = (current_index2 != last_index2) || (current_tag2 != last_tag2);

  wire send_request1 = miss_outstanding1 && !changed_addr1;
  wire send_request2 = miss_outstanding2 && !changed_addr2;

  assign Icache_data_out1 = cachemem_data1;
  assign Icache_data_out2 = cachemem_data2;

  assign Icache_valid_out1 = cachemem_valid1; 
  assign Icache_valid_out2 = cachemem_valid2; 

  assign proc2Imem_addr1 = {proc2Icache_addr1[63:3],3'b0};
  assign proc2Imem_addr2 = {proc2Icache_addr2[63:3],3'b0};
  assign proc2Imem_command1 = (miss_outstanding1 && !changed_addr1) ?  BUS_LOAD :
                                                                    BUS_NONE;
  assign proc2Imem_command2 = (miss_outstanding2 && !changed_addr2) ?  BUS_LOAD :
                                                                    BUS_NONE;                                                                  

 // assign data_write_enable =  (current_mem_tag == Imem2proc_tag) &&
                           //   (current_mem_tag != 0);
  assign data_write_enable1 = (Imem2proc_response1 == Imem2proc_tag1) && (Imem2proc_response1 != 0);
  assign data_write_enable2 = (Imem2proc_response2 == Imem2proc_tag2) && (Imem2proc_response2 != 0);

  wire update_mem_tag1 = changed_addr1 || miss_outstanding1 || data_write_enable1;
  wire update_mem_tag2 = changed_addr2 || miss_outstanding2 || data_write_enable2;

  wire unanswered_miss1 = changed_addr1 ? !Icache_valid_out1 :
                                        miss_outstanding1 && (Imem2proc_response1 == 0);
  wire unanswered_miss2 = changed_addr2 ? !Icache_valid_out2 :
                                        miss_outstanding2 && (Imem2proc_response2 == 0);                                      

  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if(reset) begin
      last_index1       <= `SD -1;   // These are -1 to get ball rolling when
      last_index2       <= `SD -1;   // These are -1 to get ball rolling when
      last_tag1         <= `SD -1;   // reset goes low because addr "changes"
      last_tag2         <= `SD -1;   // reset goes low because addr "changes"
      current_mem_tag1  <= `SD 0;
      current_mem_tag2  <= `SD 0;              
      miss_outstanding1 <= `SD 0;
      miss_outstanding2 <= `SD 0;
    end else begin
      last_index1       <= `SD current_index1;
      last_index2       <= `SD current_index2;
      last_tag1         <= `SD current_tag1;
      last_tag2         <= `SD current_tag2;
      miss_outstanding1 <= `SD unanswered_miss1;
      miss_outstanding2 <= `SD unanswered_miss2;
      
      if(update_mem_tag1)
        current_mem_tag1 <= `SD Imem2proc_response1;
      if(update_mem_tag2)
        current_mem_tag2 <= `SD Imem2proc_response2;
    end
  end

endmodule

