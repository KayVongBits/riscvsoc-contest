`include "../define/define.sv"

module wb(
    input   logic                           wr_rd_en_i          ,
    input   logic   [`REG_ADDR_WIDTH-1:0]   rd_addr_i           ,
    input   logic   [`DATA_WIDTH-1:0]       rd_data_i           ,
    input   logic   [`ADD_WIDTH-1:0]        ram_addr_i          ,
    input   logic   [`RAM_RD_MODE_LEN-1:0]  rd_ram_en_mode_i    , 
    input   logic   [`DATA_WIDTH-1:0]       ram_data_i          ,
    output  logic                           wr_rd_en_o          ,
    output  logic   [`REG_ADDR_WIDTH-1:0]   rd_addr_o           ,
    output  logic   [`DATA_WIDTH-1:0]       rd_data_o        
);

logic   [`DATA_WIDTH-1:0]   ram_data_ext    ;

always_comb begin : wb_comb
    ram_data_ext    = ram_data_i    ;

    unique case (rd_ram_en_mode_i)
        `RAM_RD_EN_LB : begin
            unique case (ram_addr_i[1:0])
                2'b00 : ram_data_ext = {{24{ram_data_i[7]}}, ram_data_i[7:0]}    ;
                2'b01 : ram_data_ext = {{24{ram_data_i[15]}}, ram_data_i[15:8]}  ;
                2'b10 : ram_data_ext = {{24{ram_data_i[23]}}, ram_data_i[23:16]} ;
                2'b11 : ram_data_ext = {{24{ram_data_i[31]}}, ram_data_i[31:24]} ;
                default : begin end
            endcase
        end
        `RAM_RD_EN_LH : begin
            unique case (ram_addr_i[1])
                1'b0 : ram_data_ext = {{16{ram_data_i[15]}}, ram_data_i[15:0]}  ;
                1'b1 : ram_data_ext = {{16{ram_data_i[31]}}, ram_data_i[31:16]} ;
                default : begin end
            endcase
        end
        `RAM_RD_EN_LW : begin
            ram_data_ext = ram_data_i    ;
        end
        `RAM_RD_EN_LBU : begin
            unique case (ram_addr_i[1:0])
                2'b00 : ram_data_ext = {24'b0, ram_data_i[7:0]}     ;
                2'b01 : ram_data_ext = {24'b0, ram_data_i[15:8]}    ;
                2'b10 : ram_data_ext = {24'b0, ram_data_i[23:16]}   ;
                2'b11 : ram_data_ext = {24'b0, ram_data_i[31:24]}   ;
                default : begin end
            endcase
        end
        `RAM_RD_EN_LHU : begin
            unique case (ram_addr_i[1])
                1'b0 : ram_data_ext = {16'b0, ram_data_i[15:0]}     ;
                1'b1 : ram_data_ext = {16'b0, ram_data_i[31:16]}    ;
                default : begin end
            endcase
        end
        default : begin end
    endcase
    
end

assign wr_rd_en_o   = wr_rd_en_i    ;
assign rd_addr_o    = rd_addr_i     ;

assign rd_data_o    = (|rd_ram_en_mode_i) ? ram_data_ext : rd_data_i ; 

endmodule