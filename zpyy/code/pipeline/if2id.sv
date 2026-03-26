`include "F:/work/jingyeda/jingyeda/zpyy/code/define/define.sv"
`include "F:/work/jingyeda/jingyeda/zpyy/code/define/rv32i_pkg.sv"
module if2id import rv32i_pkg::*; (
    // sys
    input   logic                         clk             ,
    input   logic                         rst             ,

    // ctrl
    input   logic                         flush_if2id_i   ,
    input   logic                         stall_if2id_i   ,

    input   var     If2Id_Bus_s           if2id_bus_i     ,
    output  var     If2Id_Bus_s           if2id_bus_o          
);

always_ff @(posedge clk or posedge rst) begin : if2id_add_seq
    if (rst) begin 
        if2id_bus_o.inst_addr <= `PC_INIT_ADDR      ;
        if2id_bus_o.inst      <= `INST_NOP          ;
    end else if (flush_if2id_i) begin       
        if2id_bus_o.inst_addr <= `PC_INIT_ADDR      ;
        if2id_bus_o.inst      <= `INST_NOP          ;
    end else if (stall_if2id_i) begin 
        if2id_bus_o           <= if2id_bus_o        ;
    end else begin      
        if2id_bus_o           <= if2id_bus_i        ;
    end
end : if2id_add_seq 

endmodule