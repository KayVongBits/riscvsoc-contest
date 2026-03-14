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
    I_ECALL_CSR = 7'b1110011        // ECALL , EBREAK , CSRRW , CSRRS , CSRRC , CSRRWI , CSRRSI , CSRRCI
} Opcode_e ;

/*
    @brief: 定义R型指令的FUNCT7字段
    @note: 这些字段用于指令的具体操作类型
*/
typedef enum logic [6:0] {
    R_TYPE_BASE    = 7'b0000000     ,   // ADD , SLL , SLT , SLTU , XOR , SRL , OR , AND
    R_TYPE_ALT     = 7'b0100000         // SUB , SRA
} Inst_R_Type_Funct7_e ;

/*
    @brief: 定义R型指令的FUNCT3字段
    @note: 这些字段用于R指令的具体操作类型
*/
typedef enum logic [2:0] {
    R_TYPE_ADD_SUB  = 3'b000        ,   // ADD_SUB
    R_TYPE_SLL      = 3'b001        ,   // SLL
    R_TYPE_SLT      = 3'b010        ,   // SLT
    R_TYPE_SLTU     = 3'b011        ,   // SLTU
    R_TYPE_XOR      = 3'b100        ,   // XOR
    R_TYPE_SRL_SRA  = 3'b101        ,   // SRL, SRA 
    R_TYPE_OR       = 3'b110        ,   // OR
    R_TYPE_AND      = 3'b111            // AND
} Inst_R_Type_Funct3_e ;

/*
    @brief: 定义I型指令的FUNCT3字段
    @note: 这些字段用于I指令的具体操作类型
*/
typedef enum logic [2:0] {
    I_TYPE_ADDI_LB_JALR_FENCE_ECALL_EBREAK  = 3'b000     ,      // ADDI, LB , JALR , FENCE , ECALL , EBREAK
    I_TYPE_SLLI_LH_FENCEI_CSRRW             = 3'b001     ,      // SLLI, LH , FENCEI , CSRRW
    I_TYPE_SLTI_LW_CSRRS                    = 3'b010     ,      // SLTI, LW , CSRRS
    I_TYPE_SLTIU_CSRRC                      = 3'b011     ,      // SLTIU, CSRRC
    I_TYPE_XORI_LBU                         = 3'b100     ,      // XORI, LBU
    I_TYPE_SRLI_SRAI_LHU_CSRRWI             = 3'b101     ,      // SRLI, SRAI, LHU , CSRRWI
    I_TYPE_ORI_CSRRSI                       = 3'b110     ,      // ORI, CSRRSI
    I_TYPE_ANDI_CSRRCI                      = 3'b111            // ANDI, CSRRCI
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
/*----------------------------------------------
    三、参数定义，用于表示指令信息
----------------------------------------------*/
localparam logic [4:0] REG_ZERO = 5'b00000 ; // x0寄存器地址，始终为0

endpackage