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

//`define FACT 
`define SORT 

module TOP_tb();

  reg                 tb_clk   ;                      
  reg                 tb_rst_n ;               

`ifdef FACT
    parameter INST_FILE = `FACT_INST_FILE;
    parameter REG_FILE  = `FACT_REG_FILE ; 
    parameter DATA_FILE = `FACT_DATA_FILE; 
`elsif SORT
    parameter INST_FILE = `SORT_INST_FILE;
    parameter REG_FILE  = `SORT_REG_FILE ; 
    parameter DATA_FILE = `SORT_DATA_FILE; 
`else
    parameter INST_FILE = `TEST_INST_FILE;
    parameter REG_FILE  = `TEST_REG_FILE ; 
    parameter DATA_FILE = `TEST_DATA_FILE; 
`endif

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

  TOP #( 
  .INST_FILE( INST_FILE ),
  .REG_FILE ( REG_FILE  ),
  .DATA_FILE( DATA_FILE )) TOP_TB(
  .clk  ( tb_clk   )  ,              
  .rst_n( tb_rst_n )            
  );
  
  initial begin
    `TB_BEGIN
    delay(500);
    `TB_END
    $finish;
  end

`ifdef FACT
  
  initial begin
    $dumpfile(" TOP_tb_FACT.vcd ");
    $dumpvars();
  end

  wire [`WORD - 1 : 0]         tb_r_data;
  assign tb_r_data = TOP_TB.data_path.WB.w_data;

  always @(negedge tb_clk) begin
    // Test 12!
    //if( tb_r_data == 479001600 ) $strobe("%0d, !!TEST SUCCESS!!", $time);
    // Test 6!
    if( tb_r_data == 720 ) $strobe("%0d, !!TEST SUCCESS!!", $time);
  end

`elsif SORT
  
  initial begin
    $dumpfile(" TOP_tb_SORT.vcd ");
    $dumpvars();
  end

  /*
  always@(negedge tb_clk) begin
    if() 
      $strobe("%0d, !!TEST SUCCESS!!", $time);
  end
  */

`endif


endmodule

