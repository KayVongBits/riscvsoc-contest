`timescale 1ns/1ps
`include "define.sv"


module tb_riscv_top;

logic clk , rst ;

riscv_top #(
    .FILE       ("rv32i_inst.txt")
) u_riscv_top (
    .clk    (clk),
    .rst    (rst)
);

always #10 clk = ~clk; // 10ns周期的时钟

initial begin
    rst <= 1'b1 ;
    clk <= 1'b0 ;
    #300
    rst <= 1'b0 ;
end

endmodule
