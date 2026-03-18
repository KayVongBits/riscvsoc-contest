module top(
    input   logic               clk     ,
    input   logic               rst_n   ,
    input   logic   [3:0]       key     ,
    input   logic               rx_i    ,
    output  logic               tx_o    ,
    
    output  logic   [3:0]       led
);
localparam TX_LENTH = 20;
localparam RX_LENTH = 5;

(*mark_debug = "true"*)logic rst = ~rst_n;
(*mark_debug = "true"*)logic [3:0] key_down;
logic [1:0] led_mode;
(*mark_debug = "true"*)logic rvrst =  key_down[0];

logic [8*TX_LENTH-1:0] tx_str_data;
logic [4:0] tx_str_len;
logic tx_str_en;
logic tx_str_busy;
logic [8*RX_LENTH-1:0] rx_str_data;
logic rx_str_valid;

logic pass;
assign pass = &led_mode;
riscv_top u_riscv_top (
    .clk            (clk        )   ,
    .rst            (rvrst      )   ,
    .led_mode       (led_mode   )   
);

key_proc u_key_proc (
    .clk            (clk        )   ,
    .rst            (rst        )   ,
    .key_i          (key        )   ,
    .down_o         (key_down   )  
);

led_ctrl u_led_ctrl (
    .clk            (clk        )   ,
    .rst            (rst        )   ,
    .mode           (led_mode   )   ,
    .led            (led        )        
);


uart_fifo #(
    .BAUD_RATE  	(5208           ),
    .FIFO_DEPTH 	(64             ),
    .TX_LENTH   	(TX_LENTH       ),
    .RX_LENTH   	(RX_LENTH       ))
u_uart_fifo(
    .clk          	(clk           ),
    .rst          	(rst           ),
    .rx_i         	(rx_i          ),
    .tx_o         	(tx_o          ),
    .tx_str_data  	(tx_str_data   ),
    .tx_str_len   	(tx_str_len    ),
    .tx_str_en    	(tx_str_en     ),
    .tx_str_busy  	(tx_str_busy   ),
    .rx_str_data  	(rx_str_data   ),
    .rx_str_valid 	(rx_str_valid  )
);

always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        tx_str_en    <= 1'b0   ;
        tx_str_data  <= 'b0 ;
        tx_str_len   <= 'b0 ;
    end else begin
        tx_str_en    <= 1'b0   ;

        if (rx_str_valid) begin
            if (rx_str_data[15:0] == "OK") begin
                tx_str_en    <= 1'b1   ;
                tx_str_data  <= pass ? "PASS" : "FAIL";
                tx_str_len   <= 5 ;
            end else begin
                tx_str_en    <= 1'b0   ;
                tx_str_data  <= 'b0;
                tx_str_len   <= 'b0 ;
            end
        end
    end
end
endmodule