// [VL74] 全加器 — copied from nowcoder for verification

module add_half(
    input         A  ,
    input         B  ,
    output wire   S  ,
    output wire   C   
);
    assign S = A ^ B;
    assign C = A & B;
endmodule

module add_full(
    input         A  ,
    input         B  ,
    input         Ci , 
    output wire   S  ,
    output wire   Co   
);
    wire S1, C1, S2, C2;

    add_half ah_u1(
        .A(A), .B(B), .S(S1), .C(C1)
    );

    add_half ah_u2(
        .A(S1), .B(Ci), .S(S2), .C(C2)
    );

    assign S  = S2;
    assign Co = C1 | C2;
endmodule
