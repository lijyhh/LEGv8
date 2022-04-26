`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: PipelineCPU.v
//*@File Type: verilog
//*@Version  : 0.0
//*@Author   : Zehua Dong, SIGS
//*@E-mail   : 1285507636@qq.com
//*@Date     : 2022/4/25 15:16:08
//*@Function : Datapath module in pipeline mode.  
//
//*@V0.0     : Initial.
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module PipelineCPU(
  clk     ,              
  rst_n   ,         
  IDB     ,  // Instruction data bus
  IAB     ,  // Instruction address bus
  DDB     ,  // Data data bus
  DAB     ,  // Data address bus
  MemWrite,  // Memory write signal
  MemRead    // Memory read signal
  );

  //===========================================================
  //* Input and output ports
  //===========================================================
  //
  input                           clk     ;  
  input                           rst_n   ;                
  input   [`INST_SIZE - 1 : 0]    IDB     ;
  inout   [`WORD - 1 : 0]         DDB     ;
  output  [`WORD - 1 : 0]         IAB     ;
  output  [`WORD - 1 : 0]         DAB     ;
  output                          MemWrite;            
  output                          MemRead ;            

  wire                            clk     ; 
  wire                            rst_n   ;               
  wire    [`INST_SIZE - 1 : 0]    IDB     ;
  wire    [`WORD - 1 : 0]         DDB     ;
  wire    [`WORD - 1 : 0]         IAB     ;                
  wire    [`WORD - 1 : 0]         DAB     ;                
  wire                            MemWrite;            
  wire                            MemRead ;            

  //===========================================================
  //* Internal signals
  //===========================================================
  //
  wire    [10:0]                  opcode  ;                   
  wire                            ctl_Reg2Loc ;                
  wire                            ctl_RegWrite;                
  wire                            ctl_WRegLoc ;                
  wire                            ctl_ALUSrc  ;                
  wire    [01:0]                  ctl_ALUOp   ;                
  wire                            ctl_SregUp  ;                
  wire    [02:0]                  ctl_BranchOp;               
  wire                            ctl_MemRead ;                
  wire                            ctl_MemWrite;                
  wire    [01: 0]                 ctl_MemtoReg; 

  wire    [`WORD - 1 : 0]         w_data  ;
  wire    [`WORD - 1 : 0]         r_data  ;

  assign DDB = ( MemWrite && ~MemRead ) ? w_data : 'bz;
  assign r_data = ( ~MemWrite && MemRead ) ? DDB : 'bz;

  control control_path(
  .opcode  ( opcode       ) ,          // Opcode from instruction, 11 bits     
  .Reg2Loc ( ctl_Reg2Loc  ) ,          // Select register file source register 2, 1 bit
  .RegWrite( ctl_RegWrite ) ,          // Flag of register file to write back, 1 bit 
  .WRegLoc ( ctl_WRegLoc  ) ,          // Flag of register file to select write register, 1 bit
  .ALUSrc  ( ctl_ALUSrc   ) ,          // Flag of ALU to select source data 2, 1 bit
  .ALUOp   ( ctl_ALUOp    ) ,          // ALU op for ALU control unit, 2 bits 
  .SregUp  ( ctl_SregUp   ) ,          // Update status register, 1bit
  .BranchOp( ctl_BranchOp ) ,          // Branch op for EX to select PC source, 3 bits
  .MemRead ( ctl_MemRead  ) ,          // Flag of memory read, 1 bit
  .MemWrite( ctl_MemWrite ) ,          // Flag of memory write, 1 bit
  .MemtoReg( ctl_MemtoReg )            // Flag of MUX in WB to select source data, 1 bit
  );

  PipelineDatapath data_path(
  .clk       ( clk           ),            
  .rst_n     ( rst_n         ),        
  .RegWrite  ( ctl_RegWrite  ),
  .Reg2Loc   ( ctl_Reg2Loc   ),
  .WRegLoc   ( ctl_WRegLoc   ),
  .ALUOp     ( ctl_ALUOp     ),
  .ALUSrc    ( ctl_ALUSrc    ),
  .BranchOp  ( ctl_BranchOp  ),
  .SregUp    ( ctl_SregUp    ),
  .MemtoReg  ( ctl_MemtoReg  ),
  .MemRead   ( ctl_MemRead   ),
  .MemWrite  ( ctl_MemWrite  ),
  .inst      ( IDB           ),
  .r_data    ( r_data        ),
  .pc        ( IAB           ),
  .ALUOut    ( DAB           ),
  .o_MemRead ( MemRead       ),
  .o_MemWrite( MemWrite      ),
  .o_opcode  ( opcode        ),
  .MemData   ( w_data        )
  );

endmodule

