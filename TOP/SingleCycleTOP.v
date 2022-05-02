`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: TOP.v
//*@File Type: verilog
//*@Version  : 0.0
//*@Author   : Zehua Dong, SIGS
//*@E-mail   : 1285507636@qq.com
//*@Date     : 2022/4/11 22:19:20
//*@Function : Top module for single cycle CPU. 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module SingleCycleTOP #(
  parameter INST_FILE = `TEST_INST_FILE,
  parameter DATA_FILE = `TEST_DATA_FILE,
  parameter SIZE = 1024) (
  clk    ,              
  rst_n            
  );

  input                           clk     ;                 
  input                           rst_n   ;              

  wire                            clk     ;                 
  wire                            rst_n   ;              

  wire    [`INST_SIZE - 1 : 0]    inst    ;            
  wire    [`WORD - 1 : 0]         pc      ;               
  wire    [`WORD - 1 : 0]         data    ;            
  wire    [`WORD - 1 : 0]         addr    ;               
  wire                            MemWrite;            
  wire                            MemRead ;            

  SingleCycleCPU SingleCycleCPU(
  .clk       ( clk     ) ,              
  .rst_n     ( rst_n   ) ,         
  .IDB       ( inst    ) ,  // Instruction data bus
  .IAB       ( pc      ) ,  // Instruction address bus
  .DDB       ( data    ) ,  // Data data bus
  .DAB       ( addr    ) ,  // Data address bus
  .MemWrite  ( MemWrite) ,  // Memory write signal
  .MemRead   ( MemRead )    // Memory read signal
  );

  // Instruction memory
  inst_mem #( 
  .PATH  ( INST_FILE   ) ) inst_mem (
  .pc    ( pc     ) ,  
  .inst  ( inst   )             
  );

  data_mem #( 
  .PATH    ( DATA_FILE )  , 
  .SIZE    ( SIZE      )  ) data_mem(
  .clk     ( clk       )  ,
  .MemRead ( MemRead   )  ,     // Signal of reading data from memory
  .MemWrite( MemWrite  )  ,     // Signal of writing data to memory
  .addr    ( addr      )  ,     // Data address bus
  .data    ( data      )        // Data data bus
  );

endmodule

