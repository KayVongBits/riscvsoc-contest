`include "F:/work/jingyeda/jingyeda/zpyy/code/define/define.sv"
`include "F:/work/jingyeda/jingyeda/zpyy/code/define/rv32i_pkg.sv"


module decode import rv32i_pkg::*;(
    input   logic           [`ADD_WIDTH-1:0]        inst_addr_i     ,
    input   logic           [`DATA_WIDTH-1:0]       inst_i          ,
    input   logic           [`DATA_WIDTH-1:0]       rs1_data_i      ,
    input   logic           [`DATA_WIDTH-1:0]       rs2_data_i      ,

    output  logic           [`REG_ADDR_WIDTH-1:0]   rs1_addr_o      ,
    output  logic           [`REG_ADDR_WIDTH-1:0]   rs2_addr_o      ,

    output  Id2Ex_Bus_s                             id2ex_bus_o    
);
// logic
logic [`REG_ADDR_WIDTH-1:0] static_rd_addr ;

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

// 静态提取地址
assign rs1_addr_o       = inst_s.inst[19:15]               ;
assign rs2_addr_o       = inst_s.inst[24:20]               ;
assign static_rd_addr   = inst_s.inst[11:7]                ;

// comb logic
always_comb begin
    id2ex_bus_o                         = Id2Ex_Bus_s'(0)   ;
    id2ex_bus_o.inst_addr               = inst_addr_i       ;
    id2ex_bus_o.inst                    = inst_i            ;
    id2ex_bus_o.rd_addr                 = static_rd_addr    ;
    id2ex_bus_o.rs1_data                = rs1_data_i        ;
    id2ex_bus_o.rs2_data                = rs2_data_i        ;
    id2ex_bus_o.ex_ctrl.alu_src1_sel    = `ALU_OP1_SEL_RS1  ;
    id2ex_bus_o.ex_ctrl.alu_src2_sel    = `ALU_OP2_SEL_RS2  ;
    id2ex_bus_o.rs1_addr                = rs1_addr_o        ;
    id2ex_bus_o.rs2_addr                = rs2_addr_o        ;  
    unique case ( inst_s.opcode )
        U_LUI : begin                                           // rd = imm << 12 , 低位补0
            id2ex_bus_o.wb_ctrl.reg_wr_en       = `REG_WR_ENABLE                    ;
            id2ex_bus_o.imm                     = {inst_u_type.imm[31:12], 12'h0}   ;
            id2ex_bus_o.ex_ctrl.alu_src2_sel    = `ALU_OP2_SEL_IMM                  ;
        end
        U_AUIPC : begin                                         // rd = pc + imm << 12
            id2ex_bus_o.imm                     = {inst_u_type.imm[31:12], 12'h0}   ;
            id2ex_bus_o.ex_ctrl.alu_src1_sel    = `ALU_OP1_SEL_PC                   ;
            id2ex_bus_o.ex_ctrl.alu_src2_sel    = `ALU_OP2_SEL_IMM                  ;
            id2ex_bus_o.wb_ctrl.reg_wr_en       = `REG_WR_ENABLE                    ;
        end
        J_JAL: begin
            id2ex_bus_o.imm                     = {{12{inst_j_type.imm_0}}, inst_j_type.imm_1, inst_j_type.imm_2, inst_j_type.imm_3, 1'b0}   ;
            id2ex_bus_o.ex_ctrl.alu_src1_sel    = `ALU_OP1_SEL_PC                   ;
            id2ex_bus_o.ex_ctrl.alu_src2_sel    = `ALU_OP2_SEL_IMM                  ;
            id2ex_bus_o.wb_ctrl.reg_wr_en       = `REG_WR_ENABLE                    ;
        end
        R_ARI_LOG: begin
            id2ex_bus_o.wb_ctrl.reg_wr_en       = `REG_WR_ENABLE                    ;
        end
        B_BRANCH: begin
            id2ex_bus_o.imm                     = {{20{inst_b_type.imm_0}}, inst_b_type.imm_1, inst_b_type.imm_2, inst_b_type.imm_3, 1'b0}   ;
        end
        S_STORE: begin
            id2ex_bus_o.imm                     = {{20{inst_s_type.imm_0[11]}}, inst_s_type.imm_0, inst_s_type.imm_1}  ;
            id2ex_bus_o.ex_ctrl.alu_src2_sel    = `ALU_OP2_SEL_IMM                      ;                      ;
            id2ex_bus_o.mem_ctrl.ram_wr_mask    = Ram_Wr_Mask_e'(inst_s_type.funct3)    ;
        end
        I_JALR, I_LOAD, I_ARI_LOG : begin
            id2ex_bus_o.imm                     = {{20{inst_i_type.imm[11]}}, inst_i_type.imm}  ;
            id2ex_bus_o.ex_ctrl.alu_src2_sel    = `ALU_OP2_SEL_IMM                              ;
            id2ex_bus_o.wb_ctrl.reg_wr_en       = `REG_WR_ENABLE                                ;
            if (inst_s.opcode == I_LOAD) begin                      
                id2ex_bus_o.mem_ctrl.ram_rd_mode    = Ram_Rd_Mode_e'(inst_i_type.funct3)    ;
            end else begin end
        end
        I_SYSTEM: begin                                         // 处理系统调用和CSR指令
            // case (inst_i_type.funct3)   
                
            // endcase
        end
        I_FENCE: begin                                  // 保持默认
        end
        default: begin
        end
    endcase
end

endmodule