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

  ALU_control ALU_control_TB(
  .opcode( tb_opcode )  ,    // Opcode of instruction             
  .ALUOp ( tb_ALUOp  )  ,    // ALUOp from control unit     
  .ALUCtl( tb_ALUCtl )       // Output ALU control signal 
  );

  task my_assert;
    input [3 : 0] ALUCtl;
    input integer i;
    begin
      #`CYCLE;
      assert( tb_ALUCtl == ALUCtl ) 
        $strobe("[Time: %0d], ALUCtl is 'b%0b !!TEST SUCCESS!!", $time, tb_ALUCtl);
      else $error("[%0d], tb_ALUCtl = 'b%0b", i, ALUCtl);
    end
  endtask


  initial begin
    `TB_BEGIN

    tb_opcode = 11'bxxxxxxxxxxx;
    tb_ALUOp  = 2'b00;
    my_assert(4'b0010, 0);

    tb_opcode = 11'bxxxxxxxxxxx;
    tb_ALUOp  = 2'b01;
    my_assert(4'b0111, 1);

    tb_opcode = 11'b10001011000;
    tb_ALUOp  = 2'b10;
    my_assert(4'b0010, 2);

    tb_opcode = 11'b11001011000;
    tb_ALUOp  = 2'b10;
    my_assert(4'b0110, 3);

    tb_opcode = 11'b10001010000;
    tb_ALUOp  = 2'b10;
    my_assert(4'b0000, 4);

    tb_opcode = 11'b10101010000;
    tb_ALUOp  = 2'b10;
    my_assert(4'b0001, 5);
    
    `TB_END
    $finish;
  end


endmodule

