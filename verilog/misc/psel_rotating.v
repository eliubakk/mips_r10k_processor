`include "../../sys_defs.vh"
`define DEBUG

module psel_rotating(clock, reset, req, en, count, gnt);
	parameter WIDTH=4;
    input              clock;
    input              reset;
	input  [WIDTH-1:0] req;
	input  			   en;
    output logic [$clog2(WIDTH)-1:0] count;
	output logic [WIDTH-1:0] gnt;

    //int count;
	genvar i;
    logic [WIDTH-1:0] psel_gnt;

	for(i = 0; i < WIDTH ; i = i + 1) begin
		assign gnt[i] = (en & req[i]) & ((count == i) | (~req[count] & psel_gnt[i]));
	end


    psel_single #(
        .WIDTH(WIDTH))
    
    psel_single0(
        .req(req),
        .en(en),
        .gnt(psel_gnt));        

    always_ff @(posedge clock)
    begin
        //if(reset | count >= WIDTH-1)
        if(reset)
            count <= `SD 0;
        else
            count <= `SD count+1;
    end

endmodule
