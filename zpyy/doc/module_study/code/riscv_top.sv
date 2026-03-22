`timescale 1ns/1ps
`include "define.sv"

module riscv_top (
    input   logic                       clk         ,
    input   logic                       rst         ,
    output  logic [1:0]                 led_mode    
);


// if
logic                           if_jump_en_i            ;
logic [`ADD_WIDTH-1:0]          if_jump_addr_i          ;
(*mark_debug = "true"*)logic [`ADD_WIDTH-1:0]          if_pc_o             ;
(*mark_debug = "true"*)logic [`DATA_WIDTH-1:0]         if_inst_o           ;

// id   
logic [`ADD_WIDTH-1:0]          id_inst_add_i           ;
(*mark_debug = "true"*)logic [`DATA_WIDTH-1:0]         id_inst_i           ;
logic [`REG_ADDR_WIDTH-1:0]     id_rs1_addr_o           ;
logic [`REG_ADDR_WIDTH-1:0]     id_rs2_addr_o           ;
logic [`REG_ADDR_WIDTH-1:0]     id_rd_addr_o            ;      
logic [`DATA_WIDTH-1:0]         id_rs1_data_i           ;
logic [`DATA_WIDTH-1:0]         id_rs2_data_i           ;
logic [`DATA_WIDTH-1:0]         id_rs1_data_o           ;
logic [`DATA_WIDTH-1:0]         id_rs2_data_o           ;
logic [`DATA_WIDTH-1:0]         id_imm_o                ;    
logic                           id_alu_src1_sel_o       ;
logic                           id_alu_src2_sel_o       ;

// ex
logic [`ADD_WIDTH-1:0]          ex_inst_add_i           ;
(*mark_debug = "true"*)logic [`DATA_WIDTH-1:0]         ex_inst_i           ;
logic [`DATA_WIDTH-1:0]         ex_rs1_data_i           ;
logic [`DATA_WIDTH-1:0]         ex_rs2_data_i           ;
logic [`DATA_WIDTH-1:0]         ex_imm_i                ; 
logic                           ex_alu_src1_sel_i       ;
logic                           ex_alu_src2_sel_i       ;
(*mark_debug = "true"*)logic                           ex_wr_rd_en_o       ;
(*mark_debug = "true"*)logic [`REG_ADDR_WIDTH-1:0]     ex_rd_addr_o        ;
(*mark_debug = "true"*)logic [`DATA_WIDTH-1:0]         ex_rd_data_o        ;
(*mark_debug = "true"*)logic                           ex_jump_en_o        ;
(*mark_debug = "true"*)logic [`ADD_WIDTH-1:0]          ex_jump_addr_o      ;
logic [`ADD_WIDTH-1:0]          ex_ram_addr_o           ;
logic [`BYTE_PER_WORD-1:0]      ex_ram_wr_en_mask_o     ;
logic [`DATA_WIDTH-1:0]         ex_ram_wr_data_o        ;
logic [`RAM_RD_MODE_LEN-1:0]    ex_ram_rd_en_mode_o     ;

// mem
logic                           mem_wr_rd_en_i          ;
logic [`REG_ADDR_WIDTH-1:0]     mem_rd_addr_i           ;
logic [`DATA_WIDTH-1:0]         mem_rd_data_i           ;
logic [`ADD_WIDTH-1:0]          mem_ram_addr_i          ;
logic [`BYTE_PER_WORD-1:0]      mem_wr_ram_en_mask_i    ;
logic [`DATA_WIDTH-1:0]         mem_wr_ram_data_i       ;
logic [`RAM_RD_MODE_LEN-1:0]    mem_rd_ram_en_mode_i    ;

// ram
logic [`DATA_WIDTH-1:0]         ram_rd_data_o           ;
logic                           ram_rd_en_i             ;

// wb
logic                           wb_wr_rd_en_i           ;
logic [`REG_ADDR_WIDTH-1:0]     wb_rd_addr_i            ;
logic [`DATA_WIDTH-1:0]         wb_rd_data_i            ;
logic [`ADD_WIDTH-1:0]          wb_ram_addr_i           ;
logic [`RAM_RD_MODE_LEN-1:0]    wb_rd_ram_en_mode_i     ;

// regs
logic                           regs_wr_rd_en_i         ;
logic   [`REG_ADDR_WIDTH-1:0]   regs_rd_addr_i          ;
logic   [`DATA_WIDTH-1:0]       regs_rd_data_i          ;

// ctrl
logic                           ctrl_flush_if2id        ;
logic                           ctrl_flush_id2ex        ;



assign led_mode = {u_regs.regs[26][0], u_regs.regs[27][0]};
(* dont_touch = "true" *)pc u_pc (
    .clk         	(clk                )   ,
    .rst         	(rst                )   ,
    .jump_en_i   	(ex_jump_en_o       )   ,
    .jump_addr_i 	(ex_jump_addr_o     )   ,
    .pc_o        	(if_pc_o            )
);

