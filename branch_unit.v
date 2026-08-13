`timescale 1ns/1ps
module branch_unit (
    input  [2:0]  funct3,
    input  [31:0] alu_result,
    output reg    branch_cond
);
    always @(*) begin
        case (funct3)
            3'b000: branch_cond = (alu_result == 32'h0);
            3'b001: branch_cond = (alu_result != 32'h0);
            3'b100: branch_cond = (alu_result == 32'h1);
            3'b101: branch_cond = (alu_result == 32'h0);
            3'b110: branch_cond = (alu_result == 32'h1);
            3'b111: branch_cond = (alu_result == 32'h0);
            default: branch_cond = 1'b0;
        endcase
    end
endmodule