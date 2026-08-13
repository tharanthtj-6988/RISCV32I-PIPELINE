`timescale 1ns/1ps
module data_mem #(parameter DEPTH = 1024) (
    input         clk, MemRead, MemWrite,
    input  [31:0] addr, wdata,
    output [31:0] rdata
);
    reg [31:0] mem [0:DEPTH-1];
    integer i;
    initial begin
        for (i = 0; i < DEPTH; i = i + 1) mem[i] = 32'h0;
    end
    always @(posedge clk)
        if (MemWrite) mem[addr[11:2]] <= wdata;
    assign rdata = MemRead ? mem[addr[11:2]] : 32'h0;
endmodule