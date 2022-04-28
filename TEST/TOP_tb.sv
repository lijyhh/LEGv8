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
`define SORT 
//`define SORT_1 

module TOP_tb();

  reg                 tb_clk   ;                      
  reg                 tb_rst_n ;               

  // 
  // Parameter definition

  parameter MEM_SIZE = 1024; // Data memory depth

`ifdef FACT
    //parameter INST_FILE = `FACT_INST_FILE;
    //parameter DATA_FILE = `FACT_DATA_FILE; 
    parameter INST_FILE = `PIPELINE_FACT_INST_FILE;
    parameter DATA_FILE = `PIPELINE_FACT_DATA_FILE; 
`elsif SORT
    //parameter INST_FILE = `SORT_INST_FILE;
    //parameter DATA_FILE = `SORT_DATA_FILE; 
    parameter INST_FILE = "./data/bubble_sort/inst_mem.txt";
    parameter DATA_FILE = "./data/bubble_sort/data_mem.txt"; 
    parameter DATA_FILE_TB_SORT = "./data/bubble_sort/data_mem_tb_sort.txt"; 
`elsif SORT_1
    parameter INST_FILE = `SORT_INST_FILE_1;
    parameter DATA_FILE = `SORT_DATA_FILE_1; 
`else
    parameter INST_FILE = `PIPELINE_TEST_INST_FILE;
    parameter DATA_FILE = `PIPELINE_TEST_DATA_FILE; 
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

  wire                         tb_MemWrite; // 
  wire                         tb_MemRead ;
  wire [`WORD - 1 : 0]         tb_data    ;
  wire [`WORD - 1 : 0]         tb_addr    ;

  assign tb_MemWrite = TOP_TB.data_mem.MemWrite;
  assign tb_MemRead = TOP_TB.data_mem.MemRead;
  assign tb_data = TOP_TB.data_mem.data;

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
  assign tb_inst = TOP_TB.inst;
  assign tb_w_reg = TOP_TB.PipelineCPU.data_path.ID.w_reg;

`endif
  
  // 
  // Test begin
  initial begin
    delay(10000000);
    $finish;
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
  initial begin
    `TB_BEGIN
    //$dumpfile("TOP_tb_FACT_Single_Cycle.vcd ");
    $dumpfile("TOP_tb_FACT_Pipeline.vcd ");
    $dumpvars();    
  end

  // Fact data to be calculated
  reg [4:0] tb_fact_data;
  // Fact result data
  reg [63:0] tb_fact_res;

  initial begin
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
  
  reg [63:0] tb_num_data;
  
  initial begin
    tb_num_data = 64'd100;
    tb_data_mem_handle = $fopen(DATA_FILE_TB_SORT, "w");
    if( tb_data_mem_handle == 0 ) begin
      $error("File Open Failed!");
      $finish;
    end    
  end

  // Save waveform
  initial begin
    $display("\n===== BUBBLE SORT =====");
    `TB_BEGIN
    $display("Sorting...");
    $dumpfile("TOP_tb_SORT_Single_Cycle.vcd ");
    //$dumpfile("TOP_tb_SORT_Pipeline.vcd ");
    $dumpvars();
  end
  // Open file
  initial begin
    //$system("python py/random_gen.py");
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

/*
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
      $finish;
    end
  end
*/


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

