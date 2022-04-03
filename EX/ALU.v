`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: ALU.v
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/29 12:54:52
//
//*@Function : ALU unit, including and, or, add, sub, pass, nor.
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module ALU(
  a        ,     // Input data a
  b        ,     // Input data b
  ALUCtl   ,     // ALU control signals
  Co       ,     // Carry out flag for unsigned
  Zero     ,     // Zero flag
  ALUOut   ,     // Result of ALU
  Overflow ,     // Overflow flag for signed
  Negative       // Negative flag for signed
  );

  //===========================================================
  //* Input and output ports
  //===========================================================
  //
  input  signed [`WORD - 1 : 0]   a       ;                   
  input  signed [`WORD - 1 : 0]   b       ;                
  input  [3:0]                    ALUCtl  ;                   
  output                          Co      ;                
  output                          Zero    ;                   
  output signed [`WORD - 1 : 0]   ALUOut  ;                
  output                          Overflow;                   
  output                          Negative;                   
      
  wire   signed [`WORD - 1 : 0]   a       ;                   
  wire   signed [`WORD - 1 : 0]   b       ;                
  wire   [3:0]                    ALUCtl  ;                   
  wire                            Co      ;                
  wire                            Zero    ;                   
  wire   signed [`WORD - 1 : 0]   ALUOut  ;                
  reg                             Overflow;                   
  wire                            Negative;                   

  //===========================================================
  //* Internal signals
  //===========================================================
  //
  reg    signed [`WORD : 0]       ALUTmp;
  wire                            ALUTmp_MSB;

  assign ALUOut = ALUTmp[`WORD - 1 : 0];
  assign ALUTmp_MSB = ALUTmp[`WORD];
  assign Zero = ( ALUOut == 0 );
  assign Co = 1'b1; // Dont care for signed
  assign Negative = ( ALUOut < 0 );

  always @(*) begin
    ALUTmp = 'b1;
    Overflow = 1'b0;
    case( ALUCtl )
      `ALU_AND: begin
        ALUTmp = a & b;
      end
      `ALU_OR: begin
        ALUTmp = a | b;
      end
      `ALU_ADD: begin
        ALUTmp = a + b;
        // Detect overflow
        if( a > 0 && b > 0 && ALUTmp_MSB ) begin
          Overflow = 1'b1;
        end
        else if ( a < 0 && b < 0 && ~ALUTmp_MSB ) begin
          Overflow = 1'b1;
        end
      end
      `ALU_SUB: begin
        ALUTmp = a - b;
        // Detect overflow
        if (a > 0 && b < 0 && ALUTmp_MSB) begin 
          Overflow = 1'b1;
        end
        else if (a < 0 && b > 0 && ~ALUTmp_MSB) begin
          Overflow = 1'b1;
        end
      end
      `ALU_PASS: begin
        ALUTmp = b;
      end
      `ALU_NOR: begin
        ALUTmp = ~(a | b);
      end
      `ALU_XOR: begin     
        ALUTmp = a ^ b;
      end
      `ALU_LSL: begin
        ALUTmp = a << b;
      end
      `ALU_LSR: begin
        ALUTmp = a >> b;
      end
      default: begin
        ALUTmp = 'b1; // Dont care
        Overflow = 1'b0;
      end
    endcase
  end

endmodule

