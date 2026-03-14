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
    output  logic   [`DATA_WIDTH-1:0]       rs2_data_o
);

import rv32i_pkg::*;

Inst_s        inst_s     ;
Inst_R_Type_s inst_r_type;
Inst_I_Type_s inst_i_type;
Inst_S_Type_s inst_s_type;
Inst_B_Type_s inst_b_type;
Inst_U_Type_s inst_u_type;
Inst_J_Type_s inst_j_type;

// 根据opcode字段判断是哪个指令类型，并将指令的各个字段赋值给对应的结构体
assign inst_s = Inst_s'(inst_i); // 将指令的全部32位赋值给结构体

// comb logic
always_comb begin
    unique case ( inst_s.Opcode )
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
        I_JALR, I_LOAD, I_ARI_LOG, I_FENCE, I_ECALL: begin
            inst_i_type = Inst_I_Type_s'(inst_i) ; // 处理I型指令
        end
    endcase
end


endmodule