module seg_driver (
    input logic clk_i,
    input logic rst_i,

    input logic [15:0] addr_to_seg_i,
    input logic [31:0] wdata_to_seg_i,
    input logic wen_to_seg_i,
    input logic [7:0] dp_i,
    output logic [31:0] rdata_from_seg_o,

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

    localparam SEG_0 = 8'h3F;
    localparam SEG_1 = 8'h06;
    localparam SEG_2 = 8'h5B;
    localparam SEG_3 = 8'h4F;
    localparam SEG_4 = 8'h66;
    localparam SEG_5 = 8'h6D;
    localparam SEG_6 = 8'h7D;
    localparam SEG_7 = 8'h07;
    localparam SEG_8 = 8'h7F;
    localparam SEG_9 = 8'h6F;
    localparam SEG_A = 8'h77;
    localparam SEG_B = 8'h7C;
    localparam SEG_C = 8'h39;
    localparam SEG_D = 8'h5E;
    localparam SEG_E = 8'h79;
    localparam SEG_F = 8'h71;
    localparam SEG_OFF = 8'h00;

    logic [31:0] seg_data_r;
    logic [15:0] seg_cnt_r;
    logic [2:0] seg_sel;

    logic [3:0] disp_hex;
    logic [7:0] disp_seg;

    assign rdata_from_seg_o = 32'h0;

    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            seg_data_r <= 32'h0;
        end else if (wen_to_seg_i && (addr_to_seg_i == 16'hF020)) begin
            seg_data_r <= wdata_to_seg_i;
        end
    end

    // 计数器
    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            seg_cnt_r <= 16'd0;
        end else begin
            seg_cnt_r <= seg_cnt_r + 16'd1;
        end
    end

    assign seg_sel = seg_cnt_r[15:13];

    always_comb begin
        disp_hex = 4'h0;
        case (seg_sel)
            3'd0: disp_hex = seg_data_r[3:0];
            3'd1: disp_hex = seg_data_r[7:4];
            3'd2: disp_hex = seg_data_r[11:8];
            3'd3: disp_hex = seg_data_r[15:12];
            3'd4: disp_hex = seg_data_r[19:16];
            3'd5: disp_hex = seg_data_r[23:20];
            3'd6: disp_hex = seg_data_r[27:24];
            3'd7: disp_hex = seg_data_r[31:28];
        endcase
    end

    always_comb begin
        disp_seg = SEG_OFF;
        case (disp_hex)
            4'h0: disp_seg = SEG_0;
            4'h1: disp_seg = SEG_1;
            4'h2: disp_seg = SEG_2;
            4'h3: disp_seg = SEG_3;
            4'h4: disp_seg = SEG_4;
            4'h5: disp_seg = SEG_5;
            4'h6: disp_seg = SEG_6;
            4'h7: disp_seg = SEG_7;
            4'h8: disp_seg = SEG_8;
            4'h9: disp_seg = SEG_9;
            4'hA: disp_seg = SEG_A;
            4'hB: disp_seg = SEG_B;
            4'hC: disp_seg = SEG_C;
            4'hD: disp_seg = SEG_D;
            4'hE: disp_seg = SEG_E;
            4'hF: disp_seg = SEG_F;
        endcase
    end

    always_comb begin
        led1_seg_o = SEG_OFF;
        led2_seg_o = SEG_OFF;
        led3_seg_o = SEG_OFF;
        led4_seg_o = SEG_OFF;

        led1_cs1_o = 1'b1;
        led1_cs2_o = 1'b1;
        led2_cs1_o = 1'b1;
        led2_cs2_o = 1'b1;
        led3_cs1_o = 1'b1;
        led3_cs2_o = 1'b1;
        led4_cs1_o = 1'b1;
        led4_cs2_o = 1'b1;

        case (seg_sel)
            3'd0: begin
                led1_seg_o = {dp_i[0], disp_seg[6:0]};
                led1_cs1_o = 1'b0;
            end
            3'd1: begin
                led1_seg_o = {dp_i[1], disp_seg[6:0]};
                led1_cs2_o = 1'b0;
            end
            3'd2: begin
                led2_seg_o = {dp_i[2], disp_seg[6:0]};
                led2_cs1_o = 1'b0;
            end
            3'd3: begin
                led2_seg_o = {dp_i[3], disp_seg[6:0]};
                led2_cs2_o = 1'b0;
            end
            3'd4: begin
                led4_seg_o = {dp_i[4], disp_seg[6:0]};
                led4_cs1_o = 1'b0;
            end
            3'd5: begin
                led4_seg_o = {dp_i[5], disp_seg[6:0]};
                led4_cs2_o = 1'b0;
            end
            3'd6: begin
                led3_seg_o = {dp_i[6], disp_seg[6:0]};
                led3_cs1_o = 1'b0;
            end
            3'd7: begin
                led3_seg_o = {dp_i[7], disp_seg[6:0]};
                led3_cs2_o = 1'b0;
            end
            default: begin
            end
        endcase
    end

endmodule