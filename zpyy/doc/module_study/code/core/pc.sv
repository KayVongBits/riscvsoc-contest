`include "../define/define.sv"

module pc(
    input   logic                           clk         ,
    input   logic                           rst         ,   // 蓝桥杯板子复位时正边沿

    input   logic                           jump_en_i   ,
    input   logic       [`ADD_WIDTH-1:0]    jump_addr_i ,

    output  logic       [`ADD_WIDTH-1:0]    pc_o        ,
    output  logic       [`ADD_WIDTH-1:0]    inst_o    
);

// logic define
logic [`ADD_WIDTH-1:0] current_pc   ;

always_ff @(posedge clk or posedge rst) begin : pc_update_seq
    if (rst) begin
        pc_o <= `PC_INIT_ADDR   ;
    end else if (jump_en_i) begin
        pc_o <= jump_addr_i     ;
    end else begin
        pc_o <= pc_o + `PC_STEP ;       // 每条指令长度为4字节
    end
end : pc_update_seq

always_ff @(posedge clk or posedge rst) begin : current_pc_seq
    if (rst) begin
        inst_o <= `PC_INIT_ADDR ;
    end else begin
        inst_o <= pc_o          ;
    end
end : current_pc_seq

endmodule