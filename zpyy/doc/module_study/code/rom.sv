module rom #(
    parameter FILE          = "rv32ui-p-addi.txt",
    parameter ADD_WIDTH     = 32,
    parameter DATA_WIDTH    = 32
)(
    input   logic                           clk         ,
    input   logic                           rst         ,
    
    input   logic    [ADD_WIDTH-1:0]        inst_addr_i ,           // 指令地址输入           
    output  logic    [DATA_WIDTH-1:0]       inst_data_o             // 指令数据输出
);  

static  string path        = "../../jingyeda/zpyy/doc/module_study/test/txt/" ;   
static  string full_path   = {path, FILE};  

logic   [DATA_WIDTH-1:0]    rom_mem [0:4095];               //存放指令的ROM，最多存储4096条指令

initial begin
    $readmemh(full_path,rom_mem);
end

always_comb begin : read_rom
    inst_data_o <= rom_mem[inst_addr_i[ADD_WIDTH-1:2]];     // 取指令，地址右移2位
end : read_rom

endmodule