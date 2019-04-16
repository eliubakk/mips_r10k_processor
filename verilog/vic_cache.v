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
    logic dirty;
    } CACHE_LINE_T;

    typedef struct packed {
    CACHE_LINE_T [(NUM_WAYS-1):0] cache_lines;
    } CACHE_SET_T;


module vic_cache(clock, reset, valid1, valid2, valid_cam1, valid_cam2, new_victim1, new_victim2,
                set_index_cam1, set_index_cam2, set_index1, set_index2, tag_cam1, tag_cam2,
                vic_table_out, set_index_table_out, fired_victim1, fired_victim2,
                out_victim1, out_victim2, fired_valid1, fired_valid2, out_valid1, out_valid2);

    input clock;
    input reset;
    input valid1;//cacheline input
    input valid2;//cacheline input
    input valid_cam1;//for camming
    input valid_cam2;//for camming
    input CACHE_LINE_T  new_victim1;// i don't do anything with new_victim.valid
    input CACHE_LINE_T  new_victim2;// i don't do anything with new_victim.valid
    input [(`NUM_SET_BITS - 1):0] set_index_cam1;
    input [(`NUM_SET_BITS - 1):0] set_index_cam2;
    input [(`NUM_SET_BITS - 1):0] set_index1;
    input [(`NUM_SET_BITS - 1):0] set_index2;
    input [(`NUM_TAG_BITS - 1):0] tag_cam1;
    input [(`NUM_TAG_BITS - 1):0] tag_cam2;

    output CACHE_LINE_T [3:0]	 vic_table_out;
    output logic [3:0][`NUM_SET_BITS:0] set_index_table_out;//index + 1bit for busy
    output CACHE_LINE_T  fired_victim1;
    output CACHE_LINE_T  fired_victim2;
    output CACHE_LINE_T  out_victim1;
    output CACHE_LINE_T  out_victim2;
    output logic              fired_valid1;
    output logic              fired_valid2;
    output logic              out_valid1;
    output logic              out_valid2;

    CACHE_LINE_T [3:0]	         vic_table_next;
    logic [3:0][`NUM_SET_BITS:0] set_index_table_next;
    logic [3:0]                  vic_table_hits1; 
    logic [3:0]                  vic_table_hits2;                       
    logic [3:0]                  set_index_table_hits1;
    logic [3:0]                  set_index_table_hits2;
    logic [1:0]                  index_table1;
    logic [1:0]                  index_table2;
    logic [3:0][`NUM_SET_BITS-1:0] set_index_table_temp;
    logic [3:0][`NUM_TAG_BITS-1:0] vic_table_out_temp;
    CACHE_LINE_T  fired_victim1_next;
    CACHE_LINE_T  fired_victim2_next;
    logic              fired_valid1_next;
    logic              fired_valid2_next;
    logic              out_valid1_next;
    logic              out_valid2_next;
    logic [1:0]        num_valids;
    //logic [1:0]        loop_counter;
    //logic [1:0]        valid_array;
    //logic valid_cam_module1;
    //logic valid_cam_module2;
    //CACHE_LINE_T [3:0]	         vic_table_prev;
    //logic [3:0][`NUM_SET_BITS:0] set_index_table_prev;
    CACHE_LINE_T  out_victim1_next;
    CACHE_LINE_T  out_victim2_next;

    assign fired_victim1_next = vic_table_out[2];
    assign fired_victim2_next = vic_table_out[3];
    assign out_victim1_next = vic_table_out[index_table1];
    assign out_victim2_next = vic_table_out[index_table2];
    assign num_valids = valid1 + valid2;
    //assign valid_array = {valid1,valid2};
    //assign new_victim_array = {}
    always_comb begin
        fired_valid1_next = 1'b0;
        fired_valid2_next = 1'b0;
        out_valid1_next = 1'b0;
        out_valid2_next = 1'b0;
        set_index_table_next = set_index_table_out;
        vic_table_next = vic_table_out;

        for (int i = 0; i<4; i+=1) begin
            set_index_table_temp[i]=set_index_table_out[i][`NUM_SET_BITS-1:0];
            vic_table_out_temp[i] = vic_table_out[i].tag;
            //set_index_table_temp[i]=set_index_table_next[i][`NUM_SET_BITS-1:0];
            //vic_table_out_temp[i] = vic_table_next[i].tag;
        end
        
        //valid_cam_module1=1'b1;
        if (valid_cam1 & (vic_table_hits1 == set_index_table_hits1) & (|vic_table_hits1)) begin
            out_valid1_next = 1'b1;
            //for (int i = index_table1; i>=0; i-=1) begin
            for (int i = 3; i>=0; i-=1) begin
                if (i <= index_table1) begin
                    set_index_table_next[i]=0;
                    vic_table_next[i]=0;
                    if (i>0) begin
                        set_index_table_next[i] = set_index_table_next[i-1];
                        vic_table_next[i] = vic_table_next[i-1];
                    end
                end
            end
        end
        //valid_cam_module1=1'b0;
        //valid_cam_module2=1'b1;
        if (valid_cam2 & (vic_table_hits2 == set_index_table_hits2) & (|vic_table_hits2)) begin
            out_valid2_next = 1'b1;
            //for (int i = index_table2; i>=0; i-=1) begin
            for (int i = 3; i>=0; i-=1) begin
                if (i <= index_table2) begin
                    set_index_table_next[i]=0;
                    vic_table_next[i]=0;
                    if (i>0) begin
                        set_index_table_next[i] = set_index_table_next[i-1];
                        vic_table_next[i] = vic_table_next[i-1];
                    end
                end
            end
        end
        //valid_cam_module2=1'b0;
        //if ((valid1 & valid2) & set_index_table_out[2][`NUM_SET_BITS] & ~((out_valid1 & (index_table1==2'b10)) | (out_valid2 & (index_table2==2'b10)))) begin
        if (valid1 & valid2) begin
            if((set_index_table_next[0][`NUM_SET_BITS]) & (set_index_table_out[2][`NUM_SET_BITS] & set_index_table_out[3][`NUM_SET_BITS])) begin
                fired_valid1_next = 1'b1;
                set_index_table_next[2][`NUM_SET_BITS] = 1'b0;
        end if ((~set_index_table_next[0][`NUM_SET_BITS] & set_index_table_next[1][`NUM_SET_BITS]) & (set_index_table_out[3][`NUM_SET_BITS])) begin
                fired_valid2_next = 1'b1;
                set_index_table_next[3][`NUM_SET_BITS] = 1'b0;
            end
        end

        if ((valid1 | valid2) & (set_index_table_next[0][`NUM_SET_BITS] & set_index_table_out[3][`NUM_SET_BITS])) begin
            fired_valid2_next = 1'b1;
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
                vic_table_next[1] = new_victim1;
                set_index_table_next[1] = {1'b1,set_index1};
                vic_table_next[0] = new_victim2;
                set_index_table_next[0] = {1'b1,set_index2};

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
                if(valid1) begin
                    vic_table_next[0] = new_victim1;
                    set_index_table_next[0] = {1'b1,set_index1};
                end else if(valid2) begin
                    vic_table_next[0] = new_victim2;
                    set_index_table_next[0] = {1'b1,set_index2};
                end
            end
            
        endcase
    end

    CAM #(
        .LENGTH(4),
        .WIDTH(1),
        .NUM_TAGS(1),
        .TAG_SIZE(`NUM_TAG_BITS))

    cam0(
        .enable(1'b1),
        .tags(tag_cam1),
        .table_in(vic_table_out_temp),
        .hits(vic_table_hits1));


    CAM #(
        .LENGTH(4),
        .WIDTH(1),
        .NUM_TAGS(1),
        .TAG_SIZE(`NUM_TAG_BITS))

    cam1(
        .enable(1'b1),
        .tags(tag_cam2),
        .table_in(vic_table_out_temp),
        .hits(vic_table_hits2));


    CAM #(
        .LENGTH(4),
        .WIDTH(1),
        .NUM_TAGS(1),
        .TAG_SIZE(`NUM_SET_BITS))
        
    cam2(
        .enable(1'b1),
        .tags(set_index_cam1),
        .table_in(set_index_table_temp),
        .hits(set_index_table_hits1));


    CAM #(
        .LENGTH(4),
        .WIDTH(1),
        .NUM_TAGS(1),
        .TAG_SIZE(`NUM_SET_BITS))
        
    cam3(
        .enable(1'b1),
        .tags(set_index_cam2),
        .table_in(set_index_table_temp),
        .hits(set_index_table_hits2));


    encoder #(.WIDTH(4)) enc0(
        .in(vic_table_hits1),
        .out(index_table1));

    encoder #(.WIDTH(4)) enc1(
        .in(vic_table_hits2),
        .out(index_table2));
        
    always_ff @(posedge clock) begin
        if (reset) begin
            for (int i = 0; i < 4; i += 1) begin
                set_index_table_out[i] <= `SD 0;
                vic_table_out[i].valid <= `SD 0;
                vic_table_out[i].data <= `SD 0;
                vic_table_out[i].tag <= `SD 0;
            end
            fired_valid1 <= `SD 1'b0;
            fired_valid2 <= `SD 1'b0;
            fired_victim1 <= `SD 0;
            fired_victim2 <= `SD 0;
            out_valid1 <= `SD 0;
            out_valid2 <= `SD 0;
            out_victim1 <= `SD 0;
            out_victim2 <= `SD 0;
        end else begin
            vic_table_out <= `SD vic_table_next;
            set_index_table_out <= `SD set_index_table_next;
            //vic_table_prev <= `SD vic_table_out;
            //set_index_table_prev <= `SD set_index_table_out;
            fired_valid1 <= `SD fired_valid1_next;
            fired_valid2 <= `SD fired_valid2_next;
            out_valid1   <= `SD out_valid1_next;
            out_valid2   <= `SD out_valid2_next;
            out_victim1  <= `SD out_victim1_next;
            out_victim2  <= `SD out_victim2_next;
            fired_victim1 <= `SD fired_victim1_next;
            fired_victim2 <= `SD fired_victim2_next;
        end
    end
endmodule
