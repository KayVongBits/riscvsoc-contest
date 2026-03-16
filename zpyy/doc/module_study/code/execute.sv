`include "define.sv"
`include "rv32i_pkg.sv"

module execute(
    input   logic   [`ADD_WIDTH-1:0]        inst_add_i      ,
    input   logic   [`DATA_WIDTH-1:0]       inst_i          ,
    input   logic   [`DATA_WIDTH-1:0]       rs1_data_i      ,
    input   logic   [`DATA_WIDTH-1:0]       rs2_data_i      ,
    input   logic   [`DATA_WIDTH-1:0]       imm_i           ,
    input   logic                           alu_src1_sel_i  ,
    input   logic                           alu_src2_sel_i  ,       

    output  logic                           wr_rd_en_o      ,
    output  logic   [`REG_ADDR_WIDTH-1:0]   rd_addr_o       ,
    output  logic   [`DATA_WIDTH-1:0]       rd_data_o       ,

    output  logic                           jump_en_o       ,
    output  logic   [`ADD_WIDTH-1:0]        jump_addr_o     
    // output  logic                           jump_hold_o
);

import rv32i_pkg::*;
// struct
Inst_s        inst_s        ;
Inst_R_Type_s inst_r_type   ;
Inst_I_Type_s inst_i_type   ;
Inst_S_Type_s inst_s_type   ;
Inst_B_Type_s inst_b_type   ;
Inst_U_Type_s inst_u_type   ;
Inst_J_Type_s inst_j_type   ;

// logic
logic   [`DATA_WIDTH-1:0]           alu_op1     ;
logic   [`DATA_WIDTH-1:0]           alu_op2     ;

// 根据opcode字段判断是哪个指令类型，并将指令的各个字段赋值给对应的结构体
assign inst_s       = Inst_s'(inst_i)           ;   // 将指令的全部32位赋值给结构体
assign inst_u_type  = Inst_U_Type_s'(inst_i)    ;
assign inst_j_type  = Inst_J_Type_s'(inst_i)    ;
assign inst_r_type  = Inst_R_Type_s'(inst_i)    ;
assign inst_i_type  = Inst_I_Type_s'(inst_i)    ;
assign inst_b_type  = Inst_B_Type_s'(inst_i)    ;
assign inst_s_type  = Inst_S_Type_s'(inst_i)    ;

// 根据指令类型，计算alu_op1和alu_op2
assign alu_op1 = ( alu_src1_sel_i == `ALU_OP1_SEL_RS1 ) ? rs1_data_i : inst_add_i ;
assign alu_op2 = ( alu_src2_sel_i == `ALU_OP2_SEL_RS2 ) ? rs2_data_i : imm_i      ;

