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
    output  logic [DW-1:0]  wr_reg_data

);
    logic [6:0] opcode;
    logic [4:0] rd;
    logic [2:0] func3;
    logic [6:0] func7;
    logic [11:0] imm;

    assign opcode = instr_in[6:0];
    assign rd     = instr_in[11:7];
    assign func3  = instr_in[14:12];
    assign func7  = instr_in[31:25];
    assign imm    = instr_in[31:20];

    always_comb begin : execute_logic
        if ((opcode == 7'b0010011) && (func3 == 3'b000)) begin
            wr_reg_en = 1;
            wr_reg_addr = rd;
            wr_reg_data = op1 + op2;
        end else begin
            wr_reg_en = 0;
            wr_reg_addr = 5'b0;
            wr_reg_data = 32'h0;
        end
    end


endmodule