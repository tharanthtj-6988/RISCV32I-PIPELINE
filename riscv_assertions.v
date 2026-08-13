`timescale 1ns/1ps

module riscv_assertions (
    input clk, rst,

    //pipeline'scontrol signals
    input        stall,
    input        if_id_flush,
    input        id_ex_flush,

    //forward signal
    input [1:0]  forwardA,
    input [1:0]  forwardB,

    // hazard unit inputs
    input        id_ex_MemRead,
    input [4:0]  id_ex_Rd,
    input [4:0]  if_id_Rs1,
    input [4:0]  if_id_Rs2,

    // register files write ports
    input        wb_RegWrite,
    input [4:0]  wb_rd,
    input [31:0] wb_data,

    // prog counter inp
    input [31:0] pc_out,
    input [31:0] pc_next,

    // memory axxess
    input        mem_MemWrite,
    input        mem_MemRead
);

    // Track previous reset state to mimic $fell(rst) for A9
    reg rst_prev;
    always @(posedge clk) begin
        rst_prev <= rst;
    end

    always @(posedge clk) begin
        if (!rst) begin
            // A1 - stall and flush never to occur/active at a time



            if (stall && if_id_flush)
                $display("ASSERTION FAIL A1: stall and if_id_flush both high at time %0t", $time);
            
            // A2 - forwardA shld never be 2'b11
            if (forwardA == 2'b11)
                $display("ASSERTION FAIL A2: forwardA is 11 (invalid) at time %0t", $time);

            
            // A3 - same check for forwardB
            if (forwardB == 2'b11)
                $display("ASSERTION FAIL A3: forwardB is 11 (invalid) at time %0t", $time);

            //
            //// A4- x0 reg hardwired 32b0 never written nonzero
            if (wb_RegWrite && wb_rd == 5'b0 && wb_data != 32'b0)
                $display("ASSERTION FAIL A4: attempted write to x0 with nonzero data at time %0t", $time);

           // A5:_ load_instruct hazard must should always produce stalling
            if (id_ex_MemRead && id_ex_Rd != 5'b0 && (id_ex_Rd == if_id_Rs1 || id_ex_Rd == if_id_Rs2) && !stall)
                $display("ASSERTION FAIL A5: load-use hazard detected but stall not asserted at time %0t", $time);

            /// A6:- MEM.Rd and MEm.Wr never happens together
            if (mem_MemRead && mem_MemWrite)
                $display("ASSERTION FAIL A6: MemRead and MemWrite both high at time %0t", $time);

            //////A7: PC must to be  word aligned always



            if (pc_out[1:0] != 2'b00)
                $display("ASSERTION FAIL A7: PC is not word aligned, pc=0x%h at time %0t", pc_out, $time);
            
            // A8 : backward jump observed (branch taken)
            if (pc_next < pc_out)
                $display("COVER A8: backward PC jump observed at time %0t  pc=0x%h -> next=0x%h", $time, pc_out, pc_next);
        end
    // A9:: PC is set to 0zero after reset
        if (rst_prev == 1'b1 && rst == 1'b0) begin
            if (pc_out != 32'h0)
                $display("ASSERTION FAIL A9: PC not 0 after reset at time %0t", $time);
        end
    end

    initial begin
        $display("RiscV_assertions: 9 properties of this proj ");
        $display(" A1 - stall/flush mutex");
        $display(" A2 - forwardA valid encoding");
        $display(" A3 - forwardB valid encoding");
        $display(" A4 - x0 hardwired to zero");
        $display(" A5 - load-use stall fires");
        $display(" A6 - mem read/write mutex");
        $display(" A7 - PC word aligned");
        $display(" A8 - backward jump cover");
        $display(" A9 - reset PC zero");
    end

endmodule