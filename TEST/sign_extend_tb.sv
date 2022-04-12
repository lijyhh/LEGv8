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

  task my_assert;
    input [`WORD - 1 : 0] ex_data;
    input integer i;
    begin
      #`CYCLE assert(tb_ex_data == ex_data) 
        $strobe("%0d, !!TEST SUCCESS!!", $time);
      else $error("[%0d] tb_ex_data = %0h", i, ex_data);
    end
  endtask

  
  initial begin
    `TB_BEGIN
    
    // LDUR X9, [X22, #64]
    tb_inst = 32'hF84402C9;
    my_assert(64, 0);
    
    // ADD X10, X19, X9
    tb_inst = 32'h8B09026A;
    my_assert(tb_inst, 1);
    
    // SUB X11, X20, X10
    tb_inst = 32'hCB0A028B;
    my_assert(tb_inst, 2);
    
    // STUR X11, [X22, #96]
    tb_inst = 32'hF80602CB;
    my_assert(96, 3);
    
    // CBZ X11, -5
    tb_inst = 32'hB4FFFF6B;
    my_assert(-5, 4);
    
    // CBZ X9, 8
    tb_inst = 32'hB4000109;
    my_assert(8, 5);
    
    // B 64
    tb_inst = 32'h14000040;
    my_assert(64, 6);
    
    // B -55
    tb_inst = 32'h17FFFFC9;
    my_assert(-55, 7);
    
    // ORR X9, X10, X21
    tb_inst = 32'hAA150149;
    my_assert(tb_inst, 8);
    
    // AND X9, X22, X10
    tb_inst = 32'h8A0A02C9;
    my_assert(tb_inst, 9);
    
    `TB_END
    $finish;
  end
  

endmodule


