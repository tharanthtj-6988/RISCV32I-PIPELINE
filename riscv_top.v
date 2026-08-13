`timescale 1ns/1ps
module riscv_top (
    input clk, rst
);
    wire [31:0] pc_out, pc_plus4, pc_next;
    wire [31:0] if_instr;
    wire        pc_stall, if_id_stall, if_id_flush, id_ex_flush_w;
    wire        take_branch_ex, take_jump_ex, is_jalr_ex;
    wire [31:0] branch_target_ex, jalr_target_ex;

    assign pc_plus4 = pc_out + 32'h4;
    assign pc_next  = (take_jump_ex && is_jalr_ex)     ? jalr_target_ex  :
                      (take_jump_ex || take_branch_ex) ? branch_target_ex :
                                                         pc_plus4;

    pc        u_pc  (.clk(clk),.rst(rst),.stall(pc_stall),.pc_next(pc_next),.pc_out(pc_out));
    instr_mem u_imem(.addr(pc_out),.instr(if_instr));

    wire [31:0] id_pc, id_pc_plus4, id_instr;
    if_id_reg u_if_id(
        .clk(clk),.rst(rst),.stall(if_id_stall),.flush(if_id_flush),
        .if_pc(pc_out),.if_pc_plus4(pc_plus4),.if_instr(if_instr),
        .id_pc(id_pc),.id_pc_plus4(id_pc_plus4),.id_instr(id_instr)
    );

    wire [4:0] id_rs1 = id_instr[19:15];
    wire [4:0] id_rs2 = id_instr[24:20];
    wire [4:0] id_rd  = id_instr[11:7];

    wire [4:0]  wb_rd_w;
    wire [31:0] wb_data_w;
    wire        wb_regwrite_w;

    wire [31:0] id_rd1, id_rd2;
    regfile u_rf(
        .clk(clk),.RegWrite(wb_regwrite_w),
        .rs1(id_rs1),.rs2(id_rs2),.rd(wb_rd_w),.wd(wb_data_w),
        .rd1(id_rd1),.rd2(id_rd2)
    );

    wire [31:0] id_imm;
    imm_gen u_imm(.instr(id_instr),.imm(id_imm));

    wire        id_RegWrite, id_MemRead, id_MemWrite;
    wire [1:0]  id_MemToReg, id_ALUSrc1, id_ALUOp;
    wire        id_ALUSrc, id_Branch, id_Jump, id_JALR;
    wire        id_UsesRS1, id_UsesRS2;

    control_unit u_ctrl(
        .opcode(id_instr[6:0]),
        .RegWrite(id_RegWrite),.MemRead(id_MemRead),.MemWrite(id_MemWrite),
        .MemToReg(id_MemToReg),.ALUSrc(id_ALUSrc),.ALUSrc1(id_ALUSrc1),
        .Branch(id_Branch),.Jump(id_Jump),.IsJALR(id_JALR),
        .ALUOp(id_ALUOp),.UsesRS1(id_UsesRS1),.UsesRS2(id_UsesRS2)
    );

    wire ex_MemRead_w;
    wire [4:0] ex_rd_w;
    wire load_use_stall;

    hazard_unit u_haz(
        .id_ex_MemRead(ex_MemRead_w),.id_ex_Rd(ex_rd_w),
        .if_id_Rs1(id_rs1),.if_id_Rs2(id_rs2),
        .if_id_UsesRS1(id_UsesRS1),.if_id_UsesRS2(id_UsesRS2),
        .stall(load_use_stall)
    );

    wire branch_or_jump = take_branch_ex || take_jump_ex;
    assign pc_stall      = load_use_stall;
    assign if_id_stall   = load_use_stall;
    assign if_id_flush   = branch_or_jump && !load_use_stall;
    assign id_ex_flush_w = branch_or_jump || load_use_stall;

    wire [31:0] ex_pc, ex_pc_plus4, ex_rd1, ex_rd2, ex_imm;
    wire [4:0]  ex_rs1, ex_rs2;
    wire [2:0]  ex_funct3;
    wire [6:0]  ex_funct7;
    wire        ex_RegWrite_w, ex_MemWrite_w;
    wire [1:0]  ex_MemToReg_w, ex_ALUSrc1_w, ex_ALUOp_w;
    wire        ex_ALUSrc_w, ex_Branch_w, ex_Jump_w, ex_JALR_w;

    id_ex_reg u_id_ex(
        .clk(clk),.rst(rst),.flush(id_ex_flush_w),
        .id_pc(id_pc),.id_pc_plus4(id_pc_plus4),
        .id_rd1(id_rd1),.id_rd2(id_rd2),.id_imm(id_imm),
        .id_rs1(id_rs1),.id_rs2(id_rs2),.id_rd(id_rd),
        .id_funct3(id_instr[14:12]),.id_funct7(id_instr[31:25]),
        .id_RegWrite(id_RegWrite),.id_MemRead(id_MemRead),.id_MemWrite(id_MemWrite),
        .id_MemToReg(id_MemToReg),.id_ALUSrc(id_ALUSrc),.id_ALUSrc1(id_ALUSrc1),
        .id_Branch(id_Branch),.id_Jump(id_Jump),.id_JALR(id_JALR),.id_ALUOp(id_ALUOp),
        .ex_pc(ex_pc),.ex_pc_plus4(ex_pc_plus4),
        .ex_rd1(ex_rd1),.ex_rd2(ex_rd2),.ex_imm(ex_imm),
        .ex_rs1(ex_rs1),.ex_rs2(ex_rs2),.ex_rd(ex_rd_w),
        .ex_funct3(ex_funct3),.ex_funct7(ex_funct7),
        .ex_RegWrite(ex_RegWrite_w),.ex_MemRead(ex_MemRead_w),.ex_MemWrite(ex_MemWrite_w),
        .ex_MemToReg(ex_MemToReg_w),.ex_ALUSrc(ex_ALUSrc_w),.ex_ALUSrc1(ex_ALUSrc1_w),
        .ex_Branch(ex_Branch_w),.ex_Jump(ex_Jump_w),.ex_JALR(ex_JALR_w),.ex_ALUOp(ex_ALUOp_w)
    );

    wire [4:0]  mem_rd_w;
    wire        mem_RegWrite_w;
    wire [31:0] mem_alu_result_w;

    wire [1:0] forwardA, forwardB;
    forward_unit u_fwd(
        .ex_rs1(ex_rs1),.ex_rs2(ex_rs2),
        .mem_rd(mem_rd_w),.mem_RegWrite(mem_RegWrite_w),
        .wb_rd(wb_rd_w),.wb_RegWrite(wb_regwrite_w),
        .forwardA(forwardA),.forwardB(forwardB)
    );

    wire [31:0] fwd_rs1 = (forwardA==2'b10) ? mem_alu_result_w :
                          (forwardA==2'b01) ? wb_data_w        : ex_rd1;
    wire [31:0] fwd_rs2 = (forwardB==2'b10) ? mem_alu_result_w :
                          (forwardB==2'b01) ? wb_data_w        : ex_rd2;

    wire [31:0] alu_in1 = (ex_ALUSrc1_w==2'b01) ? ex_pc   :
                          (ex_ALUSrc1_w==2'b10) ? 32'b0   : fwd_rs1;
    wire [31:0] alu_in2 = ex_ALUSrc_w ? ex_imm : fwd_rs2;

    wire [3:0]  alu_sel;
    alu_ctrl u_ac(.ALUOp(ex_ALUOp_w),.funct3(ex_funct3),.funct7(ex_funct7),.ALUSel(alu_sel));

    wire [31:0] alu_result;
    wire        alu_zero;
    alu u_alu(.a(alu_in1),.b(alu_in2),.ALUSel(alu_sel),.result(alu_result),.zero(alu_zero));

    assign branch_target_ex = ex_pc + ex_imm;
    assign jalr_target_ex   = {alu_result[31:1], 1'b0};

    wire branch_cond;
    branch_unit u_bu(.funct3(ex_funct3),.alu_result(alu_result),.branch_cond(branch_cond));

    assign take_branch_ex = ex_Branch_w & branch_cond;
    assign take_jump_ex   = ex_Jump_w;
    assign is_jalr_ex     = ex_JALR_w;

    wire [31:0] mem_store_data_w, mem_pc_plus4_w;
    wire [1:0]  mem_MemToReg_w;
    wire        mem_MemRead_w, mem_MemWrite_w;

    ex_mem_reg u_ex_mem(
        .clk(clk),.rst(rst),
        .ex_alu_result(alu_result),.ex_store_data(fwd_rs2),
        .ex_pc_plus4(ex_pc_plus4),.ex_rd(ex_rd_w),
        .ex_RegWrite(ex_RegWrite_w),.ex_MemRead(ex_MemRead_w),
        .ex_MemWrite(ex_MemWrite_w),.ex_MemToReg(ex_MemToReg_w),
        .mem_alu_result(mem_alu_result_w),.mem_store_data(mem_store_data_w),
        .mem_pc_plus4(mem_pc_plus4_w),.mem_rd(mem_rd_w),
        .mem_RegWrite(mem_RegWrite_w),.mem_MemRead(mem_MemRead_w),
        .mem_MemWrite(mem_MemWrite_w),.mem_MemToReg(mem_MemToReg_w)
    );

    wire [31:0] mem_rdata_w;
    data_mem u_dm(
        .clk(clk),.MemRead(mem_MemRead_w),.MemWrite(mem_MemWrite_w),
        .addr(mem_alu_result_w),.wdata(mem_store_data_w),.rdata(mem_rdata_w)
    );

    wire [31:0] wb_alu_result_w, wb_rdata_w, wb_pc_plus4_w;
    wire [1:0]  wb_MemToReg_w;

    mem_wb_reg u_mw(
        .clk(clk),.rst(rst),
        .mem_alu_result(mem_alu_result_w),.mem_rdata(mem_rdata_w),
        .mem_pc_plus4(mem_pc_plus4_w),.mem_rd(mem_rd_w),
        .mem_RegWrite(mem_RegWrite_w),.mem_MemToReg(mem_MemToReg_w),
        .wb_alu_result(wb_alu_result_w),.wb_rdata(wb_rdata_w),
        .wb_pc_plus4(wb_pc_plus4_w),.wb_rd(wb_rd_w),
        .wb_RegWrite(wb_regwrite_w),.wb_MemToReg(wb_MemToReg_w)
    );

    assign wb_data_w = (wb_MemToReg_w==2'b01) ? wb_rdata_w     :
                       (wb_MemToReg_w==2'b10) ? wb_pc_plus4_w  :
                                                wb_alu_result_w;
endmodule