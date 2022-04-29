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
//*@V0.1     : Merge r_data and w_data to data(inout)
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module data_mem #( 
  parameter PATH = `SINGLE_CYCLE_TEST_INST_FILE, 
  parameter SIZE = 1024) (
  clk       ,              
  MemRead   ,     // Signal of reading data from memory
  MemWrite  ,     // Signal of writing data to memory
  addr      ,     // Address
  data            // Memory data to be read or written
  //w_data    ,     // Data to be write
  //r_data          // Data read from memory
  );

  //===========================================================
  //* Input and output ports
  //===========================================================
  //
  input                           clk     ;                  
  input                           MemRead ;                   
  input                           MemWrite;                
  input  [`WORD - 1 : 0]          addr    ;                   
  inout  [`WORD - 1 : 0]          data    ;                

  wire                            clk     ;                  
  wire                            MemRead ;                   
  wire                            MemWrite;                
  wire   [`WORD - 1 : 0]          addr    ;                   
  wire   [`WORD - 1 : 0]          data    ;                

  //===========================================================
  //* Internal signals
  //===========================================================
  //
  wire   [`WORD - 1 : 0]          r_data  ;                   

  reg    [`WORD - 1 : 0]          data_memory[SIZE - 1 : 0];
  
  // Tri-state buffer
  assign data = ( MemRead && ~MemWrite ) ? r_data : 'bz;

  // Initial memory
  initial $readmemh(PATH, data_memory);

  // Read by combinational logic
  assign r_data = ( MemRead && ~MemWrite ) ? data_memory[addr/8] : 'b0;

  // Write data
  always @( posedge clk ) begin
    if( MemWrite && ~MemRead ) begin
      data_memory[addr/8] <= #1 data;
    end
  end      

endmodule

