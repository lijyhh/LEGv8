`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: mux2.v
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/28 22:53:07
//
//*@Function : 2-1 multiplexer.
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module mux2 #( 
  parameter SIZE = `WORD )(
  a    ,              
  b    ,        
  sel  ,               
  out   
  );

  input   [SIZE - 1 : 0]   a  ;                   
  input   [SIZE - 1 : 0]   b  ;                 
  input                    sel;                   
  output  [SIZE - 1 : 0]   out;                   

  wire    [SIZE - 1 : 0]   a  ;                   
  wire    [SIZE - 1 : 0]   b  ;                 
  wire                     sel;                   
  wire    [SIZE - 1 : 0]   out;                   

  assign out = sel ? b : a;

endmodule

