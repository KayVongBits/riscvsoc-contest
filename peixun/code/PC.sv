module PC(
    input logic npc,
    input logic clk,
    input logic rst,
    output logic pc
);
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        pc <= 0;
    end else begin
        pc <= npc;
    end
end

endmodule