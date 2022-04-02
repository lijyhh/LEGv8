`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: sign_extend_tb.sv
//
//*@File Type: system verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/30 17:14:18
//
//*@Function : Testbench for sign_extend module.
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module sign_extend_tb();

  reg  [`INST_SIZE-1:0] tb_inst;
  wire [`WORD-1:0]      tb_ex_data;
  
  sign_extend sign_extend_tb(
  .inst    ( tb_inst    ) ,        // Input inst     
  .ex_data ( tb_ex_data )          // Extended data            
  );
  
  initial begin
    `TB_BEGIN
    
    // LDUR X9, [X22, #64]
    tb_inst = 32'hF84402C9;
    #`CYCLE assert(tb_ex_data == `WORD'd64) else $error("[0] tb_ex_data != `WORD'd64");
    
    // ADD X10, X19, X9
    tb_inst = 32'h8B09026A;
    #`CYCLE assert(tb_ex_data == tb_inst) else $error("[1] tb_ex_data != tb_inst");
    
    // SUB X11, X20, X10
    tb_inst = 32'hCB0A028B;
    #`CYCLE assert(tb_ex_data == tb_inst) else $error("[2] tb_ex_data != tb_inst");
    
    // STUR X11, [X22, #96]
    tb_inst = 32'hF80602CB;
    #`CYCLE assert(tb_ex_data == 96) else $error("[3] tb_ex_data != 96");
    
    // CBZ X11, -5
    tb_inst = 32'hB4FFFF6B;
    #`CYCLE assert(tb_ex_data == -5) else $error("[4] tb_ex_data != -5");
    
    // CBZ X9, 8
    tb_inst = 32'hB4000109;
    #`CYCLE assert(tb_ex_data == 8) else $error("[5] tb_ex_data != 8");
    
    // B 64
    tb_inst = 32'h14000040;
    #`CYCLE assert(tb_ex_data == 64) else $error("[6] tb_ex_data != 64");
    
    // B -55
    tb_inst = 32'h17FFFFC9;
    #`CYCLE assert(tb_ex_data == -55) else $error("[7] tb_ex_data != -55");
    
    // ORR X9, X10, X21
    tb_inst = 32'hAA150149;
    #`CYCLE assert(tb_ex_data == tb_inst) else $error("[8] tb_ex_data != tb_inst");;
    
    // AND X9, X22, X10
    tb_inst = 32'h8A0A02C9;
    #`CYCLE assert(tb_ex_data == tb_inst) else $error("[9] tb_ex_data != tb_inst");
    
    `TB_END
    $finish;
  end
  

endmodule


