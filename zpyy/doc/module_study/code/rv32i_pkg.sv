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
    S_SAVE      = 7'b0100011 ,      // SB , SH , SW
    I_JALR      = 7'b1100111 ,
    I_LOAD      = 7'b0000011 ,      // LB , LH , LW , LBU , LHU
    I_ARI_LOG   = 7'b0010011 ,      // ADDI , SLTI , SLTIU , XORI , ORI , ANDI , SLLI , SRLI , SRAI
    I_FENCE     = 7'b0001111 ,      // FENCE , FENCE_I
    I_ECALL     = 7'b1110011        // ECALL , EBREAK , CSRRW , CSRRS , CSRRC , CSRRWI , CSRRSI , CSRRCI
} Opcode_e ;
/*
    @brief: 定义R型指令的FUNCT7字段
    @note: 这些字段用于指令的具体操作类型
*/
typedef enum logic [6:0] {
    R_Type_1    = 7'b0000000 ,      // ADD , SLL , SLT , SLTU , XOR , SRL , OR , AND
    R_Type_2    = 7'b0100000        // SUB , SRA
} Inst_R_Type_Funct7_e ;

/*
    @brief: 定义I型指令的FUNCT3字段
    @note: 这些字段用于指令的具体操作类型
*/
typedef enum logic [2:0] {
    R_Tpye_
} Inst_R_Type_1_Funct3_e ;

/*----------------------------------------------
    二、结构体定义，用于表示指令信息
----------------------------------------------*/
typedef struct packed {
    logic       [6:0]   funct7 ;
    logic       [4:0]   rs2    ;
    logic       [4:0]   rs1    ;
    logic       [2:0]   funct3 ;
    logic       [4:0]   rd     ;
    Opcode_e            Opcode ;
} Inst_R_Type_s ;

typedef struct packed {
    logic       [11:0]  imm    ;
    logic       [4:0]   rs1    ;
    logic       [2:0]   funct3 ;
    logic       [4:0]   rd     ;
    Opcode_e            Opcode ;
} Inst_I_Type_s ;

typedef struct packed {
    logic       [11:5]  imm_0  ;
    logic       [4:0]   rs2    ;
    logic       [4:0]   rs1    ;
    logic       [2:0]   funct3 ;
    logic       [4:0]   imm_1  ;
    Opcode_e            Opcode ;
} Inst_S_Type_s ;

typedef struct packed {
    logic       [12:12] imm_0  ;
    logic       [10:5]  imm_2  ;
    logic       [4:0]   rs2    ;
    logic       [4:0]   rs1    ;
    logic       [2:0]   funct3 ;
    logic       [4:1]   imm_3  ;
    logic       [11:11] imm_1  ;
    Opcode_e            Opcode ;
} Inst_B_Type_s ;

typedef struct packed {
    logic       [31:12] imm    ;
    logic       [4:0]   rd     ;
    Opcode_e            Opcode ;
} Inst_U_Type_s ;

typedef struct packed {
    logic       [20:20] imm_0  ;
    logic       [10:1]  imm_3  ;
    logic       [11:11] imm_2  ;
    logic       [19:12] imm_1  ;
    logic       [4:0]   rd     ;
    Opcode_e            Opcode ;
} Inst_J_Type_s ;

typedef struct packed {
    logic       [31:7]  inst    ;
    Opcode_e            Opcode ;
} Inst_s ;
/*----------------------------------------------
    三、参数定义，用于表示指令信息
----------------------------------------------*/
parameter ADD_WIDTH     = 32;       // 地址宽度
parameter DATA_WIDTH    = 32;       // 数据宽度

endpackage