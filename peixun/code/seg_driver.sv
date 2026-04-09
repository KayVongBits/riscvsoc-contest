module seg_driver (
    input logic clk_i,
    input logic rst_i,

    input logic [31:0] addr_to_seg_i,
    input logic [31:0] wdata_to_seg_i,
    input logic wen_to_seg_i,
    input logic [7:0] dp_i,
    output logic [31:0] rdata_from_seg_o,

    output logic [7:0] led1_seg_o,
    output logic [7:0] led2_seg_o,
    output logic [7:0] led3_seg_o,
    output logic [7:0] led4_seg_o,

    output logic [7:0] seg_cs
);

    localparam SEG_0 = 7'h3F;
    localparam SEG_1 = 7'h06;
    localparam SEG_2 = 7'h5B;
    localparam SEG_3 = 7'h4F;
    localparam SEG_4 = 7'h66;
    localparam SEG_5 = 7'h6D;
    localparam SEG_6 = 7'h7D;
    localparam SEG_7 = 7'h07;
    localparam SEG_8 = 7'h7F;
    localparam SEG_9 = 7'h6F;
    localparam SEG_A = 7'h77;
    localparam SEG_B = 7'h7C;
    localparam SEG_C = 7'h39;
    localparam SEG_D = 7'h5E;
    localparam SEG_E = 7'h79;
    localparam SEG_F = 7'h71;
    localparam SEG_OFF = 7'h00;

    logic [31:0] seg_data_r;
    logic [15:0] seg_cnt_r;
    logic seg_sel;

    logic [3:0] disp_hex;
    logic [7:0] disp_seg;

    assign rdata_from_seg_o = seg_data_r;

    function automatic logic [6:0] hex_to_seg(input logic [3:0] hex_val);
        logic [6:0] seg_out ;
        seg_out = SEG_OFF ;
        case (hex_val)
            4'h0: seg_out = SEG_0;
            4'h1: seg_out = SEG_1;
            4'h2: seg_out = SEG_2;
            4'h3: seg_out = SEG_3;
            4'h4: seg_out = SEG_4;
            4'h5: seg_out = SEG_5;
            4'h6: seg_out = SEG_6;
            4'h7: seg_out = SEG_7;
            4'h8: seg_out = SEG_8;
            4'h9: seg_out = SEG_9;
            4'hA: seg_out = SEG_A;
            4'hB: seg_out = SEG_B;
            4'hC: seg_out = SEG_C;
            4'hD: seg_out = SEG_D;
            4'hE: seg_out = SEG_E;
            4'hF: seg_out = SEG_F;
            default: ;
        endcase
        return seg_out;
    endfunction

    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            seg_data_r <= 32'h0;
        end else if (wen_to_seg_i && (addr_to_seg_i == 32'h8020_0020)) begin
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

    assign seg_sel = seg_cnt_r[15];

    // assign disp_hex = seg_data_r ;
    // always_comb begin
    //     disp_hex = 4'h0;
    //     case (seg_sel)
    //         3'd0: disp_hex = seg_data_r[3:0];
    //         3'd1: disp_hex = seg_data_r[7:4];
    //         3'd2: disp_hex = seg_data_r[11:8];
    //         3'd3: disp_hex = seg_data_r[15:12];
    //         3'd4: disp_hex = seg_data_r[19:16];
    //         3'd5: disp_hex = seg_data_r[23:20];
    //         3'd6: disp_hex = seg_data_r[27:24];
    //         3'd7: disp_hex = seg_data_r[31:28];
    //     endcase
    // end

    always_comb begin
        led1_seg_o = SEG_OFF;
        led2_seg_o = SEG_OFF;
        led3_seg_o = SEG_OFF;
        led4_seg_o = SEG_OFF;

        seg_cs = 8'hff ;

        case (seg_sel)
            1'b0: begin 
                seg_cs = 8'b1010_1010 ; 
                led1_seg_o = {dp_i[0],hex_to_seg(seg_data_r[3:0])} ;  // 从右到左依次为1243 
                led2_seg_o = {dp_i[2],hex_to_seg(seg_data_r[11:8])} ;
                led3_seg_o = {dp_i[4],hex_to_seg(seg_data_r[19:16])} ;
                led4_seg_o = {dp_i[6],hex_to_seg(seg_data_r[27:24])} ;
            end
            1'b1 : begin
                seg_cs = 8'b0101_0101 ; 
                led1_seg_o = {dp_i[1],hex_to_seg(seg_data_r[7:4])} ;
                led2_seg_o = {dp_i[3],hex_to_seg(seg_data_r[15:12])} ;
                led3_seg_o = {dp_i[5],hex_to_seg(seg_data_r[23:20])} ;
                led4_seg_o = {dp_i[7],hex_to_seg(seg_data_r[31:28])} ;
            end
            default: begin
            end
        endcase
    end

endmodule