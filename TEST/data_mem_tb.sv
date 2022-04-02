`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: data_mem_tb.sv
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/4/2 9:59:19
//
//*@Function : Testbench for data memory module. 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module data_mem_tb();
  
  parameter DATA_FILE = `DATA_MEM_TEST_FILE;
  
  reg                             tb_clk     ;                  
  reg                             tb_rst_n   ;               
  reg                             tb_MemRead ;                   
  reg                             tb_MemWrite;                
  reg    [`WORD - 1 : 0]          tb_addr    ;                   
  reg    [`WORD - 1 : 0]          tb_w_data  ;                
  wire   [`WORD - 1 : 0]          tb_r_data  ;                   

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


  data_mem #( 
  .PATH    ( DATA_FILE )  , 
  .SIZE    ( 1024      )  ) MEM_TB(
  .clk     ( tb_clk       )  ,
  .rst_n   ( tb_rst_n     )  ,          
  .MemRead ( tb_MemRead   )  ,     // Signal of reading data from memory
  .MemWrite( tb_MemWrite  )  ,     // Signal of writing data to memory
  .addr    ( tb_addr      )  ,     // Address
  .w_data  ( tb_w_data    )  ,     // Data to be write
  .r_data  ( tb_r_data    )        // Data read from memory
  );

  initial begin
    `TB_BEGIN
    tb_MemRead = 'b0;
    tb_MemWrite = 'b0;
    tb_addr = 'b0;
    tb_w_data = 'b0;
    repeat( 3 ) @( posedge tb_clk ) #1;

    tb_MemRead = 'b1;
    tb_addr = 'd64;  // Read data is 8
    #`CYCLE;
    assert( tb_r_data == 8 ) $strobe("%0d, !!TEST SUCCESS!!", $time);
    else $error("tb_r_data = %0d", tb_r_data);


    tb_MemRead = 'b1;
    tb_addr = 'd128;  // Read data is 16
    #`CYCLE;
    assert( tb_r_data == 16 ) $strobe("%0d, !!TEST SUCCESS!!", $time);
    else $error("tb_r_data = %0d", tb_r_data);

    tb_MemRead = 'b0;
    tb_MemWrite = 'b1;
    tb_addr = 'd64;  // Write reg is 8
    tb_w_data = 'd13;  // Write data is 13
    #`CYCLE;

    tb_MemRead = 'b1;
    tb_MemWrite = 'b0;
    tb_addr = 'd64;  // Read data is 13
    #`CYCLE;
    assert( tb_r_data == 13 ) $strobe("%0d, !!TEST SUCCESS!!", $time);
    else $error("tb_r_data = %0d", tb_r_data);
    #`CYCLE;

    `TB_END
    $finish;
  end

endmodule
