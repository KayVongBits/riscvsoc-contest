`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/04 14:02:31
// Design Name: 
// Module Name: RF
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RF #(
    parameter REG_AW = 5,
    parameter REG_DW = 32
)(
    input logic clk,
    input logic rst_n,

    input logic wr_reg_en,
    input logic [REG_AW-1:0] wr_reg_addr,
    input logic [REG_DW-1:0] wr_reg_data,

    input logic [REG_AW-1:0] rs_reg1_addr,
    input logic [REG_AW-1:0] rs_reg2_addr,

    output logic [REG_DW-1:0] rs_reg1_data,
    output logic [REG_DW-1:0] rs_reg2_data
    );

    logic [REG_DW-1:0] reg_bank [0:(1<<REG_AW)-1];

    // Write logic
    always_ff @(posedge clk or negedge rst_n) begin : Write 
        if (!rst_n) begin
            for (int i = 0; i < (1<<REG_AW); i++) begin
                reg_bank[i] <= 0;
            end
        end else if (wr_reg_en && (wr_reg_addr != '0)) begin
            reg_bank[wr_reg_addr] <= wr_reg_data;
        end
    end

    // Read logic
    always_comb begin : Read 
        if (rs_reg1_addr == '0) begin
            rs_reg1_data = '0;
        end else begin
            rs_reg1_data = reg_bank[rs_reg1_addr];
        end

        if (rs_reg2_addr == '0) begin
            rs_reg2_data = '0;
        end else begin
            rs_reg2_data = reg_bank[rs_reg2_addr];
        end
    end

endmodule
