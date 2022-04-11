`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: status_reg.v
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/30 10:52:25
//
//*@Function : Store ALU status flag. 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module status_reg(
  clk       ,           
  rst_n     ,       
  Negative  ,      
  Zero      ,  
  Ci        ,    
  Overflow  , 
  SregUp    ,  // Update status register flag
  N         ,  // Negative
  Z         ,  // Zero      
  C         ,  // Carry    
  V            // oVerflow         
  );

  input                           clk       ;              
  input                           rst_n     ;           
  input                           Negative  ;                
  input                           Zero      ;                
  input                           Ci        ;                
  input                           Overflow  ;                
  input                           SregUp    ;                
  output                          N         ;                
  output                          Z         ;                
  output                          C         ;                
  output                          V         ;                

  wire                            clk       ;              
  wire                            rst_n     ;           
  wire                            Negative  ;                
  wire                            Zero      ;                
  wire                            Ci        ;                
  wire                            Overflow  ;                
  wire                            SregUp    ;                
  reg                             N         ;                
  reg                             Z         ;                
  reg                             C         ;                
  reg                             V         ;                

  always @( posedge clk or negedge rst_n ) begin
    if( ~rst_n ) begin
      {N, Z, V, C} <= 4'b0000;
    end
    else if( SregUp ) begin
      {N, Z, V, C} <= {Negative, Zero, Overflow, Ci};
    end
  end      

endmodule

