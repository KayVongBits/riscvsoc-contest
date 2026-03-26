`include "F:/work/jingyeda/jingyeda/zpyy/code/define/define.sv"
`include "F:/work/jingyeda/jingyeda/zpyy/code/define/rv32i_pkg.sv"
module id2ex import rv32i_pkg::*; (
    // sys
    input   logic                               clk             ,
    input   logic                               rst             ,   

    // ctrl
    input   logic                               flush_id2ex_i   ,

    input   var     Id2Ex_Bus_s                 id2ex_bus_i     ,
    output  var     Id2Ex_Bus_s                 id2ex_bus_o     
);

always_ff @(posedge clk or posedge rst) begin : id2ex_dff
    if (rst) begin
        id2ex_bus_o <= '0           ;
    end else if (flush_id2ex_i == `FLUSH_ENABLE) begin
        id2ex_bus_o <= '0           ;
    end else begin
        id2ex_bus_o <= id2ex_bus_i  ;
    end
end : id2ex_dff

endmodule