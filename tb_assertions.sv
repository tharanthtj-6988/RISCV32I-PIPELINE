`timescale 1ns/1ps

module tb_assertions;

    reg clk, rst;
    integer pass, fail;

    riscv_top uut(.clk(clk), .rst(rst));

    initial clk = 0;
    always #5 clk = ~clk;

    // Tracking previous reset state 
    reg rst_prev;
    always @(posedge clk) begin
        rst_prev <= rst;
    end

    always @(posedge clk) begin
        if (!rst) begin

            // A1 - stall and flush never to occur at a time
            if (uut.load_use_stall && uut.if_id_flush) begin
                $display("FAIL A1 @ %0t : stall and flush both high", $time);
                fail = fail + 1;
            end

            // A2 - forwardA shld never be 2'b11
            if (uut.forwardA == 2'b11) begin
                $display("FAIL A2 @ %0t : forwardA invalid encoding 11", $time);
                fail = fail + 1;
            end

           //A3
            if (uut.forwardB == 2'b11) begin
                $display("FAIL A3 @ %0t : forwardB invalid encoding 11", $time);
                fail = fail + 1;
            end



            // A4 - x0 reg hardwired 32b0 never written nonzero
            if (uut.wb_regwrite_w && uut.wb_rd_w == 5'b0 && uut.wb_data_w != 32'b0) begin
                $display("FAIL A4 @ %0t : x0 written with nonzero data", $time);
                fail= fail + 1;
            end

            // A5:_ load_ins hazard must should always produce stalling
            if (uut.ex_MemRead_w && uut.ex_rd_w != 5'b0 && (uut.ex_rd_w == uut.id_rs1 || uut.ex_rd_w == uut.id_rs2)) begin
                if (!uut.load_use_stall) begin
                    $display("FAIL A5 @ %0t : load-use hazard without stall", $time);
                    fail = fail + 1;
                end
            end

            // A6:- MEM.Rd and MEm.Wr never happens together
            if (uut.mem_MemRead_w && uut.mem_MemWrite_w) begin
                $display("FAIL A6 @ %0t : MemRead and MemWrite both high", $time);
                fail = fail + 1;
            end

            // A7: PC must to be  word aligned always
            if (uut.pc_out[1:0] != 2'b00) begin
                $display("FAIL A7 @ %0t : PC not word aligned 0x%h", $time, uut.pc_out);
                fail = fail + 1;
            end

    
            // A8 : backward jump observed (branch taken)
            if (uut.pc_next < uut.pc_out) begin
                $display("COVER A8 @ %0t : backward jump 0x%h -> 0x%h", $time, uut.pc_out, uut.pc_next);
            end
        end

        // A9:: PC is set to 0zero after reset


        if (rst_prev == 1'b1 && rst == 1'b0) begin
            if (uut.pc_out != 32'h0) begin
                $display("FAIL A9 @ %0t : PC not 0 after reset", $time);
                fail = fail + 1;
            end
        end
    end

    initial begin
        pass = 0; fail = 0;

        uut.u_imem.mem[0]  = 32'h00500093;
        uut.u_imem.mem[1]  = 32'h00A00113;
        uut.u_imem.mem[2]  = 32'h002081B3;
        uut.u_imem.mem[3]  = 32'h40118233;
        uut.u_imem.mem[4]  = 32'h00400293;
        uut.u_imem.mem[5]  = 32'h0012A023;
        uut.u_imem.mem[6]  = 32'h0002A303;
        uut.u_imem.mem[7]  = 32'h00130393;
        uut.u_imem.mem[8]  = 32'h00108463;
        uut.u_imem.mem[9]  = 32'h06300413;
        uut.u_imem.mem[10] = 32'h02A00493;
        uut.u_imem.mem[11] = 32'h00000013;
        uut.u_imem.mem[12] = 32'h00000013;
        uut.u_imem.mem[13] = 32'h00000013;
        uut.u_imem.mem[14] = 32'h00000013;
        uut.u_imem.mem[15] = 32'h00000013;

        rst = 1; #22; rst = 0;

        repeat(50) @(posedge clk);

        $display("");
        $display("Assertion Summary");
        $display("Fails caught: %0d", fail);
        if (fail == 0)
            $display("ALL ASSERTIONS PASSED");
        else
            $display("ALL Assertions DIDNT Pass, SOME Have FAILED");

        $finish;
    end

endmodule