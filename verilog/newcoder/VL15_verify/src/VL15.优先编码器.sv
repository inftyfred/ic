// @nc app=nowcoder id=a7068b8f4c824d6a9592f691990b21de topic=301 question=5000584 lang=Verilog
// 2026-09-15 19:46:29
// https://www.nowcoder.com/practice/a7068b8f4c824d6a9592f691990b21de?tpId=301&tqId=5000584
// [VL15] 优先编码器Ⅰ

// @nc code=start

`timescale 1ns/1ns

module encoder_83(
   input      [7:0]       I   ,
   input                  EI  ,
   
   output wire [2:0]      Y   ,
   output wire            GS  ,
   output wire            EO    
);

reg [2:0] Y_reg;
reg GS_reg, EO_reg;

assign Y = Y_reg;
assign GS = GS_reg;
assign EO = EO_reg;

always @(*) begin
	casez({EI, I})
		9'b0_????_????: {Y_reg, GS_reg, EO_reg} = {3'b000,1'b0,1'b0};
		9'b1_0000_0000: {Y_reg, GS_reg, EO_reg} = {3'b000,1'b0,1'b1};
		9'b1_1???_????: {Y_reg, GS_reg, EO_reg} = {3'b111,1'b1,1'b0};
		9'b1_01??_????: {Y_reg, GS_reg, EO_reg} = {3'b110,1'b1,1'b0};
		9'b1_001?_????: {Y_reg, GS_reg, EO_reg} = {3'b101,1'b1,1'b0};
		9'b1_0001_????: {Y_reg, GS_reg, EO_reg} = {3'b100,1'b1,1'b0};
		9'b1_0000_1???: {Y_reg, GS_reg, EO_reg} = {3'b011,1'b1,1'b0};
		9'b1_0000_01??: {Y_reg, GS_reg, EO_reg} = {3'b010,1'b1,1'b0};
		9'b1_0000_001?: {Y_reg, GS_reg, EO_reg} = {3'b001,1'b1,1'b0};
   	9'b1_0000_0001: {Y_reg, GS_reg, EO_reg} = {3'b000,1'b1,1'b0};
		default: {Y_reg, GS_reg, EO_reg} = {3'b000,1'b0,1'b0};
	endcase
end

endmodule

// @nc code=end
