`timescale 1ns / 1ps
/****************************************Copyright (c)**************************************************
**----------------------------------------File Info-----------------------------------------------------
** File name					:	key_trig                                                                   
** Last modified Date	:	2025-09-01                                                                      
** Last Version				:	1.0                                                                             
** Descriptions       :	key trig                                                           
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
module key_trig(
	input		logic					clk							,
	input		logic					rst_n						,
	input		logic					key_in  				,
	output	logic					key_redge				,
	output	logic					key_fedge					
);

logic	[4:0]							key_in_dly			;

always_ff	@(posedge clk or negedge rst_n)
	if(!rst_n)
		key_in_dly <= 'h0;
	else
		key_in_dly <= {key_in_dly[3:0],key_in};

always_ff	@(posedge clk or negedge rst_n)
	if(!rst_n)
		key_redge <= 1'b0;
	else if(!key_in_dly[3] && key_in_dly[2])
		key_redge <= 1'b1;
	else 
		key_redge <= 1'b0;
		
always_ff	@(posedge clk or negedge rst_n)
	if(!rst_n)
		key_fedge <= 1'b0;
	else if(!key_in_dly[2] && key_in_dly[3])
		key_fedge <= 1'b1;
	else 
		key_fedge <= 1'b0;

endmodule
