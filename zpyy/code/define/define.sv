// base
`define ADD_WIDTH           32
`define DATA_WIDTH          32
`define PC_INIT_ADDR        32'h0000_0000 
`define PC_STEP             32'h4
//`define FILE                "F:/work/jingyeda/jingyeda/zpyy/doc/module_study/asm/txt/test_s.txt"
`define FILE                "F:/work/jingyeda/jingyeda/zpyy/test/txt/rv32ui-p-sb.txt"
`define INST_NOP            32'h0000_0013
`define BYTE_WIDTH          8
`define HW_WIDTH            16
`define WORD_WIDTH          32
`define BYTE_PER_WORD       4

// reg
`define REG_NUM             32
`define REG_ADDR_WIDTH      5   
`define RST_REG             5'h00
`define RST_REG_VALUE       32'h0000_0000
`define ZERO_REG            5'h00
`define ZERO_VALUE          32'h0000_0000
`define RST_IMM_VALUE       32'h0000_0000
`define REG_WR_ENABLE       1'b1
`define REG_WR_DISABLE      1'b0
`define REG_RD_ENABLE       1'b1
`define REG_RD_DISABLE      1'b0

// ROM
`define ROM_SIZE            8192

// RAM
`define RAM_SIZE            8192
`define RAM_RST_DATA        32'h0000_0000
`define RAM_RST_ADD         32'h0000_0000
// `define RAM_INIT_FILE       "F:/work/jingyeda/jingyeda/zpyy/test/txt/RAM_CLEAR.txt"      // 测试时RAM也用FILE初始化，实际用这个
`define RAM_WR_ENABLE       1'b1
`define RAM_WR_DISABLE      1'b0
`define RAM_RD_ENABLE       1'b1
`define RAM_RD_DISABLE      1'b0

// ecall en
`define ECALL_ENABLE        1'b1
`define ECALL_DISABLE       1'b0

// jump en
`define JUMP_ENABLE         1'b1
`define JUMP_DISABLE        1'b0
`define JUMP_RST_ADDR       32'h0000_0000

// alu_op select
`define ALU_OP1_SEL_PC      1'b1
`define ALU_OP1_SEL_RS1     1'b0
`define ALU_OP2_SEL_IMM     1'b1
`define ALU_OP2_SEL_RS2     1'b0

// Compare Result
`define COMPARE_TRUE        32'h0000_0001
`define COMPARE_FALSE       32'h0000_0000

// srai,srli
`define SEL_SRAI            1'b1

// bit0 clear
`define BIT0_CLEAR_MASK     32'hFFFFFFFE

// flush
`define FLUSH_ENABLE        1'b1
`define FLUSH_DISABLE       1'b0

// rd wr
`define WR_ENABLE           1'b1
`define WR_DISABLE          1'b0
`define RD_ENABLE           1'b1
`define RD_DISABLE          1'b0

// hazard_ctrl 
`define STALL_ENABLE        1'b1
`define STALL_DISABLE       1'b0
`define FLUSH_ENABLE        1'b1
`define FLUSH_DISABLE       1'b0

// 用于case  if 中的默认情况