`include "define.sv"

module pipeline_ctrl (
    // form ex
    input   logic                   jump_en_i       ,

    // flush
    output  logic                   flush_if2id_o   ,   
    output  logic                   flush_id2ex_o
);

always_comb begin : pipeline_ctrl_ctrl
    if (jump_en_i == `JUMP_ENABLE) begin
        flush_if2id_o = `FLUSH_ENABLE       ;
        flush_id2ex_o = `FLUSH_ENABLE       ;
    end else begin
        flush_if2id_o = `FLUSH_DISABLE      ;
        flush_id2ex_o = `FLUSH_DISABLE      ;
    end
end : pipeline_ctrl_ctrl

endmodule