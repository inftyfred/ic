// @nc app=nowcoder id=00b0d01b71234d0b97dd4ab64f522ed9 topic=301 question=5000589 lang=Verilog
// 2026-09-20 21:57:26
// https://www.nowcoder.com/practice/00b0d01b71234d0b97dd4ab64f522ed9?tpId=301&tqId=5000589
// [VL20] 数据选择器实现逻辑电路

// @nc code=start

`timescale 1ns/1ns

module data_sel(
   input             S0     ,
   input             S1     ,
   input             D0     ,
   input             D1     ,
   input             D2     ,
   input             D3     ,
   
   output wire        Y    
);

assign Y = ~S1 & (~S0&D0 | S0&D1) | S1&(~S0&D2 | S0&D3);
     
endmodule

module sel_exp(
   input             A     ,
   input             B     ,
   input             C     ,
   
   output wire       L            
);

data_sel u1(
   .S0(B)     ,
   .S1(A)     ,
   .D0(1'b0)     ,
   .D1(C)     ,
   .D2(~C)     ,
   .D3(1'b1)     ,
   
   .Y(L)    
);


endmodule

// @nc code=end
