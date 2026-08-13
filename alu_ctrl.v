`timescale 1ns/1ps
module alu_ctrl (
    input  [1:0] ALUOp,
    input  [2:0] funct3,
    input  [6:0] funct7,
    output reg [3:0] ALUSel
);
    always @(*) begin
        case (ALUOp)
            2'b00: ALUSel = 4'b0000;
            2'b01: case (funct3)
                3'b000,3'b001: ALUSel = 4'b0001;
                3'b100,3'b101: ALUSel = 4'b1000;
                3'b110,3'b111: ALUSel = 4'b1001;
                default:       ALUSel = 4'b0001;
            endcase
            2'b10: case (funct3)
                3'b000: ALUSel = funct7[5] ? 4'b0001 : 4'b0000;
                3'b001: ALUSel = 4'b0101;
                3'b010: ALUSel = 4'b1000;
                3'b011: ALUSel = 4'b1001;
                3'b100: ALUSel = 4'b0100;
                3'b101: ALUSel = funct7[5] ? 4'b0111 : 4'b0110;
                3'b110: ALUSel = 4'b0011;
                3'b111: ALUSel = 4'b0010;
                default:ALUSel = 4'b0000;
            endcase
            2'b11: case (funct3)
                3'b000: ALUSel = 4'b0000;
                3'b001: ALUSel = 4'b0101;
                3'b010: ALUSel = 4'b1000;
                3'b011: ALUSel = 4'b1001;
                3'b100: ALUSel = 4'b0100;
                3'b101: ALUSel = funct7[5] ? 4'b0111 : 4'b0110;
                3'b110: ALUSel = 4'b0011;
                3'b111: ALUSel = 4'b0010;
                default:ALUSel = 4'b0000;
            endcase
            default: ALUSel = 4'b0000;
        endcase
    end
endmodule