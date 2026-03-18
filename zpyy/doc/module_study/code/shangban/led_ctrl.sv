module led_ctrl #(
    parameter CLK_FREQ = 50_000_000 
)(
    input  logic       clk     ,
    input  logic       rst     , 
    input  logic [1:0] mode    ,
    output logic [3:0] led     
);

    localparam TIME_MAX = CLK_FREQ / 4; 
    
    logic [31:0] cnt;
    logic        tick;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt  <= '0;
            tick <= 1'b0;
        end else if (cnt == TIME_MAX - 1) begin
            cnt  <= '0;
            tick <= 1'b1;       
        end else begin
            cnt  <= cnt + 1'b1;
            tick <= 1'b0;
        end
    end

    logic [3:0] led_r;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            led_r <= 4'b0000;  
        end else if (tick) begin
            unique case (mode)
                2'b00: begin
                    led_r <= 4'b0000;
                end
                
                2'b01: begin
                    led_r <= ~led_r;
                end
                
                2'b10: begin
                    if (led_r == 4'b0000) begin
                        led_r <= 4'b0001;
                    end else begin
                        led_r <= {led_r[2:0], led_r[3]};
                    end
                end
                
                2'b11: begin
                    if (led_r == 4'b0101) begin
                        led_r <= 4'b1010;
                    end else begin
                        led_r <= 4'b0101;
                    end
                end
                
                default: led_r <= 4'b0000;
            endcase
        end
    end

    assign led = led_r;

endmodule