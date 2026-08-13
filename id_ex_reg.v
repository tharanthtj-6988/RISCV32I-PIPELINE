`timescale 1ns/1ps
module id_ex_reg (
    input clk, rst, flush,
    input [31:0] id_pc, id_pc_plus4,
    input [31:0] id_rd1, id_rd2, id_imm,
    input [4:0]  id_rs1, id_rs2, id_rd,
    input [2:0]  id_funct3,
    input [6:0]  id_funct7,
    input        id_RegWrite, id_MemRead, id_MemWrite,
    input [1:0]  id_MemToReg,
    input        id_ALUSrc,
    input [1:0]  id_ALUSrc1,
    input        id_Branch, id_Jump, id_JALR,
    input [1:0]  id_ALUOp,
    output reg [31:0] ex_pc, ex_pc_plus4,
    output reg [31:0] ex_rd1, ex_rd2, ex_imm,
    output reg [4:0]  ex_rs1, ex_rs2, ex_rd,
    output reg [2:0]  ex_funct3,
    output reg [6:0]  ex_funct7,
    output reg        ex_RegWrite, ex_MemRead, ex_MemWrite,
    output reg [1:0]  ex_MemToReg,
    output reg        ex_ALUSrc,
    output reg [1:0]  ex_ALUSrc1,
    output reg        ex_Branch, ex_Jump, ex_JALR,
    output reg [1:0]  ex_ALUOp
);
    always @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            ex_pc<=0; ex_pc_plus4<=0; ex_rd1<=0; ex_rd2<=0; ex_imm<=0;
            ex_rs1<=0; ex_rs2<=0; ex_rd<=0; ex_funct3<=0; ex_funct7<=0;
            ex_RegWrite<=0; ex_MemRead<=0; ex_MemWrite<=0; ex_MemToReg<=0;
            ex_ALUSrc<=0; ex_ALUSrc1<=0; ex_Branch<=0; ex_Jump<=0;
            ex_JALR<=0; ex_ALUOp<=0;
        end else begin
            ex_pc<=id_pc; ex_pc_plus4<=id_pc_plus4;
            ex_rd1<=id_rd1; ex_rd2<=id_rd2; ex_imm<=id_imm;
            ex_rs1<=id_rs1; ex_rs2<=id_rs2; ex_rd<=id_rd;
            ex_funct3<=id_funct3; ex_funct7<=id_funct7;
            ex_RegWrite<=id_RegWrite; ex_MemRead<=id_MemRead;
            ex_MemWrite<=id_MemWrite; ex_MemToReg<=id_MemToReg;
            ex_ALUSrc<=id_ALUSrc; ex_ALUSrc1<=id_ALUSrc1;
            ex_Branch<=id_Branch; ex_Jump<=id_Jump;
            ex_JALR<=id_JALR; ex_ALUOp<=id_ALUOp;
        end
    end
endmodule