`include "sys_defs.vh"
`define DEBUG

`define DELAY #2

module testbench;
	parameter LENGTH=16;
	parameter WIDTH=2;
	parameter NUM_TAG=3;
	parameter TAG_SIZE=6;
	logic clock;
	
	//module inputs/outputs
	logic [NUM_TAG-1:0] en;
	logic [NUM_TAG-1:0][TAG_SIZE-1:0] tag;
	logic [LENGTH-1:0][WIDTH-1:0][TAG_SIZE-1:0] tags_in;
	//outputs
	logic [LENGTH-1:0][WIDTH-1:0] hits, hits_correct;

	logic correct;

	`DUT(CAM) #(.LENGTH(LENGTH),
				.WIDTH(WIDTH),
				.NUM_TAG(NUM_TAG),
				.TAG_SIZE(TAG_SIZE)) CAM(
		.enable(en), 
		.tag(tag), 
		.tags_in(tags_in), 
		.hits(hits));

	always #1 clock = ~clock;

	always_ff @(posedge clock) begin
		set_correct();
		print_out();
		if( !correct ) begin //CORRECT CASE
			exit_on_error( );
		end
	end

	task print_out;
		string tags_str;
		string tag_bit;
		string tag_str;
		string hits_str;
		string hit_bit;

		for(integer i = NUM_TAG - 1; i >= 0; i = i - 1) begin 
			$display("tag: %b, en: %b", tag[i], en[i]);
		end
		$display("##### tags_in #####\t\t##### hits #####");

		//logic [(TAG_SIZE*WIDTH + 2*(WIDTH-1) + WIDTH + 3):0] row_str;
		for(integer i = LENGTH - 1; i >= 0; i = i - 1) begin
			tags_str = "";
			hits_str = "";
			for(integer j = WIDTH - 1; j >= 0; j = j - 1) begin
				tag_str = "";
				hit_bit = "";
				for(integer k = TAG_SIZE - 1; k >= 0; k = k - 1) begin
					tag_bit.bintoa(tags_in[i][j][k]);
					tag_str = {tag_str, tag_bit};				
				end
				hit_bit.bintoa(hits[i][j]);
				if(j == (WIDTH - 1)) begin
					tags_str = {tags_str, tag_str};
					hits_str = {hits_str, hit_bit};
				end else begin
					tags_str = {tags_str, " ", tag_str};
					hits_str = {hits_str, " ", hit_bit};
				end
			end
			$display({tags_str, "\t\t\t", hits_str});
		end
	endtask

	task exit_on_error;
		begin
			#1;
			print_out();
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	task set_correct;
		hits_correct = {(LENGTH*WIDTH){1'b0}};
		for(integer k = NUM_TAG - 1; k >= 0; k = k - 1) begin
			if(en[k]) begin
				for(integer i = LENGTH - 1; i >= 0; i = i - 1) begin
					for(integer j = WIDTH - 1; j >= 0; j = j - 1) begin
						hits_correct[i][j] |= (tag[k] == tags_in[i][j]); 
					end
				end
			end
		end
		correct = (hits_correct == hits);
	endtask

	initial begin
		$display("Starting test...");
		//set starting values
		clock = 1'b0;
		en = {NUM_TAG{1'b0}};
		tag = {TAG_SIZE*NUM_TAG{1'b1}};
		tags_in = {WIDTH*LENGTH*TAG_SIZE{1'b0}};
		
		//set all tags in a row to tag[0]
		@(negedge clock);
		for(integer i = WIDTH - 1; i >= 0; i = i - 1) begin
			tags_in[0][i] = tag[0];
		end

		//enable
		@(negedge clock);
		en[0] = 1'b1;
		
		//set all tags in a column to tag
		@(negedge clock);
		tag[0] = {1'b1, {(TAG_SIZE-2){1'b0}}, 1'b1};
		tags_in = {WIDTH*LENGTH*TAG_SIZE{1'b0}};
		for(integer i = LENGTH - 1; i >= 0; i = i - 1) begin
			tags_in[i][0] = tag[0];
		end

		//set 2 random tags to each tag 
		@(negedge clock);
		tag[0] = {1'b0, {(TAG_SIZE-2){1'b1}}, 1'b0};
		tag[1] = {{3{1'b1}}, {(TAG_SIZE-3){1'b0}}};
		tag[2] = {TAG_SIZE{1'b1}};
		//set all tags to random tags
		for(integer i = LENGTH - 1; i >= 0; i = i - 1) begin
			for(integer j = WIDTH - 1; j >= 0; j = j - 1) begin
				tags_in[i][j] = $urandom_range(0,(2 ** TAG_SIZE) - 1);
			end
		end
		//set some random tags to the input tag
		for(integer k = NUM_TAG - 1; k > 0; k = k - 1) begin
			for(integer i = 0; i < 2; i = i + 1) begin
				integer row, column;
				row = $urandom_range(0,LENGTH-1);
				column = $urandom_range(0,WIDTH-1);
				tags_in[row][column] = tag[k];
			end
		end
		en = {NUM_TAG{1'b1}};

		//set all tags randomly a few times
		for(integer num = 0; num < 50; num = num + 1) begin
			@(negedge clock);
			for(integer k = NUM_TAG - 1; k > 0; k = k - 1) begin
				tag[k] = $urandom_range(0,(2 ** TAG_SIZE) - 1);
			end
			for(integer i = LENGTH - 1; i >= 0; i = i - 1) begin
				for(integer j = WIDTH - 1; j >= 0; j = j - 1) begin
					tags_in[i][j] = $urandom_range(0,(2 ** TAG_SIZE) - 1);
				end
			end
		end

		@(negedge clock);
		$display("@@@PASSED");
		$finish;
	end

endmodule

