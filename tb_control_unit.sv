`timescale 1ns/1ps
module tb_ctrl;

    logic [6:0] opcode;
    logic       RegWrite, MemRead, MemWrite;
    logic       ALUSrc, Branch, Jump, IsJALR;
    logic       UsesRS1, UsesRS2;
    logic [1:0] MemToReg, ALUSrc1, ALUOp;

    int pass, fail;

    control_unit uut(
        .opcode(opcode),
        .RegWrite(RegWrite), .MemRead(MemRead),   .MemWrite(MemWrite),
        .MemToReg(MemToReg), .ALUSrc(ALUSrc),     .ALUSrc1(ALUSrc1),
        .Branch(Branch),     .Jump(Jump),          .IsJALR(IsJALR),
        .ALUOp(ALUOp),       .UsesRS1(UsesRS1),   .UsesRS2(UsesRS2)
    );

    task automatic chk(input logic ok, input string name);
        if (ok) begin
            $display("PASS %s", name);
            pass++;
        end else begin
            $display("FAIL %s", name);
            fail++;
        end
    endtask

    initial begin
        pass = 0; fail = 0;

        opcode = 7'b0110011; #10;
        chk(RegWrite==1 && MemRead==0 && MemWrite==0 &&
            ALUOp==2'b10 && UsesRS1==1 && UsesRS2==1, "R-type");

        opcode = 7'b0010011; #10;
        chk(RegWrite==1 && ALUSrc==1 &&
            ALUOp==2'b11 && UsesRS1==1, "I-arith");

        opcode = 7'b0000011; #10;
        chk(RegWrite==1 && MemRead==1 &&
            ALUSrc==1 && MemToReg==2'b01, "Load");

        opcode = 7'b0100011; #10;
        chk(MemWrite==1 && ALUSrc==1 && RegWrite==0, "Store");

        opcode = 7'b1100011; #10;
        chk(Branch==1 && ALUOp==2'b01 && RegWrite==0, "Branch");

        opcode = 7'b1101111; #10;
        chk(Jump==1 && RegWrite==1 &&
            MemToReg==2'b10 && ALUSrc1==2'b01, "JAL");

        opcode = 7'b1100111; #10;
        chk(Jump==1 && IsJALR==1 &&
            RegWrite==1 && MemToReg==2'b10, "JALR");

        opcode = 7'b0110111; #10;
        chk(RegWrite==1 && ALUSrc1==2'b10, "LUI");

        opcode = 7'b0010111; #10;
        chk(RegWrite==1 && ALUSrc1==2'b01, "AUIPC");

        $display("");
        $display("=== Control Unit Results: %0d pass  %0d fail ===", pass, fail);
        $finish;
    end

endmodule