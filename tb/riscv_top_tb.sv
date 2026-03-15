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



//// =========================================================
//    // 🚀 RISC-V 官方测试集自动化阅卷系统
//    // =========================================================
//    initial begin
//        // 1. 死等 s10(x26) 变为 1。只要它变 1，说明程序走到了 <pass> 或 <fail> 结尾
//        // ⚠️ 注意：你需要把下方的 "riscv_top_inst.u_regfile.regs" 
//        // 替换成你真实的底层模块实例化名字！
//        wait(x26 == 32'h1);
//
//        // 2. 稍微延迟几个周期 (比如 100ns)
//        // 为什么？因为汇编代码里，写完 s10 后，下一条指令才写 s11。
//        // 给流水线一点时间，确保 s11 和 gp 已经稳定写回寄存器堆。
//        #100;
//
//        $display("\n================================================");
//        // 3. 检查 s11(x27) 的最终判决
//        if (x27 == 32'h1) begin
//            $display("   congratulations!!!!!(All Tests Passed)");
//        end else begin
//            $display("   Test Failed!!!!!");
//            // 提取 gp(x3) 的值，精准定位死穴
//            $display("  --->>> failed in %0d ", x3);
//        end
//        $display("================================================\n");
//
//        // 4. 判决出炉后，直接终止仿真，不用再傻傻等 100us 跑完了
//        $stop; 
//    end
//





//initial begin
//    forever begin
//        tmp = x3;
//        @(posedge clk);
//        if (tmp !== x3) begin
//            $display("Time: %0t, x3 changed to: %h", $time, x3);
//        end else if (x26 == 32'h1) begin
//            repeat(10) @(posedge clk);
//            if (x27 == 32'h1) begin
//                $display("\n");
//                repeat(3) $display("*******************************************************");
//                $display("/n");
//                $display("%s",`FILE,"test passed!");
//                $display("/n");
//                repeat(3) $display("*******************************************************");
//                $display("\n");
//                for (int i =0;i<32 ;i++ ) begin
//                    $display("%d register value is %d",i,riscv_top_tb.u_riscv_top.u_register.regs[i]);
//                end
//                $finish;
//            end else begin
//                $display("\n");
//                repeat(3) $display("*******************************************************");
//                $display("/n");
//                $display("%s",`FILE,"test failed!");
//                $display("/n");
//                repeat(3) $display("*******************************************************");
//                $display("\n");
//                for (int i =0;i<32 ;i++ ) begin
//                    $display("%d register value is %d",i,riscv_top_tb.u_riscv_top.u_register.regs[i]);
//                end
//                $finish;
//            end
//        end
//    end
//end


initial begin
    forever begin
        tmp = x3;
        @(posedge clk);
        if (tmp !== x3) begin
            $display("[TRACE] Time: %8t | gp(x3) changed to -> %0d (0x%0h)", $time, x3, x3);
        end else if (x26 == 32'h1) begin
            repeat(10) @(posedge clk);
            if (x27 == 32'h1) begin
                $display("\n=======================================================");
                $display("  [V]  [SUCCESS] TEST PERFECTLY PASSED! "); // 用 [V] 代替 ✅
                $display("  >>>  File: %s", `FILE);                  // 用 >>> 代替 📄
                $display("=======================================================");
                $display("  [ Register Final State Dump ]");
                for (int i = 0; i < 32; i++) begin
                    $display("  x%02d : 32'h%08h  |  %11d", i, 
                             riscv_top_tb.u_riscv_top.u_register.regs[i], 
                             riscv_top_tb.u_riscv_top.u_register.regs[i]);
                end
                $display("=======================================================\n");
                $finish;
            end else begin
                $display("\n=======================================================");
                $display("  [X]  [FAILED] TEST FAILED! ");            // 用 [X] 代替 ❌
                $display("  >>>  File: %s", `FILE);
                $display("=======================================================");
                $display("  [ Register Final State Dump ]");
                for (int i = 0; i < 32; i++) begin
                    $display("  x%02d : 32'h%08h  |  %11d", i, 
                             riscv_top_tb.u_riscv_top.u_register.regs[i], 
                             riscv_top_tb.u_riscv_top.u_register.regs[i]);
                end
                $display("=======================================================\n");
                $finish;
            end
        end
    end
end
    
endmodule