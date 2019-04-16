`include "../../sys_defs.vh"
`define DELAY #2
`define CLOCK_PERIOD #10
`define DEBUG

module testbench;

    parameter _WIDTH = 4;

    logic [_WIDTH - 1:0] req;
    logic  en;
    logic [_WIDTH - 1:0] gnt;
    logic [_WIDTH - 1:0] tb_gnt;
    logic correct;
    logic [($clog2(_WIDTH) - 1):0] count;
    // logic [_WIDTH - 1:0] count;
    logic reset;
    logic clock;

    //rps4 rps4_i(.clock(clock),.reset(reset),.req(req),.en(en),.gnt(gnt),.count(count));
    psel_rotating #(
        .WIDTH(4))
    
    psel_rotating0(
        .clock(clock),
        .reset(reset),
        .req(req),
        .en(en),
        .count(count),
        .gnt(gnt));     

    assign correct=(gnt==tb_gnt);

    always @(correct)
    begin
        #2
        if(!correct)
        begin
            $display("@@@ Incorrect at time %4.0f", $time);
            $display("@@@ gnt=%b, en=%b, req=%b",gnt,en,req);
            $display("@@@ expected result=%b", tb_gnt);
            $finish;
        end
    end
    always
        #5 clock=~clock;


    initial 
    begin
        $monitor("Time:%4.0f req:%b en:%b gnt:%b, cnt:%b", $time, req, en, gnt,count);

        // CNT=????, need to reset.
        clock=0;
        reset=1;
        #6
        // CNT=0
        //@(negedge clock);
        reset=0;
        req=4'b0001;
        en=1;
        tb_gnt=4'b0001;
         #10
        // CNT=1
        //@(negedge clock);
        req=4'b0010;
        en=1;
        tb_gnt=4'b0010;
         #10
        // CNT=2
        //@(negedge clock);

        req=4'b0101;
        tb_gnt=4'b0100;
         #10
        // CNT=3
        //@(negedge clock);

        req=4'b0011;
        tb_gnt=4'b0010;
        #10
        // CNT=0
        //@(negedge clock);

        req=4'b1111;
        tb_gnt=4'b0001;
        #10
        // CNT=1
        //@(negedge clock);

        req=4'b1111;
        tb_gnt=4'b0010;
        #10
        // CNT=2
        //@(negedge clock);

        req=4'b1111;
        tb_gnt=4'b0100;
        #10
        // CNT=3
        //@(negedge clock);

        req=4'b1111;
        tb_gnt=4'b1000;
        #10
        // CNT=0
        //@(negedge clock);

        req=4'b1111;
        en=0;
        tb_gnt=4'b0000;
        #10
        // CNT=1
        //@(negedge clock);

        req=4'b1111;
        tb_gnt=4'b0000;
        #10
        $finish;
     end // initial
endmodule
