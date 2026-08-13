`timescale 1ns/1ps
module pc (
    input         clk, rst, stall,
    input  [31:0] pc_next,
    output reg [31:0] pc_out
);
    always @(posedge clk or posedge rst)
        if (rst)         pc_out <= 32'h0;
        else if (!stall) pc_out <= pc_next;
endmodule