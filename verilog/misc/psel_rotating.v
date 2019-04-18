`include "../../sys_defs.vh"
`define DEBUG

module psel_rotating(clock, reset, req, en,
                     `ifdef DEBUG
                     psel_req_out, psel_gnt_out,
                     `endif
                     count, gnt);
	parameter WIDTH=16;
    input              clock;
    input              reset;
	input  [(WIDTH-1):0] req;
	input  			   en;
    `ifdef DEBUG
        output logic [(WIDTH-1):0] psel_req_out;
        output logic [(WIDTH-1):0] psel_gnt_out;
    `endif
    output logic [($clog2(WIDTH)-1):0] count;
	output logic [(WIDTH-1):0] gnt;

    logic [(WIDTH-1):0] psel_req;
    logic [(WIDTH-1):0] psel_gnt;

    logic [($clog2(WIDTH)-1):0] high_idx;

    assign high_idx = (WIDTH-count);
	genvar i;
	for(i = 0; i < WIDTH; i += 1) begin
        assign psel_req[i] = (i >= count)? req[i-count] :
                                           req[i+high_idx];
        assign gnt[i] = (i >= high_idx)? psel_gnt[(count-(WIDTH-i))] :
                                         psel_gnt[i+count];
	end


    psel_single #(
        .WIDTH(WIDTH))
    
    psel_single0(
        .req(psel_req),
        .en(en),
        .gnt(psel_gnt));        

    always_ff @(posedge clock) begin
        if(reset) begin
            count <= `SD 0;
            `ifdef DEBUG
                psel_req_out <= `SD 0;
                psel_gnt_out <= `SD 0;
            `endif
        end else begin
            if(en) begin
                count <= `SD (count == (WIDTH-1))? 0 : count+1;
            end
            `ifdef DEBUG
                psel_req_out <= `SD psel_req;
                psel_gnt_out <= `SD psel_gnt;
            `endif
        end
    end

endmodule
