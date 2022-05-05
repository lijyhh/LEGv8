`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: EX.v
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/29 15:07:34
//
//*@Function : Realize execute of instruction. 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module EX(
  clk          ,
  rst_n        ,
  r_data1      ,      // Read data 1 from register file      
  r_data2      ,      // Read data 2 from register file
  ex_data      ,      // Extend data from sign extend
  inst         ,      // Instruction for ALU control signal
  ALUOp        ,      // Output from control unit for ALU control signal
  ALUSrc       ,      // Output from control unit for ALU source data 
  SregUp       ,      // Output from control unit for status register
  pc           ,      // Program counter for branch address
  ALUOut       ,      // Output result from ALU
  ALU_res      ,      // Address for branch from ADD ALU
  N            ,      // Negative
  Z            ,      // Zero
  C            ,      // Carry
  V                   // oVerflow
  );

  //===========================================================
  //* Input and output ports
  //===========================================================
  //
  input                           clk          ;                  
  input                           rst_n        ;                  
  input  [`WORD - 1 : 0]          r_data1      ;                  
  input  [`WORD - 1 : 0]          r_data2      ;               
  input  [`WORD - 1 : 0]          ex_data      ;                  
  input  [`INST_SIZE - 1 : 0]     inst         ;               
  input  [1:0]                    ALUOp        ;                  
  input                           ALUSrc       ;                  
  input                           SregUp       ;                  
  input  [`WORD - 1 : 0]          pc           ;               
  output [`WORD - 1 : 0]          ALUOut       ;                  
  output [`WORD - 1 : 0]          ALU_res      ;                  
  output                          N            ;     
  output                          Z            ;     
  output                          C            ;     
  output                          V            ;     

  wire                            clk          ;                  
  wire                            rst_n        ;                  
  wire   [`WORD - 1 : 0]          r_data1      ;                  
  wire   [`WORD - 1 : 0]          r_data2      ;               
  wire   [`WORD - 1 : 0]          ex_data      ;                  
  wire   [`INST_SIZE - 1 : 0]     inst         ;               
  wire   [1:0]                    ALUOp        ;                  
  wire                            ALUSrc       ;                  
  wire                            SregUp       ;                  
  wire   [`WORD - 1 : 0]          pc           ;               
  wire   [`WORD - 1 : 0]          ALUOut       ;                  
  wire   [`WORD - 1 : 0]          ALU_res      ;                  
  wire                            N            ;
  wire                            Z            ;
  wire                            V            ;
  wire                            C            ;

  //===========================================================
  //* Internal signals
  //===========================================================
  //
  wire   [`WORD - 1 : 0]          ALU_data2    ;
  wire   [3:0]                    ALUCtl       ;
  wire                            Co           ;
  wire                            Zero         ;
  wire                            Overflow     ;
  wire                            Negative     ;
  wire   [`WORD - 1 : 0]          shift_ex_data;

  // ALU source data 2
  mux2 #( 
  .SIZE( `WORD     )) mux2_ALU(
  .a   ( r_data2   ),
  .b   ( ex_data   ), 
  .sel ( ALUSrc    ),
  .out ( ALU_data2 )
  );

  // ALU control signals 
  ALU_control ALU_control(
  .opcode( inst[31:21] )  ,    // Opcode of instruction             
  .ALUOp ( ALUOp       )  ,    // ALUOp from control unit     
  .ALUCtl( ALUCtl      )       // Output ALU control signal 
  );

  // ALU unit in EX
  ALU ALU_EX(
  .a        ( r_data1   ),     // Input data a
  .b        ( ALU_data2 ),     // Input data b
  .ALUCtl   ( ALUCtl    ),     // ALU control signals
  .Co       ( Co        ),     // Carry out for unsigned
  .Zero     ( Zero      ),     // Zero
  .ALUOut   ( ALUOut    ),     // Result of ALU
  .Overflow ( Overflow  ),     // Overflow flag for signed
  .Negative ( Negative  )      // Negative flag for signed
  );

  status_reg status_reg(
  .clk      ( clk      ) ,           
  .rst_n    ( rst_n    ) ,       
  .Negative ( Negative ) ,      
  .Zero     ( Zero     ) ,  
  .Ci       ( Co       ) ,    
  .Overflow ( Overflow ) , 
  .SregUp   ( SregUp   ) ,  // Update status register flag
  .N        ( N        ) ,  // Negative
  .Z        ( Z        ) ,  // Zero      
  .C        ( C        ) ,  // Carry    
  .V        ( V        )    // oVerflow         
  );

  // Left shift 2 bits to generate shamt of address
  left_shift #(
  .SIZE  ( 64            ) , 
  .OFFSET( 2             ) ) left_shift_2bits (
  .in    ( ex_data       ) ,                  
  .out   ( shift_ex_data )            
  );

  // ADD ALU unit in EX to get PC address of branch
  ALU ALU_ADD(
  .a        ( pc            ),     // Input data a
  .b        ( shift_ex_data ),     // Input data b
  .ALUCtl   ( `ALU_ADD      ),     // ALU control signals
  .Co       (               ),     // Carry out for unsigned
  .Zero     (               ),     // Zero
  .ALUOut   ( ALU_res       ),     // Result of ALU
  .Overflow (               ),     // Overflow for signed
  .Negative (               )      // Negative flag for signed
  );

endmodule

