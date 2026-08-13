`timescale 1ns/1ps
module forward_unit (
    input [4:0] ex_rs1, ex_rs2,
    input [4:0] mem_rd,  input mem_RegWrite,
    input [4:0] wb_rd,   input wb_RegWrite,
    output reg [1:0] forwardA, forwardB
);
    always @(*) begin
        if (mem_RegWrite && mem_rd != 5'b0 && mem_rd == ex_rs1)
            forwardA = 2'b10;
        else if (wb_RegWrite && wb_rd != 5'b0 && wb_rd == ex_rs1)
            forwardA = 2'b01;
        else
            forwardA = 2'b00;

        if (mem_RegWrite && mem_rd != 5'b0 && mem_rd == ex_rs2)
            forwardB = 2'b10;
        else if (wb_RegWrite && wb_rd != 5'b0 && wb_rd == ex_rs2)
            forwardB = 2'b01;
        else
            forwardB = 2'b00;
    end
endmodule