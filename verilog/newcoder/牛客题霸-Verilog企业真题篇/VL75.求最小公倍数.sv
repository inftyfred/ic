// @nc app=nowcoder id=ce067d6beee2413c8a26d37ca1a9431f topic=311 question=5000692 lang=Verilog
// 2026-08-24 22:58:06
// https://www.nowcoder.com/practice/ce067d6beee2413c8a26d37ca1a9431f?tpId=311&tqId=5000692
// [VL75] 求最小公倍数

// @nc code=start

`timescale 1ns/1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/08/22 10:29:19
// Design Name: 
// Module Name: lcm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lcm#(
    parameter DATA_W = 8)
(
input [DATA_W-1:0] A,
input [DATA_W-1:0] B,
input 			vld_in,
input			rst_n,
input 			clk,
output	wire	[DATA_W*2-1:0] 	lcm_out,
output	wire 	[DATA_W-1:0]	mcd_out,
output	reg					vld_out
);

    reg [DATA_W-1:0] a_temp,b_temp;
    reg [DATA_W*2-1:0] lcm_buf;
    reg [DATA_W*2-1:0]mcd_reg;
    reg [1:0]c_state,n_state;
    parameter IDLE = 2'b00,BUSY = 2'b01,VALID =2'b10;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            c_state <=IDLE;
        else
            c_state <=n_state;
        
    end


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            a_temp <=0;
            b_temp <=0;
            vld_out <=0;
            lcm_buf<=0;
            mcd_reg<=0;
            n_state <=IDLE;
        end
        else
            case(c_state)
                IDLE:begin
                    if(vld_in)begin
                        a_temp <=A;
                        b_temp <=B;
                        lcm_buf <=A*B;
                        n_state <=BUSY;
                    end 
                    else begin
                        vld_out <= 0;
                        n_state <=IDLE;
                    end
                    end
                BUSY:begin
                    if(a_temp!=b_temp)begin
                        n_state <=BUSY;
                        if(a_temp>b_temp)
                            a_temp <= a_temp - b_temp;
                        else
                            b_temp <= b_temp - a_temp; 
                    end
                    else
                        begin
                            n_state <=VALID;  
                            vld_out <= 0;
                        end
                end
                VALID:begin
                        mcd_reg <=b_temp;
                        vld_out <=1;
                        n_state <=IDLE;
                end
                default:begin
                        n_state <=IDLE;
                        vld_out <=0;
                end
                        
            endcase
                    
        
    end

    assign mcd_out = mcd_reg;
    assign lcm_out = lcm_buf/mcd_reg;

endmodule


// @nc code=end
