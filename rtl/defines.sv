// ==========================================
// RISC-V Core Parameters & Instruction Defs
// ==========================================

`define AW              32
`define DW              32
`define FILE            "rv32ui-p-addi.txt"

// ------------------------------------------
// 1. 操作码 Opcodes (opcode[6:0])
// ------------------------------------------
`define INST_TYPE_I     7'b0010011 // I-Type (基础算术)
`define INST_TYPE_L     7'b0000011 // I-Type (访存 Load)
`define INST_TYPE_S     7'b0100011 // S-Type (访存 Store)
`define INST_TYPE_R_M   7'b0110011 // R-Type (算术 & 乘除法扩展)
`define INST_TYPE_B     7'b1100011 // B-Type (条件分支) -> 修复了原先的错误！

`define INST_JAL        7'b1101111 // J-Type (无条件跳转)
`define INST_JALR       7'b1100111 // I-Type (寄存器跳转)
`define INST_LUI        7'b0110111 // U-Type (高位立即数加载)
`define INST_AUIPC      7'b0010111 // U-Type (重命名自 LUIPC)

`define INST_SYSTEM     7'b1110011 // 系统指令 (ecall/ebreak/CSR)
`define INST_FENCE      7'b0001111 // 内存屏障
`define INST_NOP_OP     7'b0000000 // NOP (无操作) -> 这只是一个占位符，实际 NOP 是一个特定的指令编码

// ------------------------------------------
// 2. 功能码 Funct3 (funct3[2:0])
// ------------------------------------------
// I-Type & R-Type (算术逻辑运算)
`define INST_ADD_SUB    3'b000 // 包含 ADDI, ADD, SUB
`define INST_SLL        3'b001 // 包含 SLLI, SLL
`define INST_SLT        3'b010 // 包含 SLTI, SLT
`define INST_SLTU       3'b011 // 包含 SLTIU, SLTU
`define INST_XOR        3'b100 // 包含 XORI, XOR
`define INST_SRL_SRA    3'b101 // 包含 SRLI, SRAI, SRL, SRA
`define INST_OR         3'b110 // 包含 ORI, OR
`define INST_AND        3'b111 // 包含 ANDI, AND

// L-Type (Load)
`define INST_LB         3'b000
`define INST_LH         3'b001
`define INST_LW         3'b010
`define INST_LBU        3'b100
`define INST_LHU        3'b101

// S-Type (Store)
`define INST_SB         3'b000
`define INST_SH         3'b001
`define INST_SW         3'b010

// B-Type (Branch)
`define INST_BEQ        3'b000
`define INST_BNE        3'b001
`define INST_BLT        3'b100
`define INST_BGE        3'b101
`define INST_BLTU       3'b110
`define INST_BGEU       3'b111

// M-Extension (Mul/Div 乘除法扩展)
`define INST_MUL        3'b000
`define INST_MULH       3'b001
`define INST_MULHSU     3'b010
`define INST_MULHU      3'b011
`define INST_DIV        3'b100
`define INST_DIVU       3'b101
`define INST_REM        3'b110
`define INST_REMU       3'b111

// ------------------------------------------
// 3. 辅助功能码 Funct7 (funct7[6:0]) -> 新增！
// ------------------------------------------
// 用于区分 opcode 和 funct3 相同的指令
`define FUNCT7_0        7'b0000000 // 用于 ADD, SRL, SRLI
`define FUNCT7_1        7'b0100000 // 用于 SUB, SRA, SRAI (第30位为1)
`define FUNCT7_M        7'b0000001 // 用于乘除法 M 扩展

// ------------------------------------------
// 4. 固定 32-bit 特殊指令
// ------------------------------------------
`define INST_NOP        32'h00000013 // addi x0, x0, 0
`define INST_RET        32'h00008067 // jalr x0, ra, 0
`define INST_MRET       32'h30200073
`define INST_ECALL      32'h00000073
`define INST_EBREAK     32'h00100073