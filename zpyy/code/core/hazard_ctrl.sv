`include "F:/work/jingyeda/jingyeda/zpyy/code/define/define.sv"
`include "F:/work/jingyeda/jingyeda/zpyy/code/define/rv32i_pkg.sv"

module hazard_ctrl (
    input   logic                           clk             ,
    input   logic                           rst             ,
    // load use 
    input   logic   [`REG_ADDR_WIDTH-1:0]   id_rs1_addr_i   ,
    input   logic   [`REG_ADDR_WIDTH-1:0]   id_rs2_addr_i   ,
    input   logic   [`REG_ADDR_WIDTH-1:0]   ex_rd_addr_i    ,
    input   logic                           ex_is_load_i    ,

    // jmmp_en  
    input   logic                           ex_jump_en_i    ,

    // ctrl stall   
    output  logic                           stall_pc_o      ,
    output  logic                           stall_if2id_o   ,
    output  logic                           flush_if2id_o   ,
    output  logic                           flush_id2ex_o 
);

logic   is_load_use_hazard ;
assign  is_load_use_hazard = ex_is_load_i && (ex_rd_addr_i != `ZERO_REG) &&((id_rs1_addr_i == ex_rd_addr_i)||(id_rs2_addr_i == ex_rd_addr_i));

// jump 延迟一拍 ， 多一个周期的废数据（由于rom使用的是Bram）
logic ex_jump_en_d0 ;
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        ex_jump_en_d0 <= `JUMP_DISABLE ;
    end else begin
        ex_jump_en_d0 <= ex_jump_en_i  ;
    end
end

always_comb begin : hazard_logic
    stall_pc_o    = `STALL_DISABLE ;
    stall_if2id_o = `STALL_DISABLE ;
    flush_if2id_o = `FLUSH_DISABLE ;
    flush_id2ex_o = `FLUSH_DISABLE ;

    if (ex_jump_en_i) begin
        flush_if2id_o = `FLUSH_ENABLE ;
        flush_id2ex_o = `FLUSH_ENABLE ;
    end else if (ex_jump_en_d0) begin 
        flush_if2id_o = `FLUSH_ENABLE ;
    end else if (is_load_use_hazard) begin
        stall_pc_o    = `STALL_ENABLE ;
        stall_if2id_o = `STALL_ENABLE ;
        flush_id2ex_o = `FLUSH_ENABLE ;
    end
end
endmodule