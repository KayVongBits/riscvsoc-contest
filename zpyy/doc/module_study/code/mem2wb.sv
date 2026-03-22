`include "define.sv"

module mem2wb(
    input   logic                           clk                 ,
    input   logic                           rst                 ,

    // from mem to regs
    input   logic                           wr_rd_en_i          ,
    input   logic   [`REG_ADDR_WIDTH-1:0]   rd_addr_i           ,
    input   logic   [`DATA_WIDTH-1:0]       rd_data_i           ,

    // from mem to ctrl data from ram
    input   logic   [`ADD_WIDTH-1:0]        ram_addr_i          ,   // use low 2 bits to select
    input   logic   [`RAM_RD_MODE_LEN-1:0]  rd_ram_en_mode_i    , 

    // to regs
    output  logic                           wr_rd_en_o          ,
    output  logic   [`REG_ADDR_WIDTH-1:0]   rd_addr_o           ,
    output  logic   [`DATA_WIDTH-1:0]       rd_data_o           ,

    // to ctrl data from ram
    output  logic   [`ADD_WIDTH-1:0]        ram_addr_o          ,
    output  logic   [`RAM_RD_MODE_LEN-1:0]  rd_ram_en_mode_o            
);


always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        wr_rd_en_o          <= `REG_WR_DISABLE      ;
        rd_addr_o           <= `RST_REG             ;
        rd_data_o           <= `RST_REG_VALUE       ;
        ram_addr_o          <= `RAM_RST_ADD         ;
        rd_ram_en_mode_o    <= `RAM_WR_DISABLE      ;
    end else begin
        wr_rd_en_o          <= wr_rd_en_i           ;
        rd_addr_o           <= rd_addr_i            ;
        rd_data_o           <= rd_data_i            ;
        ram_addr_o          <= ram_addr_i           ;
        rd_ram_en_mode_o    <= rd_ram_en_mode_i     ;
    end
end

endmodule