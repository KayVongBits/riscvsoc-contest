`timescale 1ns / 1ps
/****************************************Copyright (c)**************************************************
**----------------------------------------File Info-----------------------------------------------------
** File name					:	debounce                                                                   
** Last modified Date	:	2025-09-01                                                                      
** Last Version				:	1.0                                                                             
** Descriptions       :	key debounce                                                           
**------------------------------------------------------------------------------------------------------
** Created by					:	FPGACoreCG                                                                     
** Created date				:	2025-09-01                                                                     
** Version						: 1.0                                                                             
** Descriptions				:	The original version                                                            
**------------------------------------------------------------------------------------------------------
** Modified by				:				                                                                          
** Modified date			:			                                                                            
** Version						:					                                                                        
** Descriptions				:		                                                                              
**------------------------------------------------------------------------------------------------------
*******************************************************************************************************/
module debounce(
	input		logic					clk							,
	input		logic					rst_n						,
	input		logic					key_in  				,
	output	logic					key_out					
);
localparam CNT_20MS = 2000000;
logic										key_in_dly			;
logic	[31:0]						cnt							;

always_ff	@(posedge clk or negedge rst_n)
	if(!rst_n)
		key_in_dly <= 1'b1;
	else
		key_in_dly <= key_in;

always_ff	@(posedge clk or negedge rst_n)
	if(!rst_n)
		cnt <= 'h0;
	else if(key_in != key_in_dly)
		cnt <= 'h0;
	else if(cnt == CNT_20MS - 1)
		cnt <= cnt;
	else
		cnt <= cnt + 'h1;

always_ff	@(posedge clk or negedge rst_n)
	if(!rst_n)
		key_out <= 1'b1;
	else if(cnt == CNT_20MS - 1)
		key_out <= key_in_dly;

endmodule
