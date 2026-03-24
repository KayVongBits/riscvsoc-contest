`timescale 1ns / 1ps
/****************************************Copyright (c)**************************************************
**----------------------------------------File Info-----------------------------------------------------
** File name					:	led_top                                                                             
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

module led_top(
	input		logic						clk						,
	input		logic						rst_n					,
	input		logic	[3:0]			led_pattern		,
	output	logic	[3:0]			led	        	
);
    
logic											blink_led			;
logic											breath_led		;
logic	[3:0]								flow_led			;
blink_led u_blink_led_inst(
	.clk									(clk						),
	.rst_n								(rst_n					),
	.led	  							(blink_led			)
  );

breath_led u_breath_led_inst(
	.clk				  				(clk		 		 		),
	.rst_n			  				(rst_n			 		),
	.led	  		  				(breath_led	 		)
);

flow_led u_flow_led_inst(
	.clk				  				(clk		 				),
	.rst_n			  				(rst_n			 		),
	.led	  		  				(flow_led	 		  )
);

cfg_led u_cfg_led_inst(
	.clk									(clk						),
	.rst_n								(rst_n			  	),
	.led_pattern  				(led_pattern  	),
	.blink_led						(blink_led    	),
	.breath_led	  				(breath_led   	),
	.flow_led             (flow_led       ),
	.led	        				(led          	)
);
    
endmodule
