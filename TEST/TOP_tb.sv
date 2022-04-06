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

//`define FACT 
//`define SORT 
`define SORT_1 

module TOP_tb();

  reg                 tb_clk   ;                      
  reg                 tb_rst_n ;               

`ifdef FACT
    parameter INST_FILE = `FACT_INST_FILE;
    parameter REG_FILE  = `FACT_REG_FILE ; 
    parameter DATA_FILE = `FACT_DATA_FILE; 
`elsif SORT
    parameter INST_FILE = `SORT_INST_FILE;
    parameter REG_FILE  = `SORT_REG_FILE ; 
    parameter DATA_FILE = `SORT_DATA_FILE; 
`elsif SORT_1
    parameter INST_FILE = `SORT_INST_FILE_1;
    parameter REG_FILE  = `SORT_REG_FILE_1 ; 
    parameter DATA_FILE = `SORT_DATA_FILE_1; 
`else
    parameter INST_FILE = `TEST_INST_FILE;
    parameter REG_FILE  = `TEST_REG_FILE ; 
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

  TOP #( 
  .INST_FILE( INST_FILE ),
  .REG_FILE ( REG_FILE  ),
  .DATA_FILE( DATA_FILE )) TOP_TB(
  .clk  ( tb_clk   )  ,              
  .rst_n( tb_rst_n )            
  );
  
  initial begin
    `TB_BEGIN
    delay(500);
  end

`ifdef FACT
  
  initial begin
    $display("===== FACTORIAL =====\n");
    $dumpfile(" TOP_tb_FACT.vcd ");
    $dumpvars();
  end

  wire [`WORD - 1 : 0]         tb_w_data;
  assign tb_w_data = TOP_TB.data_path.WB.w_data;

  always @(negedge tb_clk) begin
    // Test 12!
    //if( tb_w_data == 479001600 ) $strobe("%0d, !!TEST SUCCESS!!", $time);
    // Test 6!
    if( tb_w_data == 720 ) begin
      $strobe("%0d, !!TEST SUCCESS!!", $time);
      `TB_END
      $finish;
    end
  end

`elsif SORT
  
  initial begin
    $display("===== BUBBLE SORT =====\n");
    $dumpfile(" TOP_tb_SORT.vcd ");
    $dumpvars();
  end

  wire [`INST_SIZE - 1 : 0]         tb_inst;
  assign tb_inst = TOP_TB.data_path.IF.inst;

  wire [`WORD - 1 : 0]         tb_w_data;
  assign tb_w_data = TOP_TB.data_path.WB.w_data;

  wire [`WORD - 1 : 0]         tb_w_reg;
  assign tb_w_reg = TOP_TB.data_path.ID.w_reg;

  reg  [`WORD - 1 : 0]         tb_v[4:0];
  integer i;

  always@(negedge tb_clk) begin
    case( tb_inst )
      'hf8400009: begin // v[0]
        assert( tb_w_data == 'h1 && tb_w_reg == 'h9 ) begin
          tb_v[0] <= tb_w_data;
          $strobe("%0d, !!v[0] TEST SUCCESS!!", $time);
        end
        else begin
        $error("tb_w_data = %0d", tb_w_data);
        end
      end
      'hf8408009: begin // v[1]
        assert( tb_w_data == 'h2 && tb_w_reg == 'h9 ) begin
          tb_v[1] <= tb_w_data;
          $strobe("%0d, !!v[1] TEST SUCCESS!!", $time);
        end
        else begin
        $error("tb_w_data = %0d", tb_w_data);
        end
      end
      'hf8410009: begin // v[2]
        assert( tb_w_data == 'h27 && tb_w_reg == 'h9 ) begin
          tb_v[2] <= tb_w_data;
          $strobe("%0d, !!v[2] TEST SUCCESS!!", $time);
        end
        else begin
        $error("tb_w_data = %0d", tb_w_data);
        end
      end
      'hf8418009: begin // v[3]
        assert( tb_w_data == 'h45 && tb_w_reg == 'h9 ) begin
          tb_v[3] <= tb_w_data;
          $strobe("%0d, !!v[3] TEST SUCCESS!!", $time);
        end
        else begin
        $error("tb_w_data = %0d", tb_w_data);
        end
      end
      'hf8420009: begin // v[4]
        assert( tb_w_data == 'h99 && tb_w_reg == 'h9 ) begin
          tb_v[4] <= tb_w_data;
          $strobe("%0d, !!v[4] TEST SUCCESS!!", $time);
        end
        else begin
        $error("tb_w_data = %0d", tb_w_data);
        end        

        // Display result
        #1 $write("tb_v is( HEX format ): ");
        #1;
        for( i = 0; i < 5; i = i + 1 ) begin
          $write("%0h ", tb_v[i]);
        end
        #1 $strobe("");

        `TB_END
        $finish;
      end
    endcase
  end

`elsif SORT_1
  
  initial begin
    $display("===== BUBBLE SORT 1 =====\n");
    $dumpfile(" TOP_tb_SORT_1.vcd ");
    $dumpvars();
  end

  wire [`INST_SIZE - 1 : 0]         tb_inst;
  assign tb_inst = TOP_TB.data_path.IF.inst;

  wire [`WORD - 1 : 0]         tb_w_data;
  assign tb_w_data = TOP_TB.data_path.WB.w_data;

  wire [`WORD - 1 : 0]         tb_w_reg;
  assign tb_w_reg = TOP_TB.data_path.ID.w_reg;

  reg  [`WORD - 1 : 0]         tb_v[8:0];
  integer i;

  always@(negedge tb_clk) begin
    case( tb_inst )
      'hf8400009: begin // v[0]
        assert( tb_w_data == 'h1 && tb_w_reg == 'h9 ) begin
          tb_v[0] <= tb_w_data;
          $strobe("%0d, !!v[0] TEST SUCCESS!!", $time);
        end
        else begin
        $error("tb_w_data = %0d", tb_w_data);
        end
      end
      'hf8408009: begin // v[1]
        assert( tb_w_data == 'h2 && tb_w_reg == 'h9 ) begin
          tb_v[1] <= tb_w_data;
          $strobe("%0d, !!v[1] TEST SUCCESS!!", $time);
        end
        else begin
        $error("tb_w_data = %0d", tb_w_data);
        end
      end
      'hf8410009: begin // v[2]
        assert( tb_w_data == 'h16 && tb_w_reg == 'h9 ) begin
          tb_v[2] <= tb_w_data;
          $strobe("%0d, !!v[2] TEST SUCCESS!!", $time);
        end
        else begin
        $error("tb_w_data = %0d", tb_w_data);
        end
      end
      'hf8418009: begin // v[3]
        assert( tb_w_data == 'h27 && tb_w_reg == 'h9 ) begin
          tb_v[3] <= tb_w_data;
          $strobe("%0d, !!v[3] TEST SUCCESS!!", $time);
        end
        else begin
        $error("tb_w_data = %0d", tb_w_data);
        end
      end
      'hf8420009: begin // v[4]
        assert( tb_w_data == 'h45 && tb_w_reg == 'h9 ) begin
          tb_v[4] <= tb_w_data;
          $strobe("%0d, !!v[4] TEST SUCCESS!!", $time);
        end
        else begin
        $error("tb_w_data = %0d", tb_w_data);
        end        
      end
      'hf8428009: begin // v[5]
        assert( tb_w_data == 'h99 && tb_w_reg == 'h9 ) begin
          tb_v[5] <= tb_w_data;
          $strobe("%0d, !!v[5] TEST SUCCESS!!", $time);
        end
        else begin
        $error("tb_w_data = %0d", tb_w_data);
        end
      end
      'hf8430009: begin // v[6]
        assert( tb_w_data == 'h107 && tb_w_reg == 'h9 ) begin
          tb_v[6] <= tb_w_data;
          $strobe("%0d, !!v[6] TEST SUCCESS!!", $time);
        end
        else begin
        $error("tb_w_data = %0d", tb_w_data);
        end
      end
      'hf8438009: begin // v[7]
        assert( tb_w_data == 'h253 && tb_w_reg == 'h9 ) begin
          tb_v[7] <= tb_w_data;
          $strobe("%0d, !!v[7] TEST SUCCESS!!", $time);
        end
        else begin
        $error("tb_w_data = %0d", tb_w_data);
        end
      end
      'hf8440009: begin // v[8]
        assert( tb_w_data == 'h800 && tb_w_reg == 'h9 ) begin
          tb_v[8] <= tb_w_data;
          $strobe("%0d, !!v[8] TEST SUCCESS!!", $time);
        end
        else begin
        $error("tb_w_data = %0d", tb_w_data);
        end

        // Display result
        #1 $write("tb_v is( HEX format ): ");
        #1;
        for( i = 0; i < 9; i = i + 1 ) begin
          $write("%0h ", tb_v[i]);
        end
        #1 $strobe("");

        `TB_END
        $finish;
      end
    endcase
  end

`endif


endmodule