(* dont_touch = "true" *)rom u_rom (
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
    .wr_rd_en_i     (regs_wr_rd_en_i    )   ,
    .rd_addr_i      (regs_rd_addr_i     )   ,
    .rd_data_i      (regs_rd_data_i     )
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
    .inst_add_i         (ex_inst_add_i          )   ,
    .inst_i             (ex_inst_i              )   ,
    .rs1_data_i         (ex_rs1_data_i          )   ,
    .rs2_data_i         (ex_rs2_data_i          )   ,
    .imm_i              (ex_imm_i               )   ,
    .alu_src1_sel_i     (ex_alu_src1_sel_i      )   ,
    .alu_src2_sel_i     (ex_alu_src2_sel_i      )   ,
    .wr_rd_en_o         (ex_wr_rd_en_o          )   ,
    .rd_addr_o          (ex_rd_addr_o           )   ,
    .rd_data_o          (ex_rd_data_o           )   ,
    .jump_en_o          (ex_jump_en_o           )   ,
    .jump_addr_o        (ex_jump_addr_o         )   ,
    .ram_addr_o         (ex_ram_addr_o          )   ,
    .wr_ram_en_mask_o   (ex_ram_wr_en_mask_o    )   ,
    .wr_ram_data_o      (ex_ram_wr_data_o       )   ,
    .rd_ram_en_mode_o   (ex_ram_rd_en_mode_o    )       
);


ex2mem u_ex2mem(
    .clk                (clk                    )   ,
    .rst                (rst                    )   ,
    .wr_rd_en_i         (ex_wr_rd_en_o          )   ,
    .rd_addr_i          (ex_rd_addr_o           )   ,
    .rd_data_i          (ex_rd_data_o           )   ,
    .ram_addr_i         (ex_ram_addr_o          )   ,
    .wr_ram_en_mask_i   (ex_ram_wr_en_mask_o    )   ,
    .wr_ram_data_i      (ex_ram_wr_data_o       )   ,
    .rd_ram_en_mode_i   (ex_ram_rd_en_mode_o    )   ,
    .wr_rd_en_o         (mem_wr_rd_en_i         )   ,
    .rd_addr_o          (mem_rd_addr_i          )   ,
    .rd_data_o          (mem_rd_data_i          )   ,
    .ram_addr_o         (mem_ram_addr_i         )   ,
    .wr_ram_en_mask_o   (mem_wr_ram_en_mask_i   )   ,
    .wr_ram_data_o      (mem_wr_ram_data_i      )   ,
    .rd_ram_en_mode_o   (mem_rd_ram_en_mode_i   )
);

assign ram_rd_en_i = |mem_rd_ram_en_mode_i       ;

ram u_ram(
    .clk                (clk                    )   ,
    .addr_i             (mem_ram_addr_i         )   ,
    .wr_en_mask_i       (mem_wr_ram_en_mask_i   )   ,        // write enable mask, 1 means write, 0 means don't write
    .wr_data_i          (mem_wr_ram_data_i      )   ,        // write data
    .rd_en_i            (ram_rd_en_i            )   ,        // read enable
    .rd_data_o          (ram_rd_data_o          )           // read data
);

mem2wb u_mem2wb(
    .clk                (clk                    )   ,
    .rst                (rst                    )   ,
    .wr_rd_en_i         (mem_wr_rd_en_i         )   ,
    .rd_addr_i          (mem_rd_addr_i          )   ,
    .rd_data_i          (mem_rd_data_i          )   ,
    .ram_addr_i         (mem_ram_addr_i         )   ,
    .rd_ram_en_mode_i   (mem_rd_ram_en_mode_i   )   ,
    .wr_rd_en_o         (wb_wr_rd_en_i          )   ,
    .rd_addr_o          (wb_rd_addr_i           )   ,
    .rd_data_o          (wb_rd_data_i           )   ,
    .ram_addr_o         (wb_ram_addr_i          )   ,
    .rd_ram_en_mode_o   (wb_rd_ram_en_mode_i    )   
);

wb u_wb(
    .wr_rd_en_i         (wb_wr_rd_en_i          )   ,
    .rd_addr_i          (wb_rd_addr_i           )   ,
    .rd_data_i          (wb_rd_data_i           )   ,
    .ram_addr_i         (wb_ram_addr_i          )   ,
    .rd_ram_en_mode_i   (wb_rd_ram_en_mode_i    )   ,
    .ram_data_i         (ram_rd_data_o          )   ,
    .wr_rd_en_o         (regs_wr_rd_en_i        )   ,
    .rd_addr_o          (regs_rd_addr_i         )   ,
    .rd_data_o          (regs_rd_data_i         )  
);

endmodule

