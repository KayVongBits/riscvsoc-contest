`timescale 1ns/1ps
`include "../code/define/define.sv"


module tb_riscv_top;

logic clk , rst ;
logic [1:0] led_mode ;
riscv_top u_riscv_top (
    .clk        (clk),
    .rst        (rst),
    .led_mode   ()
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