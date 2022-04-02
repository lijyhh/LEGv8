`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: ALU_control_tb.sv
//
//*@File Type: system verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/30 20:47:49
//
//*@Function : Testbench for ALU control unit. 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module ALU_control_tb();

  reg  [10:0]               tb_opcode;                         
  reg  [01:0]               tb_ALUOp ;                
  reg  [03:0]               tb_ALUCtl; 

  reg  [03:0]               tb_cnt   ;

  ALU_control ALU_control_TB(
  .opcode( tb_opcode )  ,    // Opcode of instruction             
  .ALUOp ( tb_ALUOp  )  ,    // ALUOp from control unit     
  .ALUCtl( tb_ALUCtl )       // Output ALU control signal 
  );

  initial begin
    `TB_BEGIN

    tb_opcode = 11'bxxxxxxxxxxx;
    tb_ALUOp  = 2'b00;
    #`CYCLE;
    assert( tb_ALUCtl == 4'b0010 ) $strobe("%0d, !!TEST SUCCESS!!", $time);
    else $error("[0] tb_ALUCtl = %4b", tb_ALUCtl);

    tb_opcode = 11'bxxxxxxxxxxx;
    tb_ALUOp  = 2'b01;
    tb_cnt    = tb_cnt + 1'b1;
    #`CYCLE;
    assert( tb_ALUCtl == 4'b0111 ) $strobe("%0d, !!TEST SUCCESS!!", $time);
    else $error("[1] tb_ALUCtl = %4b", tb_ALUCtl);

    tb_opcode = 11'b10001011000;
    tb_ALUOp  = 2'b10;
    tb_cnt    = tb_cnt + 1'b1;
    #`CYCLE;
    assert( tb_ALUCtl == 4'b0010 ) $strobe("%0d, !!TEST SUCCESS!!", $time);
    else $error("[2] tb_ALUCtl = %4b", tb_ALUCtl);

    tb_opcode = 11'b11001011000;
    tb_ALUOp  = 2'b10;
    tb_cnt    = tb_cnt + 1'b1;
    #`CYCLE;
    assert( tb_ALUCtl == 4'b0110 ) $strobe("%0d, !!TEST SUCCESS!!", $time);
    else $error("[3] tb_ALUCtl = %4b", tb_ALUCtl);

    tb_opcode = 11'b10001010000;
    tb_ALUOp  = 2'b10;
    tb_cnt    = tb_cnt + 1'b1;
    #`CYCLE;
    assert( tb_ALUCtl == 4'b0000 ) $strobe("%0d, !!TEST SUCCESS!!", $time);
    else $error("[4] tb_ALUCtl = %4b", tb_ALUCtl);

    tb_opcode = 11'b10101010000;
    tb_ALUOp  = 2'b10;
    tb_cnt    = tb_cnt + 1'b1;
    #`CYCLE;
    assert( tb_ALUCtl == 4'b0001 ) $strobe("%0d, !!TEST SUCCESS!!", $time);
    else $error("[5] tb_ALUCtl = %4b", tb_ALUCtl);
    
    `TB_END
    $finish;
  end


endmodule

