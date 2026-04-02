`define U_LUI           7'b0110111
`define U_AUIPC         7'b0010111
`define J_JAL           7'b1101111
`define R_ARI_LOG       7'b0110011
`define B_BRANCH        7'b1100011
`define S_STORE         7'b0100011
`define I_JALR          7'b1100111
`define I_LOAD          7'b0000011
`define I_ARI_LOG       7'b0010011
`define I_FENCE         7'b0001111
`define I_SYSTEM        7'b1110011

`define NPCOP_ADD4      2'b00
`define NPCOP_BRANCH    2'b01
`define NPCOP_JALR      2'b10
`define NPCOP_JAL       2'b11

`define Mem2Reg_PCADD4  2'b00
`define Mem2Reg_ALURES  2'b01 
`define Mem2Reg_RAMDATA 2'b10
`define Mem2Reg_IMM     2'b11

`define MemWrite_En     1'b1
`define MemWrite_Dis    1'b0

`define Offset_Imm      1'b0
`define Offset_ALURES   1'b1

`define ALUSrc_RS2Data  1'b0
`define ALUSrc_IMM      1'b1  

`define RegWrite_En     1'b1
`define RegWrite_Dis    1'b0

`define Funct3_000      3'b000
`define Funct3_001      3'b001
`define Funct3_010      3'b010
`define Funct3_011      3'b011
`define Funct3_100      3'b100
`define Funct3_101      3'b101
`define Funct3_110      3'b110
`define Funct3_111      3'b111

`define Funct7_1        1'b1
`define Funct7_0        1'b0

`define ALU_ADD         4'b0000
`define ALU_SUB         4'b0001
`define ALU_AND         4'b0010
`define ALU_OR          4'b0011
`define ALU_XOR         4'b0100
`define ALU_SL          4'b0101
`define ALU_SRL         4'b0110
`define ALU_SRA         4'b0111
`define ALU_EQ          4'b1000
`define ALU_NEQ         4'b1001
`define ALU_LOW         4'b1010
`define ALU_UPPER       4'b1011