`timescale 1ns/1ps

module uart_tx #(
    parameter SEND_NBYTE = 1,
    parameter PARITY     = "EVEN"
) (
    input  logic clk,
    input  logic rst_n,
    input  logic baud_tick,
    input  logic send_en,
    input  logic [SEND_NBYTE*8-1:0] send_data,
    output logic txd,
    output logic send_done
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
    logic [3:0] bit_cnt;
    logic [$clog2(SEND_NBYTE)-1:0] byte_cnt;
    logic [SEND_NBYTE*8-1:0] send_buf;
    logic parity_bit;

    function automatic logic calc_parity(logic [7:0] data);
        if (PARITY == "NONE")
            return 1'b0;
        else if (PARITY == "ODD")
            return ~^data;
        else
            return ^data;
    endfunction

    always_comb begin
        next_state = state;
        case (state)
            IDLE: 
                if (send_en) next_state = START_BIT;
            
            START_BIT: 
                if (baud_tick) next_state = DATA_BITS;
            
            DATA_BITS: 
                if (baud_tick && bit_cnt == 7)
                    next_state = (PARITY == "NONE") ? STOP_BIT : PARITY_BIT;
            
            PARITY_BIT: 
                if (baud_tick) next_state = STOP_BIT;
            
            STOP_BIT: 
                if (baud_tick)
                    next_state = (byte_cnt == SEND_NBYTE - 1) ? IDLE : START_BIT;
            
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
                    txd <= 1'b0;  // 修正：立即发送起始位
                    tx_shift_reg <= send_buf[byte_cnt*8 +: 8];
                    parity_bit <= calc_parity(send_buf[byte_cnt*8 +: 8]);
                    if (baud_tick) begin
                        tx_shift_reg <= send_buf[byte_cnt*8 +: 8];
                        bit_cnt <= 0;
                    end
                end

                DATA_BITS: begin
                    txd <= tx_shift_reg[0];
                    if (baud_tick) begin
                        txd <= tx_shift_reg[0];
                        //if (bit_cnt == 7) begin
                            //parity_bit <= calc_parity({1'b0, tx_shift_reg[7:1]});
                        //end else begin
                        bit_cnt <= bit_cnt + 1;
                        //end
                        tx_shift_reg <= {1'b0, tx_shift_reg[7:1]};
                    end
                end

                PARITY_BIT: begin
                    txd <= parity_bit;
                    if (baud_tick)
                        txd <= parity_bit;
                end

                STOP_BIT: begin
                    txd <= 1'b1;
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
