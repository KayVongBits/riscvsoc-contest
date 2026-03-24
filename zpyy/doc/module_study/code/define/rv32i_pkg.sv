`include "define.sv"

package rv32i_pkg;

/*----------------------------------------------
    一、枚举定义，用于表示指令信息
----------------------------------------------*/
/*
    @brief: 定义RISC-V指令集的opcode
    @note: 这些opcode用于指令的分类和识别
*/
typedef enum logic [6:0] {
    U_LUI       = 7'b0110111 ,
    U_AUIPC     = 7'b0010111 ,
    J_JAL       = 7'b1101111 ,
    R_ARI_LOG   = 7'b0110011 ,      // ADD , SUB , SLL , SLT , SLTU , XOR , SRL , SRA , OR , AND
    B_BRANCH    = 7'b1100011 ,      // BEQ , BNE , BLT , BGE , BLTU , BGEU
    S_STORE     = 7'b0100011 ,      // SB , SH , SW
    I_JALR      = 7'b1100111 ,
    I_LOAD      = 7'b0000011 ,      // LB , LH , LW , LBU , LHU
    I_ARI_LOG   = 7'b0010011 ,      // ADDI , SLTI , SLTIU , XORI , ORI , ANDI , SLLI , SRLI , SRAI
    I_FENCE     = 7'b0001111 ,      // FENCE , FENCE_I
    I_SYSTEM    = 7'b1110011        // ECALL , EBREAK , CSRRW , CSRRS , CSRRC , CSRRWI , CSRRSI , CSRRCI
} Opcode_e ;

/*
    @brief: 定义R型指令的FUNCT7字段
    @note: 这些字段用于指令的具体操作类型
*/
typedef enum logic [6:0] {
    R_TYPE_BASE    = 7'b0000000     ,   // ADD , SLL , SLT , SLTU , XOR , SRL , OR , AND
    R_TYPE_ALT     = 7'b0100000     ,   // SUB , SRA
    R_TYPE_MAD     = 7'b0000001         // MUL , DIV , REM
} Inst_R_Type_Funct7_e ;

/*
    @brief: 定义R型指令的FUNCT3字段
    @note: 这些字段用于R指令的具体操作类型
*/
typedef enum logic [2:0] {
    R_TYPE_000  = 3'b000        ,   // ADD , SUB , MUL
    R_TYPE_001  = 3'b001        ,   // SLL , MULH
    R_TYPE_010  = 3'b010        ,   // SLT , MULHSU
    R_TYPE_011  = 3'b011        ,   // SLTU , MULHU
    R_TYPE_100  = 3'b100        ,   // XOR , DIV
    R_TYPE_101  = 3'b101        ,   // SRL , SRA , DIVU
    R_TYPE_110  = 3'b110        ,   // OR , REM
    R_TYPE_111  = 3'b111            // AND , REMU
} Inst_R_Type_Funct3_e ;

/*
    @brief: 定义I型指令的FUNCT3字段
    @note: 这些字段用于I指令的具体操作类型
*/
typedef enum logic [2:0] {
    I_TYPE_000  = 3'b000     ,      // ADDI, LB , JALR , FENCE , ECALL , EBREAK
    I_TYPE_001  = 3'b001     ,      // SLLI, LH , FENCEI , CSRRW
    I_TYPE_010  = 3'b010     ,      // SLTI, LW , CSRRS
    I_TYPE_011  = 3'b011     ,      // SLTIU, CSRRC
    I_TYPE_100  = 3'b100     ,      // XORI, LBU
    I_TYPE_101  = 3'b101     ,      // SRLI, SRAI, LHU , CSRRWI
    I_TYPE_110  = 3'b110     ,      // ORI, CSRRSI
    I_TYPE_111  = 3'b111            // ANDI, CSRRCI
} Inst_I_Type_Funct3_e ;

/*
    @brief: 定义S型指令的FUNCT3字段
    @note: 这些字段用于S指令的具体操作类型
*/
typedef enum logic [2:0] {
    S_TYPE_SB       = 3'b000        ,   // SB
    S_TYPE_SH       = 3'b001        ,   // SH
    S_TYPE_SW       = 3'b010            // SW
} Inst_S_Type_Funct3_e ;

/*
    @brief: 定义B型指令的FUNCT3字段
    @note: 这些字段用于B指令的具体操作类型
*/
typedef enum logic [2:0] {
    B_TYPE_BEQ      = 3'b000        ,   // BEQ
    B_TYPE_BNE      = 3'b001        ,   // BNE
    B_TYPE_BLT      = 3'b100        ,   // BLT
    B_TYPE_BGE      = 3'b101        ,   // BGE
    B_TYPE_BLTU     = 3'b110        ,   // BLTU
    B_TYPE_BGEU     = 3'b111            // BGEU
} Inst_B_Type_Funct3_e ;

typedef enum logic [3:0] {
    RAM_WR_B_1      = 4'b0001       ,
    RAM_WR_B_2      = 4'b0010       ,
    RAM_WR_B_3      = 4'b0100       ,
    RAM_WR_B_4      = 4'b1000       ,
    RAM_WR_HW_1     = 4'b0011       ,
    RAM_WR_HW_2     = 4'b1100       ,
    RAM_WR_W        = 4'b1111       ,
    RAM_WR_DISABLE  = 4'b0000
} Ram_Wr_Mask_e ;

typedef enum logic [2:0] {
    RAM_RD_DISABLE  = 3'b000        ,
    RAM_RD_EN_LB    = 3'b001        ,
    RAM_RD_EN_LH    = 3'b010        ,
    RAM_RD_EN_LW    = 3'b011        ,
    RAM_RD_EN_LBU   = 3'b100        ,
    RAM_RD_EN_LHU   = 3'b101            
} Ram_Rd_Mode_e ;
/*----------------------------------------------
    二、结构体定义，用于表示指令信息
----------------------------------------------*/
typedef struct packed {
    Inst_R_Type_Funct7_e    funct7 ;
    logic       [4:0]       rs2    ;
    logic       [4:0]       rs1    ;
    Inst_R_Type_Funct3_e    funct3 ;
    logic       [4:0]       rd     ;
    Opcode_e                opcode ;
} Inst_R_Type_s ;

typedef struct packed {
    logic       [11:0]      imm    ;
    logic       [4:0]       rs1    ;
    Inst_I_Type_Funct3_e    funct3 ;
    logic       [4:0]       rd     ;
    Opcode_e                opcode ;
} Inst_I_Type_s ;

typedef struct packed {
    logic       [11:5]      imm_0  ;
    logic       [4:0]       rs2    ;
    logic       [4:0]       rs1    ;
    Inst_S_Type_Funct3_e    funct3 ;
    logic       [4:0]       imm_1  ;
    Opcode_e                opcode ;
} Inst_S_Type_s ;

typedef struct packed {
    logic       [12:12]     imm_0  ;
    logic       [10:5]      imm_2  ;
    logic       [4:0]       rs2    ;
    logic       [4:0]       rs1    ;
    Inst_B_Type_Funct3_e    funct3 ;
    logic       [4:1]       imm_3  ;
    logic       [11:11]     imm_1  ;
    Opcode_e                opcode ;
} Inst_B_Type_s ;

typedef struct packed {
    logic       [31:12]     imm    ;
    logic       [4:0]       rd     ;
    Opcode_e                opcode ;
} Inst_U_Type_s ;

typedef struct packed {
    logic       [20:20]     imm_0  ;
    logic       [10:1]      imm_3  ;
    logic       [11:11]     imm_2  ;
    logic       [19:12]     imm_1  ;
    logic       [4:0]       rd     ;
    Opcode_e                opcode ;
} Inst_J_Type_s ;

typedef struct packed {
    logic       [31:7]  inst    ;
    Opcode_e            opcode ;
} Inst_s ;

// 控制信号结构体，用于控制指令的执行
// ex ctrl
typedef struct packed {
    logic                   alu_src1_sel  ;
    logic                   alu_src2_sel  ;
} Ex_Ctrl_s ;   

// mem ctrl
typedef struct packed {
    logic                   ram_wr_en     ;
    logic                   ram_rd_en     ;
    Ram_Wr_Mask_e           ram_wr_mask   ;
    Ram_Rd_Mode_e           ram_rd_mode   ;
} Mem_Ctrl_s ;   

// wb ctrl
typedef struct packed {
    logic                   reg_wr_en     ;
} Wb_Ctrl_s ;

// id2ex
typedef struct packed {
    Ex_Ctrl_s                           ex_ctrl     ;
    Mem_Ctrl_s                          mem_ctrl    ;
    Wb_Ctrl_s                           wb_ctrl     ;
    logic       [`ADD_WIDTH-1:0]        inst_addr   ;
    logic       [`DATA_WIDTH-1:0]       inst        ;
    logic       [`DATA_WIDTH-1:0]       imm         ;
    logic       [`DATA_WIDTH-1:0]       rs1_data    ;
    logic       [`DATA_WIDTH-1:0]       rs2_data    ;
    logic       [`REG_ADDR_WIDTH-1:0]   rd_addr     ;
} Id2Ex_Bus_s ;

// ex2mem
typedef struct packed {
    Mem_Ctrl_s                          mem_ctrl    ;
    Wb_Ctrl_s                           wb_ctrl     ;
    logic       [`DATA_WIDTH-1:0]       alu_res     ;
    logic       [`DATA_WIDTH-1:0]       rs2_data    ;
    logic       [`REG_ADDR_WIDTH-1:0]   rd_addr     ;
} Ex2Mem_Bus_s ;

// mem2wb
typedef struct packed {
    Wb_Ctrl_s                           wb_ctrl     ;
    logic       [`DATA_WIDTH-1:0]       alu_res     ;
    logic       [`REG_ADDR_WIDTH-1:0]   rd_addr     ;
} Mem2Wb_Bus_s ;


endpackage