`include "F:/work/jingyeda/jingyeda/zpyy/code/define/define.sv"
`include "F:/work/jingyeda/jingyeda/zpyy/code/define/rv32i_pkg.sv"

module mem2wb import rv32i_pkg::*;(
    input   logic                           clk                 ,
    input   logic                           rst                 ,

    input   var     Ex2Mem_Bus_s            ex2mem_bus_i        ,
    output  var     Mem2Wb_Bus_s            mem2wb_bus_o        
);


always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        mem2wb_bus_o                <= '0                                   ;
    end else begin          
        mem2wb_bus_o.wb_ctrl        <= ex2mem_bus_i.wb_ctrl                 ;
        mem2wb_bus_o.alu_res        <= ex2mem_bus_i.alu_res                 ;
        mem2wb_bus_o.rd_addr        <= ex2mem_bus_i.rd_addr                 ;
        mem2wb_bus_o.ram_rd_mode    <= ex2mem_bus_i.mem_ctrl.ram_rd_mode    ;
    end
end

endmodule