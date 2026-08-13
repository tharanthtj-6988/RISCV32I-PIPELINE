`timescale 1ns/1ps
module control_unit (
    input  [6:0] opcode,
    output reg        RegWrite, MemRead, MemWrite,
    output reg [1:0]  MemToReg,
    output reg        ALUSrc,
    output reg [1:0]  ALUSrc1,
    output reg        Branch, Jump, IsJALR,
    output reg [1:0]  ALUOp,
    output reg        UsesRS1, UsesRS2
);
    always @(*) begin
        {RegWrite,MemRead,MemWrite} = 3'b0;
        MemToReg=2'b00; ALUSrc=0; ALUSrc1=2'b00;
        {Branch,Jump,IsJALR}=3'b0; ALUOp=2'b00;
        {UsesRS1,UsesRS2}=2'b00;
        case (opcode)
            7'b0110011: begin RegWrite=1; ALUOp=2'b10; UsesRS1=1; UsesRS2=1; end
            7'b0010011: begin RegWrite=1; ALUSrc=1; ALUOp=2'b11; UsesRS1=1; end
            7'b0000011: begin RegWrite=1; MemRead=1; ALUSrc=1;
                              MemToReg=2'b01; UsesRS1=1; end
            7'b0100011: begin MemWrite=1; ALUSrc=1; UsesRS1=1; UsesRS2=1; end
            7'b1100011: begin Branch=1; ALUOp=2'b01; UsesRS1=1; UsesRS2=1; end
            7'b0110111: begin RegWrite=1; ALUSrc=1; ALUSrc1=2'b10; end
            7'b0010111: begin RegWrite=1; ALUSrc=1; ALUSrc1=2'b01; end
            7'b1101111: begin RegWrite=1; Jump=1; ALUSrc=1;
                              ALUSrc1=2'b01; MemToReg=2'b10; end
            7'b1100111: begin RegWrite=1; Jump=1; IsJALR=1; ALUSrc=1;
                              MemToReg=2'b10; UsesRS1=1; end
        endcase
    end
endmodule