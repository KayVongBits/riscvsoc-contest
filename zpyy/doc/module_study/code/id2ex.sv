`include "define.sv"

module id2ex(
    // sys
    input   logic                               clk             ,
    input   logic                               rst             ,   

    // ctrl
    input   logic                               flush_id2ex_i   ,

    input   logic   [`ADD_WIDTH-1:0]            inst_addr_i     ,
    output  logic   [`ADD_WIDTH-1:0]            inst_addr_o     ,

    input   logic   [`DATA_WIDTH-1:0]           inst_i          ,
    output  logic   [`DATA_WIDTH-1:0]           inst_o          ,

    input   logic   [`DATA_WIDTH-1:0]           rs1_data_i      ,
    output  logic   [`DATA_WIDTH-1:0]           rs1_data_o      ,

    input   logic   [`DATA_WIDTH-1:0]           rs2_data_i      ,
    output  logic   [`DATA_WIDTH-1:0]           rs2_data_o      ,

    input   logic   [`DATA_WIDTH-1:0]           imm_i           ,
    output  logic   [`DATA_WIDTH-1:0]           imm_o           ,  

    input   logic                               alu_src1_sel_i  ,
    input   logic                               alu_src2_sel_i  ,
    output  logic                               alu_src1_sel_o  ,
    output  logic                               alu_src2_sel_o      
);

always_ff @(posedge clk or posedge rst) begin : id2ex_dff
    if (rst) begin
        inst_addr_o     <= `PC_INIT_ADDR    ;
        inst_o          <= `INST_NOP        ;
        rs1_data_o      <= `RST_REG_VALUE   ;
        rs2_data_o      <= `RST_REG_VALUE   ;
        imm_o           <= `RST_IMM_VALUE   ;
        alu_src1_sel_o  <= `ALU_OP1_SEL_RS1 ;
        alu_src2_sel_o  <= `ALU_OP2_SEL_RS2 ;
    end else if (flush_id2ex_i == `FLUSH_ENABLE) begin
        inst_addr_o     <= `PC_INIT_ADDR    ;
        inst_o          <= `INST_NOP        ;
        rs1_data_o      <= `RST_REG_VALUE   ;
        rs2_data_o      <= `RST_REG_VALUE   ;
        imm_o           <= `RST_IMM_VALUE   ;
        alu_src1_sel_o  <= `ALU_OP1_SEL_RS1 ;
        alu_src2_sel_o  <= `ALU_OP2_SEL_RS2 ;
    end else begin
        inst_addr_o     <= inst_addr_i      ;
        inst_o          <= inst_i           ;
        rs1_data_o      <= rs1_data_i       ;
        rs2_data_o      <= rs2_data_i       ;
        imm_o           <= imm_i            ;
        alu_src1_sel_o  <= alu_src1_sel_i   ;
        alu_src2_sel_o  <= alu_src2_sel_i   ;
    end
end : id2ex_dff

endmodule