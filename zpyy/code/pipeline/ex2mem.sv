`include "F:/work/jingyeda/jingyeda/zpyy/code/define/define.sv"
`include "F:/work/jingyeda/jingyeda/zpyy/code/define/rv32i_pkg.sv"
module ex2mem import rv32i_pkg::*;(
    input   logic                           clk                 ,
    input   logic                           rst                 ,

    input   var     Ex2Mem_Bus_s            ex2mem_bus_i        ,
    output  var     Ex2Mem_Bus_s            ex2mem_bus_o        
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        ex2mem_bus_o    <= '0           ;
    end else begin
        ex2mem_bus_o    <= ex2mem_bus_i ;
    end
end

endmodule