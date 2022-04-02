`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: ID_tb.sv
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/31 20:12:48
//
//*@Function : Testbench for ID module. 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module ID_tb();

  parameter REG_FILE = `REG_MEM_TEST_FILE;

  reg                             tb_clk     ;                
  reg                             tb_rst_n   ;             
  reg     [`INST_SIZE - 1 : 0]    tb_inst    ;                   
  reg                             tb_RegWrite;                
  reg                             tb_Reg2Loc ;                
  reg                             tb_WRegLoc ;                
  reg     [`WORD - 1 : 0]         tb_w_data  ;                
  wire    [`WORD - 1 : 0]         tb_r_data1 ;                   
  wire    [`WORD - 1 : 0]         tb_r_data2 ;                
  wire    [`WORD - 1 : 0]         tb_ex_data ;

  reg     [2:0]                   tb_combined_signals;

  assign {tb_RegWrite, tb_Reg2Loc, tb_WRegLoc} = tb_combined_signals;

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

  
  ID #( 
  .PATH    ( REG_FILE ) ) ID_TB(
  .clk     ( tb_clk      ) ,            
  .rst_n   ( tb_rst_n    ) ,        
  .inst    ( tb_inst     ) ,       // Input tb_inst to be decoded
  .RegWrite( tb_RegWrite ) ,       // Flag of writing to register file 
  .Reg2Loc ( tb_Reg2Loc  ) ,       // Flag of judging register file 2nd source register
  .WRegLoc ( tb_WRegLoc  ) ,       // Flag of judging register file write register
  .w_data  ( tb_w_data   ) ,       // Data to be written
  .r_data1 ( tb_r_data1  ) ,       // Read data 1 from register file
  .r_data2 ( tb_r_data2  ) ,       // Read data 2 from register file
  .ex_data ( tb_ex_data  )         // Extend data
  );

  task my_assert;
    input [`WORD - 1:0] r_data1;
    input [`WORD - 1:0] r_data2;
    input [`WORD - 1:0] ex_data;
    input integer i;
    begin
      assert(tb_r_data1 == r_data1 && tb_r_data2 == r_data2 && tb_ex_data == ex_data) 
      else $error("[%d] tb_r_data1 = %d, tb_r_data2 = %d, tb_ex_data = %d", 
        i, tb_r_data1, tb_r_data2, tb_ex_data);
    end
  endtask

  initial begin
    `TB_BEGIN
    tb_inst = 32'h00000000;
    tb_w_data = `WORD'd0;
    tb_combined_signals = 3'b000;
    repeat(3) @(posedge tb_clk) #1;
    // LDUR X9, [X22, #64]
    tb_inst = 32'hF84402C9;
    tb_w_data = `WORD'd1; // X9 = 1 
    tb_combined_signals = 3'b100;
    #`CYCLE;   
    my_assert(22, 4, 64, 0);
    
    // ADD X10, X19, X9
    tb_inst = 32'h8B09026A;
    tb_w_data = `WORD'd20; // X10 = 20
    tb_combined_signals = 3'b100;
    #`CYCLE;
    my_assert(19, 1, 'h8B09026A, 1);
    
    // SUB X11, X20, X10
    tb_inst = 32'hCB0A028B;
    tb_w_data = `WORD'd0; // X11 = 0
    tb_combined_signals = 3'b100;
    #`CYCLE;
    my_assert(20, 20, 'hCB0A028B, 2);
    
    // STUR X11, [X22, #96]
    tb_inst = 32'hF80602CB;
    tb_combined_signals = 3'b010; 
    #`CYCLE;
    my_assert(22, 0, 96, 3);
    
    // CBZ X11, -5
    tb_inst = 32'hB4FFFF6B;
    tb_combined_signals = 3'b010;
    #`CYCLE;
    my_assert(27, 0, 'hFFFFFFFFFFFFFFFB, 4);
    
    // CBZ X9, 8
    tb_inst = 32'hB4000109;
    tb_combined_signals = 3'b010;
    #`CYCLE;
    my_assert(8, 1, 8, 5);
    
    // CBNZ X9, 8
    tb_inst = 32'hB5000109;
    tb_combined_signals = 3'b010;
    #`CYCLE;
    my_assert(8, 1, 8, 6);

    // B 64
    tb_inst = 32'h14000040;
    tb_combined_signals = 3'b000;
    #`CYCLE;
    my_assert(2, 0, 64, 7);
    
    // B -55
    tb_inst = 32'h17FFFFC9;
    tb_combined_signals = 3'b000;
    #`CYCLE;
    my_assert(30, 31, 'hFFFFFFFFFFFFFFC9, 8);
    
    // ORR X9, X10, X21
    tb_inst = 32'hAA150149;
    tb_w_data = `WORD'd30;
    tb_combined_signals = 3'b100;
    #`CYCLE;
    my_assert(20, 21, 'hAA150149, 9);
    
    // AND X9, X22, X10
    tb_inst = 32'h8A0A02C9;
    tb_w_data = `WORD'd16;
    tb_combined_signals = 3'b100;
    #`CYCLE;
    my_assert(22, 20, 'h8A0A02C9, 10);

    `TB_END
    $finish;
  end
  


endmodule
