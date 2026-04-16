`timescale	1ns/1ps
module uart_rx #(
    parameter RECV_NBYTE = 2,
    parameter PARITY     = "EVEN",
    parameter RX_HEAD    = 8'hA5,  // 未在本模块使用
    parameter RX_TAIL    = 8'hA5   // 未使用
) (
    input  logic clk,
    input  logic rst_n,
    input  logic baud_tick_x16,   // 16 倍波特率使能
    input  logic rxd,
    output logic recv_vld,         // 接收完成脉冲
    output logic [RECV_NBYTE*8-1:0] recv_data
);
    typedef enum logic [2:0] {
        IDLE,
        START_DETECT,
        DATA_SAMPLE,
        PARITY_SAMPLE,
        STOP_CHECK
    } state_t;

    state_t state, next_state;

    logic [3:0] sample_cnt;      // 0~15 采样计数
    logic [7:0] shift_reg;
    logic [2:0] bit_cnt;         // 0~7 数据位
    logic [2:0] byte_cnt;        // 接收字节计数
    logic [RECV_NBYTE*8-1:0] recv_buf;
    logic parity_expected;

    // 奇偶校验计算
    function automatic logic calc_parity(logic [7:0] data);
        if (PARITY == "NONE")
            return 1'b0;
        else if (PARITY == "ODD")
            return ~^data;
        else
            return ^data;
    endfunction

    // 状态转移
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (!rxd)   // 检测起始位下降沿
                    next_state = START_DETECT;
            end
            START_DETECT: begin
                if (baud_tick_x16) begin
                    if (sample_cnt == 7)   // 采样到起始位中点后确认
                        next_state = DATA_SAMPLE;
                end
            end
            DATA_SAMPLE: begin
                if (baud_tick_x16 && sample_cnt == 15) begin
                    if (bit_cnt == 7)
                        if (PARITY == "NONE")
                            next_state = STOP_CHECK;
                        else
                            next_state = PARITY_SAMPLE;
                end
            end
            PARITY_SAMPLE: begin
                if (baud_tick_x16 && sample_cnt == 15)
                    next_state = STOP_CHECK;
            end
            STOP_CHECK: begin
                if (baud_tick_x16 && sample_cnt == 15) begin
                    if (byte_cnt == RECV_NBYTE - 1)
                        next_state = IDLE;
                    else
                        next_state = START_DETECT;
                end
            end
            default: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            sample_cnt  <= 0;
            bit_cnt     <= 0;
            byte_cnt    <= 0;
            recv_buf    <= '0;
            recv_vld    <= 1'b0;
            recv_data   <= '0;
        end else begin
            state <= next_state;
            recv_vld <= 1'b0;

            case (state)
                IDLE: begin
                    sample_cnt <= 0;
                    byte_cnt   <= 0;
                    if (!rxd)
                        sample_cnt <= sample_cnt + 1;
                end

                START_DETECT: begin
                    if (baud_tick_x16) begin
                        if (sample_cnt == 7) begin
                            sample_cnt <= 0;
                            bit_cnt    <= 0;
                        end else begin
                            sample_cnt <= sample_cnt + 1;
                        end
                    end
                end

                DATA_SAMPLE: begin
                    if (baud_tick_x16) begin
                        if (sample_cnt == 15) begin
                            // 在每位中点采样
                            shift_reg <= {rxd, shift_reg[7:1]};
                            if (bit_cnt == 7) begin
                                parity_expected <= calc_parity(shift_reg);
                                bit_cnt <= 0;
                            end else begin
                                bit_cnt <= bit_cnt + 1;
                            end
                            sample_cnt <= 0;
                        end else begin
                            sample_cnt <= sample_cnt + 1;
                        end
                    end
                end

                PARITY_SAMPLE: begin
                    if (baud_tick_x16) begin
                        if (sample_cnt == 15) begin
                            // 校验检查可在此加入（此处忽略）
                            sample_cnt <= 0;
                        end else begin
                            sample_cnt <= sample_cnt + 1;
                        end
                    end
                end

                STOP_CHECK: begin
                    if (baud_tick_x16) begin
                        if (sample_cnt == 15) begin
                            recv_buf[byte_cnt*8 +: 8] <= shift_reg;
                            if (byte_cnt == RECV_NBYTE - 1) begin
                                recv_vld   <= 1'b1;
                                recv_data  <= recv_buf;
                                byte_cnt   <= 0;
                            end else begin
                                byte_cnt <= byte_cnt + 1;
                            end
                            sample_cnt <= 0;
                        end else begin
                            sample_cnt <= sample_cnt + 1;
                        end
                    end
                end
            endcase
        end
    end
endmodule
