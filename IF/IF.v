`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: fetch.v
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/28 22:19:46
//
//*@Function : Realize fetch instruction.
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module IF #( 
  parameter PATH=`INST_FILE )(
  clk         ,             
  rst_n       , 
  ALU_res     ,    // Result of ADD ALU in EX, i.e. address of branch     
  ALUOut      ,    // Result of ALU in EX
  PCSrc       ,    // Control signal of PCSrc  
  pc          ,    // Current PC
  pc_incr     ,    // Current PC + 4
  inst             // Output instruction
  );

  //===========================================================
  //* Input and output ports
  //===========================================================
  //
  input                       clk     ;                
  input                       rst_n   ;             
  input  [`WORD - 1 : 0]      ALU_res ;                   
  input  [`WORD - 1 : 0]      ALUOut  ;                   
  input  [1:0]                PCSrc   ;                   
  output [`WORD - 1 : 0]      pc      ;  
  output [`WORD - 1 : 0]      pc_incr ;   
  output [`INST_SIZE - 1 : 0] inst    ;

  wire                        clk     ;                
  wire                        rst_n   ;             
  wire   [`WORD - 1 : 0]      ALU_res ;                   
  wire   [`WORD - 1 : 0]      ALUOut  ;                   
  wire   [1:0]                PCSrc   ;                   
  wire   [`WORD - 1 : 0]      pc      ;   
  wire   [`WORD - 1 : 0]      pc_incr ;   
  wire   [`INST_SIZE - 1 : 0] inst    ;

  //===========================================================
  //* Internal signals
  //===========================================================
  //
  // Current PC
  wire [`WORD - 1 : 0] pc_c;
  // New PC selected from mux4
  wire [`WORD - 1 : 0] pc_new;


  assign pc_incr = ~rst_n ? 0 : pc + 'd4;
  assign pc = ~rst_n ? 0 : pc_c;

  // Select PC source
  mux4 #( 
  .SIZE( `WORD    ) ) mux4_pc(
  .a   ( pc_incr  ) ,  
  .b   ( ALU_res  ) ,  
  .c   ( ALUOut   ) ,  
  .d   ( pc       ) ,  
  .sel ( PCSrc    ) ,
  .out ( pc_new   )
  );

  // DFF of PC
  dff #( 
  .SIZE ( `WORD  )  ) dff_pc(
  .clk  ( clk    )  ,              
  .rst_n( rst_n  )  ,    
  .D    ( pc_new )  ,           
  .Q    ( pc_c   )             
  );

  // Instruction memory
  inst_mem #( 
  .PATH  ( PATH   ) ) inst_mem (
  .pc    ( pc     ) ,  
  .inst  ( inst   )             
  );


endmodule

