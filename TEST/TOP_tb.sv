`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: TOP_tb.v
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/30 16:27:09
//
//*@Function : Testbench for TOP module. 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module TOP_tb();

  reg                 tb_clk   ;                      
  reg                 tb_rst_n ;               

  parameter INST_FILE = `INST_FILE;
  parameter REG_FILE  = `REG_FILE ; 
  parameter DATA_FILE = `DATA_FILE; 

  task delay;
    input [31:0] num;
    begin
      repeat(num) @(posedge tb_clk);
      #1;
    end
  endtask

  initial begin
    tb_clk = 0;
  end
  always #10 tb_clk = ~tb_clk;

  initial begin
    tb_rst_n = 1;
    delay(1);
    tb_rst_n = 0;
    delay(1);
    tb_rst_n = 1;
  end

  initial begin
    $dumpfile(" TOP_tb.vcd ");
    $dumpvars();
  end

  TOP #( 
  .INST_FILE( INST_FILE ),
  .REG_FILE ( REG_FILE  ),
  .DATA_FILE( DATA_FILE )) TOP(
  .clk  ( tb_clk   )  ,              
  .rst_n( tb_rst_n )            
  );
  
  initial begin
    `TB_BEGIN
    delay(3);

    `TB_END
    $finish;
  end


endmodule

