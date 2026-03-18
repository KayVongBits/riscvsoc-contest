module clock #(
    parameter CLK_FREQ_I = 50_000_000,
    parameter CLK_FREQ_O = 1000
)(
    input   logic       clk     ,
    input   logic       rst     ,
    output  logic       tick_o
);

localparam CLK_DIV = CLK_FREQ_I / CLK_FREQ_O;

logic [27:0] tick_cnt;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        tick_o <= 1'b0;
        tick_cnt <= 28'b0;
    end else begin
        tick_o <= 1'b0;
        if (tick_cnt >= CLK_DIV - 1) begin
            tick_cnt <= 28'b0;
            tick_o <= 1'b1;
        end else begin
            tick_cnt <= tick_cnt + 1'b1;
        end
    end
end

endmodule