`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: br_control.v
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/29 15:00:48
//
//*@Function : Generate PCSrc signal for branch.
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module br_control(
  BranchOp     ,    // 3 bits branch operation code from control unit
  ConBr_type   ,    // 5 bits conditional branch type of insturction( i.e. rt register of B.cond ) 
  Zero         ,    // Zero flag from ALU
  Negative     ,    // Negative flag from ALU
  Overflow     ,    // Overflow flag from ALU
  Co           ,    // Carry out flag from ALU
  PCSrc             // 2 bits output flag for PC source
  );

  input  [2:0]                    BranchOp    ;                   
  input  [4:0]                    ConBr_type  ;                
  input                           Zero        ;                   
  input                           Negative    ;                   
  input                           Overflow    ;                   
  input                           Co          ;                   
  output [1:0]                    PCSrc       ;                

  wire   [2:0]                    BranchOp    ;                   
  wire   [4:0]                    ConBr_type  ;                
  wire                            Zero        ;                   
  wire                            Negative    ;                   
  wire                            Overflow    ;                   
  wire                            Co          ;                   
  reg    [1:0]                    PCSrc       ;                

  always @(*) begin
    case( BranchOp ) 
      `BCOND_OP_BRANCH:
        PCSrc = 'b01;
      `BCOND_OP_ZERO:
        if( Zero ) begin
          PCSrc = 'b01;
        end
      `BCOND_OP_NZERO: begin
        if( ~Zero ) begin
          PCSrc = 'b01;
        end
      end
      `BCOND_OP_ALU:
        PCSrc = 'b10;
      `BCOND_OP_NOINC:
        PCSrc = 'b11;
      `BCOND_OP_COND: begin
        case( ConBr_type )
          // Signed
          `BCOND_EQ: PCSrc <= ( Zero == 1 ); 
          `BCOND_NE: PCSrc <= ( Zero == 0 );
          `BCOND_LT: PCSrc <= ( Negative != Overflow );
          `BCOND_LE: PCSrc <= ( ( Zero == 1 ) || ( Negative != Overflow ) );
          `BCOND_GT: PCSrc <= ( ( Zero == 0 ) && ( Negative == Overflow ) );
          `BCOND_GE: PCSrc <= ( Negative == Overflow );
          // Unsigned
          `BCOND_CC: PCSrc <= ( Co == 0 );
          `BCOND_LS: PCSrc <= ( ( Co == 0 ) || ( Zero == 1 ) );
          `BCOND_HI: PCSrc <= ( ( Co == 1 ) && ( Zero == 0 ) );
          `BCOND_CS: PCSrc <= ( Co == 1 );
          default:   PCSrc <= 'b0;
        endcase
      end
      default: PCSrc <= 'b0;
    endcase
  end

endmodule

