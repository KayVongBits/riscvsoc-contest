`include "defines.sv"

module register #(
   parameter  DW = `DW
) (
    input logic clk,
    input logic rst_n,

    input logic [4:0] rd_rs1_addr,
    input logic [4:0] rd_rs2_addr,

    output logic [DW-1:0] rd_rs1_data,
    output logic [DW-1:0] rd_rs2_data,

    input logic [4:0] wr_reg_addr,
    input logic [DW-1:0] wr_reg_data,
    input logic wr_reg_en
);
    logic [DW-1:0] regs [31:0];

    always_comb begin : read_rs1
        if (!rst_n) begin
            rd_rs1_data <= 0;
        end else if (rd_rs1_addr == 5'h0) begin
            rd_rs1_data <= 0;
        end else if (wr_reg_en && (rd_rs1_addr == wr_reg_addr)) begin
            rd_rs1_data <= wr_reg_data;
        end else begin
            rd_rs1_data <= regs[rd_rs1_addr];
        end
    end

    always_comb begin : read_rs2
        if (!rst_n) begin
            rd_rs2_data <= 0;
        end else if (rd_rs2_addr == 5'h0) begin
            rd_rs2_data <= 0;
        end else if (wr_reg_en && (rd_rs2_addr == wr_reg_addr)) begin
            rd_rs2_data <= wr_reg_data;
        end else begin
            rd_rs2_data <= regs[rd_rs2_addr];
        end
    end

    always_ff @( posedge clk or negedge rst_n ) begin : write
        if (!rst_n) begin
            for (int i = 0; i < 32; i++) begin
                regs[i] <= 0;
            end
        end else if (wr_reg_en && (wr_reg_addr != 5'h0)) begin
            regs[wr_reg_addr] <= wr_reg_data;
        end
    end

endmodule