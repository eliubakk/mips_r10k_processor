
module commit(
		input clock, reset,
		input 		CAM_en, 
		input [5:0]  CDB_tag,
		input [5:0] T1 [2:0],
		input [5:0] T2 [2:0],
		output logic [2:0] T1_hit,
		output logic  [2:0] T2_hit
		
	);
		logic [2:0] T1_hit_next;
		logic [2:0] T2_hit_next;
	
	always_comb begin
		integer i;
		T1_hit = {3{0}};
		T2_hit = {3{0}};	
		if(CAM_en) begin
			for(i=0;i<3;i=i+1) begin
				T1_hit[i] = (T1[i] == CDB_tag) | T1_hit_next[i];
				T2_hit[i] = (T2[i] == CDB_tag)  | T2_hit_next[i];
			end
		end
		else begin
			T1_hit[i] = T1_hit_next[i];
			T2_hit[i] = T2_hit_next[i];
		end


	end		
	
			

always_ff @(posedge clock) begin
	if(reset) begin
		T1_hit_next<= T1_hit;
		T2_hit_next<= T2_hit;
	end
	else  begin
		T1_hit_next<= T1_hit;
		T2_hit_next<= T2_hit;
	end
end


endmodule