`include "define.sv"

module if2id (
    // sys
    input logic                         clk             ,
    input logic                         rst             ,

    // ctrl
    input logic                         flush_if2id_i   ,

    input logic     [`ADD_WIDTH-1:0]    inst_add_i      , 
    input logic     [`DATA_WIDTH-1:0]   inst_i          ,
    output logic    [`ADD_WIDTH-1:0]    inst_add_o      ,
    output logic    [`DATA_WIDTH-1:0]   inst_o
);

always_ff @(posedge clk or posedge rst) begin : if2id_add_seq
    if (rst) begin 
        inst_add_o <= `PC_INIT_ADDR ;
    end else if (flush_if2id_i) begin
        inst_add_o <= `PC_INIT_ADDR ;
    end else begin
        inst_add_o <= inst_add_i    ;
    end
end : if2id_add_seq 

always_ff @(posedge clk or posedge rst) begin : if2id_inst_seq
    if (rst) begin 
        inst_o <= `INST_NOP     ;
    end else if (flush_if2id_i) begin
        inst_o <= `INST_NOP     ;
    end else begin
        inst_o <= inst_i        ;
    end
end : if2id_inst_seq 

endmodule