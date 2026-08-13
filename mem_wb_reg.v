`timescale 1ns/1ps
module mem_wb_reg (
    input clk, rst,
    input [31:0] mem_alu_result, mem_rdata, mem_pc_plus4,
    input [4:0]  mem_rd,
    input        mem_RegWrite,
    input [1:0]  mem_MemToReg,
    output reg [31:0] wb_alu_result, wb_rdata, wb_pc_plus4,
    output reg [4:0]  wb_rd,
    output reg        wb_RegWrite,
    output reg [1:0]  wb_MemToReg
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wb_alu_result<=0; wb_rdata<=0; wb_pc_plus4<=0;
            wb_rd<=0; wb_RegWrite<=0; wb_MemToReg<=0;
        end else begin
            wb_alu_result<=mem_alu_result; wb_rdata<=mem_rdata;
            wb_pc_plus4<=mem_pc_plus4; wb_rd<=mem_rd;
            wb_RegWrite<=mem_RegWrite; wb_MemToReg<=mem_MemToReg;
        end
    end
endmodule