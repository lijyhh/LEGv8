`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: inst_mem_tb.sv
//
//*@File Type: system verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/30 21:23:40
//
//*@Function : Testbench for instruction memory module. 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module inst_mem_tb();

  parameter PATH = `TEST_INST_FILE;

  reg                   tb_clk  ;
  reg  [`WORD-1:0]      tb_pc   ;
  wire [`INST_SIZE-1:0] tb_inst ;

  initial begin
    tb_clk = 0;
  end
  always #`HALF_CYCLE tb_clk = ~tb_clk;


  inst_mem #( 
  .PATH  ( PATH   ) ) inst_mem_TB (
  .pc    ( tb_pc     ) ,  
  .inst  ( tb_inst   )             
  );

  initial begin
    `TB_BEGIN
    tb_pc = 64'd0;
    repeat(3) @(posedge tb_clk); // Wait reset    
    repeat(64) begin // 1024 is too much console spam
      @(negedge tb_clk)
      #1 assert(tb_inst == tb_pc / 4) 
        $strobe("%0d, !!TEST SUCCESS!!", $time);
      else $error("ERROR!");       
      tb_pc = tb_pc + 4;
    end
    `TB_END
    $finish;
  end

endmodule

