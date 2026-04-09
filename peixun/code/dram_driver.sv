module dram_driver (
    input logic clk_i,

    input logic [31:0] addr_to_dram_i,
    input logic [31:0] wdata_to_dram_i,
    input logic wen_to_dram_i,
    input logic [1:0] wram_mode_i,   // 0:B, 1:HW, 2:W, 3:None
    input logic [2:0] rram_mode_i,   // 0:B, 1:HW, 2:W, 4:BU, 5:HWU, 7:None

    output logic [31:0] rdata_from_dram_o
);

    logic [17:0] dram_byte_addr;
    logic [15:0] dram_word_addr;
    logic [1:0] offset;

    logic [31:0] dram_rdata;
    logic [31:0] dram_wdata;

    assign dram_byte_addr = addr_to_dram_i[17:0];
    assign dram_word_addr = addr_to_dram_i[17:2];
    assign offset = addr_to_dram_i[1:0];

    // 256 KB
    DRAM u_DRAM(
        .a(dram_word_addr),
        .d(dram_wdata),
        .clk(clk_i),
        .we(wen_to_dram_i),
        .spo(dram_rdata)
    );

    // 读
    always_comb begin
        rdata_from_dram_o = 32'h0000_0000;
        unique case(rram_mode_i)
            3'd0: begin
                unique case(offset)
                    2'b00: rdata_from_dram_o = {{24{dram_rdata[7]}}, dram_rdata[7:0]};
                    2'b01: rdata_from_dram_o = {{24{dram_rdata[15]}}, dram_rdata[15:8]};
                    2'b10: rdata_from_dram_o = {{24{dram_rdata[23]}}, dram_rdata[23:16]};
                    2'b11: rdata_from_dram_o = {{24{dram_rdata[31]}}, dram_rdata[31:24]};
                    default: rdata_from_dram_o = 32'h0000_0000;
                endcase
            end
            3'd1: begin
                unique case(offset[1])
                    1'b0: rdata_from_dram_o = {{16{dram_rdata[15]}}, dram_rdata[15:0]};
                    1'b1: rdata_from_dram_o = {{16{dram_rdata[31]}}, dram_rdata[31:16]};
                    default: rdata_from_dram_o = 32'h0000_0000;
                endcase
            end
            3'd2: begin
                rdata_from_dram_o = dram_rdata;
            end
            3'd4: begin
                unique case(offset)
                    2'b00: rdata_from_dram_o = {24'h0, dram_rdata[7:0]};
                    2'b01: rdata_from_dram_o = {24'h0, dram_rdata[15:8]};
                    2'b10: rdata_from_dram_o = {24'h0, dram_rdata[23:16]};
                    2'b11: rdata_from_dram_o = {24'h0, dram_rdata[31:24]};
                    default: rdata_from_dram_o = 32'h0000_0000;
                endcase
            end
            3'd5: begin
                unique case(offset[1])
                    1'b0: rdata_from_dram_o = {16'h0, dram_rdata[15:0]};
                    1'b1: rdata_from_dram_o = {16'h0, dram_rdata[31:16]};
                    default: rdata_from_dram_o = 32'h0000_0000;
                endcase
            end
            default: begin
            end
        endcase
    end

    // 写
    always_comb begin
        dram_wdata = wdata_to_dram_i;
        unique case(wram_mode_i)
            2'd0: begin
                unique case(offset)
                    2'b00: dram_wdata = {dram_rdata[31:8], wdata_to_dram_i[7:0]};
                    2'b01: dram_wdata = {dram_rdata[31:16], wdata_to_dram_i[7:0], dram_rdata[7:0]};
                    2'b10: dram_wdata = {dram_rdata[31:24], wdata_to_dram_i[7:0], dram_rdata[15:0]};
                    2'b11: dram_wdata = {wdata_to_dram_i[7:0], dram_rdata[23:0]};
                    default: dram_wdata = wdata_to_dram_i;
                endcase
            end
            2'd1: begin
                unique case(offset[1])
                    1'b0: dram_wdata = {dram_rdata[31:16], wdata_to_dram_i[15:0]};
                    1'b1: dram_wdata = {wdata_to_dram_i[15:0], dram_rdata[15:0]};
                    default: dram_wdata = wdata_to_dram_i;
                endcase
            end
            2'd2: begin
                dram_wdata = wdata_to_dram_i;
            end
            default: begin
            end
        endcase
    end

endmodule