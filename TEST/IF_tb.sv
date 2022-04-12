`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: IF_tb.sv
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/31 13:05:32
//
//*@Function : TestBench for IF module. 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module IF_tb;

  parameter INST_FILE = `TEST_INST_FILE;
  
  reg                         tb_clk     ;                
  reg                         tb_rst_n   ;             
  reg    [`WORD - 1 : 0]      tb_ALU_res ;                   
  reg    [`WORD - 1 : 0]      tb_ALUOut  ;                   
  reg    [1:0]                tb_PCSrc   ;                   
  reg    [`WORD - 1 : 0]      tb_pc      ;   
  wire   [`WORD - 1 : 0]      tb_pc_incr ;   
  wire   [`INST_SIZE - 1 : 0] tb_inst    ;
  
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

  initial begin
    $dumpfile(" IF_tb.vcd ");
    $dumpvars();
  end

  IF IF( 
  .clk     ( tb_clk     ),             
  .rst_n   ( tb_rst_n   ), 
  .ALU_res ( tb_ALU_res ),    // Result of ADD ALU in EX, i.e. address of branch     
  .ALUOut  ( tb_ALUOut  ),    // Result of ALU in EX
  .PCSrc   ( tb_PCSrc   ),    // Control signal of PCSrc  
  .pc      ( tb_pc      ),    // Current PC
  .pc_incr ( tb_pc_incr )     // Current PC + 4
  );

  // Instruction memory
  inst_mem #( 
  .PATH  ( INST_FILE   ) ) inst_mem (
  .pc    ( tb_pc     ) ,  
  .inst  ( tb_inst   )             
  );

  task my_assert;
    input [`INST_SIZE - 1 : 0] inst;
    input integer i;
    begin
      #`CYCLE assert(tb_inst == inst) 
        $strobe("%0d, !!TEST SUCCESS!!", $time);
      else $error("[%0d] tb_inst = %0d", i, inst);
    end
  endtask

  initial begin
    `TB_BEGIN

    tb_PCSrc = 0;
    tb_ALU_res = 0;
    tb_ALUOut = 0;
    repeat(2) @(posedge tb_clk) #1;
    
    tb_PCSrc = 'b00;  // Select PC + 4
    tb_ALU_res = 124; // Instruction is 31
    tb_ALUOut = 60;   // Instruction is 15
    #1;
    
    tb_PCSrc = 'b01;  
    my_assert(31, 0);
    
    tb_PCSrc = 'b10;  
    my_assert(15, 1);
    
    tb_PCSrc = 'b11;  
    my_assert(15, 2);

    tb_PCSrc = 'b00;  
    my_assert(16, 3);
    
    `TB_END
    $finish;
  end
  
endmodule
