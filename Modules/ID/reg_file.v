`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: reg_file.v
//
//*@File Type: verilog
//
//*@Version  : 0.1
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/28 23:39:39
//
//*@Function : 
//*@V0.0     : Realize register file read and write. 
//*@V0.1     : Replace initial block to always block.
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module reg_file( 
  clk      ,            
  rst_n    ,        
  r_reg1   ,     // Read register 1          
  r_reg2   ,     // Read register 2
  w_reg    ,     // Write register 
  w_data   ,     // Write data
  RegWrite ,     // Flag of write register
  r_data1  ,     // Read data 1
  r_data2        // Read data 2
  );

  //===========================================================
  //* Input and output ports
  //===========================================================
  //
  input                     clk     ;                
  input                     rst_n   ;             
  input  [4:0]              r_reg1  ;                   
  input  [4:0]              r_reg2  ;                
  input  [4:0]              w_reg   ;                   
  input  [`WORD - 1 : 0]    w_data  ;                
  input                     RegWrite;                   
  output [`WORD - 1 : 0]    r_data1 ;                
  output [`WORD - 1 : 0]    r_data2 ;                   

  wire                      clk   ;                
  wire                      rst_n   ;             
  wire   [4:0]              r_reg1  ;                   
  wire   [4:0]              r_reg2  ;                
  wire   [4:0]              w_reg   ;                   
  wire   [`WORD - 1 : 0]    w_data  ;                
  wire                      RegWrite;                   
  wire   [`WORD - 1 : 0]    r_data1 ;                
  wire   [`WORD - 1 : 0]    r_data2 ; 

  reg    [`WORD - 1 : 0]    reg_memory[31:0];

  //initial $readmemh(PATH, reg_memory);
  
  // Used in initialize register value
  integer i;

  assign r_data1 = reg_memory[r_reg1];
  assign r_data2 = reg_memory[r_reg2];

  always @( posedge clk or negedge rst_n ) begin
    if( ~rst_n ) begin
      for( i = 0; i < 32; i = i + 1 ) begin
        reg_memory[i] <= #1 'd0;
      end
    end
    else begin
      if( RegWrite && w_reg != 'd31 ) begin // XZR cannot be written
        reg_memory[w_reg] <= #1 w_data;
      end
    end
  end      

endmodule

