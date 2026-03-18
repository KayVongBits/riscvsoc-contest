module uart_fifo #(
    parameter BAUD_RATE = 5208  ,
    parameter FIFO_DEPTH = 64   ,
    parameter TX_LENTH  = 20    ,
    parameter RX_LENTH  = 5
)(
    input wire clk,
    input wire rst,
    
    input wire rx_i,
    output wire tx_o,

    // tx
    input wire [8*TX_LENTH-1:0] tx_str_data,
    input wire [4:0]  tx_str_len,
    input wire        tx_str_en,
    output wire       tx_str_busy,   //搬运FIFO时为1,不可发送字符串

    //rx
    output reg [8*RX_LENTH-1:0] rx_str_data,   
    output reg        rx_str_valid
);
// 内部接口
reg [7:0] user_tx_data;
reg user_tx_en;
wire user_tx_full;

wire [7:0] user_rx_data;
reg user_rx_rd;
wire user_rx_empty;

// 实例化
reg [7:0] uart_tx_data;
reg        uart_tx_start;
wire [7:0] uart_rx_data;
wire uart_tx_busy;
wire uart_rx_valid;

uart #(
    .BAUD_RATE 	(BAUD_RATE  ))
u_uart(
    .clk      	(clk       ),
    .rst      	(rst       ),
    .tx       	(tx_o        ),
    .rx       	(rx_i        ),
    .tx_start 	(uart_tx_start  ),
    .tx_data  	(uart_tx_data   ),
    .tx_busy  	(uart_tx_busy   ),
    .rx_data  	(uart_rx_data   ),
    .rx_valid 	(uart_rx_valid  )
);

// TX_FIFO
reg [7:0] tx_fifo [0:FIFO_DEPTH-1];
reg [6:0] tx_wr_ptr , tx_rd_ptr;
reg [7:0] tx_cnt;

assign user_tx_full = (tx_cnt == FIFO_DEPTH);

// user write 

always @(posedge clk or posedge rst) begin
    if (rst) begin
        tx_wr_ptr <= 0;
    end else if (user_tx_en && !user_tx_full) begin
        tx_fifo[tx_wr_ptr] <= user_tx_data;
        tx_wr_ptr <= (tx_wr_ptr == FIFO_DEPTH-1) ? 7'd0 : tx_wr_ptr + 1'd1;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        tx_rd_ptr <= 7'd0;
        uart_tx_start <= 1'd0;
    end else begin
        uart_tx_start <= 1'd0;
        if ((tx_cnt > 0) && !uart_tx_busy && !uart_tx_start) begin
            uart_tx_start <= 1'd1;
            uart_tx_data <= tx_fifo[tx_rd_ptr];
            tx_rd_ptr <= (tx_rd_ptr == FIFO_DEPTH-1) ? 7'd0 : tx_rd_ptr + 1'd1;
        end
    end
end

wire tx_wr_en = !user_tx_full && user_tx_en;
wire tx_rd_en = (tx_cnt > 0) && !uart_tx_busy && !uart_tx_start;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        tx_cnt <= 8'd0;
    end else begin
        case ({tx_wr_en,tx_rd_en}) 
            2'b10 : tx_cnt <= tx_cnt + 1'd1;
            2'b01 : tx_cnt <= tx_cnt - 1'd1;
            2'b11 : tx_cnt <= tx_cnt;
            default : tx_cnt <= tx_cnt;
        endcase
    end
end

// RX_FIFO
reg [7:0] rx_fifo [0:FIFO_DEPTH-1];
reg [6:0] rx_wr_ptr , rx_rd_ptr;
reg [7:0] rx_cnt;

assign user_rx_empty = (rx_cnt == 0);
assign user_rx_data = rx_fifo[rx_rd_ptr];

