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
//`define AUTO_SORT
`define MANUAL_SORT

module TOP_tb();

  reg                 tb_clk   ;                      
  reg                 tb_rst_n ;               

  // 
  // Parameter definition

  parameter MEM_SIZE = 1024; // Data memory depth

`ifdef FACT
    //parameter INST_FILE = `SINGLE_CYCLE_FACT_INST_FILE;
    //parameter DATA_FILE = `SINGLE_CYCLE_FACT_DATA_FILE; 

    parameter INST_FILE = `PIPELINE_FACT_INST_FILE;
    parameter DATA_FILE = `PIPELINE_FACT_DATA_FILE; 
`elsif AUTO_SORT
    parameter INST_FILE = `SINGLE_CYCLE_SORT_INST_FILE;
    parameter DATA_FILE = `SINGLE_CYCLE_SORT_DATA_FILE; 
    parameter DATA_FILE_TB = `SINGLE_CYCLE_SORT_DATA_FILE_TB; 

    //parameter INST_FILE = `PIPELINE_SORT_INST_FILE;
    //parameter DATA_FILE = `PIPELINE_SORT_DATA_FILE; 
    //parameter DATA_FILE_TB = `PIPELINE_SORT_DATA_FILE_TB; 
`elsif MANUAL_SORT
    parameter INST_FILE = `SORT_INST_FILE;
    parameter DATA_FILE = `SORT_DATA_FILE; 
`endif

  // 
  // Task of delay num cycles
  task delay;
    input [31:0] num;
    begin
      repeat(num) @(posedge tb_clk);
      #1;
    end
  endtask

  //
  // Generation of clock and reset signals 
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

  // 
  // Some test signals
  wire [`WORD - 1 : 0]         tb_w_data;   // Write back data in WB stage
  wire [`INST_SIZE - 1 : 0]    tb_inst  ;   // Instruction
  wire [`WORD - 1 : 0]         tb_w_reg ;   // Write register in ID stage

  // 
  // Module instantiation

`ifdef SINGLE_CYCLE

  SingleCycleTOP #( 
  .INST_FILE( INST_FILE ),
  .DATA_FILE( DATA_FILE ),
  .SIZE     ( MEM_SIZE  )) TOP_TB(
  .clk  ( tb_clk   )  ,              
  .rst_n( tb_rst_n )            
  );

  assign tb_w_data = TOP_TB.SingleCycleCPU.data_path.WB.w_data;
  assign tb_inst = TOP_TB.inst;
  assign tb_w_reg = TOP_TB.SingleCycleCPU.data_path.ID.w_reg;

`else

  PipelineTOP #( 
  .INST_FILE( INST_FILE ),
  .DATA_FILE( DATA_FILE ),
  .SIZE     ( MEM_SIZE  )) TOP_TB(
  .clk  ( tb_clk   )  ,              
  .rst_n( tb_rst_n )            
  );

  assign tb_w_data = TOP_TB.PipelineCPU.data_path.WB.w_data;
  assign tb_inst = TOP_TB.PipelineCPU.data_path.WB.inst;
  assign tb_w_reg = TOP_TB.PipelineCPU.data_path.ID.w_reg;

`endif
  
  // 
  // Test begin
  initial begin
    delay(10000000);
    $finish;
  end

  // 
  // Data memory handle
  integer tb_data_mem_handle;

  //
  // Test FACT/SORT
