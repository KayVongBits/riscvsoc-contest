`include "defines.sv"

module pc_counter #(
    parameter AW = `AW
)(
    input  logic clk,
    input  logic rst_n,
    input  logic jump_en,
    input  logic [AW-1:0] jump_addr,
    output logic [AW-1:0] pc_pointer
);

logic [AW-1:0] current_addr;

always_ff @( posedge clk or negedge rst_n ) begin : pc_update_seq
    if ( !rst_n ) begin
        pc_pointer <= 'h0;
    end else if ( jump_en ) begin
        pc_pointer <= jump_addr;
    end else begin
        pc_pointer <= pc_pointer + 'h4;
    end
end

always_ff @( posedge clk or negedge rst_n ) begin : current_addr_seq
    if ( !rst_n ) begin
        current_addr <= 'h0;
    end else if ( jump_en ) begin
        current_addr <= pc_pointer;
    end
end

endmodule