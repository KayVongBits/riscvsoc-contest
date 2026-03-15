`include "defines.sv"
module rom #(
    parameter FILE = `FILE,
    parameter AW = `AW,
    parameter DW = `DW
) (
    input  logic [AW-1:0] instr_addr,
    input  logic clk,
    input  logic rst_n,
    output logic [DW-1:0] instr_out
);

static string path = "../test_data//txt/"; // 这里是相对于当前文件的路径，确保它指向你的测试数据目录
static string full_path = {path, FILE};

logic [DW-1:0] rom_mem [0:4095];

initial begin
    $readmemh( full_path, rom_mem );    
end



always_comb begin : read_logic
    instr_out = rom_mem[instr_addr[AW-1:2]];
end

endmodule