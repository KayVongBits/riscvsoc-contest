`timescale 1ns / 1ps
/****************************************Copyright (c)**************************************************
**----------------------------------------File Info-----------------------------------------------------
** File name					:	key_top                                                                   
** Last modified Date	:	2025-09-01                                                                      
** Last Version				:	1.0                                                                             
** Descriptions       :	key_top                                                           
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
module key_top(
	input		logic							clk										,
	input		logic							rst_n									,
	input		logic							key_in  							,
	output	logic							key_out								,
	output	logic							key_redge							,
	output	logic							key_fedge							
);


debounce u_debounce_inst(
	.clk											(clk        		 			),
	.rst_n										(rst_n								),
	.key_in  									(key_in								),
	.key_out									(key_out							)
);

key_trig u_key_trig_inst(
	.clk											(clk        		 			),
	.rst_n										(rst_n								),
	.key_in  									(key_out							),
	.key_redge								(key_redge						),
	.key_fedge								(key_fedge						)
);

endmodule
