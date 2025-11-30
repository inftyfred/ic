//1110010

module fsm_test(in, out, state, clk, rst_n);

	input 			in;
	input			clk;
	input 			rst_n;
	output			out;
	output	[2:0]	state;

	reg	[2:0]		cur_state;
	reg	[2:0]		next_state;

	parameter	s0 = 3'd0; 
	parameter	s1 = 3'd1; 
	parameter	s2 = 3'd2; 
	parameter	s3 = 3'd3; 
	parameter	s4 = 3'd4; 
	parameter	s5 = 3'd5; 
	parameter	s6 = 3'd6; 
	parameter	s7 = 3'd7;

	assign state = cur_state;

	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			cur_state <= s0;
		end
		else begin
			cur_state <= next_state;
		end
	end

	always@(*) begin
		case (cur_state)
			s0: begin
				if(in == 0) next_state <= s0;
				else		next_state <= s1;
			end
			s1: begin
				if(in == 0) next_state <= s0;
				else		next_state <= s2;
			end
			s2: begin
				if(in == 0) next_state <= s0;
				else		next_state <= s3;
			end
			s3: begin
				if(in == 0) next_state <= s4;
				else		next_state <= s3;
			end
			s4: begin
				if(in == 0) next_state <= s5;
				else		next_state <= s1;
			end
			s5: begin
				if(in == 0) next_state <= s0;
				else 		next_state <= s6;
			end
			s6: begin
				if(in == 0) next_state <= s7;
				else		next_state <= s2;
			end
			s7: begin
				if(in == 0) next_state <= s0;
				else		next_state <= s1;
			end
		endcase
	end

	assign out = (cur_state == s7) ? 1 : 0;

	`ifdef FSDB
		initial begin
			$fsdbDumpfile("fsm_test.fsdb");
			$fsdbDumpvars();
		end
	`endif

endmodule
