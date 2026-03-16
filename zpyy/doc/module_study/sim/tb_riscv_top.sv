`timescale 1ns/1ps
`include "../code/define.sv"


module tb_riscv_top;

logic clk , rst ;

riscv_top #(
    .FILE       (`FILE)
) u_riscv_top (
    .clk        (clk),
    .rst        (rst)
);

always #5 clk <= ~clk; // 10ns周期的时钟

initial begin
    rst <= 1'b1 ;
    clk <= 1'b0 ;
    #100
    rst <= 1'b0 ;
    #5000
    $display("Simulation Timeout!");
    $finish;
end

endmodule