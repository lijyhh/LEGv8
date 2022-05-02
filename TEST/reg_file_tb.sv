`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: reg_file_tb.sv
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/30 22:04:00
//
//*@Function : Testbench for register file module. 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module reg_file_tb();
  
  reg  tb_clk, tb_rst_n;
  reg  tb_RegWrite;
  reg  [4:0] tb_r_reg1, tb_r_reg2, tb_w_reg;
  reg  [`WORD-1:0] tb_w_data;
  wire [`WORD-1:0] tb_r_data1, tb_r_data2;
  
  initial begin
    tb_clk = 0;
  end
  always #`HALF_CYCLE tb_clk = ~tb_clk;

  initial begin
    tb_rst_n = 1;
    repeat(1) @( posedge tb_clk ) #1;
    tb_rst_n = 0;
    repeat(1) @( posedge tb_clk ) #1;
    tb_rst_n = 1;
  end
  
  reg_file reg_file_TB(
  .clk     ( tb_clk       ) ,            
  .rst_n   ( tb_rst_n     ) ,        
  .r_reg1  ( tb_r_reg1    ) ,     // Read register 1          
  .r_reg2  ( tb_r_reg2    ) ,     // Read register 2
  .w_reg   ( tb_w_reg     ) ,     // Write register 
  .w_data  ( tb_w_data    ) ,     // Write data
  .RegWrite( tb_RegWrite  ) ,     // Flag of write register
  .r_data1 ( tb_r_data1   ) ,     // Read data 1
  .r_data2 ( tb_r_data2   )       // Read data 2
  );
  
  initial begin
    `TB_BEGIN
    
    // Set everything to zero
    tb_RegWrite = 0;
    tb_r_reg1 = 0;
    tb_r_reg2 = 0;
    tb_w_reg = 0;
    tb_w_data = 0;

    // Wait reset done
    repeat(3) @(posedge tb_clk) #1;
    // Begin test cases
    tb_r_reg1 = 'd31; 
    tb_r_reg2 = 'd30;

    $display("Read data testing...\n");

    // Read data from register, all values are equal to 0 in init states
    #`CYCLE assert(tb_r_data1 == 'd0 && tb_r_data2 == 'd0) 
      $strobe("[Time: %0d], Read data 1 is %0d !!TEST SUCCESS!!", $time, tb_r_data1);
    else $error("[0] tb_r_data1 = %0d", tb_r_data1);
    
    tb_r_reg1 = 'd20;
    #`CYCLE assert(tb_r_data1 == 'd0) 
      $strobe("[Time: %0d], Read data 1 is %0d !!TEST SUCCESS!!", $time, tb_r_data1);
    else $error("[1] tb_r_data1 = %0d", tb_r_data1);
    
    tb_r_reg1 = 'd0;
    #`CYCLE assert(tb_r_data1 == 'd0) 
      $strobe("[Time: %0d], Read data 1 is %0d !!TEST SUCCESS!!", $time, tb_r_data1);
    else $error("[2] tb_r_data1 = %0d", tb_r_data1);

    $display("\nRead data test done!");
    $display("\nWrite data testing...\n");

    // Write data 
    tb_w_reg = 'd11;
    tb_w_data = 'd100;
    tb_RegWrite = 1;
    #`CYCLE;
    tb_w_reg = 'd0;
    tb_w_data = 'd0;
    tb_RegWrite = 0;
    tb_r_reg1 = 'd11;
    #`CYCLE assert(tb_r_data1 == 'd100) 
      $strobe("[Time: %0d], Read data 1 is %0d !!TEST SUCCESS!!", $time, tb_r_data1);
    else $error("[6] tb_r_data1 = %0d", tb_r_data1);
    
    tb_w_reg = 'd1;
    tb_w_data = 'd123456789;
    tb_RegWrite = 1;
    #`CYCLE;
    tb_w_reg = 'd0;
    tb_w_data = 'd0;
    tb_RegWrite = 0;
    tb_r_reg2 = 'd1;
    #`CYCLE assert(tb_r_data2 == 'd123456789) 
      $strobe("[Time: %0d], Read data 2 is %0d !!TEST SUCCESS!!", $time, tb_r_data2);
    else $error("[7] tb_r_data2 = %0d", tb_r_data2);
    
    $strobe("\nWrite data test done!");

    `TB_END
    $finish;
  end
endmodule
