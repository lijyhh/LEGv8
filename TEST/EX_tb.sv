`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: TEST\EX_tb.sv
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/4/1 8:31:58
//
//*@Function : Testbench for EX module. 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module EX_tb();

  reg                             tb_clk          ;
  reg                             tb_rst_n        ;
  reg    [`WORD - 1 : 0]          tb_r_data1      ;                  
  reg    [`WORD - 1 : 0]          tb_r_data2      ;               
  reg    [`WORD - 1 : 0]          tb_ex_data      ;                  
  reg    [`INST_SIZE - 1 : 0]     tb_inst         ;               
  reg    [1:0]                    tb_ALUOp        ;                  
  reg                             tb_ALUSrc       ;                  
  reg    [2:0]                    tb_BranchOp     ;               
  reg                             tb_SregUp       ;                  
  reg    [`WORD - 1 : 0]          tb_pc           ;               
  wire   [`WORD - 1 : 0]          tb_ALUOut       ;                  
  wire   [1:0]                    tb_PCSrc        ;               
  wire   [`WORD - 1 : 0]          tb_ALU_res      ;                  

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
  
  EX EX_TB(
  .clk      ( tb_clk       )    ,
  .rst_n    ( tb_rst_n     )    ,
  .r_data1  ( tb_r_data1   )    ,      // Read data 1 from register file      
  .r_data2  ( tb_r_data2   )    ,      // Read data 2 from register file
  .ex_data  ( tb_ex_data   )    ,      // Extend data from sign extend
  .inst     ( tb_inst      )    ,      // Instruction for ALU control signal
  .ALUOp    ( tb_ALUOp     )    ,      // Output from control unit for ALU control signal
  .ALUSrc   ( tb_ALUSrc    )    ,      // Output from control unit for ALU source data 
  .BranchOp ( tb_BranchOp  )    ,      // Output from control unit for PCSrc, 3 bits
  .SregUp   ( tb_SregUp    )    ,      // Output from control unit for status register
  .pc       ( tb_pc        )    ,      // Program counter for branch address
  .ALUOut   ( tb_ALUOut    )    ,      // Output result from ALU
  .PCSrc    ( tb_PCSrc     )    ,      // PC source flag
  .ALU_res  ( tb_ALU_res   )           // Address for branch from ADD ALU
  );

    task my_assert;
    input [`WORD - 1:0] ALUOut;
    input [01:0]        PCSrc;
    input [`WORD - 1:0] ALU_res;
    input integer i;
    begin
      assert(tb_ALUOut == ALUOut && tb_PCSrc == PCSrc && tb_ALU_res == ALU_res) 
      else $error("[%d] tb_ALUOut = %d, tb_PCSrc = %d, tb_ALU_res = %h", 
        i, tb_ALUOut, tb_PCSrc, tb_ALU_res);
    end
  endtask

  initial begin
    `TB_BEGIN
    repeat(3) @(posedge tb_clk) #1;
    tb_r_data1   = 'd0;  
    tb_r_data2   = 'd0;  
    tb_ex_data   = 'd0; 
    tb_inst      = 'd0; 
    tb_ALUOp     = 'd0; 
    tb_ALUSrc    = 'd0; 
    tb_BranchOp  = `BCOND_OP_NONE;
    tb_SregUp    = 'd0; 
    tb_pc        = 'd0; 
    #`CYCLE;

    // LDUR X9, [X22, #64]
    tb_r_data1   = 'd22;  
    tb_r_data2   = 'd4;  
    tb_ex_data   = 'd64; 
    tb_inst      = 32'hF84402C9; 
    tb_ALUOp     = 'd0; 
    tb_ALUSrc    = 'd1; 
    tb_BranchOp  = `BCOND_OP_NONE;
    tb_SregUp    = 'd0; 
    tb_pc        = 'd200; 
    #`CYCLE;
    my_assert(86, 0, 456, 0);

    // ADD X10, X19, X9
    tb_r_data1   = 'd19;  
    tb_r_data2   = 'd9;  
    tb_ex_data   = 'h8B09026A; 
    tb_inst      = 32'h8B09026A; 
    tb_ALUOp     = 'b10; 
    tb_ALUSrc    = 'd0; 
    tb_BranchOp  = `BCOND_OP_NONE;
    tb_SregUp    = 'd0; 
    tb_pc        = 'd200; 
    #`CYCLE;
    my_assert(28, 0, 64'h22C240A70, 1);

    // SUB X11, X20, X10
    tb_r_data1   = 'd20;  
    tb_r_data2   = 'd20;  
    tb_ex_data   = 'hCB0A028B; 
    tb_inst      = 32'hCB0A028B; 
    tb_ALUOp     = 'b10; 
    tb_ALUSrc    = 'd0; 
    tb_BranchOp  = `BCOND_OP_NONE;
    tb_SregUp    = 'd0; 
    tb_pc        = 'd200; 
    #`CYCLE;
    my_assert(0, 0, 64'h32C280AF4, 2);

    // STUR X11, [X22, #96]
    tb_r_data1   = 'd22;  
    tb_r_data2   = 'd0;  
    tb_ex_data   = 'd96; 
    tb_inst      = 32'hF80602CB; 
    tb_ALUOp     = 'b00; 
    tb_ALUSrc    = 'd1; 
    tb_BranchOp  = `BCOND_OP_NONE;
    tb_SregUp    = 'd0; 
    tb_pc        = 'd200; 
    #`CYCLE;
    my_assert(118, 0, 584, 3);

    // CBZ X11, -5
    tb_r_data1   = 'd27;  
    tb_r_data2   = 'd0;  
    tb_ex_data   = 'hFFFFFFFFFFFFFFFB; 
    tb_inst      = 32'hB4FFFF6B; 
    tb_ALUOp     = 'b01; 
    tb_ALUSrc    = 'd1; 
    tb_BranchOp  = `BCOND_OP_ZERO;
    tb_SregUp    = 'd1; 
    tb_pc        = 'd200; 
    #`CYCLE;
    my_assert(64'hFFFFFFFFFFFFFFFB, 0, 180, 4);

    // CBNZ X9, 8
    tb_r_data1   = 'd8;  
    tb_r_data2   = 'd1;  
    tb_ex_data   = 'h8; 
    tb_inst      = 32'hB5000109; 
    tb_ALUOp     = 'b01; 
    tb_ALUSrc    = 'd1; 
    tb_BranchOp  = `BCOND_OP_NZERO;
    tb_SregUp    = 'd1; 
    tb_pc        = 'd200; 
    #`CYCLE;
    my_assert(8, 1, 64'hE8, 5);

    // B 64
    tb_r_data1   = 'd2;  
    tb_r_data2   = 'd0;  
    tb_ex_data   = 'd64; 
    tb_inst      = 32'h14000040; 
    tb_ALUOp     = 'b11; 
    tb_ALUSrc    = 'd0; 
    tb_BranchOp  = `BCOND_OP_BRANCH;
    tb_SregUp    = 'd0; 
    tb_pc        = 'd200; 
    #`CYCLE;
    my_assert(1, 1, 456, 6);

    `TB_END
    $finish;
  end

endmodule
