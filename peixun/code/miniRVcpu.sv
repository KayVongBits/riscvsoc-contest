`include "tempdefine.sv"

module miniRVcpu (
    input  logic        clk,
    input  logic        rst,

    output logic [31:0] pc_to_im,        // 当前PC
    input  logic [31:0] inst_from_im,    // IROM输出的指令

    output logic [31:0] addr_to_bridge,  // load/store 地址
    output logic [31:0] wdata_to_bridge, // store写数据
    output logic        wen_to_bridge,   // store写使能
    input  logic [31:0] rdata_from_bridge, // load读回数据
    output logic [1:0]  wram_mode ,       //0:B, 1:HW, 2:W , 3:None
    output logic [2:0]  rram_mode         //0:B, 1:HW, 2:W , 4:BU , 5: HWU , 7: None
); 
// PC
logic [31:0] npc ;
logic [31:0] pc ;

PC u_PC(
    .npc 	(npc  ),
    .clk 	(clk  ),
    .rst 	(rst  ),
    .pc  	(pc   )
);
assign pc_to_im = pc;

// NPC 
logic isTrue ;
logic [1:0] npc_op ;
logic [31:0] offset ;
logic [31:0] Result; 
logic [31:0] pcadd4 ;

NPC u_NPC(
    .isTrue 	(isTrue  ),
    .npc_op 	(npc_op  ),
    .pc     	(pc      ),
    .offset    	(offset     ),
    .Result 	(Result  ),
    .npc    	(npc     ),
    .pcadd4 	(pcadd4  )
);

// Control
logic [31:0] inst ;
logic [6:0] opcode;
assign opcode = inst[6:0] ;
logic [1:0] NpcOp;
logic [1:0] Mem2Reg;
logic MemWrite;
logic OffsetOrigin;
logic ALUSrc;
logic RegWrite;

assign inst = inst_from_im ;

Control u_Control(
    .opcode       	(opcode        ),
    .NpcOp        	(NpcOp         ),
    .Mem2Reg      	(Mem2Reg       ),
    .MemWrite     	(wen_to_bridge ),
    .OffsetOrigin 	(OffsetOrigin  ),
    .ALUSrc       	(ALUSrc        ),
    .RegWrite     	(RegWrite      )
);

// IMMGEN
logic [31:0] imm;

IMMGEN u_IMMGEN(
    .inst 	(inst  ),
    .imm  	(imm   )
);

// output declaration of module ALUController
logic [3:0] ALUControl;

ALUController u_ALUController(
    .opcode    	(opcode     ),
    .func3     	(inst[14:12]      ),
    .func7     	(inst[30]      ),
    .ALUControl (ALUControl  ) ,
    .wram_mode 	(wram_mode   ),
    .rram_mode 	(rram_mode   )
);

logic [31:0] wr_reg_data ;
logic [31:0] rs_reg1_data ;
logic [31:0] rs_reg2_data ;


RF #(
    .REG_AW 	(5   ),
    .REG_DW 	(32  ))
u_RF(
    .clk          	(clk           ),
    .rst          	(rst           ),
    .wr_reg_en    	(RegWrite     ),
    .wr_reg_addr  	(inst[11:7]   ),
    .wr_reg_data  	(wr_reg_data   ),
    .rs_reg1_addr 	(inst[19:15]  ),
    .rs_reg2_addr 	(inst[24:20]  ),
    .rs_reg1_data 	(rs_reg1_data  ),
    .rs_reg2_data 	(rs_reg2_data  )
);


logic [31:0] A;
logic [31:0] B;
assign A = rs_reg1_data;
assign B = ALUSrc == `ALUSrc_IMM ? imm : rs_reg2_data ;

ALU #(
    .DATAWIDTH 	(32  ))
u_ALU(
    .A          	(A           ),
    .B          	(B           ),
    .ALUControl 	(ALUControl  ),
    .Result     	(Result      ),
    .isTrue     	(isTrue      )
);

assign offset = (OffsetOrigin == `Offset_Imm) ? imm : Result;
assign wr_reg_data = (Mem2Reg == `Mem2Reg_PCADD4) ? pcadd4 :
                     (Mem2Reg == `Mem2Reg_ALURES) ? Result :
                     (Mem2Reg == `Mem2Reg_RAMDATA) ? rdata_from_bridge :
                     (Mem2Reg == `Mem2Reg_IMM)    ? imm : 32'h0;
                     
assign wdata_to_bridge = rs_reg2_data ;
assign addr_to_bridge = Result[15:0] ;
endmodule