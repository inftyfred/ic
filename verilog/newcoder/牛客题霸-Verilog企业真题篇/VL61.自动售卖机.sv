// @nc app=nowcoder id=487953e6d3e3434988e0dd6960b6c9f8 topic=311 question=5000684 lang=Verilog
// 2026-10-15 01:45:08
// https://www.nowcoder.com/practice/487953e6d3e3434988e0dd6960b6c9f8?tpId=311&tqId=5000684
// [VL61] 自动售卖机

// @nc code=start
`timescale 1ns/1ns

module sale(
   input                clk   ,
   input                rst_n ,
   input                sel   ,//sel=0,5$dranks,sel=1,10$drinks
   input          [1:0] din   ,//din=1,input 5$,din=2,input 10$

   output reg     [1:0] drinks_out,//drinks_out=1,输出5$饮料,drinks_out=2,输出10$饮料
   output reg           change_out //change_out=1,找零5$
);

//--------------------------------------------------
// 状态编码
//--------------------------------------------------
localparam S_IDLE  = 2'b00;   // 余额 0 元
localparam S_5YUAN = 2'b01;   // 余额 5 元，等待补投

reg [1:0] state, next_state;

//--------------------------------------------------
// 1) 状态寄存器（异步复位）
//--------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        state <= S_IDLE;
    else
        state <= next_state;
end

//--------------------------------------------------
// 2) 次态逻辑（组合）
//--------------------------------------------------
always @(*) begin
    next_state = state;
    case (state)
        S_IDLE : begin
            if (din == 2'd1)                    // 投 5 元
                next_state = sel ? S_5YUAN : S_IDLE;  // A 已够钱
            else if (din == 2'd2)               // 投 10 元，一次到位
                next_state = S_IDLE;
            else                                // din=0（din=3 不会出现）
                next_state = S_IDLE;
        end

        S_5YUAN: begin                          // 已有 5 元
            if (din == 2'd1 || din == 2'd2)     // 再投 5 或 10 都已够 10 元
                next_state = S_IDLE;
            else
                next_state = S_5YUAN;
        end

        default: next_state = S_IDLE;
    endcase
end

//--------------------------------------------------
// 3) 输出逻辑（寄存输出，默认清零 -> 天然单拍脉冲）
//--------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        drinks_out <= 2'd0;
        change_out <= 1'b0;
    end
    else begin
        drinks_out <= 2'd0;        // 每拍先清零，保证有效只保持 1 个时钟周期
        change_out <= 1'b0;

        case (state)
            S_IDLE : begin
                if (din == 2'd1 && sel == 1'b0) begin      // A: 5 元
                    drinks_out <= 2'd1;
                    change_out <= 1'b0;
                end
                else if (din == 2'd2) begin                // 一次投 10 元
                    drinks_out <= sel ? 2'd2 : 2'd1;
                    change_out <= sel ? 1'b0 : 1'b1;       // A 收 10 找 5
                end
                // din=1 且 sel=1：钱不够，不出货
            end

            S_5YUAN: begin
                if (din == 2'd1) begin                     // 5+5 = 10，B
                    drinks_out <= 2'd2;
                    change_out <= 1'b0;
                end
                else if (din == 2'd2) begin                // 5+10 = 15，B 找 5
                    drinks_out <= 2'd2;
                    change_out <= 1'b1;
                end
            end

            default: ;
        endcase
    end
end

endmodule

// @nc code=end
