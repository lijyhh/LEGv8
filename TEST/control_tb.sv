`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: TEST\control_tb.sv
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/31 10:06:18
//
//*@Function : Testbench for control path. 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module control_tb();

  reg  [`INST_SIZE-1:0] tb_inst    ;
  wire [10:0]           tb_opcode  ;

  wire                  tb_Reg2Loc ; 
  wire                  tb_RegWrite; 
  wire                  tb_WRegLoc ; 
  wire                  tb_ALUSrc  ; 
  wire [01:0]           tb_ALUOp   ; 
  wire                  tb_SregUp  ; 
  wire [02:0]           tb_BranchOp; 
  wire                  tb_MemRead ; 
  wire                  tb_MemWrite; 
  wire [01:0]           tb_MemtoReg; 

  wire [13:0]           tb_combined_signals;
  
  assign tb_combined_signals = {tb_Reg2Loc, tb_RegWrite, tb_WRegLoc, tb_ALUSrc, tb_ALUOp, tb_SregUp,
                              tb_BranchOp, tb_MemRead, tb_MemWrite, tb_MemtoReg};
  
  control control_path(
  .opcode  ( tb_opcode   ) ,          // Opcode from instruction, 11 bits     
  .Reg2Loc ( tb_Reg2Loc  ) ,          // Select register file source register 2, 1 bit
  .RegWrite( tb_RegWrite ) ,          // Flag of register file to write back, 1 bit 
  .WRegLoc ( tb_WRegLoc  ) ,          // Flag of register file to select write register, 1 bit
  .ALUSrc  ( tb_ALUSrc   ) ,          // Flag of ALU to select source data 2, 1 bit
  .ALUOp   ( tb_ALUOp    ) ,          // ALU op for ALU control unit, 2 bits 
  .SregUp  ( tb_SregUp   ) ,          // Update status register, 1bit
  .BranchOp( tb_BranchOp ) ,          // Branch op for EX to select PC source, 3 bits
  .MemRead ( tb_MemRead  ) ,          // Flag of memory read, 1 bit
  .MemWrite( tb_MemWrite ) ,          // Flag of memory write, 1 bit
  .MemtoReg( tb_MemtoReg )            // Flag of MUX in WB to select source data, 1 bit
  );
  
  assign tb_opcode = tb_inst[31:21];
  
  initial begin
    `TB_BEGIN
    
    // LDUR X9, [X22, #64]
    tb_inst = 32'hF84402C9;
    #`CYCLE assert(tb_combined_signals == {7'b0101000, `BCOND_OP_NONE, 4'b1001}) else $error("[0] tb_combined_signals: %b", tb_combined_signals);
    #`CYCLE;
    
    // ADD X10, X19, X9
    tb_inst = 32'h8B09026A;
    #`CYCLE assert(tb_combined_signals == {7'b0100100, `BCOND_OP_NONE, 4'b0000}) else $error("[1] tb_combined_signals: %b", tb_combined_signals);
    #`CYCLE;
    
    // SUB X11, X20, X10
    tb_inst = 32'hCB0A028B;
    #`CYCLE assert(tb_combined_signals == {7'b0100100, `BCOND_OP_NONE, 4'b0000}) else $error("[2] tb_combined_signals: %b", tb_combined_signals);
    #`CYCLE;
    
    // STUR X11, [X22, #96]
    tb_inst = 32'hF80602CB;
    #`CYCLE assert(tb_combined_signals == {7'b1001000, `BCOND_OP_NONE, 4'b0100}) else $error("[3]tb_combined_signals: %b", tb_combined_signals);
    #`CYCLE;
    
    // CBZ X11, -5
    tb_inst = 32'hB4FFFF6B;
    #`CYCLE assert(tb_combined_signals == {7'b1000011, `BCOND_OP_ZERO, 4'b0000}) else $error("[4] tb_combined_signals: %b", tb_combined_signals);
    #`CYCLE;
    
    // CBZ X9, 8
    tb_inst = 32'hB4000109;
    #`CYCLE assert(tb_combined_signals == {7'b1000011, `BCOND_OP_ZERO, 4'b0000}) else $error("[5] tb_combined_signals: %b", tb_combined_signals);
    #`CYCLE;
    
    // B 64
    tb_inst = 32'h14000040;
    #`CYCLE assert(tb_combined_signals == {7'b0000110, `BCOND_OP_BRANCH, 4'b0000}) else $error("[6] tb_combined_signals: %b", tb_combined_signals);
    #`CYCLE;
    
    // B -55
    tb_inst = 32'h17FFFFC9;
    #`CYCLE assert(tb_combined_signals == {7'b0000110, `BCOND_OP_BRANCH, 4'b0000}) else $error("[7] tb_combined_signals: %b", tb_combined_signals);
    #`CYCLE;
    
    // ORR X9, X10, X21
    tb_inst = 32'hAA150149;
    #`CYCLE assert(tb_combined_signals == {7'b0100100, `BCOND_OP_NONE, 4'b0000}) else $error("[8] tb_combined_signals: %b", tb_combined_signals);
    #`CYCLE;
    
    // AND X9, X22, X10
    tb_inst = 32'h8A0A02C9;
    #`CYCLE assert(tb_combined_signals == {7'b0100100, `BCOND_OP_NONE, 4'b0000}) else $error("[9] tb_combined_signals: %b", tb_combined_signals);
    #`CYCLE;
    
    `TB_END
    
    $finish;
  end

endmodule
