`include "tempdefine.sv"

module miniRVcpu (
    input  logic        clk,
    input  logic        rst,
    output logic [31:0] pc_to_im,
    input  logic [31:0] inst_from_im,
    output logic [15:0] addr_to_bridge,
    output logic [31:0] wdata_to_bridge,
    output logic        wen_to_bridge,
    input  logic [31:0] rdata_from_bridge,
    output logic [1:0]  wram_mode,
    output logic [2:0]  rram_mode
);

logic [31:0] npc;
logic [31:0] pc;
logic        isTrue;
logic [1:0]  NpcOp;
logic [31:0] offset;
logic [31:0] Result;
logic [31:0] pcadd4;
logic [31:0] inst;
logic [6:0]  opcode;
logic [1:0]  Mem2Reg;
logic        OffsetOrigin;
logic        ALUSrc;
logic        RegWrite;
logic [31:0] imm;
logic [3:0]  ALUControl;
logic [31:0] wr_reg_data;
logic [31:0] rs_reg1_data;
logic [31:0] rs_reg2_data;
logic [31:0] A;
logic [31:0] B;
logic [31:0] load_data;
logic [31:0] aligned_rdata;
logic [31:0] store_data;
logic [31:0] store_mask;
logic [31:0] store_shifted;

assign inst = inst_from_im;
assign opcode = inst[6:0];
assign pc_to_im = pc;
assign A = (opcode == `U_AUIPC) ? pc : rs_reg1_data;
assign B = (ALUSrc == `ALUSrc_IMM) ? imm : rs_reg2_data;
assign offset = (OffsetOrigin == `Offset_Imm) ? imm : Result;
assign addr_to_bridge = Result[15:0];

PC u_PC(
    .npc (npc),
    .clk (clk),
    .rst (rst),
    .pc  (pc)
);

NPC u_NPC(
    .isTrue (isTrue),
    .npc_op (NpcOp),
    .pc     (pc),
    .offset (offset),
    .Result (Result),
    .npc    (npc),
    .pcadd4 (pcadd4)
);

Control u_Control(
    .opcode       (opcode),
    .NpcOp        (NpcOp),
    .Mem2Reg      (Mem2Reg),
    .MemWrite     (wen_to_bridge),
    .OffsetOrigin (OffsetOrigin),
    .ALUSrc       (ALUSrc),
    .RegWrite     (RegWrite)
);

IMMGEN u_IMMGEN(
    .inst (inst),
    .imm  (imm)
);

ALUController u_ALUController(
    .opcode     (opcode),
    .func3      (inst[14:12]),
    .func7      (inst[30]),
    .ALUControl (ALUControl),
    .wram_mode  (wram_mode),
    .rram_mode  (rram_mode)
);

RF #(
    .REG_AW (5),
    .REG_DW (32)
) u_RF(
    .clk          (clk),
    .rst          (rst),
    .wr_reg_en    (RegWrite),
    .wr_reg_addr  (inst[11:7]),
    .wr_reg_data  (wr_reg_data),
    .rs_reg1_addr (inst[19:15]),
    .rs_reg2_addr (inst[24:20]),
    .rs_reg1_data (rs_reg1_data),
    .rs_reg2_data (rs_reg2_data)
);

ALU #(
    .DATAWIDTH (32)
) u_ALU(
    .A          (A),
    .B          (B),
    .ALUControl (ALUControl),
    .Result     (Result),
    .isTrue     (isTrue)
);

always_comb begin
    aligned_rdata = rdata_from_bridge >> {Result[1:0], 3'b000};
    unique case (rram_mode)
        `RRAM_B:   load_data = {{24{aligned_rdata[7]}}, aligned_rdata[7:0]};
        `RRAM_HW:  load_data = {{16{aligned_rdata[15]}}, aligned_rdata[15:0]};
        `RRAM_W:   load_data = rdata_from_bridge;
        `RRAM_BU:  load_data = {24'h0, aligned_rdata[7:0]};
        `RRAM_HWU: load_data = {16'h0, aligned_rdata[15:0]};
        default:   load_data = rdata_from_bridge;
    endcase
end

always_comb begin
    store_shifted = rs_reg2_data << {Result[1:0], 3'b000};
    unique case (wram_mode)
        `WRAM_B:  store_mask = 32'h000000FF << {Result[1:0], 3'b000};
        `WRAM_HW: store_mask = 32'h0000FFFF << {Result[1], 4'b0000};
        `WRAM_W:  store_mask = 32'hFFFFFFFF;
        default:  store_mask = 32'h0;
    endcase
    store_data = (rdata_from_bridge & ~store_mask) | (store_shifted & store_mask);
end

assign wr_reg_data = (Mem2Reg == `Mem2Reg_PCADD4) ? pcadd4 :
                     (Mem2Reg == `Mem2Reg_ALURES) ? Result :
                     (Mem2Reg == `Mem2Reg_RAMDATA) ? load_data :
                     (Mem2Reg == `Mem2Reg_IMM) ? imm : 32'h0;

assign wdata_to_bridge = store_data;

endmodule

