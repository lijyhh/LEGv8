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

`define SINGLE_CYCLE

//`define FACT 
//`define FACT_1 
`define SORT 
//`define SORT_1 

module TOP_tb();

  reg                 tb_clk   ;                      
  reg                 tb_rst_n ;               

`ifdef FACT
    parameter INST_FILE = `FACT_INST_FILE;
    parameter DATA_FILE = `FACT_DATA_FILE; 
`elsif FACT_1
    parameter INST_FILE = `FACT_INST_FILE_1;
    parameter DATA_FILE = `FACT_DATA_FILE_1; 
`elsif SORT
    parameter INST_FILE = `SORT_INST_FILE;
    parameter DATA_FILE = `SORT_DATA_FILE; 
`elsif SORT_1
    parameter INST_FILE = `SORT_INST_FILE_1;
    parameter DATA_FILE = `SORT_DATA_FILE_1; 
`else
    parameter INST_FILE = `TEST_INST_FILE;
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

`ifdef SINGLE_CYCLE
  SingleCycleTOP #( 
  .INST_FILE( INST_FILE ),
  .DATA_FILE( DATA_FILE )) TOP_TB(
  .clk  ( tb_clk   )  ,              
  .rst_n( tb_rst_n )            
  );
`else
  PipelineTOP #( 
  .INST_FILE( INST_FILE ),
  .DATA_FILE( DATA_FILE )) TOP_TB(
  .clk  ( tb_clk   )  ,              
  .rst_n( tb_rst_n )            
  );
`endif
  
  initial begin
    `TB_BEGIN
    delay(500);
    $finish;
  end

  wire [`WORD - 1 : 0]         tb_w_data;
  assign tb_w_data = TOP_TB.SingleCycleCPU.data_path.WB.w_data;
  
  wire [`INST_SIZE - 1 : 0]    tb_inst;
  assign tb_inst = TOP_TB.inst;

  wire [`WORD - 1 : 0]         tb_w_reg;
  assign tb_w_reg = TOP_TB.SingleCycleCPU.data_path.ID.w_reg;

  reg  [`WORD - 1 : 0]         tb_v[8:0];

  integer j;

  task my_assert;
    input  [`WORD - 1 : 0] w_data;
    input  [`WORD - 1 : 0] w_reg;
    output [`WORD - 1 : 0] v;
    input  integer         i;
    begin
      assert( tb_w_data == w_data && tb_w_reg == w_reg ) begin
          v = w_data;
          $strobe("Time: %0d, !!v[%0d] = %0h TEST SUCCESS!!", $time, i, tb_w_data);
      end
      else begin
        $error("tb_w_data = %0d", tb_w_data);
      end
    end
  endtask



`ifdef FACT
  
  initial begin
    $display("\n===== FACTORIAL: 3 =====");
    $dumpfile("TOP_tb_FACT3.vcd ");
    $dumpvars();
  end

  always @(negedge tb_clk) begin
    // Test 12!
    //if( tb_w_data == 479001600 ) $strobe("%0d, !!fact12 TEST SUCCESS!!", $time);

    // Test 3!
    if( tb_w_data == 6 ) begin
      $strobe("Time: %0d, Fact(3) = %0d, !!TEST SUCCESS!!", $time, tb_w_data);
      `TB_END
      $finish;
    end
  end

`elsif FACT_1
  
  initial begin
    $display("\n===== FACTORIAL: 6 =====");
    $dumpfile("TOP_tb_FACT6.vcd ");
    $dumpvars();
  end

  always @(negedge tb_clk) begin
    //Test 6!
    if( tb_w_data == 720 ) begin
     $strobe("Time: %0d, Fact(6) = %0d, !!TEST SUCCESS!!", $time, tb_w_data);
     `TB_END
     $finish;
    end
  end

`elsif SORT
  
  initial begin
    $display("\n===== BUBBLE SORT =====");
    $dumpfile("TOP_tb_SORT.vcd ");
    $dumpvars();
  end

  always@(negedge tb_clk) begin
    case( tb_inst )
      'hf8400009: begin // v[0]
        my_assert(1, 9, tb_v[0], 0);
      end
      'hf8408009: begin // v[1]
        my_assert(2, 9, tb_v[1], 1);
      end
      'hf8410009: begin // v[2]
        my_assert('h27, 9, tb_v[2], 2);
      end
      'hf8418009: begin // v[3]
        my_assert('h45, 9, tb_v[3], 3);
      end
      'hf8420009: begin // v[4]
        my_assert('h99, 9, tb_v[4], 4);

        // Display result
        #1 $write("tb_v is( HEX format ): ");
        #1;
        for( j = 0; j < 5; j = j + 1 ) begin
          $write("%0h ", tb_v[j]);
        end
        #1 $strobe("");

        `TB_END
        $finish;
      end
    endcase
  end

`elsif SORT_1
  
  initial begin
    $display("\n===== BUBBLE SORT 1 =====");
    $dumpfile("TOP_tb_SORT_1.vcd ");
    $dumpvars();
  end

  integer i;

  always@(negedge tb_clk) begin
    case( tb_inst )
      'hf8400009: begin // v[0]
        my_assert(1, 9, tb_v[0], 0);
      end
      'hf8408009: begin // v[1]
        my_assert(2, 9, tb_v[1], 1);
      end
      'hf8410009: begin // v[2]
        my_assert('h16, 9, tb_v[2], 2);
      end
      'hf8418009: begin // v[3]
        my_assert('h27, 9, tb_v[3], 3);
      end
      'hf8420009: begin // v[4]
        my_assert('h45, 9, tb_v[4], 4);
      end
      'hf8428009: begin // v[5]
        my_assert('h99, 9, tb_v[5], 5);
      end
      'hf8430009: begin // v[6]
        my_assert('h107, 9, tb_v[6], 6);
      end
      'hf8438009: begin // v[7]
        my_assert('h253, 9, tb_v[7], 7);
      end
      'hf8440009: begin // v[8]
        my_assert('h800, 9, tb_v[8], 8);

        // Display result
        #1 $write("tb_v is( HEX format ): ");
        #1;
        for( j = 0; j < 9; j = j + 1 ) begin
          $write("%0h ", tb_v[j]);
        end
        #1 $strobe("");

        `TB_END
        $finish;
      end
    endcase
  end

`endif


endmodule

