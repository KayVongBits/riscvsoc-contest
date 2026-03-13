`include "./../rtl/defines.sv"

module riscv_top_tb #(
    parameter DW = `DW,
    parameter AW = `AW,
    parameter FILE = `FILE
) (
    
    
);
logic clk;
logic rst_n;

logic [DW-1:0] tmp;
logic [DW-1:0] x3;
logic [DW-1:0] x26;
logic [DW-1:0] x27;


assign x3 = riscv_top_tb.u_riscv_top.u_register.regs[3];
assign x26 = riscv_top_tb.u_riscv_top.u_register.regs[26];
assign x27 = riscv_top_tb.u_riscv_top.u_register.regs[27];
    
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
    
    clk = 1'b0;
    rst_n = 1'b0;
    tmp = 32'b0;

    #1000;
    rst_n = 1'b1;
    
    
end

initial begin
    forever begin
        tmp = x3;
        @(posedge clk);
        if (tmp !== x3) begin
            $display("Time: %0t, x3 changed to: %h", $time, x3);
        end else if (x26 == 32'h1) begin
            repeat(10) @(posedge clk);
            if (x27 == 32'h1) begin
                $display("\n");
                repeat(3) $display("*******************************************************");
                $display("/n");
                $display("%s",`FILE,"test passed!");
                $display("/n");
                repeat(3) $display("*******************************************************");
                $display("\n");
                for (int i =0;i<32 ;i++ ) begin
                    $display("%d register value is %d",i,riscv_top_tb.u_riscv_top.u_register.regs[i]);
                end
                $finish;
            end else begin
                $display("\n");
                repeat(3) $display("*******************************************************");
                $display("/n");
                $display("%s",`FILE,"test failed!");
                $display("/n");
                repeat(3) $display("*******************************************************");
                $display("\n");
                for (int i =0;i<32 ;i++ ) begin
                    $display("%d register value is %d",i,riscv_top_tb.u_riscv_top.u_register.regs[i]);
                end
                //$finish;
            end
        end
    end
end
    
endmodule