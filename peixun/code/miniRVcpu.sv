module miniRVcpu (
    input  logic        clk,
    input  logic        rst,

    output logic [31:0] pc_to_im,        // 当前PC
    input  logic [31:0] inst_from_im,    // IROM输出的指令

    output logic [15:0] addr_to_bridge,  // load/store 地址
    output logic [31:0] wdata_to_bridge, // store写数据
    output logic        wen_to_bridge,   // store写使能
    input  logic [31:0] rdata_from_bridge // load读回数据
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

Control u_Control(
    .opcode       	(opcode        ),
    .NpcOp        	(NpcOp         ),
    .Mem2Reg      	(Mem2Reg       ),
    .MemWrite     	(MemWrite      ),
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
logic [3:0] AlUContrl;

ALUController u_ALUController(
    .opcode    	(opcode     ),
    .func3     	(inst[14:12]      ),
    .func7     	(inst[30]      ),
    .AlUContrl 	(AlUContrl  )
);


endmodule