module top(
    input logic clk_p_i,
    input logic clk_n_i,
    input logic rst_i,

    input logic [63:0] sw_i,
    input logic [7:0] key_i,

    output logic [31:0] led_o,

    output logic [7:0] led1_seg_o,
    output logic [7:0] led2_seg_o,
    output logic [7:0] led3_seg_o,
    output logic [7:0] led4_seg_o,
    output logic led1_cs1_o,
    output logic led1_cs2_o,
    output logic led2_cs1_o,
    output logic led2_cs2_o,
    output logic led3_cs1_o,
    output logic led3_cs2_o,
    output logic led4_cs1_o,
    output logic led4_cs2_o
);
    // PLL
    logic clk_50M;
    logic pll_locked;

    // CPU-IROM
    logic [31:0] pc_to_im;
    logic [31:0] inst_from_im;

    // CPU-Bridge
    logic [15:0] addr_to_bridge;
    logic [31:0] wdata_to_bridge;
    logic  wen_to_bridge;
    logic [31:0] rdata_from_bridge;

    // Bridge-DRAM
    logic [31:0] spo_from_dram;
    logic [13:0] a_to_dram;
    logic [31:0] d_to_dram;
    logic clk_to_dram;
    logic we_to_dram;

    // Bridge-SW
    logic [31:0] rdata_from_sw;
    logic [15:0] addr_to_sw;

    // Bridge-KEY
    logic [31:0] rdata_from_key;
    logic [15:0] addr_to_key;

    // Bridge-LED
    logic [31:0] rdata_from_led;
    logic [15:0] addr_to_led;
    logic [31:0] wdata_to_led;
    logic clk_to_led;
    logic rst_to_led;
    logic wen_to_led;
    logic [31:0] led_r;

    // Bridge-SEG
    logic [31:0] rdata_from_seg;
    logic [15:0] addr_to_seg;
    logic [31:0] wdata_to_seg;
    logic clk_to_seg;
    logic rst_to_seg;
    logic wen_to_seg;
    logic [7:0]  seg_dp;

    // 全局复位信号
    logic sys_rst;

    // 小数点全灭
    assign seg_dp = 8'h00;
    assign sys_rst = rst_i | ~pll_locked;

    PLL u_PLL(
        .clk_out1(clk_50M),     // output clk_out1
        .locked(pll_locked),       // output locked
        .clk_in1_p(clk_p_i),    // input clk_in1_p
        .clk_in1_n(clk_n_i)    // input clk_in1_n
    );

    IROM u_IROM(
        .a(pc_to_im[15:2]),      
        .spo(inst_from_im)  
    );

    miniRVcpu u_cpu(
        .clk              (clk_50M),
        .rst              (sys_rst),
        .pc_to_im         (pc_to_im),
        .inst_from_im     (inst_from_im),
        .addr_to_bridge   (addr_to_bridge),
        .wdata_to_bridge  (wdata_to_bridge),
        .wen_to_bridge    (wen_to_bridge),
        .rdata_from_bridge(rdata_from_bridge)
    );

    bridge u_bridge(
        .clk_i            (clk_50M),
        .rst_i            (sys_rst),

        // CPU侧
        .addr_from_cpu_i  (addr_to_bridge),
        .wdata_from_cpu_i (wdata_to_bridge),
        .wen_from_cpu_i   (wen_to_bridge),
        .rdata_to_cpu_o   (rdata_from_bridge),

        // DRAM侧
        .spo_from_dram_i  (spo_from_dram),
        .a_to_dram_o      (a_to_dram),
        .d_to_dram_o      (d_to_dram),
        .clk_to_dram_o    (clk_to_dram),
        .we_to_dram_o     (we_to_dram),

        // SW侧
        .rdata_from_sw_i  (rdata_from_sw),
        .addr_to_sw_o     (addr_to_sw),

        // KEY侧
        .rdata_from_key_i (rdata_from_key),
        .addr_to_key_o    (addr_to_key),

        // LED侧
        .rdata_from_led_i (rdata_from_led),
        .addr_to_led_o    (addr_to_led),
        .wdata_to_led_o   (wdata_to_led),
        .clk_to_led_o     (clk_to_led),
        .rst_to_led_o     (rst_to_led),
        .wen_to_led_o     (wen_to_led),

        // SEG侧
        .rdata_from_seg_i (rdata_from_seg),
        .addr_to_seg_o    (addr_to_seg),
        .wdata_to_seg_o   (wdata_to_seg),
        .clk_to_seg_o     (clk_to_seg),
        .rst_to_seg_o     (rst_to_seg),
        .wen_to_seg_o     (wen_to_seg)
    );

    DRAM u_DRAM(
        .a(a_to_dram),      // input wire [13 : 0] a
        .d(d_to_dram),      // input wire [31 : 0] d
        .clk(clk_to_dram),  // input wire clk
        .we(we_to_dram),    // input wire we
        .spo(spo_from_dram)  // output wire [31 : 0] spo
    );

    // LED
    always_ff @(posedge clk_to_led or posedge rst_to_led) begin
        if (rst_to_led) begin
            led_r <= 32'h0;
        end else if (wen_to_led) begin
            led_r <= wdata_to_led;
        end
    end

    assign rdata_from_led = led_r;
    assign led_o = led_r;

    // SW
    always_comb begin
        rdata_from_sw = 32'h0;
        case(addr_to_sw)
            16'hF000: rdata_from_sw = sw_i[31:0];
            16'hF004: rdata_from_sw = sw_i[63:32];
            default: rdata_from_sw = 32'h0;
        endcase
    end

    // KEY
    assign rdata_from_key = {24'h0, key_i};

    // SEG
    seg_driver u_seg_driver(
        .clk_i            (clk_to_seg),
        .rst_i            (rst_to_seg),
        .addr_to_seg_i    (addr_to_seg),
        .wdata_to_seg_i   (wdata_to_seg),
        .wen_to_seg_i     (wen_to_seg),
        .dp_i             (seg_dp),
        .rdata_from_seg_o (rdata_from_seg),
        .led1_seg_o       (led1_seg_o),
        .led2_seg_o       (led2_seg_o),
        .led3_seg_o       (led3_seg_o),
        .led4_seg_o       (led4_seg_o),
        .led1_cs1_o       (led1_cs1_o),
        .led1_cs2_o       (led1_cs2_o),
        .led2_cs1_o       (led2_cs1_o),
        .led2_cs2_o       (led2_cs2_o),
        .led3_cs1_o       (led3_cs1_o),
        .led3_cs2_o       (led3_cs2_o),
        .led4_cs1_o       (led4_cs1_o),
        .led4_cs2_o       (led4_cs2_o)
    );

endmodule