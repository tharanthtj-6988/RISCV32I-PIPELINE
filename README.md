RV32I 5-Stage Pipelined RISC-V Processor :

A fully functional 32-bit RISC-V processor implementing the RV32I base integer
instruction set, built in Verilog with a SystemVerilog verification environment.
The design covers the complete 5-stage pipeline with hardware hazard detection,
data forwarding, and branch resolution. With all instructions covered.


1) **Project Structure**

RISC/
 pc.v                 # Program counter with stall support
 instr_mem.v          # Instruction memory, word addressed
 if_id_reg.v          # IF/ID pipeline register (flush & stall)
 regfile.v            # 32x32 register file, x0 hardwired to zero
 imm_gen.v            # Immediate generator for all RV32I formats
 control_unit.v       # Main decoder
 id_ex_reg.v          # ID/EX pipeline register
 alu.v                # ALU supporting 10 operations
 alu_ctrl.v           # ALU control decoder
 branch_unit.v        # Condition evaluator for all 6 branch types
 forward_unit.v       # Forwarding unit (EX/MEM and MEM/WB paths)
 hazard_unit.v        # Load-use hazard detection and stall generation
 ex_mem_reg.v         # EX/MEM pipeline register
 data_mem.v           # Data memory
 mem_wb_reg.v         # MEM/WB pipeline register
 riscv_top.v          # Top level integration
 tb_alu.sv            # ALU unit testbench
 tb_control_unit.sv   # Control unit testbench
 tb_riscv_top.sv      # Full pipeline directed testbench
 tb_pipeline_trace.v  # Per-cycle pipeline stage trace
 tb_random.v          # Constrained random testbench with reference model
 tb_assertions.sv     # SystemVerilog assertion testbench
 riscv_assertions.v   # 9 SVA properties for protocol checking



2)**Supported Instructions**

| Type | Instructions |
|------|-------------|
| R-type | ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU |
| I-type | ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU |
| Load | LW |
| Store | SW |
| Branch | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| Jump | JAL, JALR |
| Upper | LUI, AUIPC |


3)**Pipeline Architecture**

The Pipeline of RISCV Processor: 

IF → ID → EX → MEM → WB


Pipeline registers separate each stage. Control signals are generated in ID
and propagated through the pipeline alongside the datapath values.

Hazard handling:

- Data hazards solved by forwarding from EX/MEM and MEM/WB back into EX
- Load-use hazards solved by a one-cycle stall inserted by the hazard unit
- Control hazards solved by flushing the two instructions behind a taken branch


4) **Verification**

Tools used:
- Icarus Verilog for RTL simulation locally
- Aldec Riviera-PRO on EDA Playground for SystemVerilog and SVA

Testbench summary:

| Testbench | Tests | Result |
|-----------|-------|--------|
| tb_alu.sv | 11 ALU operations including zero flag | 11/11 pass |
| tb_control_unit.sv | 9 instruction types | 9/9 pass |
| tb_riscv_top.sv | Full pipeline with all 3 hazard types | 9/9 pass |
| tb_random.v | 20 randomly generated instructions against reference model | 5/5 pass |
| tb_assertions.sv | 9 SVA properties | 0 failures |

Hazard scenarios verified:

- EX/MEM forwarding — `add x3, x1, x2` immediately after writing x1 and x2
- MEM/WB forwarding — `sub x4, x3, x1` one cycle after x3 is written
- Load-use stall — `lw x6` followed immediately by `addi x7, x6, 1`
- Branch flush — `beq x1, x1` correctly skips the next instruction

SVA properties (A1-A9):

- A1 — stall and flush are mutually exclusive
- A2 — forwardA encoding is never invalid
- A3 — forwardB encoding is never invalid
- A4 — register x0 is never written with nonzero data
- A5 — load-use hazard always produces a stall
- A6 — data memory read and write never asserted simultaneously
- A7 — program counter is always word aligned
- A8 — cover property confirming branch taken paths are exercised
- A9 — program counter resets to zero after reset


5) **Simulation Results:**

Pipeline trace output (cycle by cycle):**

======= CYCLE 10 =======
IF | pc=0x00000020 instr=0x00108463 opcode=1100011
ID | pc=0x0000001c instr=0x00130393 rs1=x6 rs2=x1 rd=x7
EX | pc=0x00000018 rd=x6 fwdA=01 fwdB=00 stall=1 flush=1
MEM | alu_result=0x00000004 rd=x0 MemWrite=1 MemRead=0
WB | wb_data=0x00000004 rd=x5 RegWrite=1


Load-use stall visible at cycle 10 — stall=1 holds the PC and IF/ID register
while a bubble is inserted into EX.


6) **How to Run the Files:**

Prerequisites: Icarus Verilog installed

**ALU test:**
```bash
iverilog -g2012 -o sim_alu tb_alu.sv alu.v
vvp sim_alu
```

**Control unit test:**
```bash
iverilog -g2012 -o sim_ctrl tb_control_unit.sv control_unit.v
vvp sim_ctrl
```

**Full pipeline test:**
```bash
iverilog -g2012 -o sim_top tb_riscv_top.sv riscv_top.v pc.v instr_mem.v \
if_id_reg.v regfile.v imm_gen.v control_unit.v id_ex_reg.v alu.v \
alu_ctrl.v branch_unit.v forward_unit.v hazard_unit.v ex_mem_reg.v \
data_mem.v mem_wb_reg.v
vvp sim_top


7) To View waveform:
```bash
gtkwave riscv_top.vcd
```


8) **Tools and Environment**

- Verilog RTL — Icarus Verilog, VSCode
- SystemVerilog and SVA — Aldec Riviera-PRO via EDA Playground
- Waveform viewer — GTKWave