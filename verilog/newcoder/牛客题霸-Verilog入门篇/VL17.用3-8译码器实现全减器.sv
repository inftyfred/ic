// @nc app=nowcoder id=4a8f2e5058554cea9c1cb2ac8bdea0a7 topic=301 question=5000588 lang=Verilog
// 2026-09-17 21:49:08
// https://www.nowcoder.com/practice/4a8f2e5058554cea9c1cb2ac8bdea0a7?tpId=301&tqId=5000588
// [VL17] 用3-8译码器实现全减器

// @nc code=start

`timescale 1ns/1ns

module decoder_38(
   input             E      ,
   input             A0     ,
   input             A1     ,
   input             A2     ,
   
   output reg       Y0n    ,  
   output reg       Y1n    , 
   output reg       Y2n    , 
   output reg       Y3n    , 
   output reg       Y4n    , 
   output reg       Y5n    , 
   output reg       Y6n    , 
   output reg       Y7n    
);

always @(*)begin
   if(!E)begin
      Y0n = 1'b1;
      Y1n = 1'b1;
      Y2n = 1'b1;
      Y3n = 1'b1;
      Y4n = 1'b1;
      Y5n = 1'b1;
      Y6n = 1'b1;
      Y7n = 1'b1;
   end  
   else begin
      case({A2,A1,A0})
         3'b000 : begin
                     Y0n = 1'b0; Y1n = 1'b1; Y2n = 1'b1; Y3n = 1'b1; 
                     Y4n = 1'b1; Y5n = 1'b1; Y6n = 1'b1; Y7n = 1'b1;
                  end 
         3'b001 : begin
                     Y0n = 1'b1; Y1n = 1'b0; Y2n = 1'b1; Y3n = 1'b1; 
                     Y4n = 1'b1; Y5n = 1'b1; Y6n = 1'b1; Y7n = 1'b1;
                  end 
         3'b010 : begin
                     Y0n = 1'b1; Y1n = 1'b1; Y2n = 1'b0; Y3n = 1'b1; 
                     Y4n = 1'b1; Y5n = 1'b1; Y6n = 1'b1; Y7n = 1'b1;
                  end 
         3'b011 : begin
                     Y0n = 1'b1; Y1n = 1'b1; Y2n = 1'b1; Y3n = 1'b0; 
                     Y4n = 1'b1; Y5n = 1'b1; Y6n = 1'b1; Y7n = 1'b1;
                  end 
         3'b100 : begin
                     Y0n = 1'b1; Y1n = 1'b1; Y2n = 1'b1; Y3n = 1'b1; 
                     Y4n = 1'b0; Y5n = 1'b1; Y6n = 1'b1; Y7n = 1'b1;
                  end 
         3'b101 : begin
                     Y0n = 1'b1; Y1n = 1'b1; Y2n = 1'b1; Y3n = 1'b1; 
                     Y4n = 1'b1; Y5n = 1'b0; Y6n = 1'b1; Y7n = 1'b1;
                  end 
         3'b110 : begin
                     Y0n = 1'b1; Y1n = 1'b1; Y2n = 1'b1; Y3n = 1'b1; 
                     Y4n = 1'b1; Y5n = 1'b1; Y6n = 1'b0; Y7n = 1'b1;
                  end 
         3'b111 : begin
                     Y0n = 1'b1; Y1n = 1'b1; Y2n = 1'b1; Y3n = 1'b1; 
                     Y4n = 1'b1; Y5n = 1'b1; Y6n = 1'b1; Y7n = 1'b0;
                  end 
         default: begin
                     Y0n = 1'b1; Y1n = 1'b1; Y2n = 1'b1; Y3n = 1'b1; 
                     Y4n = 1'b1; Y5n = 1'b1; Y6n = 1'b1; Y7n = 1'b1;
                  end
      endcase  
   end 
end    
     
endmodule

module decoder1(
   input             A     ,
   input             B     ,
   input             Ci    ,
   
   output wire       D     ,
   output wire       Co         
);

wire [7:0] Y;

assign D  = ~(Y[1] & Y[2] & Y[4] & Y[7]);
assign Co = ~(Y[1] & Y[2] & Y[3] & Y[7]);

decoder_38 u1(
     .E (1'b1)  	 , 
     .A0(Ci)		     ,
     .A1(B)          , 
     .A2(A)         ,
     
     .Y0n(Y[0])    ,  
     .Y1n(Y[1])    , 
     .Y2n(Y[2])    , 
     .Y3n(Y[3])    , 
     .Y4n(Y[4])    , 
     .Y5n(Y[5])    , 
     .Y6n(Y[6])    , 
     .Y7n(Y[7])    
  );


endmodule


