`timescale 1ns/1ps
module hazard_unit (
    input        id_ex_MemRead,
    input  [4:0] id_ex_Rd,
    input  [4:0] if_id_Rs1, if_id_Rs2,
    input        if_id_UsesRS1, if_id_UsesRS2,
    output       stall
);
    assign stall = id_ex_MemRead && (id_ex_Rd != 5'b0) &&
                   ((if_id_UsesRS1 && id_ex_Rd == if_id_Rs1) ||
                    (if_id_UsesRS2 && id_ex_Rd == if_id_Rs2));
endmodule