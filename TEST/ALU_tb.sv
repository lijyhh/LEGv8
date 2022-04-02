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
 
  initial begin
    `TB_BEGIN
    
    tb_a = 64'h7FFFFFFFFFFFFFFF;
    tb_b = 64'h0000000000000001;
    tb_ALUCtl = `ALU_ADD;
    #`CYCLE; 
    assert(tb_Overflow == 0) else $error("[0] tb_Overflow == 1");
    assert(tb_Negative == 1) else $error("[1] tb_Negative == 0");
    assert(tb_Zero == 0) else $error("[2] tb_Zero == 1");
    assert(tb_ALUOut == 64'h8000000000000000) else $error("tb_ALUOut = %h", tb_ALUOut);
    
    tb_a = 64'h7FFFFFFFFFFFFFFE;
    tb_b = 64'h0000000000000001;
    tb_ALUCtl = `ALU_ADD;
    #`CYCLE; 
    assert(tb_Overflow == 0) else $error("[3] tb_Overflow == 1");
    assert(tb_Negative == 0) else $error("[4] tb_Negative == 1");
    assert(tb_Zero == 0) else $error("[5] tb_Zero == 1"); 
    assert(tb_ALUOut == 64'h7FFFFFFFFFFFFFFF) else $error("tb_ALUOut = %h", tb_ALUOut);
    
    tb_a = 64'h8000000000000000;
    tb_b = 64'h0000000000000001;
    tb_ALUCtl = `ALU_SUB;
    #`CYCLE; 
    assert(tb_Overflow == 0) else $error("[6] tb_Overflow == 1");
    assert(tb_Negative == 0) else $error("[7] tb_Negative == 1");
    assert(tb_Zero == 0) else $error("[8] tb_Zero == 1");
    assert(tb_ALUOut == 64'h7FFFFFFFFFFFFFFF) else $error("tb_ALUOut = %h", tb_ALUOut);
    
    tb_a = 64'h8000000000000000;
    tb_b = 64'hFFFFFFFFFFFFFFFF;
    tb_ALUCtl = `ALU_SUB;
    #`CYCLE;
    assert(tb_Overflow == 0) else $error("[9] tb_Overflow == 1");
    assert(tb_Negative == 1) else $error("[10] tb_Negative == 0");
    assert(tb_Zero == 0) else $error("[11] tb_Zero == 1");
    assert(tb_ALUOut == 64'h8000000000000001) else $error("tb_ALUOut = %h", tb_ALUOut);
    
    tb_a = 64'hFFFFFFFFFFFFFFFD;
    tb_b = 64'h0000000000000003;
    tb_ALUCtl = `ALU_ADD;
    #`CYCLE;
    assert(tb_Overflow == 0) else $error("[12] tb_Overflow == 1");
    assert(tb_Negative == 0) else $error("[13] tb_Negative == 1");
    assert(tb_Zero == 1) else $error("[14] tb_Zero == 0");
    assert(tb_ALUOut == 64'h0000000000000000) else $error("tb_ALUOut = %h", tb_ALUOut);
    
    tb_a = 64'hFFFFFFFFFFFFFFFD;
    tb_b = 64'h0000000000000003;
    tb_ALUCtl = `ALU_AND;
    #`CYCLE;
    assert(tb_Overflow == 0) else $error("[15] tb_Overflow == 1");
    assert(tb_Negative == 0) else $error("[16] tb_Negative == 1");
    assert(tb_Zero == 0) else $error("[17] tb_Zero == 1");
    assert(tb_ALUOut == 64'h0000000000000001) else $error("tb_ALUOut = %h", tb_ALUOut);

    tb_a = 64'hFFFFFFFFFFFFFFFD;
    tb_b = 64'h0000000000000003;
    tb_ALUCtl = `ALU_OR;
    #`CYCLE;
    assert(tb_Overflow == 0) else $error("[18] tb_Overflow == 1");
    assert(tb_Negative == 1) else $error("[19] tb_Negative == 0");
    assert(tb_Zero == 0) else $error("[20] tb_Zero == 1");
    assert(tb_ALUOut == 64'hFFFFFFFFFFFFFFFF) else $error("tb_ALUOut = %h", tb_ALUOut);
     

    tb_a = 64'hFFFFFFFFFFFFFFFD;
    tb_b = 64'h0000000000000003;
    tb_ALUCtl = `ALU_PASS;
    #`CYCLE;
    assert(tb_Overflow == 0) else $error("[21] tb_Overflow == 1");
    assert(tb_Negative == 0) else $error("[22] tb_Negative == 1");
    assert(tb_Zero == 0) else $error("[23] tb_Zero == 1");
    assert(tb_ALUOut == 64'h0000000000000003) else $error("tb_ALUOut = %h", tb_ALUOut);

    tb_a = 64'hFFFFFFFFFFFFFFFD;
    tb_b = 64'h0000000000000003;
    tb_ALUCtl = `ALU_NOR;
    #`CYCLE;
    assert(tb_Overflow == 0) else $error("[24] tb_Overflow == 1");
    assert(tb_Negative == 0) else $error("[25] tb_Negative == 1");
    assert(tb_Zero == 1) else $error("[26] tb_Zero == 0");
    assert(tb_ALUOut == 64'h0000000000000000) else $error("tb_ALUOut = %h", tb_ALUOut);

    `TB_END
    $finish;
  end


endmodule

