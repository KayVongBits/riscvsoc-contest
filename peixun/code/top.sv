module top(
    input logic clk_p_i,
    input logic clk_n_i,
    input logic rst_i,

    input logic [63:0] sw_i,
    input logic [7:0] key_i,

    output logic [31:0] led_o,

    output logic [39:0] seg_bus 
);
    // PLL
    logic clk_50M;
    logic pll_locked;

    // CPU-IROM
    logic [31:0] pc_to_im;
    logic [31:0] inst_from_im;

    // CPU-Bridge
    logic [31:0] addr_to_bridge;
    logic [31:0] wdata_to_bridge;
    logic  wen_to_bridge;
    logic [31:0] rdata_from_bridge;
    logic [1:0] wram_mode;
    logic [2:0] rram_mode;

    // Bridge-DRAM
    logic [31:0] rdata_from_dram;
    logic [31:0] a_to_dram;
    logic [31:0] d_to_dram;
    logic clk_to_dram;
    logic we_to_dram;
    logic [1:0] wram_mode_to_dram;
    logic [2:0] rram_mode_to_dram;

    // Bridge-SW
    logic [31:0] rdata_from_sw;
    logic [31:0] addr_to_sw;

    // Bridge-KEY
    logic [31:0] rdata_from_key;
    logic [31:0] addr_to_key;

    // Bridge-LED
    logic [31:0] rdata_from_led;
    logic [31:0] addr_to_led;
    logic [31:0] wdata_to_led;
    logic clk_to_led;
    logic rst_to_led;
    logic wen_to_led;
    logic [31:0] led_r;

    // Bridge-SEG
    logic [31:0] rdata_from_seg;
    logic [31:0] addr_to_seg;
    logic [31:0] wdata_to_seg;
    logic clk_to_seg;
    logic rst_to_seg;
    logic wen_to_seg;
    logic [7:0]  seg_dp;

    // Bridge-COUNTER
    logic [31:0] rdata_from_cnt;
    logic [31:0] wdata_to_cnt;
    logic wen_to_cnt;
    logic clk_to_cnt;
    logic rst_to_cnt;

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

    // 16 KB
    IROM u_IROM(
        .a(pc_to_im[13:2]),      
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
        .rdata_from_bridge(rdata_from_bridge),
        .wram_mode        (wram_mode),
        .rram_mode        (rram_mode)
    );

    bridge u_bridge(
        .clk_i               	( clk_50M            ),
        .rst_i               	( sys_rst            ),


        .addr_from_cpu_i     	( addr_to_bridge     ),
        .wdata_from_cpu_i    	( wdata_to_bridge    ),
        .wen_from_cpu_i      	( wen_to_bridge      ),
        .wram_mode_i         	( wram_mode          ),
        .rram_mode_i         	( rram_mode          ),
        .rdata_to_cpu_o      	( rdata_from_bridge  ),


        .spo_from_dram_i     	( rdata_from_dram    ),
        .a_to_dram_o         	( a_to_dram          ),
        .d_to_dram_o         	( d_to_dram          ),
        .clk_to_dram_o       	( clk_to_dram        ),
        .we_to_dram_o        	( we_to_dram         ),
        .wram_mode_to_dram_o 	( wram_mode_to_dram  ),
        .rram_mode_to_dram_o 	( rram_mode_to_dram  ),


        .rdata_from_sw_i     	( rdata_from_sw      ),
        .addr_to_sw_o        	( addr_to_sw         ),


        .rdata_from_key_i    	( rdata_from_key     ),
        .addr_to_key_o       	( addr_to_key        ),


        .rdata_from_led_i    	( rdata_from_led     ),
        .addr_to_led_o       	( addr_to_led        ),
        .wdata_to_led_o      	( wdata_to_led       ),
        .clk_to_led_o        	( clk_to_led         ),
        .rst_to_led_o        	( rst_to_led         ),
        .wen_to_led_o        	( wen_to_led         ),


        .rdata_from_seg_i    	( rdata_from_seg     ),
        .addr_to_seg_o       	( addr_to_seg        ),
        .wdata_to_seg_o      	( wdata_to_seg       ),
        .clk_to_seg_o        	( clk_to_seg         ),
        .rst_to_seg_o        	( rst_to_seg         ),
        .wen_to_seg_o        	( wen_to_seg         ),

        
        .rdata_from_cnt_i    	( rdata_from_cnt     ),
        .wdata_to_cnt_o      	( wdata_to_cnt       ),
        .clk_to_cnt_o        	( clk_to_cnt         ),
        .rst_to_cnt_o        	( rst_to_cnt         ),
        .wen_to_cnt_o        	( wen_to_cnt         )
    );


    dram_driver u_dram_driver(
        .clk_i             	( clk_to_dram       ),
        .addr_to_dram_i    	( a_to_dram         ),
        .wdata_to_dram_i   	( d_to_dram         ),
        .wen_to_dram_i     	( we_to_dram        ),
        .wram_mode_i       	( wram_mode_to_dram ),
        .rram_mode_i       	( rram_mode_to_dram ),
        .rdata_from_dram_o 	( rdata_from_dram   )
    );

    counter u_counter(
        .clk         	( clk_to_cnt      ),
        .rst         	( rst_to_cnt      ),
        .perip_wdata 	( wdata_to_cnt    ),
        .cnt_wen     	( wen_to_cnt      ),
        .perip_rdata 	( rdata_from_cnt  )
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
        unique case(addr_to_sw)
            32'h8020_0000: rdata_from_sw = sw_i[31:0];
            32'h8020_0004: rdata_from_sw = sw_i[63:32];
            default: rdata_from_sw = 32'h0;
        endcase
    end
    // KEY
    assign rdata_from_key = {24'h0, key_i};

    // SEG
    
    seg_driver u_seg_driver(
        .clk_i            	(clk_to_seg      ),
        .rst_i            	(rst_to_seg      ),
        .addr_to_seg_i    	(addr_to_seg     ),
        .wdata_to_seg_i   	(wdata_to_seg    ),
        .wen_to_seg_i     	(wen_to_seg      ),
        .dp_i             	(seg_dp          ),
        .rdata_from_seg_o 	(rdata_from_seg  ),
        .led1_seg_o       	(seg_bus[7:0]    ),
        .led2_seg_o       	(seg_bus[17:10]  ),
        .led3_seg_o       	(seg_bus[27:20]  ),
        .led4_seg_o       	(seg_bus[37:30]  ),
        .seg_cs           	({seg_bus[9:8],seg_bus[19:18],seg_bus[29:28],seg_bus[39:38]})            
    );
    

    // seg_driver u_seg_driver(
    //     .clk_i            (clk_to_seg),
    //     .rst_i            (rst_to_seg),
    //     .addr_to_seg_i    (addr_to_seg),
    //     .wdata_to_seg_i   (wdata_to_seg),
    //     .wen_to_seg_i     (wen_to_seg),
    //     .dp_i             (seg_dp),
    //     .rdata_from_seg_o (rdata_from_seg),
    //     .led1_seg_o       (led1_seg_o),
    //     .led2_seg_o       (led2_seg_o),
    //     .led3_seg_o       (led3_seg_o),
    //     .led4_seg_o       (led4_seg_o),
    //     .led1_cs1_o       (led1_cs1_o),
    //     .led1_cs2_o       (led1_cs2_o),
    //     .led2_cs1_o       (led2_cs1_o),
    //     .led2_cs2_o       (led2_cs2_o),
    //     .led3_cs1_o       (led3_cs1_o),
    //     .led3_cs2_o       (led3_cs2_o),
    //     .led4_cs1_o       (led4_cs1_o),
    //     .led4_cs2_o       (led4_cs2_o)
    // );
endmodule