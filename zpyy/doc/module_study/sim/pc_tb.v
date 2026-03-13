`timescale 1ns / 1ps

module pc_tb;

    // 参数定义
    parameter ADD_WIDTH = 32;
    parameter CLK_PERIOD = 10;  // 100MHz时钟
    
    // 输入信号
    reg clk;
    reg rst;
    reg jump_en_i;
    reg [ADD_WIDTH-1:0] jump_addr_i;
    
    // 输出信号
    wire [ADD_WIDTH-1:0] pc_o;
    
    // 实例化PC模块
    pc #(
        .ADD_WIDTH(ADD_WIDTH)
    ) u_pc (
        .clk(clk),
        .rst(rst),
        .jump_en_i(jump_en_i),
        .jump_addr_i(jump_addr_i),
        .pc_o(pc_o)
    );
    
    // 时钟生成
    always #(CLK_PERIOD/2) clk = ~clk;
    
    // 测试过程
    initial begin
        // 初始化信号
        clk = 0;
        rst = 0;
        jump_en_i = 0;
        jump_addr_i = 0;
        
        // 应用复位
        #20;
        rst = 1;
        #20;
        rst = 0;
        
        // 测试1: 正常顺序执行（4个周期）
        $display("=== 测试1: 正常顺序执行 ===");
        repeat(4) @(posedge clk);
        $display("时间: %0t, PC值: %h", $time, pc_o);
        
        // 测试2: 跳转测试
        $display("\n=== 测试2: 跳转测试 ===");
        jump_en_i = 1;
        jump_addr_i = 32'h0000_1000;
        @(posedge clk);
        jump_en_i = 0;
        $display("跳转后PC值: %h", pc_o);
        
        // 测试3: 继续顺序执行（3个周期）
        $display("\n=== 测试3: 继续顺序执行 ===");
        repeat(3) @(posedge clk);
        $display("时间: %0t, PC值: %h", $time, pc_o);
        
        // 测试4: 复位测试
        $display("\n=== 测试4: 复位测试 ===");
        rst = 1;
        @(posedge clk);
        rst = 0;
        $display("复位后PC值: %h", pc_o);
        
        // 测试5: 边沿情况测试
        $display("\n=== 测试5: 边沿情况测试 ===");
        // 在时钟上升沿同时改变跳转信号
        jump_en_i = 1;
        jump_addr_i = 32'h0000_2000;
        @(posedge clk);
        $display("跳转后PC值: %h", pc_o);
        
        // 结束测试
        #100;
        $display("\n=== 测试完成 ===");
        $finish;
    end
    
    // 监控PC值变化
    always @(posedge clk) begin
        $display("时钟上升沿 @ %0t: PC = %h", $time, pc_o);
    end
    
    // 检查复位功能
    always @(posedge rst) begin
        if (rst) begin
            $display("复位信号激活 @ %0t", $time);
        end
    end

endmodule
