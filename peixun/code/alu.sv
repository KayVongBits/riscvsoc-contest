`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/01 10:31:41
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ALU#(
    parameter   DATAWIDTH = 32	
)(
    input  logic [DATAWIDTH - 1:0]  A           ,
    input  logic [DATAWIDTH - 1:0]  B           ,
    input  logic [3:0]              ALUControl  ,
    output logic [DATAWIDTH - 1:0]  Result      ,
    output logic                    isTrue        
);
    
    logic signed [DATAWIDTH - 1:0] As;
    logic signed [DATAWIDTH - 1:0] Bs;

    assign As = A;
    assign Bs = B;

    always_comb begin
        Result = '0;
        isTrue = 1'b0;

        unique case (ALUControl)
            4'b0000: begin
                Result = A + B;
            end
            4'b0001: begin
                Result = A - B;
            end
            4'b0010: begin
                Result = A & B;
            end
            4'b0011: begin
                Result = A | B;
            end
            4'b0100: begin
                Result = A ^ B;
            end
            4'b0101: begin
                Result = A << B[$clog2(DATAWIDTH)-1:0];
            end
            4'b0110: begin
                Result = A >> B[$clog2(DATAWIDTH)-1:0];
            end
            4'b0111: begin
                Result = As >>> B[$clog2(DATAWIDTH)-1:0];
            end
            4'b1000: begin
                isTrue = (A == B);
            end
            4'b1001: begin
                isTrue = (A != B);
            end
            4'b1010: begin
                isTrue = (As < Bs);
                Result = (As < Bs) ? 32'd1 : 32'd0;
            end
            4'b1011: begin
                isTrue = (As >= Bs);
            end
            4'b1100: begin
                isTrue = (A < B);
                Result = (A < B) ? 32'd1 : 32'd0;
            end
            4'b1101: begin
                isTrue = (A >= B);
            end
            default: begin
                Result = '0;
                isTrue = 1'b0;
            end
        endcase
    end

endmodule
