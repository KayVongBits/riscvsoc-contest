`include "./core/defines.sv"
module riscv_Soc #(
    parameter AW = `AW, // Address width;
    parameter DW = `DW  // Data width;
) ( 
    input  logic                 soc_clk_in,        // 时钟信号
    input  logic                 soc_rst_n_in,      // 复位信号，低有效
    input  logic                 soc_key_in,     // 按键输入
    output logic [4-1:0]        soc_led_out         // LED 输出
);
    
    logic sys_clk;        // 系统时钟
    logic sys_rst_n;      // 系统复位信号
    logic core_rst_n;     // 核心复位信号
    

    logic [3:0] led_pattern; // LED 显示模式
    (*mark_debug = "true"*) logic key_debounce;      // 按键去抖动信号
    (*mark_debug = "true"*) logic [DW-1:0] test_case;
    (*mark_debug = "true"*) logic [DW-1:0] reg_s10;
    (*mark_debug = "true"*) logic [DW-1:0] reg_s11;

    assign core_rst_n = key_debounce & sys_rst_n; // 系统复位信号由外部复位和 PLL 锁定信号共同控制
    
    assign led_pattern = {2'b00,reg_s10[0], reg_s11[0]}; // LED 显示模式由寄存器 s10 和 s11 的最低位控制



clk_pll u_clk_pll(
    .clk_out1 (sys_clk      ),
    .resetn   (soc_rst_n_in ),
    .locked   (sys_rst_n    ),
    .clk_in1  (soc_clk_in   )
);

led_top u_led_top(
    .clk         (sys_clk           ),
    .rst_n       (sys_rst_n         ),
    .led_pattern (led_pattern       ),
    .led         (soc_led_out       )
);

key_top u_key_top(
    .clk       (sys_clk         ),
    .rst_n     (sys_rst_n       ),
    .key_in    (soc_key_in      ),
    .key_out   (key_debounce    ),
    .key_redge (                ),
    .key_fedge (                )
);


riscv_core 
#(
    .AW   (AW   ),
    .DW   (DW   )

)
u_riscv_core(
    .clk   (sys_clk     ),
    .rst_n (core_rst_n  ),
    .test_case (test_case ),
    .reg_s10   (reg_s10   ),
    .reg_s11   (reg_s11   )

);



endmodule