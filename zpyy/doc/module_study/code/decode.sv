`include "define.sv"
`include "rv32i_pkg.sv"

module decode(
    input   logic   [`DATA_WIDTH-1:0]       inst_i          ,

    output  logic   [`REG_ADDR_WIDTH-1:0]   rs1_addr_o      ,
    output  logic   [`REG_ADDR_WIDTH-1:0]   rs2_addr_o      ,
    output  logic   [`REG_ADDR_WIDTH-1:0]   rd_addr_o       ,

    input   logic   [`DATA_WIDTH-1:0]       rs1_data_i      ,
    input   logic   [`DATA_WIDTH-1:0]       rs2_data_i      ,

    output  logic   [`DATA_WIDTH-1:0]       rs1_data_o      ,
    output  logic   [`DATA_WIDTH-1:0]       rs2_data_o      ,
    output  logic   [`DATA_WIDTH-1:0]       imm_o           ,

    output  logic                           alu_src1_sel_o  ,           
    output  logic                           alu_src2_sel_o  ,

    output  logic                           ecall_en_o          // 异常信号，用于通知流水线                
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
assign inst_s       = Inst_s'(inst_i)           ; // 将指令的全部32位赋值给结构体
assign inst_u_type  = Inst_U_Type_s'(inst_i)    ;
assign inst_j_type  = Inst_J_Type_s'(inst_i)    ;
assign inst_r_type  = Inst_R_Type_s'(inst_i)    ;
assign inst_i_type  = Inst_I_Type_s'(inst_i)    ;
assign inst_b_type  = Inst_B_Type_s'(inst_i)    ;
assign inst_s_type  = Inst_S_Type_s'(inst_i)    ;

// comb logic
always_comb begin
    rs1_addr_o      = `RST_REG              ;
    rs2_addr_o      = `RST_REG              ;
    rd_addr_o       = `RST_REG              ;
    rs1_data_o      = `RST_REG_VALUE        ;
    rs2_data_o      = `RST_REG_VALUE        ;
    imm_o           = `RST_IMM_VALUE        ;
    alu_src1_sel_o  = `ALU_OP1_SEL_RS1      ;
    alu_src2_sel_o  = `ALU_OP2_SEL_RS2      ;
    ecall_en_o      = `RST_ECALL_DISABLE    ;
    unique case ( inst_s.opcode )
        U_LUI : begin                                           // rd = imm << 12 , 低位补0
            rs1_addr_o      = `RST_REG                          ;
            rs1_data_o      = `RST_REG_VALUE                    ;
            rs2_addr_o      = `RST_REG                          ;
            rs2_data_o      = `RST_REG_VALUE                    ;
            rd_addr_o       = inst_u_type.rd                    ;
            imm_o           = {inst_u_type.imm[31:12], 12'h0}   ;
            alu_src2_sel_o  = `ALU_OP2_SEL_IMM                  ;
        end
        U_AUIPC : begin                                         // rd = pc + imm << 12
            rs1_addr_o      = `RST_REG                          ;
            rs1_data_o      = `RST_REG_VALUE                    ;
            rs2_addr_o      = `RST_REG                          ;
            rs2_data_o      = `RST_REG_VALUE                    ;
            rd_addr_o       = inst_u_type.rd                    ;
            imm_o           = {inst_u_type.imm[31:12], 12'h0}   ;
            alu_src1_sel_o  = `ALU_OP1_SEL_PC                   ;
            alu_src2_sel_o  = `ALU_OP2_SEL_IMM                  ;
        end
        J_JAL: begin
            rs1_addr_o      = `RST_REG                          ;
            rs1_data_o      = `RST_REG_VALUE                    ;
            rs2_addr_o      = `RST_REG                          ;
            rs2_data_o      = `RST_REG_VALUE                    ;
            rd_addr_o       = inst_j_type.rd                    ;
            imm_o           = {{12{inst_j_type.imm_0}}, inst_j_type.imm_1, inst_j_type.imm_2, inst_j_type.imm_3, 1'b0}   ;
            alu_src1_sel_o  = `ALU_OP1_SEL_PC                   ;
            alu_src2_sel_o  = `ALU_OP2_SEL_IMM                  ;
        end
        R_ARI_LOG: begin
            rs1_addr_o      = inst_r_type.rs1                   ;
            rs2_addr_o      = inst_r_type.rs2                   ;
            rs1_data_o      = rs1_data_i                        ;
            rs2_data_o      = rs2_data_i                        ;
            rd_addr_o       = inst_r_type.rd                    ;
            imm_o           = `RST_IMM_VALUE                    ;
        end
        B_BRANCH: begin
            rs1_addr_o      = inst_b_type.rs1                   ;
            rs2_addr_o      = inst_b_type.rs2                   ;
            rs1_data_o      = rs1_data_i                        ;
            rs2_data_o      = rs2_data_i                        ;
            rd_addr_o       = `RST_REG                          ;
            imm_o           = {{20{inst_b_type.imm_0}}, inst_b_type.imm_1, inst_b_type.imm_2, inst_b_type.imm_3, 1'b0}   ;
        end
        S_SAVE: begin
            rs1_addr_o      = inst_s_type.rs1                   ;
            rs2_addr_o      = inst_s_type.rs2                   ;
            rs1_data_o      = rs1_data_i                        ;
            rs2_data_o      = rs2_data_i                        ;
            rd_addr_o       = `RST_REG                          ;
            imm_o           = {{20{inst_s_type.imm_0[11]}}, inst_s_type.imm_0, inst_s_type.imm_1}  ;
            alu_src2_sel_o  = `ALU_OP2_SEL_IMM                  ;
        end
        I_JALR, I_LOAD, I_ARI_LOG : begin
            rs1_addr_o      = inst_i_type.rs1                   ;
            rs1_data_o      = rs1_data_i                        ;
            rs2_addr_o      = `RST_REG                          ;   // I型指令没有rs2
            rs2_data_o      = `RST_REG_VALUE                    ;   // 立即数符号扩展
            imm_o           = {{20{inst_i_type.imm[11]}}, inst_i_type.imm};
            rd_addr_o       = inst_i_type.rd                    ;
            alu_src2_sel_o  = `ALU_OP2_SEL_IMM                  ;       
        end
        I_SYSTEM: begin                                         // 处理系统调用和CSR指令
            case (inst_i_type.funct3)   
                I_TYPE_ADDI_LB_JALR_FENCE_ECALL_EBREAK : begin
                    // 不写也不读，处理系统调用以及断电
                    rs1_addr_o      = `RST_REG                  ;
                    rs2_addr_o      = `RST_REG                  ;
                    rs1_data_o      = `RST_REG_VALUE            ;
                    rs2_data_o      = `RST_REG_VALUE            ;
                    rd_addr_o       = `RST_REG                  ;
                    imm_o           = `RST_IMM_VALUE            ;
                    ecall_en_o      = inst_i_type.imm[0]        ;   // 为1是EBREAK,0是ECALL      
                end
                I_TYPE_SLLI_LH_FENCEI_CSRRW, I_TYPE_SLTI_LW_CSRRS, I_TYPE_SLTIU_CSRRC : begin
                    rs1_addr_o      = inst_i_type.rs1           ;
                    rs1_data_o      = rs1_data_i                ;
                    rs2_addr_o      = `RST_REG                  ;
                    rs2_data_o      = `RST_REG_VALUE            ;
                    rd_addr_o       = inst_i_type.rd            ;
                    imm_o           = {20'd0, inst_i_type.imm}  ;
                    alu_src2_sel_o  = `ALU_OP2_SEL_IMM          ;
                end
                I_TYPE_SRLI_SRAI_LHU_CSRRWI, I_TYPE_ORI_CSRRSI, I_TYPE_ANDI_CSRRCI : begin
                    rs1_addr_o      = `RST_REG                  ;
                    rs1_data_o      = {27'd0, inst_i_type.rs1}  ;
                    rs2_addr_o      = `RST_REG                  ;
                    rs2_data_o      = `RST_REG_VALUE            ;
                    rd_addr_o       = inst_i_type.rd            ;
                    imm_o           = {20'd0, inst_i_type.imm}  ;
                    alu_src2_sel_o  = `ALU_OP2_SEL_IMM          ;
                end
            endcase
        end
        I_FENCE: begin                                  // 保持默认
        end
        default: begin
        end
    endcase
end

endmodule