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
    output  logic   [`DATA_WIDTH-1:0]       rd_data_o   
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
assign inst_s       = Inst_s'(inst_i)           ; // 将指令的全部32位赋值给结构体
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
    wr_rd_en_o  = `WR_DISABLE       ;
    rd_addr_o   = `RST_REG          ;
    rd_data_o   = `RST_REG_VALUE    ;
    unique case (inst_s.opcode)
        U_LUI, U_AUIPC : begin
            
        end 
        J_JAL : begin   
            
        end 
        R_ARI_LOG : begin   

        end 
        B_BRANCH : begin    
            
        end 
        S_SAVE : begin  
            
        end
        I_JALR, I_LOAD, I_ARI_LOG,I_FENCE,I_ECALL_CSR : begin
            unique case (inst_i_type.opcode)
                I_ARI_LOG : begin                                       // 算术逻辑比较指令   
                    unique case (inst_i_type.funct3)
                        I_TYPE_ADDI_LB_JALR_FENCE_ECALL_EBREAK : begin  // 立即数加法
                            wr_rd_en_o  = `WR_ENABLE           ;
                            rd_addr_o   = inst_i_type.rd       ;
                            rd_data_o   = alu_op1 + alu_op2    ;
                        end
                        I_TYPE_SLTI_LW_CSRRS : begin                    // 有符号比较
                            wr_rd_en_o  = `WR_ENABLE           ;
                            rd_addr_o   = inst_i_type.rd       ;
                            rd_data_o   = $signed(alu_op1) < $signed(alu_op2) ? `COMPARE_TRUE : `COMPARE_FALSE      ;
                        end
                        I_TYPE_SLTIU_CSRRC : begin                      // 无符号比较
                            wr_rd_en_o  = `WR_ENABLE           ;
                            rd_addr_o   = inst_i_type.rd       ;
                            rd_data_o   = $unsigned(alu_op1) < $unsigned(alu_op2) ? `COMPARE_TRUE : `COMPARE_FALSE  ;
                        end
                        default : begin                           
                        end
                    endcase
                end
                I_LOAD : begin

                end 
                I_JALR : begin

                end
                I_FENCE : begin
                    
                end
                I_ECALL_CSR : begin
                    
                end 
                default : begin
                end   
            endcase
        end 
        default : begin
        end
    endcase
end : execute_comb

endmodule