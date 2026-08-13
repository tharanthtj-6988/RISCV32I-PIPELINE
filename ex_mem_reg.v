`timescale 1ns/1ps
module ex_mem_reg (
    input clk, rst,
    input [31:0] ex_alu_result, ex_store_data, ex_pc_plus4,
    input [4:0]  ex_rd,
    input        ex_RegWrite, ex_MemRead, ex_MemWrite,
    input [1:0]  ex_MemToReg,
    output reg [31:0] mem_alu_result, mem_store_data, mem_pc_plus4,
    output reg [4:0]  mem_rd,
    output reg        mem_RegWrite, mem_MemRead, mem_MemWrite,
    output reg [1:0]  mem_MemToReg
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mem_alu_result<=0; mem_store_data<=0; mem_pc_plus4<=0;
            mem_rd<=0; mem_RegWrite<=0; mem_MemRead<=0;
            mem_MemWrite<=0; mem_MemToReg<=0;
        end else begin
            mem_alu_result<=ex_alu_result; mem_store_data<=ex_store_data;
            mem_pc_plus4<=ex_pc_plus4; mem_rd<=ex_rd;
            mem_RegWrite<=ex_RegWrite; mem_MemRead<=ex_MemRead;
            mem_MemWrite<=ex_MemWrite; mem_MemToReg<=ex_MemToReg;
        end
    end
endmodule