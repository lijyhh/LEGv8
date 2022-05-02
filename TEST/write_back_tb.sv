`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: write_back_tb.sv
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/4/2 16:09:46
//
//*@Function : Testbench for write back module. 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module write_back_tb();

  reg    [`WORD - 1 : 0]          tb_ALUOut  ;                   
  reg    [`WORD - 1 : 0]          tb_r_data  ;                
  reg    [`WORD - 1 : 0]          tb_pc_incr ;                   
  reg    [`WORD - 1 : 0]          tb_r_data2 ;                   
  reg    [1:0]                    tb_MemtoReg;                   
  reg    [`INST_SIZE - 1 : 0]     tb_inst    ;                   
  wire   [`WORD - 1 : 0]          tb_w_data  ;                   

  write_back WB_TB(
  .ALUOut  ( tb_ALUOut   ) ,       // ALU output result in EX       
  .r_data  ( tb_r_data   ) ,       // Data read from MEM  
  .pc_incr ( tb_pc_incr  ) ,       // PC + 4
  .r_data2 ( tb_r_data2  ) ,       // Data read from register file, for MOVK
  .MemtoReg( tb_MemtoReg ) ,       // Memory to register signal from control unit
  .inst    ( tb_inst     ) ,       // Instruction to obtain opcode
  .w_data  ( tb_w_data   )         // Write data to be written back
  );

  initial begin
    `TB_BEGIN
    // Just test default case in write back module
    tb_ALUOut   = 'b0; 
    tb_r_data   = 'b0; 
    tb_pc_incr  = 'b0; 
    tb_r_data2  = 'b0; 
    tb_MemtoReg = 'b00;
    // Default case 
    tb_inst     = 'b0;
    #`CYCLE;

    tb_ALUOut   = 'd100; 
    tb_r_data   = 'd90; 
    tb_pc_incr  = 'd200; 
    tb_r_data2  = 'd80; 
    tb_MemtoReg = 'b00;
    #`CYCLE;
    assert( tb_w_data == 100 ) $strobe("[Time: %0d], Write data is %0d, !!TEST SUCCESS!!", $time, tb_w_data);
    else $error("tb_w_data = %0d", tb_w_data);

    tb_MemtoReg = 'b01;
    #`CYCLE;
    assert( tb_w_data == 90 ) $strobe("[Time: %0d], Write data is %0d, !!TEST SUCCESS!!", $time, tb_w_data);
    else $error("tb_w_data = %0d", tb_w_data);

    tb_MemtoReg = 'b10;
    #`CYCLE;
    assert( tb_w_data == 200 ) $strobe("[Time: %0d], Write data is %0d, !!TEST SUCCESS!!", $time, tb_w_data);
    else $error("tb_w_data = %0d", tb_w_data);

    `TB_END
    $finish;
  end

endmodule

