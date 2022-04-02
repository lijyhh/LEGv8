`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: write_back.v
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/29 21:23:03
//
//*@Function : Write data back to register file.
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module write_back(
  ALUOut   ,       // ALU output result in EX       
  r_data   ,       // Data read from MEM  
  pc_incr  ,       // PC + 4
  r_data2  ,       // Data read from register file, for MOVK
  MemtoReg ,       // Memory to register signal from control unit
  inst     ,       // Instruction opcode
  w_data           // Write data to be written back
  );

  //===========================================================
  //* Input and output ports
  //===========================================================
  //
  input  [`WORD - 1 : 0]          ALUOut  ;                   
  input  [`WORD - 1 : 0]          r_data  ;                
  input  [`WORD - 1 : 0]          pc_incr ;                   
  input  [`WORD - 1 : 0]          r_data2 ;                   
  input  [1:0]                    MemtoReg;                   
  input  [`INST_SIZE - 1 : 0]     inst    ;                   
  output [`WORD - 1 : 0]          w_data  ;                   

  wire   [`WORD - 1 : 0]          ALUOut  ;                   
  wire   [`WORD - 1 : 0]          r_data  ;                
  wire   [`WORD - 1 : 0]          pc_incr ;                   
  wire   [`WORD - 1 : 0]          r_data2 ;                   
  wire   [1:0]                    MemtoReg;                   
  wire   [`INST_SIZE - 1 : 0]     inst    ;                   
  reg    [`WORD - 1 : 0]          w_data  ;                   

  //===========================================================
  //* Internal signals
  //===========================================================
  //
  wire   [6:0]                    mov_shift;
  wire   [10:0]                   opcode   ;

  assign mov_shift = inst[22:21] << 4;
  assign opcode    = inst[31:21];

  always @(*) begin
    casez( opcode )
      `MOVZ:   w_data = (inst[20:5] << mov_shift);
      `MOVK: 
        case( mov_shift )
          0:  w_data = {r_data2[16+:48], inst[20:5]};
          16: w_data = {r_data2[32+:32], inst[20:5], r_data2[0+:16]};
          32: w_data = {r_data2[48+:16], inst[20:5], r_data2[0+:32]};
          48: w_data = {inst[20:5],  r_data2[0+:48]}; 
          default: w_data = 'b0;
        endcase
      default: 
        case( MemtoReg )
          0: w_data = ALUOut;
          1: w_data = r_data;
          2: w_data = pc_incr; 
          default: w_data = 'b0;
        endcase
    endcase
  end

endmodule

