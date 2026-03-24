`timescale 1ns / 1ps
/****************************************Copyright (c)**************************************************
**----------------------------------------File Info-----------------------------------------------------
** File name					:	cfg_led                                                                   
** Last modified Date	:	2025-09-01                                                                      
** Last Version				:	1.0                                                                             
** Descriptions       :	cfg_led                                                           
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

module cfg_led(
	input		logic						clk						,
	input		logic						rst_n					,
	input		logic	[3:0]			led_pattern 	,
	input		logic						blink_led			,
	input		logic						breath_led		,
	input		logic	[3:0]			flow_led			,
	output	logic	[3:0]			led	        	
);
 
always_ff @(posedge clk or negedge rst_n)
	if(!rst_n)
		led	<= 1'b0;
	else begin
		case(led_pattern)
			4'd0		:	led	<= {4{1'b0}};
			4'd1		:	led	<= {4{1'b1}};
			4'd2		:	led	<= {4{blink_led}};//全亮全灭交替闪烁
			4'd3		:	led	<= {4{breath_led}};//全亮全灭交替呼吸
			4'd4    : led	<= flow_led;
			4'd5		: led	<= {1'b0,1'b1,blink_led,breath_led};
			4'd6		: led	<= {blink_led,breath_led,blink_led,breath_led};
			default	:	led	<= flow_led;
		endcase
	end 
    
endmodule
