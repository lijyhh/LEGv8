`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: ALU_control.v
//
//*@File Type: verilog
//
//*@Version  : 0.1
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/29 9:56:46
//
//*@Function : Generate control signal of ALU.
// 
//*@V0.0     : Initial module.
//*@V0.1     : Update control logic, using 11 bits opcodes to judge. And 
//  add some other instructions.
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module ALU_control(
  opcode  ,    // Opcode of instruction             
  ALUOp   ,    // ALUOp from control unit     
  ALUCtl       // Output ALU control signal 
  );

  //===========================================================
  //* Input and output ports
  //===========================================================
  //
  input   [10:0]                  opcode;                     
  input   [1:0]                   ALUOp ;               
  output  [3:0]                   ALUCtl;                

  wire    [10:0]                  opcode;                     
  wire    [1:0]                   ALUOp ;               
  reg     [3:0]                   ALUCtl;                

  wire    [4:0]                   ALUTmp1; 
  wire    [12:0]                  ALUTmp2; 
  assign ALUTmp1 = { ALUOp, opcode[9], opcode[8], opcode[3] };

  always @(*) begin
    ALUCtl = `ALU_NONE;
    case( ALUOp )
      2'b00: begin // LDUR, STUR, ALU add
        ALUCtl = `ALU_ADD;
      end
      2'b01: begin // CBZ, ALU pass input b
        ALUCtl = `ALU_PASS;
      end
      2'b10: begin
        case( opcode )
          `ADD, `ADDI, `ADDIS, `ADDS: begin // ALU add
            ALUCtl = `ALU_ADD;
          end
          `SUB, `SUBI, `SUBIS, `SUBS: begin
            ALUCtl = `ALU_SUB;
          end
          `BR: begin
            ALUCtl = `ALU_PASS;
          end
          `LSL: begin
            ALUCtl = `ALU_LSL;
          end
          `LSR: begin
            ALUCtl = `ALU_LSR;
          end
          `AND, `ANDI, `ANDIS, `ANDS: begin
            ALUCtl = `ALU_AND;
          end
          `ORR, `ORRI: begin
            ALUCtl = `ALU_OR;
          end
        endcase
      end
      default: begin
        ALUCtl = `ALU_NONE;
      end
    endcase
  end

endmodule

