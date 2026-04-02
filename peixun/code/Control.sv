`include "tempdefine.sv"
module Control(
    input logic [6:0] opcode ,
    output logic [1:0] NpcOp ,
    output logic [1:0] Mem2Reg ,
    output logic MemWrite ,
    output logic OffsetOrigin ,
    output logic ALUSrc ,
    output logic RegWrite 
);

always_comb begin
    // 初始化默认值，防止锁存器
    NpcOp = `NPCOP_ADD4 ;
    Mem2Reg = `Mem2Reg_PCADD4 ;
    MemWrite = `MemWrite_Dis ;
    OffsetOrigin = `Offset_Imm ; // 默认 0 代表来自 Immediate
    ALUSrc = `ALUSrc_RS2Data ;
    RegWrite = `RegWrite_Dis ;

    unique case (opcode)
        `U_LUI : begin
            Mem2Reg = `Mem2Reg_IMM ;
            RegWrite = `RegWrite_En ;
        end
        `U_AUIPC : begin
            Mem2Reg = `Mem2Reg_ALURES ;
            ALUSrc = `ALUSrc_IMM ;
            RegWrite = `RegWrite_En ;
        end
        `J_JAL : begin
            NpcOp = `NPCOP_JAL ;
            Mem2Reg = `Mem2Reg_PCADD4 ;
            OffsetOrigin = `Offset_Imm ; // JAL 偏移来自立即数
            RegWrite = `RegWrite_En ;
        end
        `R_ARI_LOG : begin
            Mem2Reg = `Mem2Reg_ALURES ;
            ALUSrc = `ALUSrc_RS2Data ;
            RegWrite = `RegWrite_En ;
        end
        `B_BRANCH : begin
            NpcOp = `NPCOP_BRANCH ;
            ALUSrc = `ALUSrc_RS2Data ;
            OffsetOrigin = `Offset_Imm ; // Branch 偏移来自立即数
        end
        `S_STORE : begin
            MemWrite = `MemWrite_En ;
            ALUSrc = `ALUSrc_IMM ;
        end
        `I_JALR : begin
            NpcOp = `NPCOP_JALR ;
            Mem2Reg = `Mem2Reg_PCADD4 ;
            ALUSrc = `ALUSrc_IMM ;
            OffsetOrigin = `Offset_ALURES ; // JALR 偏移地址来自 ALU 计算结果 (rs1 + imm)
            RegWrite = `RegWrite_En ;
        end   
        `I_LOAD : begin
            Mem2Reg = `Mem2Reg_RAMDATA ;
            ALUSrc = `ALUSrc_IMM ;
            RegWrite = `RegWrite_En ;
        end   
        `I_ARI_LOG : begin
            Mem2Reg = `Mem2Reg_ALURES ;
            ALUSrc = `ALUSrc_IMM ;
            RegWrite = `RegWrite_En ;
        end 
        default: ; 
    endcase
end

endmodule