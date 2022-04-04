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
//*@V0.1     : Modify sequential logic to combinational logic. Because the
//  instruction memory is an external module, we dont care it operation
//  now for a simple LEGV8 instruction set.
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
  //r_clk       ,         
  //rst_n       ,     
  pc          ,  
  inst             
  );
  //===========================================================
  //* Input and output ports
  //===========================================================
  //
  //input                           r_clk      ;             
  //input                           rst_n      ;          
  input    [`WORD - 1 : 0]        pc         ;                  
  output   [`INST_SIZE - 1 : 0]   inst       ;                

  //wire                            r_clk      ;             
  //wire                            rst_n      ;          
  wire     [`WORD - 1 : 0]        pc         ;                  
  wire     [`INST_SIZE - 1 : 0]   inst       ;                

  // Instruction memory
  reg [`INST_SIZE - 1 : 0] inst_memory[SIZE - 1 : 0];

  // Initialize memory
  initial $readmemh( PATH, inst_memory );

  assign inst = inst_memory[pc / 4];

  /*
  // Load instruction
  always @( posedge r_clk or negedge rst_n ) begin
    if( ~rst_n ) begin
      inst <= #1 'b0;
    end
    else begin
      inst <= #1 inst_memory[pc / 4]; // Size of instruction is 4 Bytes
    end
  end      
  */

endmodule

