`include "F:/work/jingyeda/jingyeda/zpyy/code/define/define.sv"
`include "F:/work/jingyeda/jingyeda/zpyy/code/define/rv32i_pkg.sv"
module wb import rv32i_pkg::*;(
    input   var     Mem2Wb_Bus_s            mem2wb_bus_i    ,
    input   logic   [`DATA_WIDTH-1:0]       ram_rd_data_i   ,
    output  logic                           regs_wr_en_o    ,
    output  logic   [`DATA_WIDTH-1:0]       regs_wr_data_o  ,
    output  logic   [`REG_ADDR_WIDTH-1:0]   regs_rd_addr_o  
);

logic   [`DATA_WIDTH-1:0]   ram_data_ext    ;

always_comb begin : wb_ram_ext_logic
    ram_data_ext = ram_rd_data_i; // 默认值兜底
    unique case (mem2wb_bus_i.ram_rd_mode)
        RAM_RD_EN_LB : begin
            unique case (mem2wb_bus_i.alu_res[1:0])
                2'b00 : ram_data_ext = {{24{ram_rd_data_i[7]}},  ram_rd_data_i[7:0]};
                2'b01 : ram_data_ext = {{24{ram_rd_data_i[15]}}, ram_rd_data_i[15:8]};
                2'b10 : ram_data_ext = {{24{ram_rd_data_i[23]}}, ram_rd_data_i[23:16]};
                2'b11 : ram_data_ext = {{24{ram_rd_data_i[31]}}, ram_rd_data_i[31:24]};
                default : begin end
            endcase
        end
        RAM_RD_EN_LH : begin
            unique case (mem2wb_bus_i.alu_res[1])
                1'b0 : ram_data_ext = {{16{ram_rd_data_i[15]}}, ram_rd_data_i[15:0]};
                1'b1 : ram_data_ext = {{16{ram_rd_data_i[31]}}, ram_rd_data_i[31:16]};
                default : ;
            endcase
        end
        RAM_RD_EN_LW : ram_data_ext = ram_rd_data_i;
        RAM_RD_EN_LBU: begin
            unique case (mem2wb_bus_i.alu_res[1:0])
                2'b00 : ram_data_ext = {24'b0, ram_rd_data_i[7:0]};
                2'b01 : ram_data_ext = {24'b0, ram_rd_data_i[15:8]};
                2'b10 : ram_data_ext = {24'b0, ram_rd_data_i[23:16]};
                2'b11 : ram_data_ext = {24'b0, ram_rd_data_i[31:24]};
                default : begin end
            endcase
        end
        RAM_RD_EN_LHU: begin
            unique case (mem2wb_bus_i.alu_res[1])
                1'b0 : ram_data_ext = {16'b0, ram_rd_data_i[15:0]};
                1'b1 : ram_data_ext = {16'b0, ram_rd_data_i[31:16]};
                default : begin end
            endcase
        end
        default : begin end
    endcase
end

assign regs_wr_en_o    = mem2wb_bus_i.wb_ctrl.reg_wr_en ;
assign regs_rd_addr_o  = mem2wb_bus_i.rd_addr           ;
assign regs_wr_data_o  = (mem2wb_bus_i.ram_rd_mode != RAM_RD_DISABLE) ? ram_data_ext : mem2wb_bus_i.alu_res ;

endmodule