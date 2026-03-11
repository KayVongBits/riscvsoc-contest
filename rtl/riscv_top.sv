module riscv_top #(
    parameter AW = 32,
    parameter DW = 32,
    parameter FILE = "rv32-p-addi.txt"
) (
    input  logic clk,
    input  logic rst_n
);

logic jump_en;
logic [AW-1:0] jump_addr;
logic [AW-1:0] pc_pointer;
logic [DW-1:0] instruction;

logic [AW-1:0] instr_addr_reg;
logic [DW-1:0] instr_reg;


logic [4:0]     rd_rs1_addr;
logic [4:0]     rd_rs2_addr;
logic [6:0]     wr_rd_addr;
logic [DW-1:0]  rd_rs1_data;
logic [DW-1:0]  rd_rs2_data;
logic [DW-1:0]  op1_out;
logic [DW-1:0]  op2_out;

assign jump_en = 1'b0;
assign jump_addr = 'h0;
assign rd_rs1_data = 'd50;
assign rd_rs2_data = 'd100;

pc_counter 
#(
    .AW (AW )
)
u_pc_counter(
    .clk        (clk        ),
    .rst_n      (rst_n      ),
    .jump_en    (jump_en    ),
    .jump_addr  (jump_addr  ),
    .pc_pointer (pc_pointer )
);

rom 
#(
    .FILE (FILE ),
    .AW   (AW   ),
    .DW   (DW   )
)
u_rom(
    .instr_addr (pc_pointer ),
    .clk        (clk        ),
    .rst_n      (rst_n      ),
    .instr_out  (instruction )
);


if2id 
#(
    .AW (AW ),
    .DW (DW )
)
u_if2id(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .instr_addr_in  (instruction    ),
    .instr_in       (pc_pointer     ),
    .instr_addr_out (instr_addr_reg ),
    .instr_out      (instr_reg      )
);


decode 
#(
    .DW (DW )
)
u_decode(
    .instr_in    (instruction ),
    .rd_rs1_addr (rd_rs1_addr ),
    .rd_rs2_addr (rd_rs2_addr ),
    .wr_rd_addr  (wr_rd_addr  ),
    .rd_rs1_data (rd_rs1_data ),
    .rd_rs2_data (rd_rs2_data ),
    .op1_out     (op1_out     ),
    .op2_out     (op2_out     )
);




endmodule