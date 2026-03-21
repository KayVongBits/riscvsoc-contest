`include "define.sv"

module ram(
    input   logic                           clk             ,

    input   logic  [`ADD_WIDTH-1:0]         addr_i          ,
    
    input   logic  [`BYTE_PER_WORD-1:0]     wr_en_mask_i    ,        // write enable mask, 1 means write, 0 means don't write
    input   logic  [`DATA_WIDTH-1:0]        wr_data_i       ,        // write data

    input   logic                           rd_en_i         ,        // read enable
    output  logic  [`DATA_WIDTH-1:0]        rd_data_o                // read data
);

logic   [`DATA_WIDTH-1:0]   ram_data    [`RAM_SIZE-1:0] ;
logic   [`ADD_WIDTH-3:0]    word_idx                    ;
logic                       we                          ;

assign   word_idx = addr_i[31:2]    ;
assign   we       = |wr_en_mask_i   ;

initial begin
    $readmemh(`RAM_INIT_FILE, ram_data); 
end

// write data logic
always_ff @(posedge clk) begin
    if (we) begin
        if (wr_en_mask_i[0]) ram_data[word_idx][7:0]   <= wr_data_i[7:0] ;
        if (wr_en_mask_i[1]) ram_data[word_idx][15:8]  <= wr_data_i[15:8] ;
        if (wr_en_mask_i[2]) ram_data[word_idx][23:16] <= wr_data_i[23:16] ;
        if (wr_en_mask_i[3]) ram_data[word_idx][31:24] <= wr_data_i[31:24] ;
    end
end


// read data output logic
always_ff @(posedge clk) begin
    if (rd_en_i) begin
        rd_data_o <= ram_data[word_idx];
    end else begin
        rd_data_o <= `RAM_RST_DATA;
    end
end

endmodule