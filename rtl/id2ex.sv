module id2ex #(
    parameter AW = 32,
    parameter DW = 32
) (
    input   logic clk,
    input   logic rst_n,

    input   logic [AW-1:0]  instr_addr_in,
    input   logic [DW-1:0]  instr_in,

    input   logic [DW-1:0]  op1_in,
    input   logic [DW-1:0]  op2_in,

    //to ex
    output  logic [AW-1:0]  instr_addr_out,
    output  logic [DW-1:0]  instr_out,
    output  logic [DW-1:0]  op1_out,
    output  logic [DW-1:0]  op2_out

);

    always_ff @( posedge clk or negedge rst_n ) begin : reg_logic
        if (!rst_n) begin   
            instr_addr_out <= '0;
            instr_out <= '0;
            op1_out <= '0;
            op2_out <= '0;
        end else begin
            instr_addr_out <= instr_addr_in;
            instr_out <= instr_in;
            op1_out <= op1_in;
            op2_out <= op2_in;
        end
    end
    
endmodule