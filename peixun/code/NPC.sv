module NPC(
    input logic isTrue ,
    input logic [1:0] npc_op ,
    input logic [31:0] pc ,
    input logic [31:0] offset ,
    input logic [31:0] Result ,
    output logic [31:0] npc ,
    output logic [31:0] pcadd4 
);

always_comb begin
    npc = pc + 32'd4 ;
    unique case (npc_op)
        2'b00 : npc = pc + 32'd4 ;
        2'b01 : npc = isTrue ? pc + offset : pc +32'd4 ;
        2'b10 : npc = Result & 32'hfffffffe;
        default : npc = pc + offset ;
    endcase
end

assign pcadd4 = pc + 32'd4 ;

endmodule