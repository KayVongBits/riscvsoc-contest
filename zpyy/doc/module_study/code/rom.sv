`include "define.sv"

module rom (
    input   logic                           clk         ,
    input   logic                           rst         ,
    
    input   logic    [`ADD_WIDTH-1:0]       inst_addr_i ,           // 指令地址输入           
    output  logic    [`DATA_WIDTH-1:0]      inst_data_o             // 指令数据输出
);  

logic   [`DATA_WIDTH-1:0]    rom_mem [0:`ROM_SIZE-1];               //存放指令的ROM，最多存储4096条指令

initial begin
    $readmemh(`FILE,rom_mem);
end

always_comb begin : read_rom
    inst_data_o <= rom_mem[inst_addr_i[`ADD_WIDTH-1:2]];     // 取指令，地址右移2位
end : read_rom

endmodule

