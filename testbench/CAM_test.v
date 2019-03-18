`include "sys_defs.vh"
`define DEBUG

`define DELAY #2

module testbench;
	parameter WIDTH=2;
	parameter LENGTH=16;
	parameter TAG_SIZE=6;
	logic clock;
	
	//module inputs/outputs
	logic en;
	logic [TAG_SIZE-1:0] tag;
	logic [LENGTH-1:0][WIDTH-1:0][TAG_SIZE-1:0] in_tags;
	//outputs
	logic [LENGTH-1:0][WIDTH-1:0] hits, hits_correct;

	logic correct;

	`DUT(CAM) #(.WIDTH(WIDTH), 
				.LENGTH(LENGTH), 
				.TAG_SIZE(TAG_SIZE)) CAM(
		.enable(en), 
		.tag(tag), 
		.in_tags(in_tags), 
		.hits(hits));

	always #0.5 clock = ~clock;

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

		$display("tag: %b", tag);
		$display("##### in_tags #####\t\t##### hits #####");

		//logic [(TAG_SIZE*WIDTH + 2*(WIDTH-1) + WIDTH + 3):0] row_str;
		for(integer i = LENGTH - 1; i >= 0; i = i - 1) begin
			tags_str = "";
			hits_str = "";
			for(integer j = WIDTH - 1; j >= 0; j = j - 1) begin
				tag_str = "";
				hit_bit = "";
				for(integer k = TAG_SIZE - 1; k >= 0; k = k - 1) begin
					tag_bit.bintoa(in_tags[i][j][k]);
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
		if(en) begin
			for(integer i = LENGTH - 1; i >= 0; i = i - 1) begin
				for(integer j = WIDTH - 1; j >= 0; j = j - 1) begin
					hits_correct[i][j] = (tag == in_tags[i][j]); 
				end
			end
		end
		correct = (hits_correct == hits);
	endtask

	initial begin
		$display("Starting test...");
		//set starting values
		clock = 1'b0;
		en = 1'b0;
		tag = {TAG_SIZE{1'b1}};
		in_tags = {WIDTH*LENGTH*TAG_SIZE{1'b0}};
		
		//set all tags in a row to tag
		@(negedge clock);
		for(integer i = WIDTH - 1; i >= 0; i = i - 1) begin
			in_tags[0][i] = tag;
		end
		en = 1'b1;
		
		//set all tags in a column to tag
		@(negedge clock);
		tag = {1'b1, {(TAG_SIZE-2){1'b0}}, 1'b1};
		in_tags = {WIDTH*LENGTH*TAG_SIZE{1'b0}};
		for(integer i = LENGTH - 1; i >= 0; i = i - 1) begin
			in_tags[i][0] = tag;
		end

		//set random tags to tag
		@(negedge clock);
		tag = {1'b0, {(TAG_SIZE-2){1'b1}}, 1'b0};
		//set all tags to random tags
		for(integer i = LENGTH - 1; i >= 0; i = i - 1) begin
			for(integer j = WIDTH - 1; j >= 0; j = j - 1) begin
				in_tags[i][j] = $urandom_range(0,(2 ** TAG_SIZE) - 1);
			end
		end
		//set some random tags to the input tag
		for(integer i = 0; i < 8; i = i + 1) begin
			integer row, column;
			row = $urandom_range(0,LENGTH-1);
			column = $urandom_range(0,WIDTH-1);
			$display("row: %d, column: %d", row, column);
			in_tags[row][column] = tag;
		end

		//set all tags randomly a few times
		for(integer num = 0; num < 50; num = num + 1) begin
			@(negedge clock);
			tag = $urandom_range(0,(2 ** TAG_SIZE) - 1);
			for(integer i = LENGTH - 1; i >= 0; i = i - 1) begin
				for(integer j = WIDTH - 1; j >= 0; j = j - 1) begin
					in_tags[i][j] = $urandom_range(0,(2 ** TAG_SIZE) - 1);
				end
			end
		end

		@(negedge clock);
		$display("@@@PASSED");
		$finish;
	end

endmodule

