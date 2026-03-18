module uart #(
    parameter BAUD_RATE = 5208
)(
    input wire          clk,
    input wire          rst,

    output reg          tx,
    input wire          rx,
    // tx
    input wire          tx_start,
    input wire [7:0]    tx_data,
    output reg          tx_busy,
    // rx
    output reg [7:0]    rx_data,
    output reg          rx_valid
);


// tx
reg [15:0] tx_cnt;
reg [3:0]  tx_bit_cnt;
reg [9:0]  tx_data_reg;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        tx_cnt <= 16'd0;
        tx_bit_cnt <= 4'd0;
        tx_data_reg <= 10'd0;
        tx <= 1'b1;
        tx_busy <= 1'b0;
    end else begin
        if (tx_start & ~tx_busy) begin
            tx_busy <= 1'b1;
            tx_data_reg <= {1'b1 , tx_data , 1'b0};
            tx_cnt  <= 16'd0;
            tx_bit_cnt <= 4'd0;
        end else if(tx_busy) begin
            if (tx_cnt >= BAUD_RATE - 1) begin
                tx_data_reg <= {tx_data_reg[0] , tx_data_reg[9:1]};
                tx <= tx_data_reg[0];
                tx_cnt  <= 16'd0;
                if (tx_bit_cnt == 4'd9) begin
                    tx_busy <= 1'b0;
                end else begin
                    tx_bit_cnt <= tx_bit_cnt + 1'b1; 
                end
            end else begin
                tx_cnt <= tx_cnt + 1'b1;
            end
        end
    end
end

// rx
reg rx_d0 , rx_d1;
wire rx_negedge;
reg [15:0] rx_cnt;
reg [3:0] rx_bit_cnt;
reg [7:0] rx_data_reg;
reg rx_busy;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        rx_d0 <= 1'b1;
        rx_d1 <= 1'b1;
    end else begin
        rx_d0 <= rx;
        rx_d1 <= rx_d0;
    end
end

assign rx_negedge = ~rx_d0 & rx_d1;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        rx_cnt <= 16'd0;
        rx_bit_cnt <= 4'd0;
        rx_data_reg <= 8'd0;
        rx_busy <= 1'b0;
        rx_valid <= 1'b0;
        rx_data <= 8'b0;
    end else begin
        rx_valid <= 1'b0;

        if (!rx_busy) begin
            if (rx_negedge) begin
                rx_busy <= 1'b1;
                rx_bit_cnt <= 4'b0;
                rx_cnt <= 16'b0;
            end
        end else begin 
            if (rx_cnt >= (rx_bit_cnt ? BAUD_RATE : BAUD_RATE >> 1) - 1) begin
                rx_cnt <= 16'd0;
                if (rx_bit_cnt ==4'd0) begin
                    if (~rx_d1) begin
                        rx_bit_cnt <= rx_bit_cnt + 1'b1;
                    end else begin
                        rx_busy <= 1'b0;
                    end
                end else if (rx_bit_cnt >= 4'd1 && rx_bit_cnt <= 4'd8) begin
                    rx_data_reg[rx_bit_cnt-1] <= rx_d1;
                    rx_bit_cnt <= rx_bit_cnt + 1'b1;
                end else  begin
                    rx_busy <= 1'b0;
                    if (rx_d1) begin
                        rx_data <= rx_data_reg;
                        rx_valid <= 1'd1;
                    end else begin
                        rx_data <= 8'd0;
                        rx_valid <= 1'd0;
                    end
                end
            end else begin
                rx_cnt <= rx_cnt + 1'b1;
            end
        end
    end
end

endmodule