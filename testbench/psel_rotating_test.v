`include "../../sys_defs.vh"
`define DEBUG

`define DELAY #2

module testbench;
    parameter WIDTH = 16;
    logic clock;
    logic reset;

    //module inputs/outputs
    logic [(WIDTH-1):0] req;
    logic en;
    logic [(WIDTH-1):0] psel_req_out;
    logic [(WIDTH-1):0] psel_gnt_out;
    logic [($clog2(WIDTH)-1):0] count;
    logic [(WIDTH-1):0] gnt;
    logic [(WIDTH-1):0] gnt_correct;

    logic correct;

    `DUT(psel_rotating) #(.WIDTH(WIDTH)) psel_rot(
        .clock(clock),
        .reset(reset),
        .req(req),
        .en(en),
        .psel_req_out(psel_req_out),
        .psel_gnt_out(psel_gnt_out),
        .count(count),
        .gnt(gnt));

    always #1.5 clock = ~clock;

    always_ff @(posedge clock) begin
        set_gnt_correct();
        print_gnt();
        if( !correct ) begin //CORRECT CASE
            exit_on_error( );
        end
    end

    task print_gnt;
        $display("en: %b, req: %b, count: %d, gnt: %b, gnt_correct: %b", en, req, count, gnt, gnt_correct);
        $display("psel_req_out: %b, psel_gnt_out: %b", psel_req_out, psel_gnt_out);
    endtask

    task exit_on_error;
        begin
            #1;
            print_gnt();
            $display("@@@Failed at time %f", $time);
            $finish;
        end
    endtask

    task set_gnt_correct;
        int gnt_count;
        int looped;
        int found;
        found = 0;
        gnt_count = 0;
        looped = 0;
        gnt_correct = {WIDTH{1'b0}};
        for (int i = WIDTH - count - 1; i >= 0; --i) begin
            if (en & req[i] & !found) begin
                gnt_correct[i] = 1'b1;
                found = 1;
            end
        end
        for (int i = WIDTH - 1; i > (WIDTH - count - 1); --i) begin
            if (en & req[i] & !found) begin
                gnt_correct[i] = 1'b1;
                found = 1;
            end
        end
        // for(integer i = WIDTH-count-1; !looped & i != (WIDTH-count-1); i -= 1) begin
        //     if(en & gnt_count == 0 & req[i] == 1'b1) begin 
        //         gnt_correct[i] = 1'b1;
        //         gnt_count = 1;
        //     end
        //     if(i == 0) begin
        //         i = WIDTH;
        //         looped = 1;
        //     end
        // end
        correct = (gnt == gnt_correct);
    endtask

    initial begin
        $display("Starting test...");

        //set starting values
        clock = 1'b0;
        reset = 1'b1;
        en = 1'b0;
        req = {WIDTH{1'b0}};

        @(negedge clock);
        reset = 1'b0;

        //check gnt doesn't change when en = 0
        @(negedge clock);
        req[WIDTH-1] = 1'b1;

        //enable
        @(negedge clock);
        req = 16'b1000100101001111;
        en = 1'b1;

        //check all 1's
        @(negedge clock);
        req = {WIDTH{1'b1}};

        //check all 0's
        @(negedge clock);
        req = {WIDTH{1'b0}};

        //check 1, some 0's, then 1's
        @(negedge clock);
        //different test depending on WIDTH
        //if WIDTH is too small, no need to test.
        if(WIDTH > 6) begin
            req = {1'b1, {(WIDTH-6){1'b0}}, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1};
        end else if(WIDTH > 2) begin
            req = {1'b1, {(WIDTH-2){1'b0}}, 1'b1};
        end

        //check 0's, then 1's, then 0's
        @(negedge clock);
        //Again, change depending on width
        if(WIDTH > 10) begin
            req = {{(WIDTH-10){1'b0}}, 1'b1, 1'b0, 1'b1, {7{1'b0}}};
        end else if(WIDTH > 4) begin
            req = {{(WIDTH-4){1'b0}}, 1'b1, 1'b0, 1'b1, 1'b0};
        end

        //check 0's, then NUM_REQ 1's
        //@(negedge clock);
        //req = {{(WIDTH-NUM_REQS){1'b0}}, {NUM_REQS{1'b1}}};

        //check alternating 0's, 1's
        @(negedge clock);
        for(integer i = WIDTH; i >= 0; i = i - 1) begin
            if(i % 2) begin
                req[i] = 1'b0;
            end else begin
                req[i] = 1'b1;
            end
        end

        @(negedge clock);
        $display("@@@PASSED");
        $finish;
    end

endmodule

