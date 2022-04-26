`ifndef COMMON_HEADER
`define COMMON_HEADER

//*******************************
// Definition of data type
//*******************************

// Size of a WORD
`define WORD      64
// Size of a HALF_WORD
`define HALF_WORD 32
// Length of instructions
`define INST_SIZE `HALF_WORD

//*******************************
// Definition of file path
//*******************************

// Factorial
// Instruction memory file test 
`define FACT_INST_FILE "data/factorial/inst_mem.txt"
// Data file
`define FACT_DATA_FILE  "data/factorial/data_mem.txt"

// Pipeline Factorial
// Instruction memory file test
`define PIPELINE_FACT_INST_FILE "data/factorial/pipeline_inst_mem.txt"
// Data file
`define PIPELINE_FACT_DATA_FILE  "data/factorial/pipeline_data_mem.txt"

// Bubble sort test 0
// Instruction memory file
`define SORT_INST_FILE "data/bubble_sort/0/inst_mem.txt"
// Data file
`define SORT_DATA_FILE  "data/bubble_sort/0/data_mem.txt"

// Bubble sort test 1
// Instruction memory file
`define SORT_INST_FILE_1 "data/bubble_sort/1/inst_mem.txt"
// Data file
`define SORT_DATA_FILE_1  "data/bubble_sort/1/data_mem.txt"

// Test
// Instruction memory for test
`define TEST_INST_FILE "data/test/inst_mem.txt"
// Data memory for test
`define TEST_DATA_FILE "data/test/data_mem.txt"

// Instruction memory for pipeline test
`define PIPELINE_TEST_INST_FILE "data/test/pipeline_inst_mem.txt"
// Data memory for test
`define PIPELINE_TEST_DATA_FILE "data/test/pipeline_data_mem.txt"

//*******************************
// Definition of instruction opcode
//*******************************

`define ADD     11'b10001011000
`define ADDI    11'b1001000100?
`define ADDS    11'b10101011000
`define ADDIS   11'b1011000100?
`define AND     11'b10001010000
`define ANDI    11'b1001001000?
`define ANDS    11'b11101010000
`define ANDIS   11'b1111001000?
`define B       11'b000101?????
`define BL      11'b100101?????
`define BR      11'b11010110000
`define BCOND   11'b01010100???
`define CBZ     11'b10110100???
`define CBNZ    11'b10110101???
`define CMPI    11'b1100001110?
`define DIV     11'b10011010110
`define EOR     11'b11001010000
`define EORI    11'b1101001000?
`define LDURS   11'b10111100010
`define STURS   11'b10111100000
`define LDURD   11'b11111100010
`define STURD   11'b11111100000
`define LDA     11'b10010110101
`define LDUR    11'b11111000010
`define LDURB   11'b00111000010
`define LDURH   11'b01111000010
`define LDURSW  11'b10111000100
`define LSL     11'b11010011011
`define LSR     11'b11010011010
`define MOVK    11'b111100101??
`define MOVZ    11'b110100101??
`define MUL     11'b10011011000
`define ORR     11'b10101010000
`define ORRI    11'b1011001000?
`define STUR    11'b11111000000
`define STURB   11'b00111000000
`define STURH   11'b01111000000
`define STURW   11'b10111000000
`define SUB     11'b11001011000
`define SUBI    11'b1101000100?
`define SUBS    11'b11101011000
`define SUBIS   11'b1111000100?

//*******************************
// Conditional branch rt values
//*******************************

`define BCOND_NV  5'b00000 // Always, NV exists only to provide a valid disassembly of the ‘00000b’ encoding, and otherwise behaves identically to AL.
`define BCOND_EQ  5'b00001 // Equal, Z == 1
`define BCOND_NE  5'b00010 // Not equal, Z == 0
`define BCOND_CS  5'b00011 // AKA HS, Unsigned higher or same( Carry set ), C == 1
`define BCOND_LE  5'b00100 // Signed less than or equal, !( Z == 0 && N == V )
`define BCOND_CC  5'b00101 // AKA LO, unsigned lower( Carry clear ), C == 0
`define BCOND_MI  5'b00111 // Minus( negative ), N == 1
`define BCOND_PL  5'b01000 // Plus( positive or zero ), N == 0
`define BCOND_VS  5'b01001 // Overflow set , V == 1
`define BCOND_VC  5'b01010 // Overflow clear, V == 0
`define BCOND_HI  5'b01011 // Unsigned higher, C == 1 && Z == 0
`define BCOND_LS  5'b01100 // Unsigned lower or same, !( C == 1 && Z == 0 )
`define BCOND_GE  5'b01101 // Signed greater than or equal, N == V
`define BCOND_LT  5'b01110 // Signed less than, N != V
`define BCOND_GT  5'b01111 // Signed greater than, Z == 0 && N == V
`define BCOND_AL  5'b11111 // Always

//*******************************
// Conditional branch ops
//*******************************

`define BCOND_OP_NONE    3'b000
`define BCOND_OP_BRANCH  3'b001
`define BCOND_OP_COND    3'b010
`define BCOND_OP_ZERO    3'b011
`define BCOND_OP_NZERO   3'b100
`define BCOND_OP_ALU     3'b101
`define BCOND_OP_NOINC   3'b110

//*******************************
// ALU control signals
//*******************************

`define ALU_AND   4'b0000 
`define ALU_OR    4'b0001 
`define ALU_ADD   4'b0010 
`define ALU_MUL   4'b0011 
`define ALU_SUB   4'b0110
`define ALU_PASS  4'b0111
`define ALU_NOR   4'b1100
`define ALU_XOR   4'b0100
`define ALU_LSL   4'b1000
`define ALU_LSR   4'b1001
`define ALU_NONE  4'b1111

`define TB_BEGIN \
    $display("=== BEGIN TESTBENCH %m ===\n");
    
`define TB_END \
    #`CYCLE $display("\n===== END TESTBENCH %m ===");
    
`define CYCLE 10
`define HALF_CYCLE (`CYCLE/2)

`endif 
