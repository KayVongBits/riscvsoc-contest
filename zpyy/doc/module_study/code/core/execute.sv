`include "../define/define.sv"
`include "../define/rv32i_pkg.sv"     // 实际上板子注释掉
module execute import rv32i_pkg::*;(
    input   var     Id2Ex_Bus_s         id2ex_bus_i     ,
    output  var     Ex2Mem_Bus_s        ex2mem_bus_o    ,
    output  logic                       jump_en_o       ,
    output  logic   [`DATA_WIDTH-1:0]   jump_addr_o     
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
assign inst_s       = Inst_s'(id2ex_bus_i.inst)           ;   // 将指令的全部32位赋值给结构体
assign inst_u_type  = Inst_U_Type_s'(id2ex_bus_i.inst)    ;
assign inst_j_type  = Inst_J_Type_s'(id2ex_bus_i.inst)    ;
assign inst_r_type  = Inst_R_Type_s'(id2ex_bus_i.inst)    ;
assign inst_i_type  = Inst_I_Type_s'(id2ex_bus_i.inst)    ;
assign inst_b_type  = Inst_B_Type_s'(id2ex_bus_i.inst)    ;
assign inst_s_type  = Inst_S_Type_s'(id2ex_bus_i.inst)    ;

// 根据指令类型，计算alu_op1和alu_op2
assign alu_op1 = ( id2ex_bus_i.ex_ctrl.alu_src1_sel == `ALU_OP1_SEL_RS1 ) ? id2ex_bus_i.rs1_data : id2ex_bus_i.inst_addr    ;
assign alu_op2 = ( id2ex_bus_i.ex_ctrl.alu_src2_sel == `ALU_OP2_SEL_RS2 ) ? id2ex_bus_i.rs2_data : id2ex_bus_i.imm          ;

always_comb begin
    ex2mem_bus_o.mem_ctrl = id2ex_bus_i.mem_ctrl;
    ex2mem_bus_o.wb_ctrl  = id2ex_bus_i.wb_ctrl ;
    ex2mem_bus_o.rd_addr  = id2ex_bus_i.rd_addr ;
    ex2mem_bus_o.rs2_data = id2ex_bus_i.rs2_data;
    ex2mem_bus_o.alu_res  = `RST_REG_VALUE      ;
    jump_en_o             = `JUMP_DISABLE       ;
    jump_addr_o           = `JUMP_RST_ADDR      ;

    unique case (inst_s.opcode) 
        U_LUI : begin
            ex2mem_bus_o.alu_res = alu_op2                      ;
        end
        U_AUIPC : begin
            ex2mem_bus_o.alu_res = alu_op1 + alu_op2            ;
        end
        J_JAL : begin
            ex2mem_bus_o.alu_res    = alu_op1 + `PC_STEP       ;
            jump_en_o               = `JUMP_ENABLE             ;
            jump_addr_o             = alu_op1 + alu_op2        ;
        end
        R_ARI_LOG : begin
            unique case (inst_r_type.funct7)
                R_TYPE_BASE :begin
                    unique case (inst_r_type.funct3)
                        R_TYPE_000 : begin
                            ex2mem_bus_o.alu_res = alu_op1 + alu_op2           ;
                        end
                        R_TYPE_001 : begin
                            ex2mem_bus_o.alu_res = alu_op1 << alu_op2[4:0]     ;
                        end   
                        R_TYPE_010 : begin
                            ex2mem_bus_o.alu_res = ($signed(alu_op1) < $signed(alu_op2)) ? `COMPARE_TRUE : `COMPARE_FALSE     ;
                        end   
                        R_TYPE_011 : begin
                            ex2mem_bus_o.alu_res = ($unsigned(alu_op1) < $unsigned(alu_op2)) ? `COMPARE_TRUE : `COMPARE_FALSE ;
                        end  
                        R_TYPE_100 : begin
                            ex2mem_bus_o.alu_res = alu_op1 ^ alu_op2           ;
                        end     
                        R_TYPE_101 : begin
                            ex2mem_bus_o.alu_res = $unsigned(alu_op1) >> alu_op2[4:0]      ;
                        end
                        R_TYPE_110 : begin
                            ex2mem_bus_o.alu_res = alu_op1 | alu_op2           ;
                        end    
                        R_TYPE_111 : begin
                            ex2mem_bus_o.alu_res = alu_op1 & alu_op2           ;
                        end 
                        default : begin                           
                        end   
                    endcase
                end
                R_TYPE_ALT : begin
                    unique case (inst_r_type.funct3)
                        R_TYPE_000 : begin
                            ex2mem_bus_o.alu_res = alu_op1 - alu_op2           ;
                        end 
                        R_TYPE_101 : begin
                            ex2mem_bus_o.alu_res = $signed(alu_op1) >>> alu_op2[4:0]       ;
                        end
                        default : begin                           
                        end   
                    endcase
                end
                default : begin end
            endcase
        end
        B_BRANCH : begin
            jump_addr_o = id2ex_bus_i.inst_addr + id2ex_bus_i.imm ;
            case (inst_b_type.funct3)
                B_TYPE_BEQ : begin
                    jump_en_o = (alu_op1 == alu_op2) ? `JUMP_ENABLE : `JUMP_DISABLE                               ;
                end
                B_TYPE_BNE : begin
                    jump_en_o = (alu_op1 != alu_op2) ? `JUMP_ENABLE : `JUMP_DISABLE                               ;
                end
                B_TYPE_BLT : begin
                    jump_en_o = ($signed(alu_op1) < $signed(alu_op2)) ? `JUMP_ENABLE : `JUMP_DISABLE              ;
                end
                B_TYPE_BGE : begin
                    jump_en_o = ($signed(alu_op1) >= $signed(alu_op2)) ? `JUMP_ENABLE : `JUMP_DISABLE             ;
                end
                B_TYPE_BLTU : begin
                    jump_en_o = ($unsigned(alu_op1) < $unsigned(alu_op2)) ? `JUMP_ENABLE : `JUMP_DISABLE          ;
                end
                B_TYPE_BGEU : begin
                    jump_en_o = ($unsigned(alu_op1) >= $unsigned(alu_op2)) ? `JUMP_ENABLE : `JUMP_DISABLE         ;
                end
                default : begin end
            endcase
        end
        S_STORE : begin
            ex2mem_bus_o.mem_ctrl.ram_wr_mask   = Ram_Wr_Mask_e'{`RAM_WR_DISABLE}   ;
            ex2mem_bus_o.rs2_data               = `RAM_RST_DATA;
            ex2mem_bus_o.alu_res                = alu_op1 + alu_op2                 ;
            unique case (inst_s_type.funct3)
                S_TYPE_SB : begin
                    unique case (ex2mem_bus_o.alu_res[1:0])
                        2'b00 : begin
                            ex2mem_bus_o.rs2_data[7:0]          = id2ex_bus_i.rs2_data[7:0] ;
                            ex2mem_bus_o.mem_ctrl.ram_wr_mask   = RAM_WR_B_1                ;  
                        end
                        2'b01 : begin
                            ex2mem_bus_o.rs2_data[15:8]         = id2ex_bus_i.rs2_data[7:0] ;
                            ex2mem_bus_o.mem_ctrl.ram_wr_mask   = RAM_WR_B_2                ;  
                        end
                        2'b10 : begin
                            ex2mem_bus_o.rs2_data[23:16]        = id2ex_bus_i.rs2_data[7:0] ;
                            ex2mem_bus_o.mem_ctrl.ram_wr_mask   = RAM_WR_B_3                ;  
                        end
                        default : begin
                            ex2mem_bus_o.rs2_data[31:24]        = id2ex_bus_i.rs2_data[7:0] ;
                            ex2mem_bus_o.mem_ctrl.ram_wr_mask   = RAM_WR_B_4                ;  
                        end
                    endcase
                end
                S_TYPE_SH : begin
                    unique case (ex2mem_bus_o.alu_res[1])
                        1'b0 : begin
                            ex2mem_bus_o.rs2_data[15:0]         = id2ex_bus_i.rs2_data[15:0]    ;
                            ex2mem_bus_o.mem_ctrl.ram_wr_mask   = RAM_WR_HW_1                   ;  
                        end
                        default : begin
                            ex2mem_bus_o.rs2_data[31:16]        = id2ex_bus_i.rs2_data[15:0]    ;
                            ex2mem_bus_o.mem_ctrl.ram_wr_mask   = RAM_WR_HW_2                   ;
                        end
                    endcase
                end
                S_TYPE_SW : begin
                    ex2mem_bus_o.rs2_data               = id2ex_bus_i.rs2_data  ;
                    ex2mem_bus_o.mem_ctrl.ram_wr_mask   = RAM_WR_W              ;
                end
                default : begin end
            endcase
        end
        I_JALR : begin
            ex2mem_bus_o.alu_res    = id2ex_bus_i.inst_addr + `PC_STEP          ;
            jump_en_o               = `JUMP_ENABLE                              ;
            jump_addr_o             = (alu_op1 + alu_op2) & `BIT0_CLEAR_MASK    ;
        end
        I_LOAD : begin
            ex2mem_bus_o.alu_res = alu_op1 + alu_op2    ;
        end
        I_ARI_LOG : begin
            unique case (inst_i_type.funct3)
                I_TYPE_000 : begin
                    ex2mem_bus_o.alu_res = alu_op1 + alu_op2           ;
                end
                I_TYPE_001 : begin
                    ex2mem_bus_o.alu_res = alu_op1 << alu_op2[4:0]     ;
                end   
                I_TYPE_010 : begin
                    ex2mem_bus_o.alu_res = ($signed(alu_op1) < $signed(alu_op2)) ? `COMPARE_TRUE : `COMPARE_FALSE     ;
                end   
                I_TYPE_011 : begin
                    ex2mem_bus_o.alu_res = ($unsigned(alu_op1) < $unsigned(alu_op2)) ? `COMPARE_TRUE : `COMPARE_FALSE ;
                end  
                I_TYPE_100 : begin
                    ex2mem_bus_o.alu_res = alu_op1 ^ alu_op2           ;
                end     
                I_TYPE_101 : begin
                    if (id2ex_bus_i.imm[10] == `SEL_SRAI) begin
                        ex2mem_bus_o.alu_res = $signed(alu_op1) >>> alu_op2[4:0]        ;
                    end else begin
                        ex2mem_bus_o.alu_res = $unsigned(alu_op1) >> alu_op2[4:0]       ;
                    end
                end
                I_TYPE_110 : begin
                    ex2mem_bus_o.alu_res = alu_op1 | alu_op2           ;
                end    
                I_TYPE_111 : begin
                    ex2mem_bus_o.alu_res = alu_op1 & alu_op2           ;
                end 
                default : begin                           
                end   
            endcase
        end
        default : begin end
    endcase
end

endmodule