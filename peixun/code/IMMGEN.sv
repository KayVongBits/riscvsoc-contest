`include "tempdefine.sv" 

module IMMGEN(
    input logic [31:0] inst ,
    output logic [31:0] imm 
); 

    logic [6:0] opcode;
    assign opcode = inst[6:0];

    always_comb begin
        imm = 32'b0; 
        
        unique case (opcode)
            // I-Type: Load, JALR, 立即数算术逻辑指令
            `I_LOAD, `I_JALR, `I_ARI_LOG: begin 
                imm = {{20{inst[31]}}, inst[31:20]};
            end
            // S-Type: Store
            `S_STORE: begin 
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            end
            // B-Type: Branch
            `B_BRANCH: begin 
                imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            end
            // U-Type: LUI, AUIPC
            `U_LUI, `U_AUIPC: begin 
                imm = {inst[31:12], 12'b0};
            end
            // J-Type: JAL
            `J_JAL: begin 
                imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
            end
            default: imm = 32'b0;
        endcase
    end

endmodule