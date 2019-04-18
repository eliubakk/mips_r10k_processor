 `include "../../sys_defs.vh"

 `define DEBUG
    parameter NUM_WAYS = 4;
    parameter NUM_SETS = (32/NUM_WAYS);
    parameter RD_PORTS = 1;
    `define NUM_SET_BITS $clog2(NUM_SETS)
    `define NUM_TAG_BITS (13-`NUM_SET_BITS)

    typedef struct packed {
    logic [63:0] data;
    logic [(`NUM_TAG_BITS-1):0] tag;
    logic valid;
    //logic dirty;
    } CACHE_LINE_T;

    typedef struct packed {
    CACHE_LINE_T [(NUM_WAYS-1):0] cache_lines;
    } CACHE_SET_T;

module vic_cache(clock, reset, valid, valid_cam, new_victim,
                set_index_cam, set_index, tag_cam,
                vic_table_out, set_index_table_out, fired_victim,
                out_victim, fired_valid, out_valid);

    input clock;
    input reset;
    input [1:0] valid;//cacheline input
    input [1:0] valid_cam;//for camming
    input CACHE_LINE_T  [1:0] new_victim;// i don't do anything with new_victim.valid
    input [1:0] [(`NUM_SET_BITS - 1):0] set_index_cam;
    input [1:0] [(`NUM_SET_BITS - 1):0] set_index;
    input [1:0] [(`NUM_TAG_BITS - 1):0] tag_cam;

    output CACHE_LINE_T [3:0]	 vic_table_out;
    output logic [3:0][`NUM_SET_BITS:0] set_index_table_out;//index + 1bit for busy
    output CACHE_LINE_T  [1:0] fired_victim;
    output CACHE_LINE_T  [1:0] out_victim;
    output logic [1:0]              fired_valid;
    output logic [1:0]             out_valid;

    CACHE_LINE_T [3:0]	         vic_table_next;
    logic [3:0][`NUM_SET_BITS:0] set_index_table_next;
    logic [1:0][3:0]                  vic_table_hits;                   
    logic [1:0][3:0]                  set_index_table_hits;
    logic [1:0][1:0]                  index_table;
    logic [3:0][`NUM_SET_BITS-1:0] set_index_table_temp;
    logic [3:0][`NUM_TAG_BITS-1:0] vic_table_out_temp;
    CACHE_LINE_T  [1:0] fired_victim_next;
    logic [1:0]             fired_valid_next;
    logic [1:0]             out_valid_next;
    logic [1:0]        num_valids;
    CACHE_LINE_T [1:0] out_victim_next;

    assign fired_victim_next [0] = vic_table_out[2];
    assign fired_victim_next [1] = vic_table_out[3];
    genvar ig;
	for (ig = 0; ig < 2; ig+=1) begin
        assign out_victim_next[ig] = vic_table_out[index_table[ig]];
    end
    assign num_valids = valid[0] + valid[1];

    always_comb begin
        fired_valid_next = 1'b0;
        out_valid_next = 1'b0;
        set_index_table_next = set_index_table_out;
        vic_table_next = vic_table_out;

        for (int i = 0; i<4; i+=1) begin
            set_index_table_temp[i]=set_index_table_out[i][`NUM_SET_BITS-1:0];
            vic_table_out_temp[i] = vic_table_out[i].tag;
        end
        
        for (int j = 0; j < 2; j+=1) begin
            if (valid_cam[j] & (vic_table_hits[j] == set_index_table_hits[j]) & (|vic_table_hits[j])) begin
                out_valid_next[j] = 1'b1;
                for (int i = 3; i>=0; i-=1) begin
                    if (i <= index_table[j]) begin
                        set_index_table_next[i]=0;
                        vic_table_next[i]=0;
                        if (i>0) begin
                            set_index_table_next[i] = set_index_table_next[i-1];
                            vic_table_next[i] = vic_table_next[i-1];
                        end
                    end
                end
            end
        end
        
        if (&valid) begin
            if((set_index_table_next[0][`NUM_SET_BITS]) & (set_index_table_out[2][`NUM_SET_BITS] & set_index_table_out[3][`NUM_SET_BITS])) begin
                fired_valid_next[0] = 1'b1;
                set_index_table_next[2][`NUM_SET_BITS] = 1'b0;
        end if ((~set_index_table_next[0][`NUM_SET_BITS] & set_index_table_next[1][`NUM_SET_BITS]) & (set_index_table_out[3][`NUM_SET_BITS])) begin
                fired_valid_next[1] = 1'b1;
                set_index_table_next[3][`NUM_SET_BITS] = 1'b0;
            end
        end

        if ((|valid) & (set_index_table_next[0][`NUM_SET_BITS] & set_index_table_out[3][`NUM_SET_BITS])) begin
            fired_valid_next[1] = 1'b1;
            set_index_table_next[3][`NUM_SET_BITS] = 1'b0;
        end

        case(num_valids)
            2'b10:begin
                if(set_index_table_next[0][`NUM_SET_BITS]) begin
                    for (int i=1; i>=0; i-=1) begin
                        set_index_table_next[i+2] = set_index_table_next[i];
                        vic_table_next[i+2] = vic_table_next[i];
                    end
                end else if(set_index_table_next[1][`NUM_SET_BITS] & ~set_index_table_next[0][`NUM_SET_BITS]) begin
                    for (int i=2; i>=0; i-=1) begin
                        set_index_table_next[i+1] = set_index_table_next[i];
                        vic_table_next[i+1] = vic_table_next[i];
                    end
                end
                vic_table_next[1:0] = 0;
                set_index_table_next[1:0] = 0;
                for (int i = 0; i < 2; i+=1) begin
                    vic_table_next[i] = new_victim[-i+1];
                    set_index_table_next[i] = {1'b1,set_index[-i+1]};
                end
            end

            2'b01:begin
                if(set_index_table_next[0][`NUM_SET_BITS]) begin
                    for (int i=2; i>=0; i-=1) begin
                        set_index_table_next[i+1] = set_index_table_next[i];
                        vic_table_next[i+1] = vic_table_next[i];
                    end
                end
                vic_table_next[0] = 0;
                set_index_table_next[0] = 0;
                for (int i = 0; i < 2; i+=1) begin
                    if(valid[i]) begin
                        vic_table_next[0] = new_victim[i];
                        set_index_table_next[0] = {1'b1,set_index[i]};
                    end
                end 
            end
            
        endcase
    end

    for (ig = 0; ig < 2; ig+=1) begin
        CAM #(
            .LENGTH(4),
            .WIDTH(1),
            .NUM_TAGS(1),
            .TAG_SIZE(`NUM_TAG_BITS))

        cam0(
            .enable(1'b1),
            .tags(tag_cam[ig]),
            .table_in(vic_table_out_temp),
            .hits(vic_table_hits[ig]));

        CAM #(
            .LENGTH(4),
            .WIDTH(1),
            .NUM_TAGS(1),
            .TAG_SIZE(`NUM_SET_BITS))
            
        cam1(
            .enable(1'b1),
            .tags(set_index_cam[ig]),
            .table_in(set_index_table_temp),
            .hits(set_index_table_hits[ig]));

        encoder #(.WIDTH(4)) enc0(
            .in(vic_table_hits[ig]),
            .out(index_table[ig]));
    end
        
    always_ff @(posedge clock) begin
        if (reset) begin
            set_index_table_out <= `SD 0;
            vic_table_out <= `SD 0;
            fired_valid <= `SD 0;
            fired_victim <= `SD 0;
            out_valid <= `SD 0;
            out_victim <= `SD 0;
        end else begin
            vic_table_out <= `SD vic_table_next;
            set_index_table_out <= `SD set_index_table_next;
            for (int i =0; i<2; i+=1) begin
                fired_valid[i] <= `SD fired_valid_next[i];
                out_valid[i]   <= `SD out_valid_next[i];
                out_victim[i]  <= `SD out_victim_next[i];
                fired_victim[i] <= `SD fired_victim_next[i];
            end
        end
    end
endmodule