always @(posedge clk or posedge rst) begin
    if (rst) begin
        rx_wr_ptr <= 7'd0;
    end else if (uart_rx_valid && (rx_cnt < FIFO_DEPTH)) begin
        rx_fifo[rx_wr_ptr] <= uart_rx_data;
        rx_wr_ptr <= (rx_wr_ptr == FIFO_DEPTH-1) ? 7'd0 : rx_wr_ptr + 1'd1;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        rx_rd_ptr <= 7'd0;
    end else if (user_rx_rd && ~user_rx_empty) begin
        rx_rd_ptr <= (rx_rd_ptr == FIFO_DEPTH-1) ? 7'd0 : rx_rd_ptr + 1'd1;
    end
end

wire rx_wr_en = uart_rx_valid && (rx_cnt < FIFO_DEPTH);
wire rx_rd_en = user_rx_rd && ~user_rx_empty;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        rx_cnt <= 8'd0;
    end else begin
        case ({rx_wr_en,rx_rd_en}) 
            2'b10 : rx_cnt <= rx_cnt + 1'd1;
            2'b01 : rx_cnt <= rx_cnt - 1'd1;
            2'b11 : rx_cnt <= rx_cnt;
            default : rx_cnt <= rx_cnt;
        endcase
    end
end

// 字符串发送状态机
localparam [1:0]    TX_IDLE = 2'b00,
                    TX_PUSH_FIFO = 2'b01,
                    TX_NEXT_CHAR = 2'b10;

reg [1:0] tx_state;
reg [8*TX_LENTH-1:0] tx_shift_reg;
reg [4:0] tx_char_cnt;

assign tx_str_busy = (tx_state != TX_IDLE);
always @(posedge clk or posedge rst) begin
    if (rst) begin
        user_tx_en <= 1'b0;
        user_tx_data <= 8'd0;
        tx_state <= TX_IDLE;
        tx_char_cnt <= 4'd0;
        tx_shift_reg <= 'd0;
    end else begin
        user_tx_en <= 1'b0;
        case (tx_state)
            TX_IDLE : begin
                if (tx_str_en && tx_str_len > 0) begin
                    tx_shift_reg <= tx_str_data;
                    tx_char_cnt <= tx_str_len;
                    tx_state <= TX_PUSH_FIFO;
                end 
            end
            TX_PUSH_FIFO : begin
                if (!user_tx_full) begin
                    user_tx_en <= 1'b1;
                    user_tx_data <= tx_shift_reg[(tx_char_cnt*8 - 1) -: 8];
                    tx_state <= TX_NEXT_CHAR;
                end 
            end
            TX_NEXT_CHAR : begin
                tx_char_cnt <= tx_char_cnt - 1;
                if(tx_char_cnt == 4'd1) begin
                    tx_state <= TX_IDLE;
                end else begin
                    tx_state <= TX_PUSH_FIFO;
                end
            end
            default : tx_state <= TX_IDLE;
        endcase
    end
end

//  字符串接收
reg rx_state;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        user_rx_rd   <= 1'b0;
        rx_str_data  <= 64'b0;
        rx_str_valid <= 1'b0;
        rx_state     <= 1'b0;
    end else begin
        rx_str_valid <= 1'b0;
        user_rx_rd   <= 1'b0;
    
        // 收到完整字符串并在外层读取后，清空历史记录，防止残影
        if (rx_str_valid) begin
            rx_str_data <= 'd0;
        end

        case (rx_state)
        1'b0: begin
            // 只要有数据，就抓取
            if (!user_rx_empty) begin
                user_rx_rd <= 1'b1; // 通知 FIFO：数据我拿了，你准备下一个
                rx_state   <= 1'b1; // 进入等待周期！！！(解决重复读取的关键)
                
                if (user_rx_data == "\n" || user_rx_data == "\r") begin
                    rx_str_valid <= 1'b1; // 触发有效脉冲
                end 
                else begin
                    if (rx_str_valid) 
                        rx_str_data <= {rx_str_data[8*RX_LENTH-9:0], user_rx_data};
                    else
                        rx_str_data <= {rx_str_data[8*RX_LENTH-9:0], user_rx_data};
                end
            end
        end       
        1'b1: begin
            /// 纯等 1 个时钟周期。
            rx_state <= 1'b0;
        end
        endcase
    end 
end

endmodule