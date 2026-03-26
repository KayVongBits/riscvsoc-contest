`include "F:/work/jingyeda/jingyeda/zpyy/code/define/define.sv"
`include "F:/work/jingyeda/jingyeda/zpyy/code/define/rv32i_pkg.sv"


module rom (
    input   logic                           clk         ,
    input   logic                           rst         ,
    input   logic                           stall_i     ,        
    input   logic    [`ADD_WIDTH-1:0]       inst_addr_i ,           // 指令地址输入           
    output  logic    [`DATA_WIDTH-1:0]      inst_data_o             // 指令数据输出
);  
(* ram_style = "block" *)logic   [`DATA_WIDTH-1:0]    rom_mem [0:`ROM_SIZE-1];               //存放指令的ROM，最多存储4096条指令

initial begin
    $readmemh(`FILE,rom_mem);
end

always_ff @(posedge clk) begin
    if (rst) begin
        inst_data_o     <= `INST_NOP                            ;
    end else if (stall_i) begin
        inst_data_o     <= inst_data_o                          ;
    end else begin
        inst_data_o     <= rom_mem[inst_addr_i[`ADD_WIDTH-1:2]] ;
    end
end


endmodule

