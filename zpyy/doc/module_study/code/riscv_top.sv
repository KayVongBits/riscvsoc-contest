`timescale 1ns/1ps
`include "define.sv"

module riscv_top #(
    parameter FILE          = "rv32ui-p-addi.txt"
)(
    input logic                     clk,
    input logic                     rst
);

// if
logic                           if_jump_en_i        ;
logic [`ADD_WIDTH-1:0]          if_jump_addr_i      ;
logic [`ADD_WIDTH-1:0]          if_pc_o             ;
logic [`DATA_WIDTH-1:0]         if_inst_o           ;

// id   
logic [`ADD_WIDTH-1:0]          id_inst_add_i       ;
logic [`DATA_WIDTH-1:0]         id_inst_i           ;
logic [`REG_ADDR_WIDTH-1:0]     id_rs1_addr_o       ;
logic [`REG_ADDR_WIDTH-1:0]     id_rs2_addr_o       ;
logic [`REG_ADDR_WIDTH-1:0]     id_rd_addr_o        ;      
logic [`DATA_WIDTH-1:0]         id_rs1_data_i       ;
logic [`DATA_WIDTH-1:0]         id_rs2_data_i       ;
logic [`DATA_WIDTH-1:0]         id_rs1_data_o       ;
logic [`DATA_WIDTH-1:0]         id_rs2_data_o       ;
logic [`DATA_WIDTH-1:0]         id_imm_o            ;    

// ex
logic [`ADD_WIDTH-1:0]          ex_inst_add_i       ;
logic [`DATA_WIDTH-1:0]         ex_inst_i           ;
logic [`DATA_WIDTH-1:0]         ex_rs1_data_i       ;
logic [`DATA_WIDTH-1:0]         ex_rs2_data_i       ;
logic [`DATA_WIDTH-1:0]         ex_imm_i            ; 
logic                           ex_wr_rd_en_o       ;
logic [`REG_ADDR_WIDTH-1:0]     ex_rd_addr_o        ;
logic [`DATA_WIDTH-1:0]         ex_rd_data_o        ;

assign if_jump_en_i        = 1'b0;                     // 暂时不使用跳转功能
assign if_jump_addr_i      = {`ADD_WIDTH{1'b0}};       // 跳转地址   

pc u_pc (
    .clk         	(clk                )   ,
    .rst         	(rst                )   ,
    .jump_en_i   	(if_jump_en_i       )   ,
    .jump_addr_i 	(if_jump_addr_i     )   ,
    .pc_o        	(if_pc_o            )
);

rom #(
    .FILE           ( FILE                     )
) u_rom (
    .clk         	(clk                )   ,
    .rst         	(rst                )   ,
    .inst_addr_i 	(if_pc_o            )   ,   
    .inst_data_o 	(if_inst_o     )    
);


if2id u_if2id(
    .clk        	(clk                )   ,
    .rst        	(rst                )   ,
    .inst_add_i 	(if_pc_o            )   ,
    .inst_i     	(if_inst_o          )   ,
    .inst_add_o 	(id_inst_add_i      )   ,
    .inst_o     	(id_inst_i          )
);

decode u_decode(
    .inst_i     	(id_inst_i          )   ,
    .rs1_addr_o 	(id_rs1_addr_o      )   ,
    .rs2_addr_o 	(id_rs2_addr_o      )   ,
    .rd_addr_o  	(id_rd_addr_o       )   ,
    .rs1_data_i 	(id_rs1_data_i      )   ,
    .rs2_data_i 	(id_rs2_data_i      )   ,
    .rs1_data_o 	(id_rs1_data_o      )   ,
    .rs2_data_o 	(id_rs2_data_o      )   ,
    .imm_o      	(id_imm_o           )   
);

regs u_regs(
    .clk            (clk                )   ,
    .rst            (rst                )   ,              
    .rs1_addr_i     (id_rs1_addr_o      )   ,
    .rs2_addr_i     (id_rs2_addr_o      )   ,                   
    .rs1_data_o     (id_rs1_data_i      )   ,
    .rs2_data_o     (id_rs2_data_i      )   ,
    .wr_rd_en_i     (ex_wr_rd_en_o      )   ,
    .rd_addr_i      (ex_rd_addr_o       )   ,
    .rd_data_i      (ex_rd_data_o       )
);

id2ex u_id2ex(
    .clk            (clk                )   ,
    .rst            (rst                )   , 
    .inst_addr_i    (id_inst_add_i      )   ,
    .inst_addr_o    (ex_inst_add_i      )   ,
    .inst_i         (id_inst_i          )   ,
    .inst_o         (ex_inst_i          )   ,
    .rs1_data_i     (id_rs1_data_o      )   ,
    .rs1_data_o     (ex_rs1_data_i      )   ,
    .rs2_data_i     (id_rs2_data_o      )   ,
    .rs2_data_o     (ex_rs2_data_i      )   ,
    .imm_i          (id_imm_o           )   ,
    .imm_o          (ex_imm_i           )
);
execute u_execute(
    .inst_add_i     (ex_inst_add_i             )   ,
    .inst_i         (ex_inst_i                 )   ,
    .rs1_data_i     (ex_rs1_data_i             )   ,
    .rs2_data_i     (ex_rs2_data_i             )   ,
    .imm_i          (ex_imm_i                  )   ,
    .wr_rd_en_o     (ex_wr_rd_en_o             )   ,
    .rd_addr_o      (ex_rd_addr_o              )   ,
    .rd_data_o      (ex_rd_data_o              )   
);
endmodule

