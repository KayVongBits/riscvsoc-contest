`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/04 14:46:30
// Design Name: 
// Module Name: alu
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


module alu#(
    parameter   DATAWIDTH = 32   
)(
    input  logic [DATAWIDTH - 1:0]  A           ,
    input  logic [DATAWIDTH - 1:0]  B           ,
    input  logic [1:0]              ALUControl  ,
    output logic [DATAWIDTH - 1:0]  Result      ,
    output logic                    N           ,
    output logic                    Z           ,
    output logic                    V           ,
    output logic                    C           
);

    always_comb begin
        V = 1'b0; // Overflow flag is not used in this simple ALU
        C = 1'b0; // Carry flag default
        Result = '0; // Default result

        case (ALUControl)

            2'b00: begin
                {C, Result} = A + B; // ADD
                V = (A[DATAWIDTH - 1] == B[DATAWIDTH - 1]) && (A[DATAWIDTH - 1] != Result[DATAWIDTH - 1]);
            end
            2'b01: begin 
                Result = A - B; // SUB
                C = A >= B;
                V = (A[DATAWIDTH - 1] != B[DATAWIDTH - 1]) && (Result[DATAWIDTH - 1] != A[DATAWIDTH - 1]);
            end
            2'b10: Result = A & B;      // AND
            2'b11: Result = A | B;      // OR
            default: Result = '0;
        endcase

        N = Result[DATAWIDTH - 1]; 
        Z = (Result == '0);        
        
    end

    

endmodule
