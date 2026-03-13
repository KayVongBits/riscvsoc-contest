`define PC_INIT_ADDR 32'h0000_0000 

module pc #(
    parameter ADD_WIDTH = 32
)(
    input wire clk,
    input wire rst,   // 蓝桥杯板子复位时正边沿

    input wire jump_en_i,
    input wire [ADD_WIDTH-1:0] jump_addr_i,

    output reg [ADD_WIDTH-1:0] pc_o
);

reg [ADD_WIDTH-1:0] current_pc;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        pc_o <= `PC_INIT_ADDR;
    end else if (jump_en_i) begin
        pc_o <= jump_addr_i;
    end else begin
        pc_o <= pc_o + 4;       // 每条指令长度为4字节
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        current_pc <= `PC_INIT_ADDR;
    end else begin
        current_pc <= pc_o;
    end
end

endmodule