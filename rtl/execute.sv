`include "defines.sv"
module execute #(
    parameter AW = 32,
    parameter DW = 32
) (
    input   logic clk,
    input   logic rst_n,

    input   logic [AW-1:0]  instr_addr_in,
    input   logic [DW-1:0]  instr_in,
    input   logic [DW-1:0]  op1,
    input   logic [DW-1:0]  op2,

    output  logic           wr_reg_en,
    output  logic [4:0]     wr_reg_addr,
    output  logic [DW-1:0]  wr_reg_data,

    //to ctrl
    output  logic           jump_en,
    output  logic [AW-1:0]  jump_addr,
    output  logic           jump_hold
);
    logic [6:0]     opcode;
    logic [4:0]     rd;
    logic [2:0]     func3;
    logic [6:0]     func7;
    logic [31:0]    imm;
    logic           equal;
    logic [AW-1:0]  jump_imm;

    assign opcode = instr_in[6:0];
    assign rd     = instr_in[11:7];
    assign func3  = instr_in[14:12];
    assign func7  = instr_in[31:25];
    assign imm    = {{{20{instr_in[31]}}},instr_in[7], instr_in[30:25], instr_in[11:8], 1'b0}; // B-Type 立即数
    assign jump_imm = instr_addr_in + imm;
    assign equal = (op1 == op2);


    always_comb begin : execute_logic
        case (opcode)
            `INST_TYPE_I: begin
                case (func3)
                    `INST_ADD_SUB: begin
                        wr_reg_en = 1'b1;
                        wr_reg_addr = rd;
                        wr_reg_data = op1 + op2;
                        jump_en = 1'b0;
                        jump_addr = 32'b0;
                        jump_hold = 1'b0;
                    end
                    `INST_AND: begin
                        wr_reg_en = 1'b1;
                        wr_reg_addr = rd;
                        wr_reg_data = op1 & op2;
                        jump_en = 1'b0;
                        jump_addr = 32'b0;
                        jump_hold = 1'b0;
                    end
                    `INST_XOR: begin
                        wr_reg_en = 1'b1;
                        wr_reg_addr = rd;
                        wr_reg_data = op1 ^ op2;
                        jump_en = 1'b0;
                        jump_addr = 32'b0;
                        jump_hold = 1'b0;
                    end
                    `INST_SLL: begin
                        wr_reg_en = 1'b1;
                        wr_reg_addr = rd;
                        wr_reg_data = op1 << op2[4:0];
                        jump_en = 1'b0;
                        jump_addr = 32'b0;
                        jump_hold = 1'b0;
                    end
                    `INST_OR: begin
                        wr_reg_en = 1'b1;
                        wr_reg_addr = rd;
                        wr_reg_data = op1 | op2;
                        jump_en = 1'b0;
                        jump_addr = 32'b0;
                        jump_hold = 1'b0;
                    end
                    `INST_SRL_SRA: begin
                        if (func7 == `FUNCT7_0) begin
                            wr_reg_en = 1'b1;
                            wr_reg_addr = rd;
                            wr_reg_data = op1 >> op2[4:0];
                            jump_en = 1'b0;
                            jump_addr = 32'b0;
                            jump_hold = 1'b0;
                        end else begin
                            wr_reg_en = 1'b1;
                            wr_reg_addr = rd;
                            wr_reg_data = $signed(op1) >>> op2[4:0];
                            jump_en = 1'b0;
                            jump_addr = 32'b0;
                            jump_hold = 1'b0;
                        end
                    end
                    `INST_SLT: begin
                        wr_reg_en = 1'b1;
                        wr_reg_addr = rd;
                        wr_reg_data = ($signed(op1) < $signed(op2)) ? 32'b1 : 32'b0;
                        jump_en = 1'b0;
                        jump_addr = 32'b0;
                        jump_hold = 1'b0;
                    end
                    `INST_SLTU: begin
                        wr_reg_en = 1'b1;
                        wr_reg_addr = rd;
                        wr_reg_data = (op1 < op2) ? 32'b1 : 32'b0;
                        jump_en = 1'b0;
                        jump_addr = 32'b0;
                        jump_hold = 1'b0;
                    end
                    default: begin
                        wr_reg_en = 0;
                        wr_reg_addr = 5'b0;
                        wr_reg_data = 32'h0;
                        jump_en = 1'b0;
                        jump_addr = 32'b0;
                        jump_hold = 1'b0;
                    end
                endcase
            end
            `INST_TYPE_R_M:begin
                case (func3)
                    `INST_ADD_SUB:begin
                        if (func7 == 7'b0) begin
                            wr_reg_en = 1'b1;
                            wr_reg_addr = rd;
                            wr_reg_data = op1 + op2;
                            jump_en = 1'b0;
                            jump_addr = 32'b0;
                            jump_hold = 1'b0;
                        end else begin
                            wr_reg_en = 1'b1;
                            wr_reg_addr = rd;
                            wr_reg_data = op1 - op2;
                            jump_en = 1'b0;
                            jump_addr = 32'b0;
                            jump_hold = 1'b0;
                        end
                    end
                    `INST_AND:begin
                        wr_reg_en = 1'b1;
                        wr_reg_addr = rd;
                        wr_reg_data = op1 & op2;
                        jump_en = 1'b0;
                        jump_addr = 32'b0;
                        jump_hold = 1'b0;
                    end
                    `INST_OR:begin
                        wr_reg_en = 1'b1;
                        wr_reg_addr = rd;
                        wr_reg_data = op1 | op2;
                        jump_en = 1'b0;
                        jump_addr = 32'b0;
                        jump_hold = 1'b0;
                    end
                    `INST_XOR:begin
                        wr_reg_en = 1'b1;
                        wr_reg_addr = rd;
                        wr_reg_data = op1 ^ op2;
                        jump_en = 1'b0;
                        jump_addr = 32'b0;
                        jump_hold = 1'b0;
                    end
                    `INST_SLL:begin
                        wr_reg_en = 1'b1;
                        wr_reg_addr = rd;
                        wr_reg_data = op1 << op2[4:0];
                        jump_en = 1'b0;
                        jump_addr = 32'b0;
                        jump_hold = 1'b0;
                    end
                    `INST_SRL_SRA:begin
                        if (func7 == 7'b0) begin
                            wr_reg_en = 1'b1;
                            wr_reg_addr = rd;
                            wr_reg_data = op1 >> op2[4:0];
                            jump_en = 1'b0;
                            jump_addr = 32'b0;
                            jump_hold = 1'b0;
                        end else begin
                            wr_reg_en = 1'b1;
                            wr_reg_addr = rd;
                            wr_reg_data = $signed(op1) >>> op2[4:0];
                            jump_en = 1'b0;
                            jump_addr = 32'b0;
                            jump_hold = 1'b0;
                        end
                    end
                    `INST_SLT:begin
                        wr_reg_en = 1'b1;
                        wr_reg_addr = rd;
                        wr_reg_data = ($signed(op1) < $signed(op2)) ? 32'b1 : 32'b0;
                        jump_en = 1'b0;
                        jump_addr = 32'b0;
                        jump_hold = 1'b0;
                    end
                    `INST_SLTU:begin
                        wr_reg_en = 1'b1;
                        wr_reg_addr = rd;
                        wr_reg_data = (op1 < op2) ? 32'b1 : 32'b0;
                        jump_en = 1'b0;
                        jump_addr = 32'b0;
                        jump_hold = 1'b0;
                    end
                     // M-Extension 乘除法指令
                    default:begin
                        wr_reg_en = 0;
                        wr_reg_addr = 5'b0;
                        wr_reg_data = 32'h0;
                        jump_en = 1'b0;
                        jump_addr = 32'b0;
                        jump_hold = 1'b0;
                    end
                endcase
            end
            `INST_TYPE_B:begin
                case (func3)
                    `INST_BNE:begin
                        wr_reg_en = 1'b0;
                        wr_reg_addr = 5'b0;
                        wr_reg_data = 32'b0;
                        jump_en = ~equal;
                        jump_addr = ~equal ? jump_imm : 32'b0;
                        jump_hold = 1'b0;
                    end
                    `INST_BEQ:begin
                        wr_reg_en = 1'b0;
                        wr_reg_addr = 5'b0;
                        wr_reg_data = 32'b0;
                        jump_en = equal;
                        jump_addr = equal ? jump_imm : 32'b0;
                        jump_hold = 1'b0;
                    end
                    `INST_BLT:begin
                        wr_reg_en = 1'b0;
                        wr_reg_addr = 5'b0;
                        wr_reg_data = 32'b0;
                        jump_en = ($signed(op1) < $signed(op2));
                        jump_addr = ($signed(op1) < $signed(op2)) ? jump_imm : 32'b0;
                        jump_hold = 1'b0;
                    end
                    `INST_BGE:begin
                        wr_reg_en = 1'b0;
                        wr_reg_addr = 5'b0;
                        wr_reg_data = 32'b0;
                        jump_en = ($signed(op1) >= $signed(op2));
                        jump_addr = ($signed(op1) >= $signed(op2)) ? jump_imm : 32'b0;
                        jump_hold = 1'b0;
                    end
                    `INST_BLTU:begin
                        wr_reg_en = 1'b0;
                        wr_reg_addr = 5'b0;
                        wr_reg_data = 32'b0;
                        jump_en = (op1 < op2);
                        jump_addr = (op1 < op2) ? jump_imm : 32'b0;
                        jump_hold = 1'b0;
                    end
                    `INST_BGEU:begin
                        wr_reg_en = 1'b0;
                        wr_reg_addr = 5'b0;
                        wr_reg_data = 32'b0;
                        jump_en = (op1 >= op2);
                        jump_addr = (op1 >= op2) ? jump_imm : 32'b0;
                        jump_hold = 1'b0;
                    end
                    default: begin
                        wr_reg_en = 1'b0;
                        wr_reg_addr = 5'b0;
                        wr_reg_data = 32'b0;
                        jump_en = 1'b0;
                        jump_addr = 32'b0;
                        jump_hold = 1'b0;
                    end
                endcase
            end
            `INST_JAL:begin
                wr_reg_en = 1'b1;
                wr_reg_addr = rd;
                wr_reg_data = instr_addr_in + 32'd4;
                jump_en = 1'b1;
                jump_addr = instr_addr_in + op2; // JAL 的目标地址是 PC + 立即数
                jump_hold = 1'b0;
            end
            `INST_JALR:begin
                wr_reg_en = 1'b1;
                wr_reg_addr = rd;
                wr_reg_data = instr_addr_in + 32'd4;
                jump_en = 1'b1;
                jump_addr = op1 + op2; // JALR 的目标地址是 rs1 + 立即数
                jump_hold = 1'b0;
            end
            `INST_LUI:begin
                wr_reg_en = 1'b1;
                wr_reg_addr = rd;
                wr_reg_data = op2;
                jump_en = 1'b0;
                jump_addr = 32'b0;
                jump_hold = 1'b0;
            end
            `INST_AUIPC:begin
                wr_reg_en = 1'b1;
                wr_reg_addr = rd;
                wr_reg_data = instr_addr_in + op2; // AUIPC 的结果是 PC + 立即数
                jump_en = 1'b0;
                jump_addr = 32'b0;
                jump_hold = 1'b0;
            end
            `INST_NOP_OP:begin
                wr_reg_en = 1'b0;
                wr_reg_addr = 5'b0;
                wr_reg_data = 32'b0;
                jump_en = 1'b0;
                jump_addr = 32'b0;
                jump_hold = 1'b0;
            end
            default: begin
                wr_reg_en = 0;
                wr_reg_addr = 5'b0;
                wr_reg_data = 32'h0;
                jump_en = 1'b0;
                jump_addr = 32'b0;
                jump_hold = 1'b0;
            end
        endcase
    end


endmodule