`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: dff.v
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/28 22:13:32
//
//*@Function : Module of D filp flop  
//
//******************************************************************

// Header file
`include "common.vh"

//
// Module
module dff #( parameter SIZE = `WORD )(
  clk    ,              
  rst_n  ,    
  D      ,           
  Q                 
  );

  input                     clk    ;                 
  input                     rst_n  ;              
  input   [SIZE - 1 : 0]    D      ;             
  output  [SIZE - 1 : 0]    Q      ;          

  wire                      clk    ;                 
  wire                      rst_n  ;              
  wire    [SIZE - 1 : 0]    D      ;             
  reg     [SIZE - 1 : 0]    Q      ;          

  always @( posedge clk or negedge rst_n ) begin
    if( ~rst_n ) begin
      Q <= #1 'b0;
    end
    else begin
      Q <= #1 D;
    end
  end      

endmodule

