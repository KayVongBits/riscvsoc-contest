`include "defines.sv"

module ram #(
    parameter AW = `AW, // 地址宽度
    parameter DW = `DW  // 数据宽度
) (
    input  logic                 clk,       // 时钟信号
    input  logic                 rst_n,     // 复位信号，低有效

    input  logic                 we,        // 写使能
    input  logic [AW-1:0]        waddr,     // 地址输入
    input  logic [DW-1:0]        wdata,     // 写数据

    input  logic [AW-1:0]        raddr,     // 读地址输入
    output logic [DW-1:0]        rdata      // 读数据输出

);
    


    logic [DW-1:0] ram_mem [0:`RAM_DEPTH-1]; // RAM 存储器

    always_ff @( posedge clk or negedge rst_n ) begin : blockName
        if ( !rst_n ) begin
            for(int i=0;i<`RAM_DEPTH;i=i+1)
            ram_mem[i] <= 'h0;	
        end else if ( we ) begin
            ram_mem[waddr[AW-1:2]] <= wdata;
        end
    end

    always_comb	begin
	rdata = ram_mem[raddr[AW-1:2]];
    end


    
endmodule