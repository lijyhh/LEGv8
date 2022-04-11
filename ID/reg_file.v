`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: reg_file.v
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/28 23:39:39
//
//*@Function : Realize register file read and wirte. 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module reg_file #( 
  parameter PATH = `TEST_REG_FILE )(
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
  initial $readmemh(PATH, reg_memory);

  /*
  // Read data from register memory
  always @( posedge clk or negedge rst_n ) begin
    if( ~rst_n ) begin
      r_data1 <= 'b0;
      r_data2 <= 'b0;
    end
    else begin
      r_data1 <= reg_memory[r_reg1];
      r_data2 <= reg_memory[r_reg2];
    end
  end  
  */

  assign r_data1 = reg_memory[r_reg1];
  assign r_data2 = reg_memory[r_reg2];

  always @( posedge clk or negedge rst_n ) begin
    if( rst_n && RegWrite && w_reg != 'd31 ) begin
      reg_memory[w_reg] <= w_data;
    end
  end      

endmodule

