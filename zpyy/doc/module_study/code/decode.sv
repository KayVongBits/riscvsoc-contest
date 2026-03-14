`include "define.sv"
`include "rv32i_pkg.sv"

module decode(
    input   logic   [`DATA_WIDTH-1:0]       inst_i      ,

    output  logic   [`REG_ADDR_WIDTH-1:0]   rs1_addr_o  ,
    output  logic   [`REG_ADDR_WIDTH-1:0]   rs2_addr_o  ,
    output  logic   [`REG_ADDR_WIDTH-1:0]   rd_addr_o   ,
    
    input   logic   [`DATA_WIDTH-1:0]       rs1_data_i  ,
    input   logic   [`DATA_WIDTH-1:0]       rs2_data_i  ,

    output  logic   [`DATA_WIDTH-1:0]       rs1_data_o  ,
    output  logic   [`DATA_WIDTH-1:0]       rs2_data_o  ,

    output  logic   [`DATA_WIDTH-1:0]       imm_o       
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

// 根据opcode字段判断是哪个指令类型，并将指令的各个字段赋值给对应的结构体
assign inst_s = Inst_s'(inst_i); // 将指令的全部32位赋值给结构体

// comb logic
always_comb begin
    unique case ( inst_s.opcode )
        U_LUI, U_AUIPC: begin
            inst_u_type = Inst_U_Type_s'(inst_i) ; // 处理U型指令
        end
        J_JAL: begin
            inst_j_type = Inst_J_Type_s'(inst_i) ; // 处理J型指令
        end
        R_ARI_LOG: begin
            inst_r_type = Inst_R_Type_s'(inst_i) ; // 处理R型指令
        end
        B_BRANCH: begin
            inst_b_type = Inst_B_Type_s'(inst_i) ; // 处理B型指令
        end
        S_SAVE: begin
            inst_s_type = Inst_S_Type_s'(inst_i) ; // 处理S型指令
        end
        I_JALR, I_LOAD, I_ARI_LOG, I_FENCE, I_ECALL_CSR: begin
            inst_i_type = Inst_I_Type_s'(inst_i) ; // 处理I型指令
            unique case (inst_i_type.opcode)
                I_ARI_LOG: begin // 处理I型算术逻辑指令
                    unique case (inst_i_type.funct3) 
                        I_TYPE_ADDI_LB_JALR_FENCE_ECALL_EBREAK, I_TYPE_SLTI_LW_CSRRS, I_TYPE_SLTIU_CSRRC, I_TYPE_XORI_LBU, I_TYPE_ORI_CSRRSI, I_TYPE_ANDI_CSRRCI: begin
                            rs1_addr_o = inst_i_type.rs1                                ;
                            rs1_data_o = rs1_data_i                                     ;
                            rs2_addr_o = `RST_REG                                       ;   // I型指令没有rs2
                            rs2_data_o = `RST_REG_VALUE                                 ;   // 立即数符号扩展
                            rd_addr_o  = inst_i_type.rd                                 ;
                            imm_o      = {{20{inst_i_type.imm[11]}}, inst_i_type.imm}   ;
                            
                        end
                        default: begin
                            rs1_addr_o = `RST_REG       ;
                            rs2_addr_o = `RST_REG       ;
                            rd_addr_o  = `RST_REG       ;
                            rs1_data_o = `RST_REG_VALUE ;
                            rs2_data_o = `RST_REG_VALUE ;
                            imm_o      = `RST_IMM_VALUE ;
                        end
                    endcase
                end
                I_LOAD: begin
                    // 处理I型加载指令
                end
                I_JALR: begin
                    // 处理I型寄存器跳转指令
                end
                I_FENCE: begin
                    // 处理FENCE指令
                end
                I_ECALL_CSR: begin
                    // 处理系统调用和CSR指令
                end
                default: begin
                    // 其他I型指令的处理（如果有的话）
                    rs1_addr_o = `RST_REG       ;
                    rs2_addr_o = `RST_REG       ;
                    rd_addr_o  = `RST_REG       ;
                    rs1_data_o = `RST_REG_VALUE ;
                    rs2_data_o = `RST_REG_VALUE ;
                    imm_o      = `RST_IMM_VALUE ;
                end
            endcase
        end
        default: begin
            // 其他类型指令的处理（如果有的话）
            rs1_addr_o = `RST_REG       ;
            rs2_addr_o = `RST_REG       ;
            rd_addr_o  = `RST_REG       ;
            rs1_data_o = `RST_REG_VALUE ;
            rs2_data_o = `RST_REG_VALUE ;
            imm_o      = `RST_IMM_VALUE ;
        end
    endcase
end

endmodule