`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: ID.v
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/29 8:05:48
//
//*@Function : Realize instruction decode. 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module ID #( 
  parameter PATH = `TEST_REG_FILE ) (
  clk      ,            
  rst_n    ,        
  inst     ,       // Input instruction to be decoded
  RegWrite ,       // Flag of writing to register file 
  Reg2Loc  ,       // Flag of judging register file 2nd source register
  WRegLoc  ,       // Flag of judging register file write register
  w_data   ,       // Data to be written
  r_data1  ,       // Read data 1 from register file
  r_data2  ,       // Read data 2 from register file
  ex_data          // Extend data
  );

  //===========================================================
  //* Input and output ports
  //===========================================================
  //
  input                           clk     ;                
  input                           rst_n   ;             
  input   [`INST_SIZE - 1 : 0]    inst    ;                   
  input                           RegWrite;                
  input                           Reg2Loc ;                
  input                           WRegLoc ;                
  input   [`WORD - 1 : 0]         w_data  ;                
  output  [`WORD - 1 : 0]         r_data1 ;                   
  output  [`WORD - 1 : 0]         r_data2 ;                
  output  [`WORD - 1 : 0]         ex_data ;

  wire                            clk     ;                
  wire                            rst_n   ;             
  wire    [`INST_SIZE - 1 : 0]    inst    ;                   
  wire                            RegWrite;                
  wire                            Reg2Loc ;                
  wire                            WRegLoc ;                
  wire    [`WORD - 1 : 0]         w_data  ;                
  wire    [`WORD - 1 : 0]         r_data1 ;                   
  wire    [`WORD - 1 : 0]         r_data2 ;                
  wire    [`WORD - 1 : 0]         ex_data ;

  //===========================================================
  //* Internal signals
  //===========================================================
  //
  // Read register
  wire    [4:0]                   r_reg1  ;
  wire    [4:0]                   r_reg2  ;
  wire    [4:0]                   w_reg   ;

  assign r_reg1 = inst[9:5];

  mux2 #( 
    .SIZE( 5           )) mux2_read_reg2(
    .a   ( inst[20:16] ), 
    .b   ( inst[4:0]   ), 
    .sel ( Reg2Loc     ), 
    .out ( r_reg2      ) 
  );

  mux2 #( 
    .SIZE( 5           )) mux2_write_reg(
    .a   ( inst[4:0]   ), 
    .b   ( 5'd30       ), // Link register
    .sel ( WRegLoc     ), 
    .out ( w_reg       ) 
  );

  reg_file #( 
  .PATH    ( PATH      ) ) reg_file(
  .clk     ( clk       ) ,     // Should be clk       
  .rst_n   ( rst_n     ) ,        
  .r_reg1  ( r_reg1    ) ,     // Read register 1          
  .r_reg2  ( r_reg2    ) ,     // Read register 2
  .w_reg   ( w_reg     ) ,     // Write register 
  .w_data  ( w_data    ) ,     // Write data
  .RegWrite( RegWrite  ) ,     // Flag of write register
  .r_data1 ( r_data1   ) ,     // Read data 1
  .r_data2 ( r_data2   )       // Read data 2
  );

  sign_extend sign_extend(
  .inst    ( inst    ) ,        // Input inst     
  .ex_data ( ex_data )          // Extended data            
  );

endmodule

