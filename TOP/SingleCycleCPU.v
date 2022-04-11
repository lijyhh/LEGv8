`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: TOP.v
//
//*@File Type: verilog
//
//*@Version  : 0.1
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/30 16:07:50
//
//*@Function : 
//*V0.0      : Single cycle CPU module of single cycle LEGv8 instruction set. 
//*V0.1      : Remove instrction memory and data memory from CPU.
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module SingleCycleCPU #( 
  parameter INST_FILE = `TEST_INST_FILE,
  parameter REG_FILE  = `TEST_REG_FILE ,
  parameter DATA_FILE = `TEST_DATA_FILE) (
  clk    ,              
  rst_n            
  );

  input                           clk  ;  
  input                           rst_n;                

  wire                            clk  ; 
  wire                            rst_n;                

  wire    [10:0]                  opcode  ;                   
  wire                            Reg2Loc ;                
  wire                            RegWrite;                
  wire                            WRegLoc ;                
  wire                            ALUSrc  ;                
  wire    [01:0]                  ALUOp   ;                
  wire                            SregUp  ;                
  wire    [02:0]                  BranchOp;                
  wire                            MemRead ;                
  wire                            MemWrite;                
  wire    [01: 0]                 MemtoReg;                

  control control_path(
  .opcode  ( opcode   ) ,          // Opcode from instruction, 11 bits     
  .Reg2Loc ( Reg2Loc  ) ,          // Select register file source register 2, 1 bit
  .RegWrite( RegWrite ) ,          // Flag of register file to write back, 1 bit 
  .WRegLoc ( WRegLoc  ) ,          // Flag of register file to select write register, 1 bit
  .ALUSrc  ( ALUSrc   ) ,          // Flag of ALU to select source data 2, 1 bit
  .ALUOp   ( ALUOp    ) ,          // ALU op for ALU control unit, 2 bits 
  .SregUp  ( SregUp   ) ,          // Update status register, 1bit
  .BranchOp( BranchOp ) ,          // Branch op for EX to select PC source, 3 bits
  .MemRead ( MemRead  ) ,          // Flag of memory read, 1 bit
  .MemWrite( MemWrite ) ,          // Flag of memory write, 1 bit
  .MemtoReg( MemtoReg )            // Flag of MUX in WB to select source data, 1 bit
  );

  datapath #( 
  .INST_FILE( INST_FILE ),
  .REG_FILE ( REG_FILE  ),
  .DATA_FILE( DATA_FILE )) data_path(
  .clk      ( clk       ),            
  .rst_n    ( rst_n     ),        
  .RegWrite ( RegWrite  ),
  .Reg2Loc  ( Reg2Loc   ),
  .WRegLoc  ( WRegLoc   ),
  .ALUOp    ( ALUOp     ),
  .ALUSrc   ( ALUSrc    ),
  .BranchOp ( BranchOp  ),
  .SregUp   ( SregUp    ),
  .MemRead  ( MemRead   ),
  .MemWrite ( MemWrite  ),
  .MemtoReg ( MemtoReg  ),
  .opcode   ( opcode    )
  );

endmodule

