`timescale 1ns/1ps
module if_id_reg (
    input         clk, rst, stall, flush,
    input  [31:0] if_pc, if_pc_plus4, if_instr,
    output reg [31:0] id_pc, id_pc_plus4, id_instr
);
    always @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            id_pc       <= 32'h0;
            id_pc_plus4 <= 32'h4;
            id_instr    <= 32'h0000_0013;
        end else if (!stall) begin
            id_pc       <= if_pc;
            id_pc_plus4 <= if_pc_plus4;
            id_instr    <= if_instr;
        end
    end
endmodule