`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: sign_extend.v
//
//*@File Type: verilog
//
//*@Version  : 0.0
//
//*@Author   : Zehua Dong, SIGS
//
//*@E-mail   : 1285507636@qq.com
//
//*@Date     : 2022/3/29 0:33:51
//
//*@Function : Extend immitates to 64 bits. 
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module
module sign_extend(
  inst     ,        // Input inst     
  ex_data          // Extended data            
  );

  //===========================================================
  //* Input and output ports
  //===========================================================
  //
  input   [`INST_SIZE - 1 : 0]    inst    ;                 
  output  [`WORD - 1 : 0]         ex_data ;               

  wire    [`INST_SIZE - 1 : 0]    inst    ;                 
  reg     [`WORD - 1 : 0]         ex_data ;               


  always @( * ) begin
    casez(inst[31:21])
      `LSL, `LSR:
        ex_data = {{(`WORD-6){inst[15]}}, inst[15:10]};
      `ADDI, `ANDI, `EORI, `ORRI, `SUBI, `SUBIS:
        ex_data = {{(`WORD-12){inst[21]}}, inst[21:10]};
      `LDUR, `STUR:
        ex_data = {{(`WORD-9){inst[20]}}, inst[20:12]};
      `CBZ, `CBNZ, `BCOND:
        ex_data = {{(`WORD-19){inst[23]}}, inst[23:5]};
      `B, `BL:
        ex_data = {{(`WORD-26){inst[25]}}, inst[25:0]};
      `MOV: 
        ex_data = {`WORD{1'b0}};
      `MOVK, `MOVZ:
        ex_data = {{(`WORD-16){1'b0}}, inst[20:5]};
      default:
        ex_data = {{(`WORD-`INST_SIZE){1'b0}}, inst};
    endcase
  end

endmodule


