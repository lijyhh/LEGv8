`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: ALU_tb.sv
//
//*@File Type: system verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/30 19:44:05
//
//*@Function : Testbench for ALU module. 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module ALU_tb();

  reg  [`WORD-1:0] tb_a, tb_b;
  reg  [3:0]       tb_ALUCtl;
  wire [`WORD-1:0] tb_ALUOut;
  wire tb_Zero, tb_Negative, tb_Carry, tb_Overflow;
  
  ALU ALU_TB(
  .a        ( tb_a         ),     // Input data a
  .b        ( tb_b         ),     // Input data b
  .ALUCtl   ( tb_ALUCtl    ),     // ALU control signals
  .Co       ( tb_Carry     ),     // Carry out for unsigned
  .Zero     ( tb_Zero      ),     // Zero
  .ALUOut   ( tb_ALUOut    ),     // Result of ALU
  .Overflow ( tb_Overflow  ),     // Overflow flag for signed
  .Negative ( tb_Negative  )      // Negative flag for signed
  ); 

  task my_assert;
    input [63:0] a;
    input [63:0] b;
    input [03:0] ALUCtl;
    input  Overflow, Negative, Zero;
    input [63:0] ALUOut;
    begin
      tb_a = a;
      tb_b = b;
      tb_ALUCtl = ALUCtl;
      #`CYCLE;
      assert(tb_Overflow == Overflow) else $error("[0] tb_Overflow == %0d", tb_Overflow);
      assert(tb_Negative == Negative) else $error("[1] tb_Negative == %0d", tb_Negative);
      assert(tb_Zero == Zero) else $error("[2] tb_Zero == %0d", tb_Zero);
      assert(tb_ALUOut == ALUOut) else $error("tb_ALUOut = %0h", tb_ALUOut);
      $strobe("|\t%0d\t|\t    %0d  \t\t|\t   %0d\t\t|\t %0d\t|\t0x%16h\t|\tT\t|", $time, tb_Overflow, tb_Negative, tb_Zero, tb_ALUOut);
    end
  endtask
 
  initial begin
    `TB_BEGIN
    
    $display("|\tTime\t|\tOverflow\t|\tNegative\t|\tZero\t|\tALUOut  \t\t|\tT/F\t|");

    my_assert(64'h7FFFFFFFFFFFFFFF, 64'h0000000000000001, `ALU_ADD, 0, 1, 0, 64'h8000000000000000);
    
    my_assert(64'h7FFFFFFFFFFFFFFE, 64'h0000000000000001, `ALU_ADD, 0, 0, 0, 64'h7FFFFFFFFFFFFFFF);
       
    my_assert(64'hFFFFFFFFFFFFFFFD, 64'h0000000000000003, `ALU_ADD, 0, 0, 1, 64'h0000000000000000);
   
    my_assert(64'h8000000000000000, 64'h0000000000000001, `ALU_SUB, 0, 0, 0, 64'h7FFFFFFFFFFFFFFF);
    
    my_assert(64'h8000000000000000, 64'hFFFFFFFFFFFFFFFF, `ALU_SUB, 0, 1, 0, 64'h8000000000000001);
  
    my_assert(64'hFFFFFFFFFFFFFFFD, 64'h0000000000000003, `ALU_AND, 0, 0, 0, 64'h0000000000000001);

    my_assert(64'hFFFFFFFFFFFFFFFD, 64'h0000000000000003, `ALU_OR, 0, 1, 0, 64'hFFFFFFFFFFFFFFFF);

    my_assert(64'hFFFFFFFFFFFFFFFD, 64'h0000000000000003, `ALU_PASS, 0, 0, 0, 64'h0000000000000003);

    my_assert(64'hFFFFFFFFFFFFFFFD, 64'h0000000000000003, `ALU_ADD, 0, 0, 1, 64'h0000000000000000);

    `TB_END
    $finish;
  end

endmodule

