`timescale 1ns/1ps
module uart_tx #(
    parameter SEND_NBYTE = 1,          // 每次发送的字节数
    parameter PARITY     = "EVEN",     // "NONE", "ODD", "EVEN"
    parameter ODD_EVEN   = 0,          // 备用，实际以 PARITY 为准
    parameter TX_HEAD    = 8'h5A,      // 未在本模块使用，由顶层决定
    parameter TX_TAIL    = 8'h00       // 未使用
) (
    input  logic clk,
    input  logic rst_n,
    input  logic baud_tick,            // 位时钟使能
    input  logic send_en,              // 发送使能（脉冲）
    input  logic [SEND_NBYTE*8-1:0] send_data,
    output logic txd,                  // 串行输出
    output logic send_done             // 发送完成脉冲
);
    typedef enum logic [2:0] {
        IDLE,
        START_BIT,
        DATA_BITS,
        PARITY_BIT,
        STOP_BIT
    } state_t;

    state_t state, next_state;

    logic [7:0] tx_shift_reg;
    logic [3:0] bit_cnt;               // 0~7 数据位
    logic [2:0] byte_cnt;              // 当前发送第几个字节
    logic [SEND_NBYTE*8-1:0] send_buf; // 发送缓冲
    logic parity_bit;

    // 计算奇偶校验位（偶校验：偶数个1；奇校验：奇数个1）
    function automatic logic calc_parity(logic [7:0] data);
        if (PARITY == "NONE")
            return 1'b0;
        else if (PARITY == "ODD")
            return ~^data;  // 奇校验：奇数个1输出1
        else                // 默认 EVEN
            return ^data;   // 偶校验：偶数个1输出0
    endfunction

    // 状态机
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (send_en)
                    next_state = START_BIT;
            end
            START_BIT: begin
                if (baud_tick)
                    next_state = DATA_BITS;
            end
            DATA_BITS: begin
                if (baud_tick && bit_cnt == 7)
                    if (PARITY == "NONE")
                        next_state = STOP_BIT;
                    else
                        next_state = PARITY_BIT;
            end
            PARITY_BIT: begin
                if (baud_tick)
                    next_state = STOP_BIT;
            end
            STOP_BIT: begin
                if (baud_tick) begin
                    if (byte_cnt == SEND_NBYTE - 1)
                        next_state = IDLE;
                    else
                        next_state = START_BIT;
                end
            end
            default: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            txd       <= 1'b1;
            bit_cnt   <= 0;
            byte_cnt  <= 0;
            send_buf  <= '0;
            send_done <= 1'b0;
        end else begin
            state <= next_state;
            send_done <= 1'b0;

            case (state)
                IDLE: begin
                    txd <= 1'b1;
                    if (send_en) begin
                        send_buf <= send_data;
                        byte_cnt <= 0;
                    end
                end

                START_BIT: begin
                    if (baud_tick) begin
                        tx_shift_reg <= send_buf[byte_cnt*8 +: 8];
                        txd <= 1'b0;   // 起始位
                        bit_cnt <= 0;
                    end
                end

                DATA_BITS: begin
                    if (baud_tick) begin
                        txd <= tx_shift_reg[0];
                        tx_shift_reg <= {1'b0, tx_shift_reg[7:1]};
                        if (bit_cnt == 7) begin
                            parity_bit <= calc_parity(tx_shift_reg);
                        end else begin
                            bit_cnt <= bit_cnt + 1;
                        end
                    end
                end

                PARITY_BIT: begin
                    if (baud_tick)
                        txd <= parity_bit;
                end

                STOP_BIT: begin
                    if (baud_tick) begin
                        txd <= 1'b1;
                        if (byte_cnt == SEND_NBYTE - 1) begin
                            send_done <= 1'b1;
                        end else begin
                            byte_cnt <= byte_cnt + 1;
                        end
                    end
                end
            endcase
        end
    end
endmodule
