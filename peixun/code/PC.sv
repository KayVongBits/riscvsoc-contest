module PC(
    input logic [31:0] npc,
    input logic clk,
    input logic rst,
    output logic [31:0] pc
);
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        pc <= 0;
    end else begin
        pc <= npc;
    end
end

endmodule