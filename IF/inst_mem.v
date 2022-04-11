`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: inst_mem.v
//
//*@File Type: verilog
//
//*@Version  : 0.1
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/28 20:57:52
//
//*@Function : Memory of instruction. 
//
//*@V0.0     : Initial.
//*@V0.1     : 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module inst_mem #( 
  parameter PATH = `TEST_INST_FILE, // instruction file
  parameter SIZE = 1024)( // size of instruction mem
  pc          ,  
  inst             
  );
  //===========================================================
  //* Input and output ports
  //===========================================================
  //
  input    [`WORD - 1 : 0]        pc         ;                  
  output   [`INST_SIZE - 1 : 0]   inst       ;                

  wire     [`WORD - 1 : 0]        pc         ;                  
  wire     [`INST_SIZE - 1 : 0]   inst       ;                

  // Instruction memory
  reg [`INST_SIZE - 1 : 0] inst_memory[SIZE - 1 : 0];

  // Initialize memory
  initial $readmemh( PATH, inst_memory );

  assign inst = inst_memory[pc / 4];

endmodule

