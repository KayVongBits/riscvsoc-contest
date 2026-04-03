module bridge(
    input logic clk_i,
    input logic rst_i,

    // CPU侧 
    input logic [15:0] addr_from_cpu_i,
    input logic [31:0] wdata_from_cpu_i,
    input logic wen_from_cpu_i,
    output logic [31:0] rdata_to_cpu_o,

    // DRAM侧
    input logic [31:0] spo_from_dram_i,
    output logic [13:0] a_to_dram_o,
    output logic [31:0] d_to_dram_o,
    output logic clk_to_dram_o,
    output logic we_to_dram_o,

    // SW侧
    input logic [31:0] rdata_from_sw_i,
    output logic [15:0] addr_to_sw_o,

    // KEY侧
    input logic [31:0] rdata_from_key_i,
    output logic [15:0] addr_to_key_o,

    // LED侧 
    input logic [31:0] rdata_from_led_i,
    output logic [15:0] addr_to_led_o,
    output logic [31:0] wdata_to_led_o,
    output logic clk_to_led_o,
    output logic rst_to_led_o,
    output logic  wen_to_led_o,

    // SEG侧 
    input logic [31:0] rdata_from_seg_i,
    output logic [15:0] addr_to_seg_o,
    output logic [31:0] wdata_to_seg_o,
    output logic clk_to_seg_o,
    output logic rst_to_seg_o,
    output logic wen_to_seg_o
);

    logic access_mem;
    logic access_seg;
    logic access_led;
    logic access_sw;
    logic access_key;
    logic [4:0] access_bit;
    logic [15:0] dram_addr_byte;

    // 地址选择电路
    assign access_bit = {access_mem,
                        access_seg,
                        access_led,
                        access_sw,
                        access_key};

    assign access_mem = (addr_from_cpu_i[15:12] != 4'b1111) ? 1'b1 : 1'b0;
    assign access_seg = (addr_from_cpu_i <= 16'hF03C && addr_from_cpu_i >= 16'hF020) ? 1'b1 : 1'b0;
    assign access_led = (addr_from_cpu_i == 16'hF040) ? 1'b1 : 1'b0;
    assign access_sw  = (addr_from_cpu_i == 16'hF000 || addr_from_cpu_i == 16'hF004) ? 1'b1 : 1'b0;
    assign access_key = (addr_from_cpu_i == 16'hF010) ? 1'b1 : 1'b0;


    // DRAM地址映射 0x4000~0xEFFF时减0x4000
    always_comb begin
        dram_addr_byte = addr_from_cpu_i;
        if (addr_from_cpu_i >= 16'h4000 && addr_from_cpu_i <= 16'hEFFF) begin
            dram_addr_byte = addr_from_cpu_i - 16'h4000;
        end 
    end

    // DRAM IP核接口
    assign a_to_dram_o = dram_addr_byte[15:2];
    assign d_to_dram_o = wdata_from_cpu_i;
    assign clk_to_dram_o = clk_i;
    assign we_to_dram_o = access_mem & wen_from_cpu_i;

    // MMIO转发
    assign addr_to_sw_o = addr_from_cpu_i;

    assign addr_to_key_o = addr_from_cpu_i;

    assign addr_to_led_o = addr_from_cpu_i;
    assign wdata_to_led_o = wdata_from_cpu_i;
    assign clk_to_led_o = clk_i;
    assign rst_to_led_o = rst_i;
    assign wen_to_led_o = access_led & wen_from_cpu_i;

    assign addr_to_seg_o = addr_from_cpu_i;
    assign wdata_to_seg_o = wdata_from_cpu_i;
    assign clk_to_seg_o = clk_i;
    assign rst_to_seg_o = rst_i;
    assign wen_to_seg_o = access_seg & wen_from_cpu_i;

    // 读数据返回CPU
    always_comb begin
        rdata_to_cpu_o = 32'h0;
        unique case(access_bit)
            5'b10000: rdata_to_cpu_o = spo_from_dram_i;
            5'b01000: rdata_to_cpu_o = rdata_from_seg_i;
            5'b00100: rdata_to_cpu_o = rdata_from_led_i;
            5'b00010: rdata_to_cpu_o = rdata_from_sw_i;
            5'b00001: rdata_to_cpu_o = rdata_from_key_i;
        endcase
    end

endmodule