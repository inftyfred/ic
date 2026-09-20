// @nc app=nowcoder id=89659f98cb124362b1c816f06d5235d0 topic=301 question=5000586 lang=Verilog
// 2026-09-19 00:18:08
// https://www.nowcoder.com/practice/89659f98cb124362b1c816f06d5235d0?tpId=301&tqId=5000586
// [VL18] 实现3-8译码器①

// @nc code=start

`timescale 1ns/1ns

module decoder_38(
   input             E1_n   ,
   input             E2_n   ,
   input             E3     ,
   input             A0     ,
   input             A1     ,
   input             A2     ,
   
   output wire       Y0_n   ,  
   output wire       Y1_n   , 
   output wire       Y2_n   , 
   output wire       Y3_n   , 
   output wire       Y4_n   , 
   output wire       Y5_n   , 
   output wire       Y6_n   , 
   output wire       Y7_n   
);

reg [7:0] Y_n;

assign Y0_n = Y_n[0];
assign Y1_n = Y_n[1];
assign Y2_n = Y_n[2];
assign Y3_n = Y_n[3];
assign Y4_n = Y_n[4];
assign Y5_n = Y_n[5];
assign Y6_n = Y_n[6];
assign Y7_n = Y_n[7];

always @(*) begin
	casez({E3, E2_n, E1_n, A2, A1, A0})
		6'b??_1???,6'b0?_????,6'b?1_????:Y_n = 8'b1111_1111;
		6'b10_0000:Y_n = 8'b1111_1110;
		6'b10_0001:Y_n = 8'b1111_1101;
		6'b10_0010:Y_n = 8'b1111_1011;
		6'b10_0011:Y_n = 8'b1111_0111;
		6'b10_0100:Y_n = 8'b1110_1111;
		6'b10_0101:Y_n = 8'b1101_1111;
		6'b10_0110:Y_n = 8'b1011_1111;
		6'b10_0111:Y_n = 8'b0111_1111;
		default:   Y_n = 8'b1111_1111;
	endcase

end

endmodule

// @nc code=end
