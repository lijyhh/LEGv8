`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: left_shift.v
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/29 9:21:07
//
//*@Function : Logic left shift. 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module left_shift #( 
  parameter SIZE = `WORD, 
  parameter OFFSET = 2 )(
  in  ,                  
  out            
  );

  input  [SIZE - 1 : 0]           in  ;                     
  output [SIZE - 1 : 0]           out ;                

  wire   [SIZE - 1 : 0]           in  ;                     
  wire   [SIZE - 1 : 0]           out ;                

  assign out = in << OFFSET;

endmodule

