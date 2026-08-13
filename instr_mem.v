`timescale 1ns/1ps
module instr_mem #(parameter DEPTH = 1024) (
    input  [31:0] addr,
    output [31:0] instr
);
    reg [31:0] mem [0:DEPTH-1];  //accessing memory 1024 rows 32bits wide instructions
    integer i;
    initial begin
        for (i = 0; i <DEPTH; i =i + 1)
            mem[i] = 32'h0000_0013;
    end
    assign instr = mem[addr[11:2]];
endmodule