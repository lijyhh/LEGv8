`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: mux4.v
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/29 20:26:55
//
//*@Function : 4-1 multiplexer. 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module mux4 #( 
  parameter SIZE = `WORD )(
  a     ,             
  b     ,       
  c     ,      
  d     ,    
  sel   ,       
  out    
  );

  input  [SIZE - 1 : 0]           a  ;                   
  input  [SIZE - 1 : 0]           b  ;                
  input  [SIZE - 1 : 0]           c  ;                   
  input  [SIZE - 1 : 0]           d  ;                
  input  [1:0]                    sel;                   
  output [SIZE - 1 : 0]           out;                

  wire   [SIZE - 1 : 0]           a  ;                   
  wire   [SIZE - 1 : 0]           b  ;                
  wire   [SIZE - 1 : 0]           c  ;                   
  wire   [SIZE - 1 : 0]           d  ;                
  wire   [1:0]                    sel;                   
  reg    [SIZE - 1 : 0]           out;                

  always @(*) begin
    case( sel )
      2'b00: out = a;
      2'b01: out = b;
      2'b10: out = c;
      2'b11: out = d;
      default: out = 'b0;
    endcase
  end

endmodule

