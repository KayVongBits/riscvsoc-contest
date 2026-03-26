module key_read(
    input   logic       clk         ,
    input   logic       rst         ,
    input   logic       tick_100    ,
    input   logic [3:0] key_i       ,
    output  logic [3:0] down_o
);

logic [3:0] key_d0 , key_d1;
logic [3:0] old_v , new_v;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        key_d0 <= 4'hf;
        key_d1 <= 4'hf;
        old_v <= 4'hf;      
        new_v <= 4'hf;
        down_o <= 4'h0;
    end else begin
        key_d0 <= key_i;
        key_d1 <= key_d0;
        down_o <= 4'h0;
        if (tick_100) begin
            old_v <= new_v;
            new_v <= key_d1;
            down_o <= old_v & (old_v ^ new_v);
        end
    end
end

endmodule