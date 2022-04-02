`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: datapath.v
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/30 9:18:01
//
//*@Function : Datapath module. 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module datapath #( 
  parameter INST_FILE = `INST_FILE,
  parameter REG_FILE = `REG_FILE,
  parameter DATA_FILE = `DATA_FILE) (
  clk      ,            
  rst_n    ,        
  RegWrite ,
  Reg2Loc  ,
  WRegLoc  ,
  ALUOp    ,
  ALUSrc   ,
  BranchOp ,
  SregUp   ,
  MemRead  ,
  MemWrite ,
  MemtoReg ,
  opcode 
  );

  //===========================================================
  //* Input and output ports
  //===========================================================
  //
  input                           clk      ;               
  input                           rst_n    ;
  input                           RegWrite ;
  input                           Reg2Loc  ;
  input                           WRegLoc  ;
  input    [01: 0]                ALUOp    ;
  input                           ALUSrc   ;
  input    [02: 0]                BranchOp ;
  input                           SregUp   ;                  
  input                           MemRead  ;
  input                           MemWrite ;
  input    [01: 0]                MemtoReg ;
  output   [10: 0]                opcode   ;

  wire                            clk      ;               
  wire                            rst_n    ;  
  wire                            RegWrite ;
  wire                            Reg2Loc  ;
  wire                            WRegLoc  ;
  wire     [01: 0]                ALUOp    ;
  wire                            ALUSrc   ;
  wire     [02: 0]                BranchOp ;
  wire                            SregUp   ;                  
  wire                            MemRead  ;
  wire                            MemWrite ;
  wire     [01: 0]                MemtoReg ;
  wire     [10: 0]                opcode   ;

  //===========================================================
  //* Internal signals
  //===========================================================
  //
  wire     [`WORD - 1 : 0]        ALU_res ;
  wire     [`WORD - 1 : 0]        ALUOut  ;
  wire     [01:0]                 PCSrc   ;
  wire     [`WORD - 1 : 0]        pc      ;
  wire     [`WORD - 1 : 0]        pc_incr ;
  wire     [`INST_SIZE - 1 : 0]   inst    ;

  wire     [`WORD - 1 : 0]        w_data  ;
  wire     [`WORD - 1 : 0]        r_data1 ;
  wire     [`WORD - 1 : 0]        r_data2 ;
  wire     [`WORD - 1 : 0]        r_data  ;
  wire     [`WORD - 1 : 0]        ex_data ;

  assign opcode = inst[31:21];

  IF #( 
  .PATH   ( INST_FILE ) ) IF(
  .clk    ( clk       ) ,             
  .rst_n  ( rst_n     ) , 
  .ALU_res( ALU_res   ) ,    // Result of ADD ALU in EX, i.e. address of branch     
  .ALUOut ( ALUOut    ) ,    // Result of ALU in EX
  .PCSrc  ( PCSrc     ) ,    // Control signal of PCSrc  
  .pc     ( pc        ) ,    // Current PC
  .pc_incr( pc_incr   ) ,    // Current PC + 4
  .inst   ( inst      )      // Output instruction
  );

  ID #( 
  .PATH    ( REG_FILE ) ) ID(
  .clk     ( clk      ) ,            
  .rst_n   ( rst_n    ) ,        
  .inst    ( inst     ) ,       // Input instruction to be decoded
  .RegWrite( RegWrite ) ,       // Flag of writing to register file 
  .Reg2Loc ( Reg2Loc  ) ,       // Flag of judging register file 2nd source register
  .WRegLoc ( WRegLoc  ) ,       // Flag of judging register file write register
  .w_data  ( w_data   ) ,       // Data to be written
  .r_data1 ( r_data1  ) ,       // Read data 1 from register file
  .r_data2 ( r_data2  ) ,       // Read data 2 from register file
  .ex_data ( ex_data  )         // Extend data
  );

  EX EX(
  .clk      ( clk       ) ,           
  .rst_n    ( rst_n     ) ,       
  .r_data1  ( r_data1   )    ,      // Read data 1 from register file      
  .r_data2  ( r_data2   )    ,      // Read data 2 from register file
  .ex_data  ( ex_data   )    ,      // Extend data from sign extend
  .inst     ( inst      )    ,      // Instruction for ALU control signal
  .ALUOp    ( ALUOp     )    ,      // Output from control unit for ALU control signal
  .ALUSrc   ( ALUSrc    )    ,      // Output from control unit for ALU source data 
  .BranchOp ( BranchOp  )    ,      // Output from control unit for PCSrc, 3 bits
  .SregUp   ( SregUp    )    ,      // Output from control unit for status register
  .pc       ( pc        )    ,      // Program counter for branch address
  .ALUOut   ( ALUOut    )    ,      // Output result from ALU
  .PCSrc    ( PCSrc     )    ,      // PC source flag
  .ALU_res  ( ALU_res   )           // Address for branch from ADD ALU
  );

  data_mem #( 
  .PATH    ( DATA_FILE )  , 
  .SIZE    ( 1024      )  ) MEM(
  .clk     ( clk       )  ,
  .rst_n   ( rst_n     )  ,          
  .MemRead ( MemRead   )  ,     // Signal of reading data from memory
  .MemWrite( MemWrite  )  ,     // Signal of writing data to memory
  .addr    ( ALUOut    )  ,     // Address
  .w_data  ( r_data2   )  ,     // Data to be write
  .r_data  ( r_data    )        // Data read from memory
  );

  write_back WB(
  .ALUOut  ( ALUOut   ) ,       // ALU output result in EX       
  .r_data  ( r_data   ) ,       // Data read from MEM  
  .pc_incr ( pc_incr  ) ,       // PC + 4
  .r_data2 ( r_data2  ) ,       // Data read from register file, for MOVK
  .MemtoReg( MemtoReg ) ,       // Memory to register signal from control unit
  .inst    ( inst     ) ,       // Instruction to obtain opcode
  .w_data  ( w_data   )         // Write data to be written back
  );

endmodule
  
