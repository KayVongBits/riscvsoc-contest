
`define ADD_WIDTH           32
`define DATA_WIDTH          32
`define PC_INIT_ADDR        32'h0000_0000 
`define PC_INIT_INST        32'h0000_0000
`define PC_STEP             32'h4


`define REG_NUM             32
`define REG_ADDR_WIDTH      5   
`define RST_REG             5'h00
`define RST_REG_VALUE       32'h0000_0000
`define ZERO_REG            5'h00
`define ZERO_VALUE          32'h0000_0000

`define RST_IMM_VALUE       32'h0000_0000



`define COMPARE_TRUE        32'h0000_0001
`define COMPARE_FALSE       32'h0000_0000
// ecall en
`define RST_ECALL_ENABLE    1'b1
`define RST_ECALL_DISABLE   1'b0

// alu_op select
`define ALU_OP1_SEL_PC      1'b1
`define ALU_OP1_SEL_RS1     1'b0
`define ALU_OP2_SEL_IMM     1'b1
`define ALU_OP2_SEL_RS2     1'b0

`define WR_ENABLE           1'b1
`define WR_DISABLE          1'b0
`define RD_ENABLE           1'b1
`define RD_DISABLE          1'b0
// 用于case 或 if 中的默认情况