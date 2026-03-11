module riscv_top_tb #(
    parameter DW = 32,
    parameter AW = 32,
    parameter FILE = "instr_data.txt"
) (
    
    
);
logic clk;
logic rst_n;

riscv_top 
#(
    .AW   (AW   ),
    .DW   (DW   ),
    .FILE (FILE )
)
u_riscv_top(
    .clk   (clk   ),
    .rst_n (rst_n )
);

always #5 clk = ~clk;

initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, riscv_top_tb);
    clk = 1'b0;
    rst_n = 1'b0;

    #1000;
    rst_n = 1'b1;
    
    #1000;
    $finish;
end


    
endmodule