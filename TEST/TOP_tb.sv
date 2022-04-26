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

//`define SINGLE_CYCLE

`define FACT 
//`define SORT 
//`define SORT_1 

module TOP_tb();

  reg                 tb_clk   ;                      
  reg                 tb_rst_n ;               

`ifdef FACT
    //parameter INST_FILE = `FACT_INST_FILE;
    //parameter DATA_FILE = `FACT_DATA_FILE; 
    parameter INST_FILE = `PIPELINE_FACT_INST_FILE;
    parameter DATA_FILE = `PIPELINE_FACT_DATA_FILE; 
`elsif SORT
    parameter INST_FILE = `SORT_INST_FILE;
    parameter DATA_FILE = `SORT_DATA_FILE; 
`elsif SORT_1
    parameter INST_FILE = `SORT_INST_FILE_1;
    parameter DATA_FILE = `SORT_DATA_FILE_1; 
`else
    parameter INST_FILE = `PIPELINE_TEST_INST_FILE;
    parameter DATA_FILE = `PIPELINE_TEST_DATA_FILE; 
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

  wire [`WORD - 1 : 0]         tb_w_data;
  wire [`INST_SIZE - 1 : 0]    tb_inst;
  wire [`WORD - 1 : 0]         tb_w_reg;

`ifdef SINGLE_CYCLE

  SingleCycleTOP #( 
  .INST_FILE( INST_FILE ),
  .DATA_FILE( DATA_FILE )) TOP_TB(
  .clk  ( tb_clk   )  ,              
  .rst_n( tb_rst_n )            
  );

  assign tb_w_data = TOP_TB.SingleCycleCPU.data_path.WB.w_data;
  assign tb_inst = TOP_TB.inst;
  assign tb_w_reg = TOP_TB.SingleCycleCPU.data_path.ID.w_reg;

  initial begin
    $dumpfile("TOP_tb_FACT_Single_Cycle.vcd ");
    $dumpvars();    
  end

`else

  PipelineTOP #( 
  .INST_FILE( INST_FILE ),
  .DATA_FILE( DATA_FILE )) TOP_TB(
  .clk  ( tb_clk   )  ,              
  .rst_n( tb_rst_n )            
  );

  assign tb_w_data = TOP_TB.PipelineCPU.data_path.WB.w_data;
  assign tb_inst = TOP_TB.inst;
  assign tb_w_reg = TOP_TB.PipelineCPU.data_path.ID.w_reg;

  initial begin
    $dumpfile("TOP_tb_FACT_Pipeline.vcd ");
    $dumpvars();    
  end

`endif
  
  initial begin
    `TB_BEGIN
    delay(1000);
    $finish;
  end

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
  // Fact data
  reg [4:0] tb_fact_data;
  // Fact result data
  reg [63:0] tb_fact_res;
  // Data memory handle
  integer tb_data_mem_handle;

  initial begin
    /******************Modify fact data and result here********************/

    //tb_fact_data = 3;
    //tb_fact_res  = 64'h6;

    //tb_fact_data = 6;
    //tb_fact_res  = 64'h2D0;

    tb_fact_data = 20;
    tb_fact_res  = 64'h21C3_677C_82B4_0000;

    /*********************************************************************/

    // Open file
    tb_data_mem_handle = $fopen(DATA_FILE, "w");
    if( tb_data_mem_handle == 0 ) begin
      $error("File Open Failed!");
      $finish;
    end

    // Write data to data memory file
    $fdisplay(tb_data_mem_handle, "%0x", 1023*8);         // Stack pointer
    $fdisplay(tb_data_mem_handle, "%0x", tb_fact_data); // Fact data
    for( j = 0; j < 1024 - 2; j = j + 1 ) begin
      $fdisplay(tb_data_mem_handle, "%0x", 0); // Others = 0
    end

    // Close data memory file
    $fclose(tb_data_mem_handle);

    $display("\n===== FACTORIAL: %0d =====", tb_fact_data);
  end

  always @(negedge tb_clk) begin
    if( tb_w_data == tb_fact_res ) begin
      $strobe("Time: %0d, Fact(%0d) = 0x%0x, !!TEST SUCCESS!!", $time, tb_fact_data, tb_w_data);
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

`else  
  initial begin
    $display("\n===== PIPELINE TEST =====");
    $dumpfile("TOP_tb_Pipeline_test.vcd ");
    $dumpvars();
  end

  initial begin
    wait( tb_w_data == 3 )  $strobe("tb_w_data = %0d", tb_w_data);
    wait( tb_w_data == 4 )  $strobe("tb_w_data = %0d", tb_w_data);
    delay(1);
    `TB_END
    $finish;
  end

`endif


endmodule

