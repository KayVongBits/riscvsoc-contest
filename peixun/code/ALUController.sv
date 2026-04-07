`include "tempdefine.sv"

module ALUController(
    input logic [6:0] opcode ,
    input logic [2:0] func3  ,
    input logic       func7  ,
    output logic [3:0] AlUControl 
);

/*
    ALUCtrol 
    0000 add
    0001 sub
    0010 &
    0011 |
    0100 ^
    0101 shiftl
    0110 shiftr_logic
    0111 shiftr_ari
    1000 eq
    1001 not eq
    1010 <
    1011 >=
*/


    always_comb begin
        // 默认执行加法
        AlUControl = `ALU_ADD; 

        unique case (opcode)
            `R_ARI_LOG: begin
                case (func3)
                    `Funct3_000: AlUControl = (func7 == `Funct7_1) ? `ALU_SUB : `ALU_ADD; // sub : add
                    `Funct3_001: AlUControl = `ALU_SL; // shiftl
                    `Funct3_010: AlUControl = `ALU_LOW; // < (slt)
                    `Funct3_011: AlUControl = `ALU_LOW; // < (sltu)
                    `Funct3_100: AlUControl = `ALU_XOR; // ^ (xor)
                    `Funct3_101: AlUControl = (func7 == `Funct7_1) ? `ALU_SRA : `ALU_SRL; // shiftr_ari : shiftr_logic
                    `Funct3_110: AlUControl = `ALU_OR; // | (or)
                    `Funct3_111: AlUControl = `ALU_AND; // & (and)
                endcase
            end

            `I_ARI_LOG: begin
                case (func3)
                    `Funct3_000: AlUControl = `ALU_ADD; // add
                    `Funct3_001: AlUControl = `ALU_SL; // shiftl
                    `Funct3_010: AlUControl = `ALU_LOW; // < (slti)
                    `Funct3_011: AlUControl = `ALU_LOW; // < (sltiu)
                    `Funct3_100: AlUControl = `ALU_XOR; // ^ (xori)
                    `Funct3_101: AlUControl = (func7 == `Funct7_1) ? `ALU_SRA : `ALU_SRL; // shiftr_ari : shiftr_logic
                    `Funct3_110: AlUControl = `ALU_OR; // | (ori)
                    `Funct3_111: AlUControl = `ALU_AND; // & (andi)
                endcase
            end

            `B_BRANCH: begin
                case (func3)
                    `Funct3_000: AlUControl = `ALU_EQ;    // beq  -> eq
                    `Funct3_001: AlUControl = `ALU_NEQ;   // bne  -> not eq
                    `Funct3_100: AlUControl = `ALU_LOW;   // blt  -> <
                    `Funct3_101: AlUControl = `ALU_UPPER; // bge  -> >=
                    `Funct3_110: AlUControl = `ALU_LOW;   // bltu -> <
                    `Funct3_111: AlUControl = `ALU_UPPER; // bgeu -> >=
                    default: AlUControl = `ALU_EQ;
                endcase
            end

            // Load, Store, AUIPC, JALR 的地址计算均使用加法
            `I_LOAD, `S_STORE, `U_AUIPC, `I_JALR: begin
                AlUControl = `ALU_ADD;
            end
            
            default: AlUControl = `ALU_ADD;
        endcase
    end
endmodule