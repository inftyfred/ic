// @nc app=nowcoder id=ce067d6beee2413c8a26d37ca1a9431f topic=311 question=5000692 lang=Verilog
// 2026-08-24 22:58:06
// https://www.nowcoder.com/practice/ce067d6beee2413c8a26d37ca1a9431f?tpId=311&tqId=5000692
// [VL75] 求最小公倍数

// @nc code=start

`timescale 1ns/1ns

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

parameter IDLE  = 3'b001;
parameter S     = 3'b010;
parameter DONE  = 3'b100;

reg [2:0] cur_state, next_state;

reg [DATA_W-1:0] A_reg, B_reg;
reg [2*DATA_W:0] AB_reg;
reg [DATA_W-1:0] mcd_reg;

// When both inputs are zero, GCD is defined as 0 (not 1).
// Internally we keep mcd_reg=1 to avoid division-by-zero in lcm_out,
// but mask the output wire correctly.
assign mcd_out = (A == '0 && B == '0) ? '0 : mcd_reg;
assign lcm_out = AB_reg / mcd_reg;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cur_state <= IDLE;
    end else begin
        cur_state <= next_state;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        A_reg   <= 0;
        B_reg   <= 0;
        AB_reg  <= 0;
        mcd_reg <= 1;
        vld_out <= 0;
    end else begin
        case(cur_state)
            // ── IDLE: load inputs and detect zero-edge cases ────────
            IDLE:begin
                if(vld_in) begin
                    if(A == '0 && B == '0) begin
                        // Both zero: lcm=0, gcd=0
                        mcd_reg <= 1;           // divider = 1 → lcm_out=0/1=0
                        AB_reg  <= '0;
                        vld_out <= 1;           // pulse high this cycle
                    end else if(A == '0 || B == '0) begin
                        // One zero: lcm=0, gcd=nonzero
                        mcd_reg <= (A == '0) ? B : A;   // divider = nonzero → lcm=0
                        AB_reg  <= '0;                 // AB = 0
                        vld_out <= 1;               // pulse high this cycle
                    end else begin
                        // Normal case: load inputs
                        A_reg <= A;
                        B_reg <= B;
                        AB_reg <= A * B;
                        mcd_reg <= 1;
                        vld_out <= 0;
                    end
                end else begin
                    A_reg <= A_reg;
                    B_reg <= B_reg;
                    vld_out <= 0;
                end
            end
            // ── S: Stein's binary GCD ──────────────────────────────
            S:begin
                // Early termination: when either operand becomes zero,
                // the OTHER operand (scaled by mcd_reg) is the GCD.
                if(A_reg == '0 || B_reg == '0) begin
                    // Use whichever is nonzero; if both are zero, use 1
                    // so lcm_out = 0 / 1 = 0 (correct).
                    if(A_reg != '0)
                        mcd_reg <= A_reg * mcd_reg;
                    else if(B_reg != '0)
                        mcd_reg <= B_reg * mcd_reg;
                    else
                        mcd_reg <= 1;
                    vld_out <= 1;
                end else if(!A_reg[0] && !B_reg[0]) begin
                    // Both even: divide by 2, accumulate factor 2
                    mcd_reg <= 2 * mcd_reg;
                    A_reg <= A_reg >> 1;
                    B_reg <= B_reg >> 1;
                end else if(A_reg[0] && B_reg[0]) begin
                    // Both odd: reduce by (|a-b|)/2
                    if(A_reg > B_reg) begin
                        A_reg <= (A_reg - B_reg) >> 1;
                        B_reg <= B_reg;
                    end else begin
                        A_reg <= (B_reg - A_reg) >> 1;
                        B_reg <= A_reg;
                    end
                end else begin
                    // Exactly one even: divide the even one by 2
                    if(!A_reg[0])
                        A_reg <= A_reg >> 1;
                    else
                        B_reg <= B_reg >> 1;
                end
            end
            // ── DONE: results are already valid (set in S-state above) ─
            DONE:begin
                // mcd_reg and vld_out were set in S-state when we entered DONE.
                // Just stay here until next IDLE transition.
                vld_out <= vld_out;
            end
            default:begin
                A_reg   <= 0;
                B_reg   <= 0;
                AB_reg  <= 0;
                mcd_reg <= 1;
                vld_out <= 0;
            end
        endcase
    end
end

always @(*) begin
    case(cur_state)
        IDLE:begin
            if(vld_in) begin
                // Check for zero-input cases that self-complete in IDLE/DONE
                if(A == '0 || B == '0)
                    next_state = DONE;   // vld_out already asserted above
                else
                    next_state = S;
            end else begin
                next_state = IDLE;
            end
        end
        S:begin
            // Terminate when EITHER operand reaches zero
            if(A_reg == '0 || B_reg == '0)
                next_state = DONE;
            else
                next_state = S;
        end
        DONE:begin
            next_state = IDLE;
        end
        default:begin
            next_state = IDLE;
        end
    endcase
end

endmodule

// @nc code=end
