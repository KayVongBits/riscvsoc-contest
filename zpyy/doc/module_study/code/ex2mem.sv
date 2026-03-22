`include "define.sv"

module ex2mem(
    input   logic                           clk                 ,
    input   logic                           rst                 ,

    // from ex to regs
    input   logic                           wr_rd_en_i          ,
    input   logic   [`REG_ADDR_WIDTH-1:0]   rd_addr_i           ,
    input   logic   [`DATA_WIDTH-1:0]       rd_data_i           ,

    // from ex to mem
    input   logic   [`ADD_WIDTH-1:0]        ram_addr_i          ,
    input   logic   [`BYTE_PER_WORD-1:0]    wr_ram_en_mask_i    ,
    input   logic   [`DATA_WIDTH-1:0]       wr_ram_data_i       ,
    input   logic   [`RAM_RD_MODE_LEN-1:0]  rd_ram_en_mode_i    ,

    // to regs
    output  logic                           wr_rd_en_o          ,
    output  logic   [`REG_ADDR_WIDTH-1:0]   rd_addr_o           ,
    output  logic   [`DATA_WIDTH-1:0]       rd_data_o           ,
 
    // to mem
    output  logic   [`ADD_WIDTH-1:0]        ram_addr_o          ,
    output  logic   [`BYTE_PER_WORD-1:0]    wr_ram_en_mask_o    ,
    output  logic   [`DATA_WIDTH-1:0]       wr_ram_data_o       ,
    output  logic   [`RAM_RD_MODE_LEN-1:0]  rd_ram_en_mode_o   
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        wr_rd_en_o          <= `REG_WR_DISABLE      ;
        rd_addr_o           <= `RST_REG             ;
        rd_data_o           <= `RST_REG_VALUE       ;
        ram_addr_o          <= `RAM_RST_ADD         ;
        wr_ram_en_mask_o    <= `RAM_WR_DISABLE      ;
        wr_ram_data_o       <= `RAM_RST_DATA        ;
        rd_ram_en_mode_o    <= `RAM_RD_DISABLE      ;
    end else begin
        wr_rd_en_o          <= wr_rd_en_i           ;
        rd_addr_o           <= rd_addr_i            ;
        rd_data_o           <= rd_data_i            ;
        ram_addr_o          <= ram_addr_i           ;
        wr_ram_en_mask_o    <= wr_ram_en_mask_i     ;
        wr_ram_data_o       <= wr_ram_data_i        ;
        rd_ram_en_mode_o    <= rd_ram_en_mode_i     ;
    end
end

endmodule