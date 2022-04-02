`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: control.v
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/30 9:58:47
//
//*@Function : Control path to generate all control signals. 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module control(
  opcode   ,          // Opcode from instruction, 11 bits     
  Reg2Loc  ,          // Select register file source register 2, 1 bit, assert when `STUR、`CBZ、`CBNZ、`BR、`MOVK valid
  RegWrite ,          // Flag of register file to write back, 1 bit, assert when `ADD, `SUB, `AND, `ORR, `LSL, `LSR, `ADDI, `ANDI, `EORI, `ORRI, `SUBI, `ADDIS, `ANDIS, `SUBS, `ADDIS, `ANDIS, `SUBS, `LDUR, `BL, `MOV, `MOVZ, `MOVK valid
  WRegLoc  ,          // Flag of register file to select write register, 1 bit, assert when `BL valid
  ALUSrc   ,          // Flag of ALU to select source data 2, 1 bit, assert when `LSL, `LSR, `ADDI, `ANDI, `EORI, `ORRI, `SUBI, `ADDIS, `ANDIS, `SUBS, `LDUR, `STUR, `MOV, `MOVZ, `MOVK valid
  ALUOp    ,          // ALU op for ALU control unit, 2 bits, assert time please see the code 
  SregUp   ,          // Update status register, 1bit, assert when `ADDS, `ANDS, `SUBS, `ADDIS, `ANDIS, `SUBS, `CMP, `CBZ, `CBNZ valid
  BranchOp ,          // Branch op for EX to select PC source, 3 bits, assert time please see the code
  MemRead  ,          // Flag of memory read, 1 bit, assert when `LDUR valid
  MemWrite ,          // Flag of memory write, 1 bit, assert when `STUR valid
  MemtoReg            // Flag of MUX in WB to select source data, 2 bit, assert when `LDUR, `BL valid
  );

  //===========================================================
  //* Input and output ports
  //===========================================================
  //
  input   [10:0]                  opcode  ;                   
  output                          Reg2Loc ;                
  output                          RegWrite;                
  output                          WRegLoc ;                
  output                          ALUSrc  ;                
  output  [01:0]                  ALUOp   ;                
  output                          SregUp  ;                
  output  [02:0]                  BranchOp;                
  output                          MemRead ;                
  output                          MemWrite;                
  output  [01:0]                  MemtoReg;                

  wire    [10:0]                  opcode  ;                   
  reg                             Reg2Loc ;                
  reg                             RegWrite;                
  reg                             WRegLoc ;                
  reg                             ALUSrc  ;                
  reg     [01:0]                  ALUOp   ;                
  reg                             SregUp  ;                
  reg     [02:0]                  BranchOp;                
  reg                             MemRead ;                
  reg                             MemWrite;                
  reg     [01:0]                  MemtoReg;                

  always @(*) begin
    // Avoid latch
    Reg2Loc  = 'b0;  
    RegWrite = 'b0;
    WRegLoc  = 'b0;
    ALUSrc   = 'b0;
    SregUp   = 'b0;
    BranchOp = `BCOND_OP_NONE;
    MemRead  = 'b0;
    MemWrite = 'b0;
    MemtoReg = 'b0;
    casez( opcode )
      `ADD, `SUB, `AND, `ORR: begin
        RegWrite = 'b1;
      end
      `LSL, `LSR, `ADDI, `ANDI, `EORI, `ORRI, `SUBI: begin
        RegWrite = 'b1;
        ALUSrc   = 'b1;
      end
      `ADDS, `ANDS, `SUBS: begin
        RegWrite = 'b1;
        SregUp   = 'b1;
      end
      `ADDIS, `ANDIS, `SUBIS: begin
        RegWrite = 'b1;
        ALUSrc   = 'b1;
        SregUp   = 'b1;
      end
      `CMP: begin
        SregUp   = 'b1;
      end
      `LDUR: begin
        RegWrite = 'b1;
        ALUSrc   = 'b1;
        MemRead  = 'b1;
        MemtoReg = 'b01;
      end
      `STUR: begin
        Reg2Loc  = 'b1;
        ALUSrc   = 'b1;
        MemWrite = 'b1;
      end
      `CBZ: begin
        Reg2Loc  = 'b1;
        SregUp   = 'b1;
        BranchOp = `BCOND_OP_ZERO;
      end
      `CBNZ: begin
        Reg2Loc  = 'b1;
        SregUp   = 'b1;
        BranchOp = `BCOND_OP_NZERO;
      end
      `B: begin
        BranchOp = `BCOND_OP_BRANCH;
      end
      `BCOND: begin
        BranchOp = `BCOND_OP_COND;
      end
      `BL: begin
        RegWrite = 'b1;
        BranchOp = `BCOND_OP_BRANCH;
        WRegLoc  = 'b1; // Link regisyter
        MemtoReg = 'b10;
      end
      `BR: begin
        Reg2Loc  = 'b1;
        BranchOp = `BCOND_OP_ALU;
      end
      `MOV, `MOVZ: begin
        RegWrite = 'b1;
        ALUSrc   = 'b1;
      end
      `MOVK: begin
        Reg2Loc  = 'b1;
        RegWrite = 'b1;
        ALUSrc   = 'b1;
      end
    endcase
  end

  always @(*) begin
    casez( opcode )
      `LDUR, `STUR: begin
        ALUOp = 'b00;
      end
      `CBZ: begin
        ALUOp = 'b01;
      end
      `ADD, `SUB, `AND, `ORR, `LSL, `LSR, `SUBS, `ADDS, `BR, `ADDI, `SUBI, `SUBIS: begin
        ALUOp = 'b10;
      end
      default: begin
        ALUOp = 'b11;
      end
    endcase
  end

endmodule

