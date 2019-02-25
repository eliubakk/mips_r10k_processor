

module testbench;
    logic CAM_en;
	logic [5:0]  CDB_tag;
	logic [5:0] T1 [2:0];
	logic [5:0] T2 [2:0];
	logic 	  [2:0] T1_hit;
	logic 	  [2:0] T2_hit;
    logic clock;
    logic reset;

commit rs(
		.clock(clock),
        .reset(reset),
        .CAM_en(CAM_en), 
		.CDB_tag(CDB_tag),
		.T1(T1),
		.T2(T2),
		.T1_hit(T1_hit),
		.T2_hit(T2_hit)
		
);

always begin
    #5 clock = ~clock;
end

 initial begin

        $monitor("Time:%4.0f clock: %b CAM_en:%b CDB_tag:%b  T1_hit:%b T2_hit:%b", $time, clock, CAM_en, CDB_tag, T1_hit, T2_hit );

        //Intialize

        CAM_en= 0;
        CDB_tag= 0;
        T1[0] = 6'd0;
        T1[1] = 6'd0;
        T1[2] = 6'd0;
        T2[0] = 6'd0;
        T2[1] = 6'd0;
        T2[2] = 6'd0;
        reset= 1;
        clock=0;

        @(negedge clock);

        reset=0 ;
        CAM_en= 1;
        CDB_tag= 6'd15;
        T1[0] = 6'd13;
        T1[1] = 6'd14;
        T1[2] = 6'd9;
        T2[0] = 6'd13;
        T2[1] = 6'd14;
        T2[2] = 6'd16;

        @(negedge clock);
        reset=0 ;
        CAM_en= 1;
        CDB_tag= 6'd13;
        T1[0] = 6'd13;
        T1[1] = 6'd14;
        T1[2] = 6'd15;
        T2[0] = 6'd13;
        T2[1] = 6'd14;
        T2[2] = 6'd15;

     @(negedge clock);
        reset=0 ;
        CAM_en= 1;
        CDB_tag= 6'd14;
        T1[0] = 6'd13;
        T1[1] = 6'd14;
        T1[2] = 6'd15;
        T2[0] = 6'd13;
        T2[1] = 6'd14;
        T2[2] = 6'd15;

     @(negedge clock);   

     $finish;
     end
endmodule