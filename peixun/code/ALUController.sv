`include "tempdefine.sv"

module ALUController(
    input logic [6:0] opcode ,
    input logic [2:0] func3  ,
    input logic       func7  ,
    output logic [3:0] ALUControl ,
    output logic [1:0]  wram_mode ,
    output logic [2:0]  rram_mode
);

    always_comb begin
        ALUControl = `ALU_ADD;
        wram_mode = `WRAM_NONE;
        rram_mode = `RRAM_NONE;

        unique case (opcode)
            `R_ARI_LOG: begin
                unique case (func3)
                    `Funct3_000: ALUControl = (func7 == `Funct7_1) ? `ALU_SUB : `ALU_ADD;
                    `Funct3_001: ALUControl = `ALU_SL;
                    `Funct3_010: ALUControl = `ALU_LOW;
                    `Funct3_011: ALUControl = `ALU_LOWU;
                    `Funct3_100: ALUControl = `ALU_XOR;
                    `Funct3_101: ALUControl = (func7 == `Funct7_1) ? `ALU_SRA : `ALU_SRL;
                    `Funct3_110: ALUControl = `ALU_OR;
                    `Funct3_111: ALUControl = `ALU_AND;
                    default: ALUControl = `ALU_ADD;
                endcase
            end

            `I_ARI_LOG: begin
                unique case (func3)
                    `Funct3_000: ALUControl = `ALU_ADD;
                    `Funct3_001: ALUControl = `ALU_SL;
                    `Funct3_010: ALUControl = `ALU_LOW;
                    `Funct3_011: ALUControl = `ALU_LOWU;
                    `Funct3_100: ALUControl = `ALU_XOR;
                    `Funct3_101: ALUControl = (func7 == `Funct7_1) ? `ALU_SRA : `ALU_SRL;
                    `Funct3_110: ALUControl = `ALU_OR;
                    `Funct3_111: ALUControl = `ALU_AND;
                    default: ALUControl = `ALU_ADD;
                endcase
            end

            `B_BRANCH: begin
                unique case (func3)
                    `Funct3_000: ALUControl = `ALU_EQ;
                    `Funct3_001: ALUControl = `ALU_NEQ;
                    `Funct3_100: ALUControl = `ALU_LOW;
                    `Funct3_101: ALUControl = `ALU_UPPER;
                    `Funct3_110: ALUControl = `ALU_LOWU;
                    `Funct3_111: ALUControl = `ALU_UPPERU;
                    default: ALUControl = `ALU_EQ;
                endcase
            end

            `S_STORE: begin
                unique case (func3)
                    `Funct3_000: wram_mode = `WRAM_B;
                    `Funct3_001: wram_mode = `WRAM_HW;
                    `Funct3_010: wram_mode = `WRAM_W;
                    default: wram_mode = `WRAM_NONE;
                endcase
            end

            `I_LOAD: begin
                unique case (func3)
                    `Funct3_000: rram_mode = `RRAM_B;
                    `Funct3_001: rram_mode = `RRAM_HW;
                    `Funct3_010: rram_mode = `RRAM_W;
                    `Funct3_100: rram_mode = `RRAM_BU;
                    `Funct3_101: rram_mode = `RRAM_HWU;
                    default: rram_mode = `RRAM_NONE;
                endcase
            end

            default: ALUControl = `ALU_ADD;
        endcase
    end
endmodule
