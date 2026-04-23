`timescale 1ns/1ps

module uart_rx #(
    parameter RECV_NBYTE = 2,
    parameter PARITY     = "EVEN"
) (
    input  logic clk,
    input  logic rst_n,
    input  logic baud_tick_x16,
    input  logic rxd,
    output logic recv_vld,
    output logic [RECV_NBYTE*8-1:0] recv_data,
    output logic parity_err           // 新增：校验错误标志
);
    typedef enum logic [2:0] {
        IDLE,
        START_DETECT,
        DATA_SAMPLE,
        PARITY_SAMPLE,
        STOP_CHECK
    } state_t;

    state_t state, next_state;
    logic [3:0] sample_cnt;
    logic [7:0] shift_reg;
    logic [2:0] bit_cnt;
    logic [$clog2(RECV_NBYTE)-1:0] byte_cnt;
    logic [RECV_NBYTE*8-1:0] recv_buf;
    logic parity_expected;
	logic rxd_fall;
	logic rxd_d0;

    function automatic logic calc_parity(logic [7:0] data);
        if (PARITY == "NONE")
            return 1'b0;
        else if (PARITY == "ODD")
            return ~^data;
        else
            return ^data;
    endfunction

	

	always_ff @(posedge clk or negedge rst_n) begin
		if(!rst_n) 
			rxd_d0 <= 1'b1;
		else begin
			rxd_d0 <= rxd;
		end
	end

	assign rxd_fall = !rxd && rxd_d0;

    // 状态机组合逻辑
    always_comb begin
        next_state = state;
        case (state)
            IDLE: 
                if (rxd_fall) next_state = START_DETECT;
            
            START_DETECT: 
                if (baud_tick_x16 && sample_cnt == 7 && !rxd)
                    next_state = DATA_SAMPLE;
                else if (baud_tick_x16 && sample_cnt == 7 && rxd)
                    next_state = IDLE;  // 毛刺，返回空闲
            
            DATA_SAMPLE: 
                if (baud_tick_x16 && sample_cnt == 15 && bit_cnt == 7)
                    next_state = (PARITY == "NONE") ? STOP_CHECK : PARITY_SAMPLE;
            
            PARITY_SAMPLE: 
                if (baud_tick_x16 && sample_cnt == 15)
                    next_state = STOP_CHECK;
            
            STOP_CHECK: 
                if (baud_tick_x16 && sample_cnt == 15)
                    next_state = IDLE;//(byte_cnt == RECV_NBYTE - 1) ? IDLE : START_DETECT;
            
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
            parity_err  <= 1'b0;
        end else begin
            state <= next_state;
            recv_vld <= 1'b0;

            case (state)
                IDLE: begin
                    if (rxd_fall) begin
                        sample_cnt <= 0;//sample_cnt + 1;
                        if(byte_cnt > RECV_NBYTE - 1) begin
							byte_cnt   <= 0;
							parity_err <= 1'b0;
						end
                    end else begin
                        sample_cnt <= 0;
                    end
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
                            // 修正：先计算校验（用新值），再移位
                            if (bit_cnt == 7) begin
                                parity_expected <= calc_parity({rxd, shift_reg[7:1]});
                                shift_reg <= {rxd, shift_reg[7:1]};
                                bit_cnt <= 0;
                            end else begin
                                shift_reg <= {rxd, shift_reg[7:1]};
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
                            sample_cnt <= 0;
							if(parity_err == 0)
	                            parity_err <= (rxd != parity_expected);
							else
								parity_err <= 1'b1;
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
                                recv_vld  <= 1'b1;
                                recv_data <= recv_buf;
                                byte_cnt  <= 0;
                            end else begin
                                byte_cnt <= byte_cnt + 1;
                            end
                            sample_cnt <= 0;
                        end else begin
                            recv_buf[byte_cnt*8 +: 8] <= shift_reg;
                            sample_cnt <= sample_cnt + 1;
                        end
                    end
                end
            endcase
        end
    end
endmodule
