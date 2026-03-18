module key_proc(
    input   logic               clk,
    input   logic               rst,
    input   logic   [3:0]       key_i,
    output  logic   [3:0]       down_o
);

logic tick_100;

clock #(
    .CLK_FREQ_I(50_000_000),
    .CLK_FREQ_O(100)
)u_tick_100(
    .clk(clk) ,
    .rst(rst) ,
    .tick_o( tick_100)
);

key_read key_read_value(
    .clk( clk),
    .rst( rst),
    .tick_100( tick_100),
    .key_i(key_i),
    .down_o(down_o)
);

endmodule