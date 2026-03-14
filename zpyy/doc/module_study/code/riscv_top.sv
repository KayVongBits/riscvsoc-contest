`timescale 1ns/1ps
`include "define.sv"

module riscv_top #(
    parameter FILE          = "rv32ui-p-addi.txt"
)(
    input logic                     clk,
    input logic                     rst
);

logic                       jump_en_i;
logic [`ADD_WIDTH-1:0]      pc_o;
logic [`ADD_WIDTH-1:0]      jump_addr_i;
logic [`DATA_WIDTH-1:0]     inst_data_o;
logic [`ADD_WIDTH-1:0]      inst_add_o;
logic [`DATA_WIDTH-1:0]     inst_o;

logic [`REG_ADDR_WIDTH-1:0]   rs1_addr_o;
logic [`REG_ADDR_WIDTH-1:0]   rs2_addr_o;
logic [`REG_ADDR_WIDTH-1:0]   rd_addr_o;
logic [`DATA_WIDTH-1:0]       rs1_data_i;
logic [`DATA_WIDTH-1:0]       rs2_data_i;
logic [`DATA_WIDTH-1:0]       rs1_data_o;
logic [`DATA_WIDTH-1:0]       rs2_data_o;

assign jump_en_i        = 1'b0;                // 暂时不使用跳转功能
assign jump_addr_i      = {`ADD_WIDTH{1'b0}}; // 跳转地址
assign rs1_data_i      = `DATA_WIDTH'd50;  // 寄存器数据输入，暂时不连接寄存器堆
assign rs2_data_i      = `DATA_WIDTH'd100; //

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


if2id u_if2id(
    .clk        	(clk         ),
    .rst        	(rst         ),
    .inst_add_i 	(pc_o  ),
    .inst_i     	(inst_data_o      ),
    .inst_add_o 	(inst_add_o  ),
    .inst_o     	(inst_o      )
);

decode u_decode(
    .inst_i     	(inst_o      ),
    .rs1_addr_o 	(rs1_addr_o  ),
    .rs2_addr_o 	(rs2_addr_o  ),
    .rd_addr_o  	(rd_addr_o   ),
    .rs1_data_i 	(rs1_data_i  ),
    .rs2_data_i 	(rs2_data_i  ),
    .rs1_data_o 	(rs1_data_o  ),
    .rs2_data_o 	(rs2_data_o  )
);


endmodule

