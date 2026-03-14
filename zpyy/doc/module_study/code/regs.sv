`include "define.sv"
`include "rv32i_pkg.sv"

module regs(
    input   logic                           clk             ,
    input   logic                           rst             ,
    // from decoder 
    input   logic   [`REG_ADDR_WIDTH-1:0]   rs1_addr_i      ,
    input   logic   [`REG_ADDR_WIDTH-1:0]   rs2_addr_i      ,
    // to decode    
    output  logic   [`DATA_WIDTH-1:0]       rs1_data_o      ,
    output  logic   [`DATA_WIDTH-1:0]       rs2_data_o      ,
    //from execute
    input   logic                           wr_reg_en_i     ,
    input   logic   [`REG_ADDR_WIDTH-1:0]   wr_reg_addr_i   ,
    input   logic   [`DATA_WIDTH-1:0]       wr_reg_data_i
);

import rv32i_pkg::*;

logic   [`DATA_WIDTH-1:0]       regs        [0:`REG_NUM-1]  ;         

always_comb begin : read_value_reg1
    if (rst) begin
        rs1_data_o = `REG_RST_VALUE ;
    end else if (rs1_addr_i == `ZERO_REG) begin
        rs1_data_o = `ZERO_VALUE ;
    end else if (wr_reg_en_i && (rs1_addr_i == wr_reg_addr_i)) begin        //  写回地址等于读地址，优先输出写回数据
        rs1_data_o = wr_reg_data_i ;
    end else begin
        rs1_data_o = regs[rs1_addr_i] ;
    end
end : read_value_reg1

always_comb begin : read_value_reg2
    if (rst) begin
        rs2_data_o = `REG_RST_VALUE ;
    end else if (rs2_addr_i == `ZERO_REG) begin
        rs2_data_o = `ZERO_VALUE ;
    end else if (wr_reg_en_i && (rs2_addr_i == wr_reg_addr_i)) begin        //  写回地址等于读地址，优先输出写回数据
        rs2_data_o = wr_reg_data_i ;
    end else begin
        rs2_data_o = regs[rs2_addr_i] ;
    end
end : read_value_reg2

always_ff @(posedge clk or posedge rst) begin : write_back
    if (rst) begin
        for(int i = 0 ; i < `REG_NUM ; i++) begin
            regs[i] <= `ZERO_VALUE ;
        end
    end else if (wr_reg_en_i && (wr_reg_addr_i != `ZERO_REG)) begin
        regs[wr_reg_addr_i] <= wr_reg_data_i ;
    end
end
endmodule