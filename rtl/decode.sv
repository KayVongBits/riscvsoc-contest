module decode #(
    parameter DW = 32
) (
    input logic [DW-1:0] instr_in,

    //to reg
    output logic [4:0] rd_rs1_addr,
    output logic [4:0] rd_rs2_addr,
    output logic [6:0] wr_rd_addr,

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
    assign imm    = instr_in[31:20];

    always_comb begin : decode_logic
        if ((opcode == 7'b0010011) && (func3 == 3'b000)) begin //addi
            rd_rs1_addr = rs1;
            rd_rs2_addr = 5'b0;
            wr_rd_addr  = rd;
            op1_out     = rd_rs1_data;
            op2_out     = imm;
        end
        else begin
            rd_rs1_addr = 5'b0;
            rd_rs2_addr = 5'b0;
            wr_rd_addr  = 5'b0;
            op1_out     = 32'b0;
            op2_out     = 32'b0;
        end
    end

endmodule