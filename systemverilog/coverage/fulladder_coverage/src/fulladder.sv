// dut.sv - 简单全加器
module full_adder(
    input logic a, b, cin,
    output logic sum, cout
);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule
