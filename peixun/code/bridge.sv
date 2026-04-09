module bridge(
    input logic clk_i,
    input logic rst_i,

    // CPU侧
    input logic [31:0] addr_from_cpu_i,
    input logic [31:0] wdata_from_cpu_i,
    input logic wen_from_cpu_i,
    input logic [1:0] wram_mode_i,  // 0:B, 1:HW, 2:W, 3:None
    input logic [2:0] rram_mode_i,  // 0:B, 1:HW, 2:W, 4:BU, 5:HWU, 7:None
    output logic [31:0] rdata_to_cpu_o,

    // DRAM侧
    input logic [31:0] spo_from_dram_i,
    output logic [31:0] a_to_dram_o,
    output logic [31:0] d_to_dram_o,
    output logic clk_to_dram_o,
    output logic we_to_dram_o,
    output logic [1:0]  wram_mode_to_dram_o,
    output logic [2:0]  rram_mode_to_dram_o,

    // SW侧
    input logic [31:0] rdata_from_sw_i,
    output logic [31:0] addr_to_sw_o,

    // KEY侧
    input logic [31:0] rdata_from_key_i,
    output logic [31:0] addr_to_key_o,

    // LED侧
    input  logic [31:0] rdata_from_led_i,
    output logic [31:0] addr_to_led_o,
    output logic [31:0] wdata_to_led_o,
    output logic clk_to_led_o,
    output logic rst_to_led_o,
    output logic wen_to_led_o,

    // SEG侧
    input logic [31:0] rdata_from_seg_i,
    output logic [31:0] addr_to_seg_o,
    output logic [31:0] wdata_to_seg_o,
    output logic clk_to_seg_o,
    output logic rst_to_seg_o,
    output logic  wen_to_seg_o,

    // CNT侧
    input  logic [31:0] rdata_from_cnt_i,
    output logic [31:0] wdata_to_cnt_o,
    output logic clk_to_cnt_o,
    output logic rst_to_cnt_o,
    output logic wen_to_cnt_o
);

    localparam DRAM_ADDR_START = 32'h8010_0000;
    localparam DRAM_ADDR_END   = 32'h8013_FFFF;
    localparam SW0_ADDR  = 32'h8020_0000;  // sw[31:0]
    localparam SW1_ADDR  = 32'h8020_0004;  // sw[63:32]
    localparam KEY_ADDR  = 32'h8020_0010;  // key[7:0]
    localparam SEG_ADDR  = 32'h8020_0020;  // seg
    localparam LED_ADDR  = 32'h8020_0040;  // led[31:0]
    localparam CNT_ADDR  = 32'h8020_0050;  // counter

    logic access_mem;
    logic access_seg;
    logic access_led;
    logic access_sw;
    logic access_key;
    logic access_cnt;
    logic [5:0] access_bit;

    // 地址选择电路
    assign access_bit = {access_mem,
                         access_seg,
                         access_led,
                         access_sw,
                         access_key,
                         access_cnt};

    assign access_mem = (addr_from_cpu_i >= DRAM_ADDR_START && addr_from_cpu_i <= DRAM_ADDR_END) ? 1'b1 : 1'b0;
    assign access_seg = (addr_from_cpu_i == SEG_ADDR) ? 1'b1 : 1'b0;
    assign access_led = (addr_from_cpu_i == LED_ADDR) ? 1'b1 : 1'b0;
    assign access_sw  = (addr_from_cpu_i == SW0_ADDR || addr_from_cpu_i == SW1_ADDR) ? 1'b1 : 1'b0;
    assign access_key = (addr_from_cpu_i == KEY_ADDR) ? 1'b1 : 1'b0;
    assign access_cnt = (addr_from_cpu_i == CNT_ADDR) ? 1'b1 : 1'b0;


    assign a_to_dram_o = addr_from_cpu_i;
    assign d_to_dram_o = wdata_from_cpu_i;
    assign clk_to_dram_o = clk_i;
    assign we_to_dram_o = access_mem & wen_from_cpu_i;
    assign wram_mode_to_dram_o = wram_mode_i;
    assign rram_mode_to_dram_o = rram_mode_i;


    assign addr_to_sw_o = addr_from_cpu_i;

    assign addr_to_key_o = addr_from_cpu_i;

    assign addr_to_led_o  = addr_from_cpu_i;
    assign wdata_to_led_o = wdata_from_cpu_i;
    assign clk_to_led_o  = clk_i;
    assign rst_to_led_o = rst_i;
    assign wen_to_led_o = access_led & wen_from_cpu_i;

    assign addr_to_seg_o = addr_from_cpu_i;
    assign wdata_to_seg_o = wdata_from_cpu_i;
    assign clk_to_seg_o = clk_i;
    assign rst_to_seg_o = rst_i;
    assign wen_to_seg_o = access_seg & wen_from_cpu_i;

    assign wdata_to_cnt_o = wdata_from_cpu_i;
    assign clk_to_cnt_o = clk_i;
    assign rst_to_cnt_o = rst_i;
    assign wen_to_cnt_o = access_cnt & wen_from_cpu_i;

    // 读数据返回 CPU
    always_comb begin
        rdata_to_cpu_o = 32'h0;
        unique case (access_bit)
            6'b100000: rdata_to_cpu_o = spo_from_dram_i;
            6'b010000: rdata_to_cpu_o = rdata_from_seg_i;
            6'b001000: rdata_to_cpu_o = rdata_from_led_i;
            6'b000100: rdata_to_cpu_o = rdata_from_sw_i;
            6'b000010: rdata_to_cpu_o = rdata_from_key_i;
            6'b000001: rdata_to_cpu_o = rdata_from_cnt_i;
        endcase
    end

endmodule