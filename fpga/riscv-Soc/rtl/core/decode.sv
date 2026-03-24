`include "defines.sv"

module decode #(
    parameter DW = 32
) (
    input logic [DW-1:0] instr_in,

    //to reg
    output logic [4:0] rd_rs1_addr,
    output logic [4:0] rd_rs2_addr,
    //output logic [4:0] wr_rd_addr,

    //from reg
    input logic [DW-1:0] rd_rs1_data,
    input logic [DW-1:0] rd_rs2_data,

    //to execute
    output logic [DW-1:0] op1_out,
    output logic [DW-1:0] op2_out
);
    
    logic [6:0] opcode;
    logic [4:0] rd;
    logic [2:0] func3;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [6:0] func7;
    logic [31:0] imm;

    assign opcode = instr_in[6:0];
    assign rd     = instr_in[11:7];
    assign func3  = instr_in[14:12];
    assign rs1    = instr_in[19:15];
    assign rs2    = instr_in[24:20];
    assign func7  = instr_in[31:25];
    //assign imm    = instr_in[31:20];


    always_comb begin : imm_gen
        case (opcode)
            `INST_TYPE_I,`INST_TYPE_L,`INST_JALR: begin
                imm = {{20{instr_in[31]}}, instr_in[31:20]}; // I-Type 立即数
            end 
            `INST_TYPE_S: begin
                imm = {{20{instr_in[31]}}, instr_in[31:25], instr_in[11:7]}; // S-Type 立即数
            end
            `INST_TYPE_B: begin
                imm = {{20{instr_in[31]}}, instr_in[31], instr_in[7], instr_in[30:25], instr_in[11:8], 1'b0}; // B-Type 立即数
            end
            `INST_JAL: begin
                imm = {{12{instr_in[31]}}, instr_in[31], instr_in[19:12], instr_in[20], instr_in[30:21], 1'b0}; // J-Type 立即数
            end
            `INST_LUI,`INST_AUIPC: begin
                imm = {instr_in[31:12], 12'b0}; // U-Type 立即数
            end
            default: imm = 32'b0; // 默认值
        endcase
    end




    always_comb begin : decode_logic
        case (opcode)
            `INST_TYPE_I: begin
                case (func3)
                    `INST_ADD_SUB: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = 5'b0;
                        op1_out     = rd_rs1_data;
                        op2_out     = imm;
                    end
                    `INST_AND: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = 5'b0;
                        op1_out     = rd_rs1_data;
                        op2_out     = imm;
                    end
                    `INST_XOR: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = 5'b0;
                        op1_out     = rd_rs1_data;
                        op2_out     = imm;
                    end
                    `INST_OR: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = 5'b0;
                        op1_out     = rd_rs1_data;
                        op2_out     = imm;
                    end
                    `INST_SLL: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = 5'b0;
                        op1_out     = rd_rs1_data;
                        op2_out     = imm; // SLLI 的移位量只取立即数的低5位
                    end
                    `INST_SRL_SRA: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = 5'b0;
                        op1_out     = rd_rs1_data;
                        op2_out     = imm; // SRLI/SRAI 的移位量只取立即数的低5位
                    end
                    `INST_SLT: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = 5'b0;
                        op1_out     = rd_rs1_data;
                        op2_out     = imm;
                    end
                    `INST_SLTU: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = 5'b0;
                        op1_out     = rd_rs1_data;
                        op2_out     = imm;
                    end
                    default: begin
                        rd_rs1_addr = 5'b0;
                        rd_rs2_addr = 5'b0;
                        op1_out     = 32'b0;
                        op2_out     = 32'b0;
                    end
                endcase
            end
            `INST_TYPE_R_M:begin
                case (func3)
                    `INST_ADD_SUB: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = rs2;
                        op1_out     = rd_rs1_data;
                        op2_out     = rd_rs2_data;
                    end
                    `INST_AND: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = rs2;
                        op1_out     = rd_rs1_data;
                        op2_out     = rd_rs2_data;
                    end
                    `INST_XOR: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = rs2;
                        op1_out     = rd_rs1_data;
                        op2_out     = rd_rs2_data;
                    end
                    `INST_OR: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = rs2;
                        op1_out     = rd_rs1_data;
                        op2_out     = rd_rs2_data;
                    end
                    `INST_SLL: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = rs2;
                        op1_out     = rd_rs1_data;
                        op2_out     = rd_rs2_data; // SLL 的移位量只取 rs2 的低5位
                    end
                    `INST_SRL_SRA: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = rs2;
                        op1_out     = rd_rs1_data;
                        op2_out     = rd_rs2_data; // SRL/SRA 的移位量只取 rs2 的低5位
                    end
                    `INST_SLT: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = rs2;
                        op1_out     = rd_rs1_data;
                        op2_out     = rd_rs2_data;
                    end
                    `INST_SLTU: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = rs2;
                        op1_out     = rd_rs1_data;
                        op2_out     = rd_rs2_data;
                    end
                     `INST_MUL: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = rs2;
                        op1_out     = rd_rs1_data;
                        op2_out     = rd_rs2_data;
                    end
                    default: begin
                        rd_rs1_addr = 5'b0;
                        rd_rs2_addr = 5'b0;
                        op1_out     = 32'b0;
                        op2_out     = 32'b0;
                    end
                endcase
            end
            `INST_TYPE_B:begin
                case (func3)
                    `INST_BNE: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = rs2;
                        op1_out     = rd_rs1_data;
                        op2_out     = rd_rs2_data;
                    end
                    `INST_BEQ: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = rs2;
                        op1_out     = rd_rs1_data;
                        op2_out     = rd_rs2_data;
                    end
                    `INST_BLT: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = rs2;
                        op1_out     = rd_rs1_data;
                        op2_out     = rd_rs2_data;
                    end
                    `INST_BGE: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = rs2;
                        op1_out     = rd_rs1_data;
                        op2_out     = rd_rs2_data;
                    end
                    `INST_BLTU: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = rs2;
                        op1_out     = rd_rs1_data;
                        op2_out     = rd_rs2_data;
                    end
                    `INST_BGEU: begin
                        rd_rs1_addr = rs1;
                        rd_rs2_addr = rs2;
                        op1_out     = rd_rs1_data;
                        op2_out     = rd_rs2_data;
                    end
                    default: begin
                        rd_rs1_addr = 5'b0;
                        rd_rs2_addr = 5'b0;
                        op1_out     = 32'b0;
                        op2_out     = 32'b0;
                    end
                endcase
            end
            `INST_JAL: begin
                rd_rs1_addr = 5'b0;
                rd_rs2_addr = 5'b0;
                op1_out     = 32'b0;
                op2_out     = imm;
            end
            `INST_JALR: begin
                rd_rs1_addr = rs1;
                rd_rs2_addr = 5'b0;
                op1_out     = rd_rs1_data;
                op2_out     = imm;
            end
            `INST_LUI: begin
                rd_rs1_addr = 5'b0;
                rd_rs2_addr = 5'b0;
                op1_out     = 32'b0;
                op2_out     = imm;
            end
            `INST_AUIPC: begin
                rd_rs1_addr = 5'b0;
                rd_rs2_addr = 5'b0;
                op1_out     = 32'b0;
                op2_out     = imm;
            end
            `INST_NOP_OP: begin
                rd_rs1_addr = 5'b0;
                rd_rs2_addr = 5'b0;
                op1_out     = 32'b0;
                op2_out     = 32'b0;
            end
            default: begin
                rd_rs1_addr = 5'b0;
                rd_rs2_addr = 5'b0;
                op1_out     = 32'b0;
                op2_out     = 32'b0;
            end
        endcase
    end

endmodule