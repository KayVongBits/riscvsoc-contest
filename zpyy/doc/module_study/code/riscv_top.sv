`timescale 1ns/1ps
`include "define.sv"

module riscv_top #(
    parameter FILE          = "rv32i_inst.txt"
)(
    input logic                     clk,
    input logic                     rst
);

logic                       jump_en_i;
logic [`ADD_WIDTH-1:0]      pc_o;
logic [`ADD_WIDTH-1:0]      jump_addr_i;
logic [`DATA_WIDTH-1:0]     inst_data_o;

assign jump_en_i        = 1'b0;                // 暂时不使用跳转功能
assign jump_addr_i      = {`ADD_WIDTH{1'b0}}; // 跳转地址

pc u_pc (
    .clk         	(clk          ),
    .rst         	(rst          ),
    .jump_en_i   	(jump_en_i    ),
    .jump_addr_i 	(jump_addr_i  ),
    .pc_o        	(pc_o         )
);



rom #(
    .FILE           (FILE       )
) u_rom (
    .clk         	(clk          ),
    .rst         	(rst          ),
    .inst_addr_i 	(pc_o         ),   
    .inst_data_o 	(inst_data_o  )    
);


endmodule

