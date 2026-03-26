`include "F:/work/jingyeda/jingyeda/zpyy/code/define/define.sv"
`include "F:/work/jingyeda/jingyeda/zpyy/code/define/rv32i_pkg.sv"

module riscv_top import rv32i_pkg::*; (
    input   logic                       clk         ,
    input   logic                       rst         ,
    output  logic [1:0]                 led_mode    
);

// piprline bus
If2Id_Bus_s     if2id_bus_i , if2id_bus_o;
Id2Ex_Bus_s     id2ex_bus_i , id2ex_bus_o;
Ex2Mem_Bus_s    ex2mem_bus_i, ex2mem_bus_o;
Mem2Wb_Bus_s    mem2wb_bus_o;

// pc
logic [`ADD_WIDTH-1:0]          pc_o                            ;

// ex jump to if
logic                           ex_jump_en                      ;
logic [`DATA_WIDTH-1:0]         ex_jump_addr                    ;

// ram read data                
logic [`DATA_WIDTH-1:0]         ram_rd_data                     ;

// wb wr to regs                
logic                           wb_regs_wr_en                   ;
logic [`REG_ADDR_WIDTH-1:0]     wb_regs_rd_addr                 ;
logic [`DATA_WIDTH-1:0]         wb_regs_wr_data                 ;

// regs read data in decode stage
logic [`REG_ADDR_WIDTH-1:0]     id_rs1_addr , id_rs2_addr       ;
logic [`DATA_WIDTH-1:0]         id_rs1_data , id_rs2_data       ;

// ctrl_flush
logic                           stall_pc                        ;
logic                           stall_if2id                     ;
logic                           flush_if2id                     ;
logic                           flush_id2ex                     ;

// forwarding ctrl
Forwarding_Mode_e               forwarding_rs1_sel              ;
Forwarding_Mode_e               forwarding_rs2_sel              ;
assign flush_en = 1'b0 ;

// if 阶段
pc u_pc(
    .clk         	(clk                    )   ,
    .rst         	(rst                    )   ,
    .jump_en_i   	(ex_jump_en             )   ,
    .jump_addr_i 	(ex_jump_addr           )   ,
    .pc_o        	(pc_o                   )   ,
    .inst_addr_o    (if2id_bus_i.inst_addr  )   ,
    .stall_pc_i     (stall_pc               )
);

rom u_rom(
    .clk            (clk                    )   ,
    .rst            (rst                    )   ,
    .stall_i        (stall_pc               )   ,
    .inst_addr_i    (pc_o                   )   ,
    .inst_data_o    (if2id_bus_i.inst       )
);

if2id u_if2id(
    .clk            (clk                    )   ,
    .rst            (rst                    )   ,
    .if2id_bus_i    (if2id_bus_i            )   ,
    .if2id_bus_o    (if2id_bus_o            )   ,
    .flush_if2id_i  (flush_if2id            )   ,
    .stall_if2id_i  (stall_if2id            )
);

// id 阶段
decode u_decode(
    .inst_addr_i    (if2id_bus_o.inst_addr  )   ,
    .inst_i         (if2id_bus_o.inst       )   ,
    .rs1_data_i     (id_rs1_data            )   ,
    .rs2_data_i     (id_rs2_data            )   ,
    .rs1_addr_o     (id_rs1_addr            )   ,
    .rs2_addr_o     (id_rs2_addr            )   ,
    .id2ex_bus_o    (id2ex_bus_i            )
);

regs u_regs(
    .clk        	(clk                    )   ,
    .rst        	(rst                    )   ,
    .rs1_addr_i 	(id_rs1_addr            )   ,
    .rs2_addr_i 	(id_rs2_addr            )   ,
    .rs1_data_o 	(id_rs1_data            )   ,
    .rs2_data_o 	(id_rs2_data            )   ,
    .wr_rd_en_i 	(wb_regs_wr_en          )   ,
    .rd_addr_i  	(wb_regs_rd_addr        )   ,
    .rd_data_i  	(wb_regs_wr_data        )
);

id2ex u_id2ex(
    .clk            (clk                    )   ,
    .rst            (rst                    )   ,   
    .id2ex_bus_i    (id2ex_bus_i            )   ,
    .id2ex_bus_o    (id2ex_bus_o            )   ,
    .flush_id2ex_i  (flush_id2ex            )
);

// ex 阶段
execute u_execute(
    .id2ex_bus_i        (id2ex_bus_o            )   ,
    .ex2mem_bus_o       (ex2mem_bus_i           )   ,
    .jump_en_o          (ex_jump_en             )   ,
    .jump_addr_o        (ex_jump_addr           )   ,
    .rs1_forward_mode_i (forwarding_rs1_sel     )   ,
    .rs2_forward_mode_i (forwarding_rs2_sel     )   ,
    .mem_forward_data_i (ex2mem_bus_o.alu_res   )   ,
    .wb_forward_data_i  (wb_regs_wr_data        )                       
);

ex2mem u_ex2mem(
    .clk            (clk                    )   ,
    .rst            (rst                    )   ,
    .ex2mem_bus_i   (ex2mem_bus_i           )   ,
    .ex2mem_bus_o   (ex2mem_bus_o           )   
);

// mem 阶段
ram u_ram(
    .clk            (clk                                                    )   ,
    .addr_i         (ex2mem_bus_o.alu_res                                   )   , 
    .wr_en_mask_i   (ex2mem_bus_o.mem_ctrl.ram_wr_mask                      )   ,        
    .wr_data_i      (ex2mem_bus_o.rs2_data                                  )   ,        
    .rd_en_i        (ex2mem_bus_o.mem_ctrl.ram_rd_mode != RAM_RD_DISABLE    )   ,        
    .rd_data_o      (ram_rd_data                                            )            
);

mem2wb u_mem2wb(
    .clk            (clk                    )   ,
    .rst            (rst                    )   ,
    .ex2mem_bus_i   (ex2mem_bus_o           )   ,
    .mem2wb_bus_o   (mem2wb_bus_o           )   
);

// wb 阶段
wb u_wb(
    .mem2wb_bus_i   (mem2wb_bus_o           )   ,
    .ram_rd_data_i  (ram_rd_data            )   ,
    .regs_wr_en_o   (wb_regs_wr_en          )   ,
    .regs_wr_data_o (wb_regs_wr_data        )   ,
    .regs_rd_addr_o (wb_regs_rd_addr        )   
);

// 处理数据前递 forwarding module
forwarding u_forwarding(
    .ex_rs1_addr_i          (id2ex_bus_o.rs1_addr           )   ,
    .ex_rs2_addr_i          (id2ex_bus_o.rs2_addr           )   ,
    .mem_wr_regs_en_i       (ex2mem_bus_o.wb_ctrl.reg_wr_en )   ,
    .mem_wr_regs_addr_i     (ex2mem_bus_o.rd_addr           )   ,
    .wb_wr_regs_en_i        (mem2wb_bus_o.wb_ctrl.reg_wr_en )   ,
    .wb_wr_regs_addr_i      (mem2wb_bus_o.rd_addr           )   ,
    .forwarding_rs1_sel_o   (forwarding_rs1_sel             )   ,
    .forwarding_rs2_sel_o   (forwarding_rs2_sel             )   
);



hazard_ctrl u_hazard_ctrl(
    .clk            (clk                    )   ,
    .rst            (rst                    )   ,
    .id_rs1_addr_i 	(id_rs1_addr            )   ,
    .id_rs2_addr_i 	(id_rs2_addr            )   ,
    .ex_rd_addr_i  	(ex2mem_bus_i.rd_addr   )   ,
    .ex_is_load_i  	(ex2mem_bus_i.mem_ctrl.ram_rd_mode != RAM_RD_DISABLE   ),
    .ex_jump_en_i  	(ex_jump_en             )   ,
    .stall_pc_o    	(stall_pc               )   ,
    .stall_if2id_o 	(stall_if2id            )   ,
    .flush_if2id_o 	(flush_if2id            )   ,
    .flush_id2ex_o 	(flush_id2ex            )
);

endmodule

