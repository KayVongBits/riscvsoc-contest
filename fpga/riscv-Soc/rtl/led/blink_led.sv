`timescale 1ns / 1ps
/****************************************Copyright (c)**************************************************
**----------------------------------------File Info-----------------------------------------------------
** File name					:	blink_led                                                                   
** Last modified Date	:	2025-09-01                                                                      
** Last Version				:	1.0                                                                             
** Descriptions       :	blink led                                                           
**------------------------------------------------------------------------------------------------------
** Created by					: FPGACoreCG                                                                     
** Created date				: 2025-09-01                                                                     
** Version						: 1.0                                                                             
** Descriptions				:	The original version                                                            
**------------------------------------------------------------------------------------------------------
** Modified by				:				                                                                          
** Modified date			:			                                                                            
** Version						:					                                                                        
** Descriptions				:		                                                                                                                                                                                  
**------------------------------------------------------------------------------------------------------
*******************************************************************************************************/
//`define	SIM

module blink_led(
	input		logic				clk				,
	input		logic				rst_n			,
	output	logic				led	  		
);                          		
`ifdef SIM
	localparam CLK_FRQ = 10;
`else  
	localparam CLK_FRQ = 100000000;
`endif

logic	[31:0]	cnt	;

always_ff @(posedge clk or negedge rst_n)
  if(!rst_n)
    cnt	<= 'h0;        
  else if(cnt == CLK_FRQ - 1)
  	cnt	<= 'h0; 
  else
  	cnt	<= cnt + 'h1; 

always_ff @(posedge clk or negedge rst_n)
	if(!rst_n)
		led <= 1'b0;
	else if(cnt == CLK_FRQ - 1)
		led <= ~led;
  
endmodule
