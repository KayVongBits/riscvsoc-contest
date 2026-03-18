`timescale 1ns/1ps
`include "define.sv"

module riscv_top (
    input   logic                       clk         ,
    input   logic                       rst         ,
    output  logic [1:0]                 led_mode    
);


// if
logic                           if_jump_en_i        ;
logic [`ADD_WIDTH-1:0]          if_jump_addr_i      ;
(*mark_debug = "true"*)logic [`ADD_WIDTH-1:0]          if_pc_o             ;
(*mark_debug = "true"*)logic [`DATA_WIDTH-1:0]         if_inst_o           ;

// id   
logic [`ADD_WIDTH-1:0]          id_inst_add_i       ;
(*mark_debug = "true"*)logic [`DATA_WIDTH-1:0]         id_inst_i           ;
logic [`REG_ADDR_WIDTH-1:0]     id_rs1_addr_o       ;
logic [`REG_ADDR_WIDTH-1:0]     id_rs2_addr_o       ;
logic [`REG_ADDR_WIDTH-1:0]     id_rd_addr_o        ;      
logic [`DATA_WIDTH-1:0]         id_rs1_data_i       ;
logic [`DATA_WIDTH-1:0]         id_rs2_data_i       ;
logic [`DATA_WIDTH-1:0]         id_rs1_data_o       ;
logic [`DATA_WIDTH-1:0]         id_rs2_data_o       ;
logic [`DATA_WIDTH-1:0]         id_imm_o            ;    
logic                           id_alu_src1_sel_o   ;
logic                           id_alu_src2_sel_o   ;
// ex
logic [`ADD_WIDTH-1:0]          ex_inst_add_i       ;
(*mark_debug = "true"*)logic [`DATA_WIDTH-1:0]         ex_inst_i           ;
logic [`DATA_WIDTH-1:0]         ex_rs1_data_i       ;
logic [`DATA_WIDTH-1:0]         ex_rs2_data_i       ;
logic [`DATA_WIDTH-1:0]         ex_imm_i            ; 
logic                           ex_alu_src1_sel_i   ;
logic                           ex_alu_src2_sel_i   ;
(*mark_debug = "true"*)logic                           ex_wr_rd_en_o       ;
(*mark_debug = "true"*)logic [`REG_ADDR_WIDTH-1:0]     ex_rd_addr_o        ;
(*mark_debug = "true"*)logic [`DATA_WIDTH-1:0]         ex_rd_data_o        ;
(*mark_debug = "true"*)logic                           ex_jump_en_o        ;
(*mark_debug = "true"*)logic [`ADD_WIDTH-1:0]          ex_jump_addr_o      ;

// ctrl
logic                           ctrl_flush_if2id    ;
logic                           ctrl_flush_id2ex    ;

assign led_mode = {u_regs.regs[26][0], u_regs.regs[27][0]};
(* dont_touch = "true" *)pc u_pc (
    .clk         	(clk                )   ,
    .rst         	(rst                )   ,
    .jump_en_i   	(ex_jump_en_o       )   ,
    .jump_addr_i 	(ex_jump_addr_o     )   ,
    .pc_o        	(if_pc_o            )
);

(* dont_touch = "true" *)rom #(
    .FILE           (`FILE               )
) u_rom (
    .clk         	(clk                )   ,
    .rst         	(rst                )   ,
    .inst_addr_i 	(if_pc_o            )   ,   
    .inst_data_o 	(if_inst_o     )    
);


(* dont_touch = "true" *)pipeline_ctrl u_pipeline_ctrl(
    .jump_en_i     	(ex_jump_en_o       )   ,
    .flush_if2id_o 	(ctrl_flush_if2id   )   ,
    .flush_id2ex_o 	(ctrl_flush_id2ex   )
);
 

(* dont_touch = "true" *)if2id u_if2id(
    .clk        	(clk                )   ,
    .rst        	(rst                )   ,
    .flush_if2id_i  (ctrl_flush_if2id   )   ,
    .inst_add_i 	(if_pc_o            )   ,
    .inst_i     	(if_inst_o          )   ,
    .inst_add_o 	(id_inst_add_i      )   ,
    .inst_o     	(id_inst_i          )
);

(* dont_touch = "true" *)decode u_decode(
    .inst_i     	(id_inst_i          )   ,
    .rs1_addr_o 	(id_rs1_addr_o      )   ,
    .rs2_addr_o 	(id_rs2_addr_o      )   ,
    .rd_addr_o  	(id_rd_addr_o       )   ,
    .rs1_data_i 	(id_rs1_data_i      )   ,
    .rs2_data_i 	(id_rs2_data_i      )   ,
    .rs1_data_o 	(id_rs1_data_o      )   ,
    .rs2_data_o 	(id_rs2_data_o      )   ,
    .imm_o      	(id_imm_o           )   ,
    .alu_src1_sel_o (id_alu_src1_sel_o  )   ,
    .alu_src2_sel_o (id_alu_src2_sel_o  )
);

(* dont_touch = "true" *)regs u_regs(
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

(* dont_touch = "true" *)id2ex u_id2ex(
    .clk            (clk                )   ,
    .rst            (rst                )   ,
    .flush_id2ex_i  (ctrl_flush_id2ex   )   ,
    .inst_addr_i    (id_inst_add_i      )   ,
    .inst_addr_o    (ex_inst_add_i      )   ,
    .inst_i         (id_inst_i          )   ,
    .inst_o         (ex_inst_i          )   ,
    .rs1_data_i     (id_rs1_data_o      )   ,
    .rs1_data_o     (ex_rs1_data_i      )   ,
    .rs2_data_i     (id_rs2_data_o      )   ,
    .rs2_data_o     (ex_rs2_data_i      )   ,
    .imm_i          (id_imm_o           )   ,
    .imm_o          (ex_imm_i           )   ,
    .alu_src1_sel_i (id_alu_src1_sel_o  )   ,
    .alu_src2_sel_i (id_alu_src2_sel_o  )   ,
    .alu_src1_sel_o (ex_alu_src1_sel_i  )   ,
    .alu_src2_sel_o (ex_alu_src2_sel_i)
);

(* dont_touch = "true" *)execute u_execute(
    .inst_add_i     (ex_inst_add_i      )   ,
    .inst_i         (ex_inst_i          )   ,
    .rs1_data_i     (ex_rs1_data_i      )   ,
    .rs2_data_i     (ex_rs2_data_i      )   ,
    .imm_i          (ex_imm_i           )   ,
    .alu_src1_sel_i (ex_alu_src1_sel_i  )   ,
    .alu_src2_sel_i (ex_alu_src2_sel_i  )   ,
    .wr_rd_en_o     (ex_wr_rd_en_o      )   ,
    .rd_addr_o      (ex_rd_addr_o       )   ,
    .rd_data_o      (ex_rd_data_o       )   ,
    .jump_en_o      (ex_jump_en_o       )   ,
    .jump_addr_o    (ex_jump_addr_o     )
);

endmodule

