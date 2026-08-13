`timescale 1ns/1ps
module regfile (
    input         clk, RegWrite,
    input  [4:0]  rs1, rs2, rd,
    input  [31:0] wd,
    output [31:0] rd1, rd2
);
    reg [31:0] regs [0:31];
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) regs[i] = 32'h0;
    end
    always @(posedge clk)
        if (RegWrite && rd != 5'b0) regs[rd] <= wd;

    assign rd1 = (rs1 == 5'b0)          ? 32'b0 :
                 (RegWrite && rd == rs1) ? wd    : regs[rs1];
    assign rd2 = (rs2 == 5'b0)          ? 32'b0 :
                 (RegWrite && rd == rs2) ? wd    : regs[rs2];
endmodule