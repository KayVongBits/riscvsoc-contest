`timescale 1ns / 1ps                                                                                     
/****************************************Copyright (c)**************************************************
**----------------------------------------File Info-----------------------------------------------------
** File name					:	breath_led                                                                   
** Last modified Date	:	2025-09-01                                                                      
** Last Version				:	1.0                                                                             
** Descriptions       :	breath led                                                           
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
//`define SIM
module breath_led(
	input		logic							clk				,
	input		logic							rst_n			,
	output	logic							led	  		
  ); 
  
`ifdef SIM
	localparam TOTAL_PWM_NUM 	= 8				;
	localparam SINGLE_PWM_NUM	= 8				;
	localparam CELL_NUM   		= 2   		;
`else   
	localparam TOTAL_PWM_NUM 	= 1000		;
	localparam SINGLE_PWM_NUM	= 1000		;
	localparam CELL_NUM   		= 100   	;
`endif

logic	[15:0]	cell_cnt								;
logic	[15:0]	single_pwm_cnt					;
logic	[15:0] 	total_pwm_cnt						;
logic         flag										;
logic					cell_done								;
logic					single_pwm_done					;
logic					total_pwm_done					;

assign	cell_done 			= (cell_cnt == CELL_NUM - 1);
assign	single_pwm_done =	(single_pwm_cnt == SINGLE_PWM_NUM - 1);
assign	total_pwm_done	=	(total_pwm_cnt == TOTAL_PWM_NUM - 1);

always_ff @(posedge clk or negedge rst_n)
  if(!rst_n)
    cell_cnt	<= 'h0;        
  else if(cell_done)
  	cell_cnt	<= 'h0; 
  else
  	cell_cnt	<= cell_cnt + 'h1; 

always_ff @(posedge clk or negedge rst_n)
	if(!rst_n)
		single_pwm_cnt <= 'h0;
	else if(cell_done) begin
		if(single_pwm_done) 
			single_pwm_cnt <= 'h0;
		else
			single_pwm_cnt <= single_pwm_cnt + 'h1;
	end
	
always_ff @(posedge clk or negedge rst_n)
	if(!rst_n)
		total_pwm_cnt <= 'h0;
	else if(cell_done && single_pwm_done) begin
		if(total_pwm_done) 
			total_pwm_cnt <= 'h0;
		else
			total_pwm_cnt <= total_pwm_cnt + 'h1;
	end	

always_ff @(posedge clk or negedge rst_n)
	if(!rst_n)
		flag <= 1'b1;
	else if(cell_done && single_pwm_done && total_pwm_done)
		flag <= ~flag;


always_ff @(posedge clk or negedge rst_n)
	if(!rst_n)		
  	led <= 1'b0;
  else if(single_pwm_cnt <= total_pwm_cnt)
  	led <= flag;
  else
  	led <= ~flag;
  	
endmodule
