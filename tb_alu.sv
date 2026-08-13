`timescale 1ns/1ps

//ALu testbench
module tb_alu;

    logic [31:0] a, b;
    logic [3:0]  ALUSel;
    logic [31:0] result;
    logic        zero;

    int pass, fail;

    alu uut(.a(a), .b(b), .ALUSel(ALUSel), .result(result), .zero(zero));

    task automatic chk(input [31:0] exp, input string name);
        #1;
        if (result !== exp) begin
            $display("FAIL %s: got 0x%h  exp 0x%h",name, result,exp);
            fail++;
            end else begin
                $display("PASS %s", name);
                pass++;
        end
    endtask

    initial begin
        pass = 0; fail = 0;

        // arithmetic instrs
        a = 5;            b = 3;            ALUSel = 4'b0000; chk(8,  "ADD");
        a = 10;           b = 4;            ALUSel = 4'b0001; chk(6,  "SUB");

        // logical
        a = 32'hFF;       b = 32'h0F;       ALUSel = 4'b0010; chk(32'h0F, "AND");
        a = 32'hF0;       b = 32'h0F;       ALUSel = 4'b0011; chk(32'hFF, "OR");
        a = 32'hFF;       b = 32'hFF;       ALUSel = 4'b0100; chk(0,       "XOR");

        // shift insts
        a = 1;            b = 4;            ALUSel = 4'b0101; chk(16,  "SLL");
        a = 32'h10;       b = 2;            ALUSel = 4'b0110; chk(4,   "SRL");
        a = 32'hFFFFFFFC; b = 1;            ALUSel = 4'b0111; chk(32'hFFFFFFFE, "SRA");

        // compareisiion
        a = 32'hFFFFFFFF; b = 1;            ALUSel = 4'b1000; chk(1, "SLT signed");
        a = 1;            b = 32'hFFFFFFFF; ALUSel = 4'b1001; chk(1, "SLTU unsigned");

        // zero flag
        a = 5; b = 5; ALUSel = 4'b0001; #1;
        if (zero) begin
            $display("PASS zero flag");
            pass++;
            end else begin
                $display("FAIL zero flag");
                fail++;
        end

        $display("");
        $display("ALU TB Results: %0d instructions passed  %0d instructions failed", pass, fail);
        $finish;
    end

endmodule