always_comb begin : execute_comb
    wr_rd_en_o      = `WR_DISABLE           ;
    rd_addr_o       = `RST_REG              ;
    rd_data_o       = `RST_REG_VALUE        ;
    jump_en_o       = `JUMP_DISABLE         ;               // 默认不跳转
    jump_addr_o     = `JUMP_RST_ADDR        ;
    unique case (inst_s.opcode)
        U_LUI : begin
            wr_rd_en_o      = `WR_ENABLE                    ;
            rd_addr_o       = inst_u_type.rd                ;
            rd_data_o       = alu_op2                       ;
        end 
        U_AUIPC : begin
            wr_rd_en_o      = `WR_ENABLE                    ;
            rd_addr_o       = inst_u_type.rd                ;
            rd_data_o       = alu_op1 + alu_op2             ;
        end
        J_JAL : begin  
            wr_rd_en_o      = `WR_ENABLE                    ;
            rd_addr_o       = inst_j_type.rd                ;
            rd_data_o       = alu_op1 + `PC_STEP            ;
            jump_en_o       = `JUMP_ENABLE                  ;
            jump_addr_o     = alu_op1 + alu_op2             ;
        end 
        R_ARI_LOG : begin 
            wr_rd_en_o      = `WR_ENABLE                    ;
            rd_addr_o       = inst_r_type.rd                ;
            rd_data_o       = `RST_REG_VALUE                ; 
            unique case (inst_r_type.funct7)
                R_TYPE_BASE : begin                     // ADD , SLL , SLT , SLTU , XOR , SRL , OR , AND
                    unique case (inst_r_type.funct3)
                        R_TYPE_ADD_SUB : begin
                            rd_data_o = alu_op1 + alu_op2           ;
                        end
                        R_TYPE_SLL : begin
                            rd_data_o = alu_op1 << alu_op2[4:0]     ;
                        end   
                        R_TYPE_SLT : begin
                            rd_data_o = ($signed(alu_op1) < $signed(alu_op2)) ? `COMPARE_TRUE : `COMPARE_FALSE     ;
                        end   
                        R_TYPE_SLTU : begin
                            rd_data_o = ($unsigned(alu_op1) < $unsigned(alu_op2)) ? `COMPARE_TRUE : `COMPARE_FALSE ;
                        end  
                        R_TYPE_XOR : begin
                            rd_data_o = alu_op1 ^ alu_op2           ;
                        end     
                        R_TYPE_SRL_SRA : begin
                            rd_data_o = $unsigned(alu_op1) >> alu_op2[4:0]      ;
                        end
                        R_TYPE_OR : begin
                            rd_data_o = alu_op1 | alu_op2           ;
                        end    
                        R_TYPE_AND : begin
                            rd_data_o = alu_op1 & alu_op2           ;
                        end 
                        default : begin                           
                        end   
                    endcase
                end
                R_TYPE_ALT : begin                      // SUB , SRA 
                    unique case (inst_r_type.funct3)
                        R_TYPE_ADD_SUB : begin
                            rd_data_o = alu_op1 - alu_op2           ;
                        end
                        R_TYPE_SRL_SRA : begin
                            rd_data_o = $signed(alu_op1) >>> alu_op2[4:0]       ;
                        end
                        default : begin                           
                        end   
                    endcase
                end
                default : begin
                end
            endcase
        end 
        B_BRANCH : begin    
            jump_addr_o     =  imm_i + inst_add_i           ;
            case (inst_b_type.funct3) 
                B_TYPE_BEQ : begin
                    jump_en_o   = (alu_op1 == alu_op2) ? `JUMP_ENABLE : `JUMP_DISABLE                               ;
                end                 
                B_TYPE_BNE : begin                  
                    jump_en_o   = (alu_op1 != alu_op2) ? `JUMP_ENABLE : `JUMP_DISABLE                               ;
                end
                B_TYPE_BLT : begin  // 有符号小于
                    jump_en_o   = ($signed(alu_op1) < $signed(alu_op2)) ? `JUMP_ENABLE : `JUMP_DISABLE              ;
                end
                B_TYPE_BGE : begin  // 有符号大于等于
                    jump_en_o   = ($signed(alu_op1) >= $signed(alu_op2)) ? `JUMP_ENABLE : `JUMP_DISABLE             ;
                end
                B_TYPE_BLTU : begin // 无符号小于
                    jump_en_o   = ($unsigned(alu_op1) < $unsigned(alu_op2)) ? `JUMP_ENABLE : `JUMP_DISABLE          ;
                end
                B_TYPE_BGEU : begin // 无符号大于等于
                    jump_en_o   = ($unsigned(alu_op1) >= $unsigned(alu_op2)) ? `JUMP_ENABLE : `JUMP_DISABLE         ;
                end
            endcase
        end 
        S_SAVE : begin  
            
        end
        I_JALR : begin
            wr_rd_en_o      = `WR_ENABLE                                ;
            rd_addr_o       = inst_j_type.rd                            ;
            rd_data_o       = inst_add_i + `PC_STEP                     ;
            jump_en_o       = `JUMP_ENABLE                              ;
            jump_addr_o     = (alu_op1 + alu_op2) & `BIT0_CLEAR_MASK    ;
        end
        I_LOAD : begin
            
        end
        I_ARI_LOG : begin
            wr_rd_en_o      = `WR_ENABLE                ;
            rd_addr_o       = inst_i_type.rd            ;
            rd_data_o       = `RST_REG_VALUE            ;
            unique case (inst_i_type.funct3) 
                I_TYPE_ADDI_LB_JALR_FENCE_ECALL_EBREAK : begin                   
                    rd_data_o       = alu_op1 + alu_op2         ;                   
                end 
                I_TYPE_SLLI_LH_FENCEI_CSRRW : begin 
                    rd_data_o       = alu_op1 << alu_op2[4:0]   ;
                end
                I_TYPE_SLTI_LW_CSRRS : begin
                    rd_data_o       = ($signed(alu_op1) < $signed(alu_op2)) ? `COMPARE_TRUE : `COMPARE_FALSE     ;
                end
                I_TYPE_SLTIU_CSRRC : begin
                    rd_data_o       = ($unsigned(alu_op1) < $unsigned(alu_op2)) ? `COMPARE_TRUE : `COMPARE_FALSE ;
                end
                I_TYPE_XORI_LBU : begin
                    rd_data_o       = alu_op1 ^ alu_op2         ;
                end
                I_TYPE_SRLI_SRAI_LHU_CSRRWI : begin
                    if (inst_i_type.imm[10] == `SEL_SRAI) begin                 // 算数右移
                        rd_data_o   = $signed(alu_op1) >>> alu_op2[4:0]         ;
                    end else begin                                              // 逻辑右移
                        rd_data_o   = $unsigned(alu_op1) >> alu_op2[4:0]        ;
                    end
                end
                I_TYPE_ORI_CSRRSI : begin   
                    rd_data_o       = alu_op1 | alu_op2         ;
                end
                I_TYPE_ANDI_CSRRCI : begin
                    rd_data_o       = alu_op1 & alu_op2         ;
                end
                default : begin
                end
            endcase
        end
        I_FENCE : begin
            
        end
        I_SYSTEM : begin
            
        end
        default : begin
        end
    endcase
end : execute_comb

endmodule