// VL70.序列检测器（Moore型）
// Detects sequence "11011", outputs Y=1 in state S4

module det_moore(
    input         clk  ,
    input         rst_n,
    input         din  ,
    output reg    Y
);

    parameter IDLE = 5'b0_0001;
    parameter S1   = 5'b0_0010;
    parameter S2   = 5'b0_0100;
    parameter S3   = 5'b0_1000;
    parameter S4   = 5'b1_0000;

    reg [4:0] cur_state, next_state;

    // State register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cur_state <= IDLE;
        else
            cur_state <= next_state;
    end

    // Next-state logic
    always @(*) begin
        case (cur_state)
            IDLE: next_state = (din == 1'b1) ? S1 : IDLE;
            S1:   next_state = (din == 1'b1) ? S2 : IDLE;
            S2:   next_state = (din == 1'b1) ? S1 : S3;
            S3:   next_state = (din == 1'b1) ? S4 : IDLE;
            default: next_state = IDLE;
        endcase
    end

    // Output logic (Moore: Y depends on current state only)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            Y <= 1'b0;
        else begin
            case (cur_state)
                IDLE, S1, S2, S3: Y <= 1'b0;
                S4:               Y <= 1'b1;
                default:          Y <= 1'b0;
            endcase
        end
    end

endmodule
