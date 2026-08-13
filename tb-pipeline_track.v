`timescale 1ns/1ps
module tb_pipeline_trace;

    reg clk, rst;
    integer cycle_count;

    riscv_top uut(.clk(clk), .rst(rst));

    initial clk = 0;
    always #5 clk = ~clk;

    // just counts cycles so the trace is readable
    initial cycle_count = 0;
    always @(posedge clk) cycle_count = cycle_count + 1;

    // prints what each stage is doing every clock
    // IF and ID show full instruction word
    // EX/MEM/WB show decoded fields since we dont carry instr word that far
    always @(posedge clk) begin
        if (!rst) begin
            $display("======= CYCLE %0d =======", cycle_count);

            // IF stage
            $display("  IF  | pc=0x%h  instr=0x%h  opcode=%07b",
                uut.pc_out,
                uut.if_instr,
                uut.if_instr[6:0]);

            // ID stage
            $display("  ID  | pc=0x%h  instr=0x%h  rs1=x%0d rs2=x%0d rd=x%0d",
                uut.id_pc,
                uut.id_instr,
                uut.id_instr[19:15],
                uut.id_instr[24:20],
                uut.id_instr[11:7]);

            // EX stage - show forwarding signals too, useful for debugging hazards
            $display("  EX  | pc=0x%h  rd=x%0d  fwdA=%02b fwdB=%02b  stall=%b  flush=%b",
                uut.ex_pc,
                uut.ex_rd_w,
                uut.forwardA,
                uut.forwardB,
                uut.load_use_stall,
                uut.id_ex_flush_w);

            // MEM stage
            $display("  MEM | alu_result=0x%h  rd=x%0d  MemWrite=%b MemRead=%b",
                uut.mem_alu_result_w,
                uut.mem_rd_w,
                uut.mem_MemWrite_w,
                uut.mem_MemRead_w);

            // WB stage
            $display("  WB  | wb_data=0x%h  rd=x%0d  RegWrite=%b",
                uut.wb_data_w,
                uut.wb_rd_w,
                uut.wb_regwrite_w);

            $display("");
        end
    end

    initial begin
        $dumpfile("pipeline_trace.vcd");
        $dumpvars(0, tb_pipeline_trace);

        // same test program as tb_riscv_top
        uut.u_imem.mem[0]  = 32'h00500093; // addi x1, x0, 5
        uut.u_imem.mem[1]  = 32'h00A00113; // addi x2, x0, 10
        uut.u_imem.mem[2]  = 32'h002081B3; // add  x3, x1, x2  -> x3=15
        uut.u_imem.mem[3]  = 32'h40118233; // sub  x4, x3, x1  -> x4=10
        uut.u_imem.mem[4]  = 32'h00400293; // addi x5, x0, 4
        uut.u_imem.mem[5]  = 32'h0012A023; // sw   x1, 0(x5)
        uut.u_imem.mem[6]  = 32'h0002A303; // lw   x6, 0(x5)   -> x6=5
        uut.u_imem.mem[7]  = 32'h00130393; // addi x7, x6, 1   -> x7=6  (load-use stall here)
        uut.u_imem.mem[8]  = 32'h00108463; // beq  x1, x1, +8  -> taken
        uut.u_imem.mem[9]  = 32'h06300413; // addi x8, x0, 99  -> skipped by branch
        uut.u_imem.mem[10] = 32'h02A00493; // addi x9, x0, 42
        uut.u_imem.mem[11] = 32'h00000013;
        uut.u_imem.mem[12] = 32'h00000013;
        uut.u_imem.mem[13] = 32'h00000013;
        uut.u_imem.mem[14] = 32'h00000013;
        uut.u_imem.mem[15] = 32'h00000013;

        rst = 1; #22; rst = 0;

        // run for 25 cycles so we can see every instruction flow through
        repeat(25) @(posedge clk);
        $finish;
    end

endmodule