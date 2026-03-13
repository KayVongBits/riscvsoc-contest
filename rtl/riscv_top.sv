`include "defines.sv"

module riscv_top #(
    parameter AW = `AW,
    parameter DW = `DW,
    parameter FILE = `FILE
) (
    input  logic clk,
    input  logic rst_n
);

//wires and regs
logic           jump_en;
logic [AW-1:0]  jump_addr;
logic [AW-1:0]  pc_pointer;
logic [DW-1:0]  instruction;
logic [AW-1:0]  instr_addr_reg;
logic [DW-1:0]  instr_reg;


logic [4:0]     rd_rs1_addr;
logic [4:0]     rd_rs2_addr;
logic [DW-1:0]  rd_rs1_data;
logic [DW-1:0]  rd_rs2_data;
logic [DW-1:0]  decode_op1;
logic [DW-1:0]  decode_op2;

logic [4:0]     wr_reg_addr;
logic [DW-1:0]  wr_reg_data;
logic           wr_reg_en;


logic [AW-1:0]  execute_instr_addr;
logic [DW-1:0]  execute_instr;
logic [DW-1:0]  execute_op1;
logic [DW-1:0]  execute_op2;


logic jump_hold ;



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
    .instr_addr_in  ( pc_pointer   ),
    .instr_in       (  instruction  ),
    .instr_addr_out (instr_addr_reg ),
    .instr_out      (instr_reg      )
);

 
decode 
#(
    .DW (DW )
)
u_decode(
    .instr_in    (instr_reg ),
    .rd_rs1_addr (rd_rs1_addr ),
    .rd_rs2_addr (rd_rs2_addr ), 
    .rd_rs1_data (rd_rs1_data ),
    .rd_rs2_data (rd_rs2_data ),
    .op1_out     (decode_op1     ),
    .op2_out     (decode_op2     )
);

register 
#(
    .DW (DW )
)
u_register(
    .clk         (clk         ),
    .rst_n       (rst_n       ),
    .rd_rs1_addr (rd_rs1_addr ),
    .rd_rs2_addr (rd_rs2_addr ),
    .rd_rs1_data (rd_rs1_data ),
    .rd_rs2_data (rd_rs2_data ),
    .wr_reg_addr (wr_reg_addr ),
    .wr_reg_data (wr_reg_data ),
    .wr_reg_en   (wr_reg_en   )
);

id2ex 
#(
    .AW (AW ),
    .DW (DW )
)
u_id2ex(
    .clk            (clk                ),
    .rst_n          (rst_n              ),
    .instr_addr_in  (instr_addr_reg     ),
    .instr_in       (instr_reg          ),
    .op1_in         (decode_op1         ),
    .op2_in         (decode_op2         ),
    .instr_addr_out (execute_instr_addr ),
    .instr_out      (execute_instr      ),
    .op1_out        (execute_op1        ),
    .op2_out        (execute_op2        )
);

execute 
#(
    .AW (AW ),
    .DW (DW )
)
u_execute(
    .clk           (clk                 ),
    .rst_n         (rst_n               ),
    .instr_addr_in (execute_instr_addr  ),
    .instr_in      (execute_instr       ),
    .op1           (execute_op1         ),
    .op2           (execute_op2         ),
    .wr_reg_en     (wr_reg_en           ),
    .wr_reg_addr   (wr_reg_addr         ),
    .wr_reg_data   (wr_reg_data         ),
    .jump_en       (jump_en             ),
    .jump_addr     (jump_addr           ),
    .jump_hold    (jump_hold           )

);

 

endmodule