`timescale 1ns/1ps
module alu (
    input  [31:0] a, b,
    input  [3:0]  ALUSel,
    output reg [31:0] result,
    output        zero
);
    wire [4:0] shamt = b[4:0];
    always @(*) begin
        case (ALUSel)
            4'b0000: result = a + b;
            4'b0001: result = a - b;
            4'b0010: result = a & b;
            4'b0011: result = a | b;
            4'b0100: result = a ^ b;
            4'b0101: result = a << shamt;
            4'b0110: result = a >> shamt;
            4'b0111: result = $signed(a) >>> shamt;
            4'b1000: result = ($signed(a) < $signed(b)) ? 32'h1 : 32'h0;
            4'b1001: result = (a < b)                   ? 32'h1 : 32'h0;
            default: result = 32'h0;
        endcase
    end
    assign zero = (result == 32'h0);
endmodule