// cachemem32x64
`include "../../sys_defs.vh"
`include "../../cache_defs.vh"
`define DEBUG

//`include "../../cache_defs.vh"
`define NUM_WAYS 4
`define NUM_SETS (32/`NUM_WAYS)
`define NUM_SET_BITS $clog2(`NUM_SETS)
`define NUM_TAG_BITS (13-`NUM_SET_BITS)



/*typedef struct packed {
  logic [63:0] data;
  logic [(`NUM_TAG_BITS-1):0] tag;
  logic valid;
  logic dirty;
} CACHE_LINE_T;

typedef struct packed {
  CACHE_LINE_T [(`NUM_WAYS-1):0] cache_lines;
} CACHE_SET_T;
*/

module cachemem(clock, reset, 
                rd_en, rd_idx, rd_tag,
                wr_en, wr_idx, wr_tag, wr_data, wr_dirty,
                `ifdef DEBUG
                  sets_out, bst_out,
                `endif
                rd_data, rd_valid,
                rd_miss_idx, rd_miss_tag, rd_miss_valid,
                wr_miss_idx, wr_miss_tag, wr_miss_valid,
                vic_idx, victim, victim_valid);
  parameter NUM_WAYS = 4;
  parameter RD_PORTS = 3;
  parameter WR_PORTS = 3;

//`define NUM_WAYS NUM_WAYS
//`include "../../cache_defs.vh"

    input clock, reset;
  
  //read inputs
  input [(RD_PORTS-1):0] rd_en;
  input [(RD_PORTS-1):0][(`NUM_SET_BITS-1):0] rd_idx;
  input [(RD_PORTS-1):0][(`NUM_TAG_BITS-1):0] rd_tag;

  //write inputs
  input [(WR_PORTS-1):0] wr_en;
  input [(WR_PORTS-1):0][(`NUM_SET_BITS-1):0] wr_idx;
  input [(WR_PORTS-1):0][(`NUM_TAG_BITS-1):0] wr_tag;
  input [(WR_PORTS-1):0][63:0] wr_data;
  input [(WR_PORTS-1):0] wr_dirty;

	`ifdef DEBUG
		output CACHE_SET_T [(`NUM_SETS-1):0] sets_out;
		output logic [(`NUM_SETS-1):0][(NUM_WAYS-2):0] bst_out;
	`endif

  //read outputs
  output logic [(RD_PORTS-1):0][63:0] rd_data;
  output logic [(RD_PORTS-1):0] rd_valid;
	output logic [(RD_PORTS-1):0][(`NUM_SET_BITS-1):0] rd_miss_idx; 
	output logic [(RD_PORTS-1):0][(`NUM_TAG_BITS-1):0] rd_miss_tag;
  output logic [(RD_PORTS-1):0] rd_miss_valid;

  //write outputs
	output logic [(WR_PORTS-1):0][(`NUM_SET_BITS-1):0] wr_miss_idx;
	output logic [(WR_PORTS-1):0][(`NUM_TAG_BITS-1):0] wr_miss_tag;
  output logic [(WR_PORTS-1):0] wr_miss_valid;

  // victim cache outputs
  output logic [(WR_PORTS-1):0][(`NUM_SET_BITS-1):0] vic_idx;
  output CACHE_LINE_T [(WR_PORTS-1):0] victim;
  output logic [(WR_PORTS-1):0] victim_valid;

	// given addr, find set index
	// cam through the tags in that set for match
	// output data at index of match

	//internal data
	CACHE_SET_T [(`NUM_SETS-1):0] sets, sets_next;
  logic [(`NUM_SETS-1):0][(NUM_WAYS-2):0] bst, bst_next;

  //LRU search/update variables
	logic [($clog2(NUM_WAYS-1)-1):0] next_bst_idx;
	logic [($clog2(NUM_WAYS)-1):0] acc; 
  logic [$clog2(NUM_WAYS)-1:0] temp_idx;

  //rd search variables
	logic [(RD_PORTS-1):0][(NUM_WAYS-1):0][0:0][(`NUM_TAG_BITS-1):0] rd_cam_table_in;
	logic [(RD_PORTS-1):0][(NUM_WAYS-1):0][0:0] rd_cam_hits_out;
	logic [(RD_PORTS-1):0][(NUM_WAYS-1):0] rd_tag_hits;
  logic [(RD_PORTS-1):0][$clog2(NUM_WAYS)-1:0] rd_tag_idx;
  logic [(RD_PORTS-1):0] wr_forward_to_rd;

  //wr search variables
  logic [(WR_PORTS-1):0][(NUM_WAYS-1):0][0:0][(`NUM_TAG_BITS-1):0] wr_cam_table_in;
	logic [(WR_PORTS-1):0][(NUM_WAYS-1):0][0:0] wr_cam_hits_out;
	logic [(WR_PORTS-1):0][(NUM_WAYS-1):0] wr_tag_hits;
  logic [(WR_PORTS-1):0][$clog2(NUM_WAYS)-1:0] wr_tag_idx;
  logic [$clog2(NUM_WAYS)-1:0] wr_new_tag_idx;

  // assign statements
  `ifdef DEBUG
    assign sets_out = sets;
    assign bst_out = bst;
  `endif

	genvar ig, jg;

  //rd search logic
  for(ig = 0; ig < RD_PORTS; ig += 1) begin
    for(jg = 0; jg < NUM_WAYS; jg += 1) begin
      assign rd_cam_table_in[ig][jg][0] = sets[rd_idx[ig]].cache_lines[jg].tag;
      assign rd_tag_hits[ig][jg] = rd_cam_hits_out[ig][jg][0] & sets[rd_idx[ig]].cache_lines[jg].valid;
    end

  	CAM #(
  		.LENGTH(NUM_WAYS),
  		.WIDTH(1),
  		.NUM_TAGS(1),
  		.TAG_SIZE(`NUM_TAG_BITS))
  	rd_cam(
  		.enable(rd_en[ig]),
  		.tags(rd_tag[ig]),
  		.table_in(rd_cam_table_in[ig]),
  		.hits(rd_cam_hits_out[ig]));

  	encoder #(.WIDTH(NUM_WAYS))
  	rd_enc(
  		.in(rd_tag_hits[ig]),
  		.out(rd_tag_idx[ig]));
  end
	
  //wr search logic
  for(ig = 0; ig < WR_PORTS; ig += 1) begin
    for(jg = 0; jg < NUM_WAYS; jg += 1) begin
      assign wr_cam_table_in[ig][jg][0] = sets[wr_idx[ig]].cache_lines[jg].tag;
      assign wr_tag_hits[ig][jg] = wr_cam_hits_out[ig][jg][0] & sets[wr_idx[ig]].cache_lines[jg].valid;
    end

  	CAM #(
  		.LENGTH(NUM_WAYS),
  		.WIDTH(1),
  		.NUM_TAGS(1),
  		.TAG_SIZE(`NUM_TAG_BITS))
  	wr_cam(
  		.enable(wr_en[ig]),
  		.tags(wr_tag[ig]),
  		.table_in(wr_cam_table_in[ig]),
  		.hits(wr_cam_hits_out[ig]));

  	encoder #(.WIDTH(NUM_WAYS)) 
  	wr_enc(
  		.in(wr_tag_hits[ig]),
  		.out(wr_tag_idx[ig]));
  end

  //output and update logic
	always_comb begin
		sets_next = sets;
		bst_next = bst;
    next_bst_idx = 0;
    acc = 0;
    temp_idx = 0;

    for(int i = 0; i < RD_PORTS; ++i) begin
      rd_data[i] = 64'b0;
      rd_valid[i] = 1'b0;
      rd_miss_idx[i] = {`NUM_SET_BITS{1'b0}}; 
      rd_miss_tag[i] = {`NUM_TAG_BITS{1'b0}};
      rd_miss_valid[i] = 1'b0;
    end
    for(int i = 0; i < WR_PORTS; ++i) begin
      wr_miss_idx[i] = {`NUM_SET_BITS{1'b0}};
      wr_miss_tag[i] = {`NUM_TAG_BITS{1'b0}};
      wr_miss_valid[i] = 1'b0;

      // victim cache outputs
      vic_idx[i] = {`NUM_SET_BITS{1'b0}};
      victim[i] = EMPTY_CACHE_LINE;
      victim_valid[i] = 1'b0;
    end

    //rd output logic
    for(int i = 0; i < RD_PORTS; i += 1) begin
      rd_data[i] = 0;
      rd_valid[i] = 0;
      wr_forward_to_rd[i] = 0;
      for(int j = 0; j < WR_PORTS; j += 1) begin
        //wr to rd forwarding
        if(rd_en[i] & wr_en[j] & ((wr_idx[j] == rd_idx[i]) & (wr_tag[j] == rd_tag[i]))) begin
          rd_data[i] = wr_data[j];
          rd_valid[i] = 1'b1;
          wr_forward_to_rd[i] |= 1'b1;
        end
      end
      //if not forwarded, rd block
      if(~wr_forward_to_rd[i]) begin
        rd_data[i] = sets[rd_idx[i]].cache_lines[rd_tag_idx[i]].data;
        rd_valid[i] = (|rd_tag_hits[i])? sets[rd_idx[i]].cache_lines[rd_tag_idx[i]].valid : 1'b0;
      end

      //rd miss if not found
      rd_miss_idx[i] = rd_idx[i];
      rd_miss_tag[i] = rd_tag[i];
      rd_miss_valid[i] = (rd_en[i] & ~rd_valid[i]);
    end

    //wr logic
    for(int i = 0; i < WR_PORTS; i += 1) begin
      wr_miss_idx[i] = wr_idx[i];
      wr_miss_tag[i] = wr_tag[i];
      wr_miss_valid[i] = 1'b0;
      wr_new_tag_idx = 0;
      vic_idx[i] = wr_idx[i];
      victim[i].data = 0;
      victim[i].tag = 0;
      victim[i].valid = 0;
      victim[i].dirty = 0;
      victim_valid[i] = 1'b0;

  		if (wr_en[i]) begin
  			if (|wr_tag_hits[i]) begin
          //wr hit, update LRU
          wr_miss_valid[i] = 1'b0;
          wr_new_tag_idx = wr_tag_idx[i];
  				next_bst_idx = 0;
  				acc = NUM_WAYS / 2;
  				temp_idx = NUM_WAYS / 2;

  				for (int j = 0; j < $clog2(NUM_WAYS); j += 1) begin
  					if (wr_new_tag_idx >= temp_idx) begin
              bst_next[wr_idx[i]][next_bst_idx] = 1'b0;
  						next_bst_idx = (2 * next_bst_idx) + 2;
  						temp_idx += (acc / 2);
  					end else begin
              bst_next[wr_idx[i]][next_bst_idx] = 1'b1;
  						next_bst_idx = (2 * next_bst_idx) + 1;
  						temp_idx -= (acc / 2);
  					end
  					acc /= 2;
  				end
  			end else begin
          //wr miss, find LRU index
  				wr_miss_valid[i] = 1'b1;
  				wr_new_tag_idx = 0;
  				next_bst_idx = 0;
  				acc = NUM_WAYS / 2;

  				for (int j = 0; j < $clog2(NUM_WAYS); j += 1) begin
  					bst_next[wr_idx[i]][next_bst_idx] = ~bst_next[wr_idx[i]][next_bst_idx];
  					if (~bst_next[wr_idx[i]][next_bst_idx]) begin
  						wr_new_tag_idx += acc;
  						next_bst_idx = (2 * next_bst_idx) + 2;
  					end else begin
  						next_bst_idx = (2 * next_bst_idx) + 1;
  					end
  					acc /= 2;
  				end

          //if LRU index was filled, send to victim cache
          victim[i] = sets_next[wr_idx[i]].cache_lines[wr_new_tag_idx];
          victim_valid[i] = sets_next[wr_idx[i]].cache_lines[wr_new_tag_idx].valid;
  			end

        //wr block
        sets_next[wr_idx[i]].cache_lines[wr_new_tag_idx].data = wr_data[i];
        sets_next[wr_idx[i]].cache_lines[wr_new_tag_idx].tag = wr_tag[i];	
  			sets_next[wr_idx[i]].cache_lines[wr_new_tag_idx].valid = 1'b1;
        sets_next[wr_idx[i]].cache_lines[wr_new_tag_idx].dirty = wr_dirty[i];
  		end
    end

    //update LRU for rd
    for(int i = 0; i < RD_PORTS; i += 1) begin
  		if (rd_en[i]) begin
  			if (|rd_tag_hits[i]) begin
  				next_bst_idx = 0;
  				acc = NUM_WAYS / 2;
  				temp_idx = NUM_WAYS / 2;

  				for (int j = 0; j < $clog2(NUM_WAYS); j += 1) begin
  					if (rd_tag_idx[i] >= temp_idx) begin
  						bst_next[rd_idx[i]][next_bst_idx] = 1'b0;
  						next_bst_idx = (2 * next_bst_idx) + 2;
  						temp_idx += (acc / 2);
  					end else begin
  						bst_next[rd_idx[i]][next_bst_idx] = 1'b1;
  						next_bst_idx = (2 * next_bst_idx) + 1;
  						temp_idx -= (acc / 2);
  					end
  					acc /= 2;
  				end
  			end
  		end
    end
	end

  //sequential logic
  // synopsys sync_set_reset "reset"
	always_ff @(posedge clock) begin
		if (reset) begin
			for (int i = 0; i < `NUM_SETS; i += 1) begin
				for (int j = 0; j < NUM_WAYS; j += 1) begin
					sets[i].cache_lines[j].data <= `SD 64'h0;
					sets[i].cache_lines[j].tag <= `SD 0;
					sets[i].cache_lines[j].valid <= `SD 0;
					sets[i].cache_lines[j].dirty <= `SD 0;
				end
				bst[i] <= `SD 0;
			end
		end else begin
			sets <= `SD sets_next;
			bst <= `SD bst_next;
		end
	end

endmodule
