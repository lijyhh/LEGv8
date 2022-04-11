`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: data_mem.v
//
//*@File Type: verilog
//
//*@Version  : 0.1
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/29 20:52:03
//
//*@Function : Realize data memory. 
//
//*@V0.0     : Initial design with separate read and write clock.
//*@V0.1     : 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module data_mem #( 
  parameter PATH = `TEST_DATA_FILE, 
  parameter SIZE = 1024) (
  clk       ,              
  rst_n     ,          
  MemRead   ,     // Signal of reading data from memory
  MemWrite  ,     // Signal of writing data to memory
  addr      ,     // Address
  w_data    ,     // Data to be write
  r_data          // Data read from memory
  );

  //===========================================================
  //* Input and output ports
  //===========================================================
  //
  input                           clk     ;                  
  input                           rst_n   ;               
  input                           MemRead ;                   
  input                           MemWrite;                
  input  [`WORD - 1 : 0]          addr    ;                   
  input  [`WORD - 1 : 0]          w_data  ;                
  output [`WORD - 1 : 0]          r_data  ;                   

  wire                            clk     ;                  
  wire                            rst_n   ;               
  wire                            MemRead ;                   
  wire                            MemWrite;                
  wire   [`WORD - 1 : 0]          addr    ;                   
  wire   [`WORD - 1 : 0]          w_data  ;                
  wire   [`WORD - 1 : 0]          r_data  ;                   

  reg    [`WORD - 1 : 0]          data_memory[SIZE - 1 : 0];
  
  // Initial memory
  initial $readmemh(PATH, data_memory);

  // Read by combinational logic
  assign r_data = ( MemRead ? data_memory[addr/8] : 'b0 );

  // Write data
  always @( posedge clk or negedge rst_n ) begin
    if( rst_n && MemWrite ) begin
      data_memory[addr/8] <= w_data;
    end
  end      

endmodule

