`timescale 1ns/1ps
module tb_random;

    reg clk, rst;
    integer i;
    integer pass, fail;

    // reference register file - software model of what the pipeline should do
    reg [31:0] ref_regs [0:31];

    riscv_top uut(.clk(clk), .rst(rst));

    initial clk = 0;
    always #5 clk = ~clk;

    // instruction builders - easier than writing hex by hand
    function [31:0] mk_addi;
        input [4:0] rd, rs1;
        input [11:0] imm;
        mk_addi = {imm, rs1, 3'b000, rd, 7'b0010011};
    endfunction

    function [31:0] mk_add;
        input [4:0] rd, rs1, rs2;
        mk_add = {7'b0000000, rs2, rs1, 3'b000, rd, 7'b0110011};
    endfunction

    function [31:0] mk_sub;
        input [4:0] rd, rs1, rs2;
        mk_sub = {7'b0100000, rs2, rs1, 3'b000, rd, 7'b0110011};
    endfunction

    function [31:0] mk_and;
        input [4:0] rd, rs1, rs2;
        mk_and = {7'b0000000, rs2, rs1, 3'b111, rd, 7'b0110011};
    endfunction

    function [31:0] mk_or;
        input [4:0] rd, rs1, rs2;
        mk_or = {7'b0000000, rs2, rs1, 3'b110, rd, 7'b0110011};
    endfunction

    // picks a random register between 1 and 5
    // keeping it to x1-x5 so the reference model is easy to check
    function [4:0] rand_reg;
        input [31:0] rval;
        rand_reg = (rval % 5) + 1;
    endfunction

    reg [4:0]  rd, rs1, rs2;
    reg [11:0] imm;
    reg [1:0]  op_pick;
    reg [31:0] rval;

    integer num_instr;

    initial begin
        pass = 0; fail = 0;
        num_instr = 20;

        // zero out reference model
        for (i = 0; i < 32; i = i + 1)
            ref_regs[i] = 0;

        // seed x1-x5 with known values first
        // this way the random instructions have non-zero inputs to work with
        uut.u_imem.mem[0] = mk_addi(5'd1, 5'd0, 12'd9);  ref_regs[1] = 9;
        uut.u_imem.mem[1] = mk_addi(5'd2, 5'd0, 12'd4);  ref_regs[2] = 4;
        uut.u_imem.mem[2] = mk_addi(5'd3, 5'd0, 12'd11); ref_regs[3] = 11;
        uut.u_imem.mem[3] = mk_addi(5'd4, 5'd0, 12'd2);  ref_regs[4] = 2;
        uut.u_imem.mem[4] = mk_addi(5'd5, 5'd0, 12'd7);  ref_regs[5] = 7;

        $display("Generating %0d random instructions", num_instr);

        // generate random instructions starting at mem[5]
        for (i = 5; i < 5 + num_instr; i = i + 1) begin
            rval   = $random;
            rd     = rand_reg($random);
            rs1    = rand_reg($random);
            rs2    = rand_reg($random);
            imm    = ($random & 12'hFF) % 10; // small positive immediates only
            op_pick = $random % 4;

            case (op_pick)
                0: begin
                    uut.u_imem.mem[i] = mk_addi(rd, rs1, imm);
                    ref_regs[rd] = ref_regs[rs1] + {{20{imm[11]}}, imm};
                    $display("  mem[%0d] addi x%0d, x%0d, %0d", i, rd, rs1, imm);
                end
                1: begin
                    uut.u_imem.mem[i] = mk_add(rd, rs1, rs2);
                    ref_regs[rd] = ref_regs[rs1] + ref_regs[rs2];
                    $display("  mem[%0d] add  x%0d, x%0d, x%0d", i, rd, rs1, rs2);
                end
                2: begin
                    uut.u_imem.mem[i] = mk_sub(rd, rs1, rs2);
                    ref_regs[rd] = ref_regs[rs1] - ref_regs[rs2];
                    $display("  mem[%0d] sub  x%0d, x%0d, x%0d", i, rd, rs1, rs2);
                end
                3: begin
                    uut.u_imem.mem[i] = mk_or(rd, rs1, rs2);
                    ref_regs[rd] = ref_regs[rs1] | ref_regs[rs2];
                    $display("  mem[%0d] or   x%0d, x%0d, x%0d", i, rd, rs1, rs2);
                end
            endcase

            // x0 is hardwired to 0
            ref_regs[0] = 0;
        end

        for (i = 5 + num_instr; i < 5 + num_instr + 8; i = i + 1)
            uut.u_imem.mem[i] = 32'h00000013;

        $display("");

        rst = 1; #22; rst = 0;

        // wait for all instructions and pipeline drain
        repeat (num_instr + 25) @(posedge clk);

        // compare x1-x5 against reference model
        $display("Register Check");
        for (i = 1; i <= 5; i = i + 1) begin
            if (uut.u_rf.regs[i] === ref_regs[i]) begin
                $display("PASS x%0d = %0d", i, uut.u_rf.regs[i]);
                pass = pass + 1;
            end else begin
                $display("FAIL x%0d : got %0d  expected %0d",
                    i, uut.u_rf.regs[i], ref_regs[i]);
                fail = fail + 1;
            end
        end

        $display("");
        $display("Random TB: %0d pass  %0d fail", pass, fail);
        $finish;
    end

endmodule