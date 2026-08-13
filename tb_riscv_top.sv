`timescale 1ns/1ps
module tb_riscv_top;

    logic clk, rst;
    int   pass, fail;

    riscv_top uut(.clk(clk), .rst(rst));

    // clock generation
    initial clk = 0;
    always #5 clk = ~clk; // changes every 5ns 

    // task to check a register value 
    task automatic chk_reg(
        input int        reg_num,
        input logic [31:0] got,
        input logic [31:0] exp
    );
        if (got === exp) begin
            $display("PASS x%0d = %0d", reg_num, got);
            pass++;
        end else begin
            $display("FAIL x%0d : got %0d  exp %0d", reg_num, got, exp);
            fail++;
        end
    endtask

    initial begin
        pass = 0; fail = 0;

        $dumpfile("riscv_top_sv.vcd");
        $dumpvars(0, tb_riscv_top);

        // load test program
        // this program covers every hazard type and also forwarding parts and stall
        uut.u_imem.mem[0]  = 32'h00500093; // addi x1, x0, 5
        uut.u_imem.mem[1]  = 32'h00A00113; // addi x2, x0, 10
        uut.u_imem.mem[2]  = 32'h002081B3; // add  x3, x1, x2   EX/MEM forward
        uut.u_imem.mem[3]  = 32'h40118233; // sub  x4, x3, x1   MEM/WB forward
        uut.u_imem.mem[4]  = 32'h00400293; // addi x5, x0, 4
        uut.u_imem.mem[5]  = 32'h0012A023; // sw   x1, 0(x5)
        uut.u_imem.mem[6]  = 32'h0002A303; // lw   x6, 0(x5)
        uut.u_imem.mem[7]  = 32'h00130393; // addi x7, x6, 1    load-use stall
        uut.u_imem.mem[8]  = 32'h00108463; // beq  x1, x1, +8   branch taken
        uut.u_imem.mem[9]  = 32'h06300413; // addi x8, x0, 99   flushed
        uut.u_imem.mem[10] = 32'h02A00493; // addi x9, x0, 42
        uut.u_imem.mem[11] = 32'h00000013;
        uut.u_imem.mem[12] = 32'h00000013;
        uut.u_imem.mem[13] = 32'h00000013;
        uut.u_imem.mem[14] = 32'h00000013;
        uut.u_imem.mem[15] = 32'h00000013;

        rst = 1; #22; rst = 0;

        repeat(50) @(posedge clk);

        $display("");
        $display("RiscV32I Pipeline Register's Check:");
        chk_reg(1, uut.u_rf.regs[1],  32'd5);
        chk_reg(2, uut.u_rf.regs[2],  32'd10);
        chk_reg(3, uut.u_rf.regs[3],  32'd15);
        chk_reg(4, uut.u_rf.regs[4],  32'd10);
        chk_reg(5, uut.u_rf.regs[5],  32'd4);
        chk_reg(6, uut.u_rf.regs[6],  32'd5);
        chk_reg(7, uut.u_rf.regs[7],  32'd6);
        chk_reg(8, uut.u_rf.regs[8],  32'd0);
        chk_reg(9, uut.u_rf.regs[9],  32'd42);

        $display("");
        $display("Results: %0d pass  %0d fail", pass, fail);

        if (fail == 0)
            $display("ALL Tests Passed");
        else
            $display("All Havenot Passed, SOME TESTS FAILED ");

        $finish;
    end

endmodule