`ifdef FACT

  // Open file
  initial begin
    tb_data_mem_handle = $fopen(DATA_FILE, "w");
    if( tb_data_mem_handle == 0 ) begin
      $error("File Open Failed!");
      $finish;
    end
  end

  // Save waveform
  //initial begin
  //  $dumpfile("TOP_tb_FACT_Single_Cycle.vcd ");
  //  $dumpfile("TOP_tb_FACT_Pipeline.vcd ");
  //  $dumpvars();    
  //end

  // Fact data to be calculated
  reg [4:0] tb_fact_data;
  // Fact result data
  reg [63:0] tb_fact_res;

  initial begin
    `TB_BEGIN
    /******************Modify fact data and result here********************/

    //tb_fact_data = 3;
    //tb_fact_res  = 64'h6;

    //tb_fact_data = 6;
    //tb_fact_res  = 64'h2D0;

    tb_fact_data = 20;
    tb_fact_res  = 64'h21C3_677C_82B4_0000;

    /*********************************************************************/

    // Write data to data memory file
    $fdisplay(tb_data_mem_handle, "%0x", ( MEM_SIZE - 1 )*8);         // Stack pointer,
    $fdisplay(tb_data_mem_handle, "%0x", tb_fact_data);   // Fact data

    // Close data memory file
    $fclose(tb_data_mem_handle);

    $display("===== FACTORIAL: %0d =====", tb_fact_data);
  end

  always @(negedge tb_clk) begin
    if( tb_w_data == tb_fact_res ) begin
      $strobe("Time: %0d, Fact(%0d) = 0x%0x, !!TEST SUCCESS!!", $time, tb_fact_data, tb_w_data);
      `TB_END
      $finish;
    end
  end

`elsif AUTO_SORT
  
  // Data number to be sorted
  reg [63:0] tb_num_data;
  
  // Open data file to be written
  initial begin
    tb_num_data = 64'd100;
    tb_data_mem_handle = $fopen(DATA_FILE_TB, "w");
    if( tb_data_mem_handle == 0 ) begin
      $error("File Open Failed!");
      $finish;
    end    
  end

  // Save waveform
  //initial begin
  //  $dumpfile("TOP_tb_SORT_Single_Cycle.vcd ");
  //  $dumpfile("TOP_tb_SORT_Pipeline.vcd ");
  //  $dumpvars();
  //end

  initial begin
    `TB_BEGIN
    $display("===== AUTO BUBBLE SORT =====");
    $display("Number of random data: %0d", tb_num_data);
    $display("\nSorting...");
    // Wait 'B #0'
    wait( tb_inst == 'h14000000 ) begin
      delay(1);
      $display("Sort Done!");
      for( j = 0; j < tb_num_data; j = j + 1 ) begin
        $fdisplay(tb_data_mem_handle, "%0h", TOP_TB.data_mem.data_memory[j+3]);
        delay(1);
      end
    end
    $fclose(tb_data_mem_handle);
    $display("\nComparing...");
    $system("python py/compare.py");
    `TB_END
    $finish;
  end

`elsif MANUAL_SORT
 
  initial begin
    `TB_BEGIN
    $display("===== MANUAL BUBBLE SORT =====");
    //$dumpfile("TOP_tb_MANUAL_SORT.vcd ");
    //$dumpvars();
  end
 
  // 
  // Used for sort test
  reg  [`WORD - 1 : 0]         tb_v[8:0]; // Array v in testbench
  integer j;                              // Variable in loop to print value in 

  // Assert sorted data
  task my_assert;
    input  [`WORD - 1 : 0] w_data;
    input  [`WORD - 1 : 0] w_reg;
    output [`WORD - 1 : 0] v;
    input  integer         i;
    begin
      assert( tb_w_data == w_data && tb_w_reg == w_reg ) begin
          v = w_data;
          $strobe("Time: %0d, !!v[%0d] = 0x%0h TEST SUCCESS!!", $time, i, tb_w_data);
      end
      else begin
        $error("[%0d], tb_w_data = 0x%0h", i, tb_w_data);
      end
    end
  endtask

  // Check result using my_assert
  always@(negedge tb_clk) begin
    wait( tb_inst == 'hf8400009) begin // v[0]
      #1;
      my_assert(1, 9, tb_v[0], 0);
    end
    wait( tb_inst == 'hf8408009) begin // v[1]
      #1;
      my_assert(2, 9, tb_v[1], 1);
    end
    wait( tb_inst == 'hf8410009) begin // v[2]
      #1;
      my_assert('h27, 9, tb_v[2], 2);
    end
    wait( tb_inst == 'hf8418009) begin // v[3]
      #1;
      my_assert('h45, 9, tb_v[3], 3);
    end
    wait( tb_inst == 'hf8420009) begin // v[4]
      #1;
      my_assert('h99, 9, tb_v[4], 4);

      // Display result
      #1 $write("tb_v is( HEX format ): ");
      #1;
      for( j = 0; j < 5; j = j + 1 ) begin
        $write("%0h ", tb_v[j]);
      end
      #1 $strobe("");
      delay(1);
      `TB_END
      $finish;
    end
  end

`endif


endmodule

