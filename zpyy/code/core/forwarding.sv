`include "F:/work/jingyeda/jingyeda/zpyy/code/define/define.sv"
`include "F:/work/jingyeda/jingyeda/zpyy/code/define/rv32i_pkg.sv"

module forwarding import rv32i_pkg::*;(
    // ex rs1 rs2 now
    input   logic   [`REG_ADDR_WIDTH-1:0]       ex_rs1_addr_i           ,
    input   logic   [`REG_ADDR_WIDTH-1:0]       ex_rs2_addr_i           ,

    // from mem wr ctrl
    input   logic                               mem_wr_regs_en_i        ,
    input   logic   [`REG_ADDR_WIDTH-1:0]       mem_wr_regs_addr_i      ,
    
    // from wb wr ctrl
    input   logic                               wb_wr_regs_en_i         ,
    input   logic   [`REG_ADDR_WIDTH-1:0]       wb_wr_regs_addr_i       ,

    // forwardinf decision (00 : no forwarding , 01 : use mem , 10 , use wb)
    output  var     Forwarding_Mode_e           forwarding_rs1_sel_o    ,
    output  var     Forwarding_Mode_e           forwarding_rs2_sel_o    
);

always_comb begin : rs1_dorwarding_select
    forwarding_rs1_sel_o    = NO_FORWARDING     ;
    if (ex_rs1_addr_i != `ZERO_REG) begin
        if (mem_wr_regs_en_i && (mem_wr_regs_addr_i == ex_rs1_addr_i)) begin
            forwarding_rs1_sel_o    = MEM_FORWARDING    ;
        end else if (wb_wr_regs_en_i && (wb_wr_regs_addr_i == ex_rs1_addr_i)) begin
            forwarding_rs1_sel_o    = WB_FORWARDING     ;
        end else begin end
    end else begin end
end

always_comb begin : rs2_dorwarding_select
    forwarding_rs2_sel_o    = NO_FORWARDING     ;
    if (ex_rs2_addr_i != `ZERO_REG) begin
        if (mem_wr_regs_en_i && (mem_wr_regs_addr_i == ex_rs2_addr_i)) begin
            forwarding_rs2_sel_o    = MEM_FORWARDING    ;
        end else if (wb_wr_regs_en_i && (wb_wr_regs_addr_i == ex_rs2_addr_i)) begin
            forwarding_rs2_sel_o    = WB_FORWARDING     ;
        end else begin end
    end else begin end
end


endmodule