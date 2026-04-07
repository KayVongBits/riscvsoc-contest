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
    
    // Signed views for arithmetic and comparisons
    logic signed [DATAWIDTH - 1:0] As;
    logic signed [DATAWIDTH - 1:0] Bs;

    assign As = A;
    assign Bs = B;

    always_comb begin
        // Default outputs
        Result = '0;
        isTrue = 1'b0;

        unique case (ALUControl)
            4'b0000: begin // add
                Result = A + B;
            end
            4'b0001: begin // sub
                Result = A - B;
            end
            4'b0010: begin // and
                Result = A & B;
            end
            4'b0011: begin // or
                Result = A | B;
            end
            4'b0100: begin // xor
                Result = A ^ B;
            end
            4'b0101: begin // shift left logical
                Result = A << B[$clog2(DATAWIDTH)-1:0];
            end
            4'b0110: begin // shift right logical
                Result = A >> B[$clog2(DATAWIDTH)-1:0];
            end
            4'b0111: begin // shift right arithmetic
                Result = As >>> B[$clog2(DATAWIDTH)-1:0];
            end
            4'b1000: begin // equal
                isTrue = (A == B);
            end
            4'b1001: begin // not equal
                isTrue = (A != B);
            end
            4'b1010: begin // less than (signed)
                isTrue = (As < Bs);
                Result = (As < Bs) ? 32'd1 : 32'd0; // SLT 指令需要把结果写回寄存器
            end
            4'b1011: begin // greater or equal (signed)
                isTrue = (As >= Bs);
            end
            default: begin
                Result = '0;
                isTrue = 1'b0;
            end
        endcase
    end

endmodule