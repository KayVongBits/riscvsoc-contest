module rom #(
    parameter FILE = "rv32-p-addi.txt",
    parameter AW = 32,
    parameter DW = 32
) (
    input  logic [AW-1:0] instr_addr,
    input  logic clk,
    input  logic rst_n,
    output logic [DW-1:0] instr_out
);

static string path = "../test_data/";
static string full_path = {path, FILE};

logic [DW-1:0] rom_mem [0:4095];

initial begin
    $readmemh( full_path, rom_mem );    
end



always_comb begin : read_logic
    instr_out = rom_mem[instr_addr[AW-1:2]];
end

endmodule