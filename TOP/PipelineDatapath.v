`timescale 1ns/1ps

//******************************************************************
//
//*@File Name: PipelineDatapath.v
//*@File Type: verilog
//*@Version  : 0.0
//*@Author   : Zehua Dong, SIGS
//*@E-mail   : 1285507636@qq.com
//*@Date     : 2022/4/22 16:51:15
//*@Function : LEGv8 pipeline CPU datapath.
//
//*@V0.0     : Initial.
//
//******************************************************************

//
// Header file
`include "common.vh"

//
// Module

module PipelineDatapath( 
  clk       ,            
  rst_n     ,        
  RegWrite  ,
  Reg2Loc   ,
  WRegLoc   ,
  ALUOp     ,
  ALUSrc    ,
  BranchOp  ,      // Output from control unit for PCSrc, 3 bits
  SregUp    ,
  MemtoReg  ,
  MemRead   ,
  MemWrite  ,
  inst      ,    
  r_data    ,
  pc        ,
  ALUOut    ,
  o_MemRead ,
  o_MemWrite,
  o_opcode  ,
  MemData       // Data to be written into data memory
  );

  //===========================================================
  //* Input and output ports
  //===========================================================
  //
  input                           clk       ;               
  input                           rst_n     ;
  input                           RegWrite  ;
  input                           Reg2Loc   ;
  input                           WRegLoc   ;
  input    [01: 0]                ALUOp     ;
  input                           ALUSrc    ;
  input    [02: 0]                BranchOp  ;
  input                           SregUp    ;                  
  input    [01: 0]                MemtoReg  ;
  input                           MemWrite  ;            
  input                           MemRead   ;            
  input    [`INST_SIZE - 1 : 0]   inst      ;
  input    [`WORD - 1 : 0]        r_data    ;
  output   [`WORD - 1 : 0]        pc        ;
  output   [`WORD - 1 : 0]        ALUOut    ;
  output                          o_MemWrite;            
  output                          o_MemRead ;  
  output   [10:0]                 o_opcode  ;
  output   [`WORD - 1 : 0]        MemData   ;

  wire                            clk       ;               
  wire                            rst_n     ;  
  wire                            RegWrite  ;
  wire                            Reg2Loc   ;
  wire                            WRegLoc   ;
  wire     [01: 0]                ALUOp     ;
  wire                            ALUSrc    ;
  wire     [02: 0]                BranchOp  ;
  wire                            SregUp    ;                  
  wire     [01: 0]                MemtoReg  ;
  wire                            MemWrite  ;            
  wire                            MemRead   ;            
  wire     [`INST_SIZE - 1 : 0]   inst      ;
  wire     [`WORD - 1 : 0]        r_data    ;
  wire     [`WORD - 1 : 0]        pc        ;
  wire     [`WORD - 1 : 0]        ALUOut    ;
  wire                            o_MemWrite;            
  wire                            o_MemRead ;  
  wire     [10:0]                 o_opcode  ;
  wire     [`WORD - 1 : 0]        MemData   ;

  //===========================================================
  //* Internal signals
  //===========================================================
  //
  // Pipeline registers
  // Instantiate through dff module
  //         96bits =  [63:0] PC + [31:0] instruction, no control signals
  localparam IF_ID_REG_SIZE = 96,  
             // 301bits = [12:0] control signals + [63:0] reg read data 1 + 
             // [63:0] reg read data 2 + [63:0] sign extented + [63:0] PC + [31:0] instruction
             ID_EX_REG_SIZE = 301, 
             // 297bits = [08:0] control signals + [63:0] ALU_res + [63:0] ALUOut +
             // [63:0] reg read 2 + [63:0] PC + [31:0] instruction
             EX_MEM_REG_SIZE = 297,
             // 292bits = [03:0] control signals + [63:0] ALUOut + [63:0] register read data2( for MOVK ) +  
             // [63:0] Mem read data  + [63:0] PC + [31:0] instruction
             MEM_WB_REG_SIZE = 292;

  // Control signal size
             // 13 bits control signals = ( ALUSrc + [01:0] ALUOp + SregUp ) + 
             // ( [02:0] BranchOp + MemRead + MemWrite ) + ( RegWrite + WRegLoc + [01:0] MemtoReg )
  localparam ID_EX_CON_SIZE  = 13,
             // 9 bits control signals = ( [02:0] BranchOp + MemRead + MemWrite ) +
             // ( RegWrite + WRegLoc + [01:0] MemtoReg )
             EX_MEM_CON_SIZE = 9,
             // 4bits control signals = ( RegWrite + WRegLoc + [01:0] MemtoReg )
             MEM_WB_CON_SIZE = 4;

  wire     [IF_ID_REG_SIZE  - 1 : 0]   IF_ID_reg ;
  wire     [ID_EX_REG_SIZE  - 1 : 0]   ID_EX_reg ;
  wire     [EX_MEM_REG_SIZE - 1 : 0]   EX_MEM_reg;
  wire     [MEM_WB_REG_SIZE - 1 : 0]   MEM_WB_reg;

  wire     [IF_ID_REG_SIZE  - 1 : 0]   IF_ID_tmp ;
  wire     [ID_EX_REG_SIZE  - 1 : 0]   ID_EX_tmp ;
  wire     [EX_MEM_REG_SIZE - 1 : 0]   EX_MEM_tmp;
  wire     [MEM_WB_REG_SIZE - 1 : 0]   MEM_WB_tmp;

  
  // Internal signals from IF to ID
  wire     [`INST_SIZE - 1 : 0]        IF_ID_inst; 
  wire     [`WORD - 1 : 0]             IF_ID_pc  ; 

  wire     [`WORD - 1 : 0]             IF_pc_incr;

  // Internal signals from ID to EX
  wire     [ID_EX_CON_SIZE - 1 : 0]    ID_EX_Control_tmp; 

  wire     [`INST_SIZE - 1 : 0]        ID_EX_inst   ; 
  wire     [`WORD - 1 : 0]             ID_EX_pc     ; 
  wire     [`WORD - 1 : 0]             ID_EX_ex_data; 
  wire     [`WORD - 1 : 0]             ID_EX_r_data2; 
  wire     [`WORD - 1 : 0]             ID_EX_r_data1; 
  wire     [ID_EX_CON_SIZE - 1 : 0]    ID_EX_Control; 

  wire                                 ID_EX_ALUSrc ;
  wire     [1:0]                       ID_EX_ALUOp  ;
  wire                                 ID_EX_SregUp ;

  wire     [`WORD - 1 : 0]             ID_r_data1   ;
  wire     [`WORD - 1 : 0]             ID_r_data2   ;
  wire     [`WORD - 1 : 0]             ID_ex_data   ;
  wire     [4:0]                       ID_w_reg     ;

  // Internal signals from EX to MEM
  wire     [EX_MEM_CON_SIZE - 1 : 0]   EX_MEM_Control_tmp;

  wire     [`INST_SIZE - 1 : 0]        EX_MEM_inst    ; 
  wire     [`WORD - 1 : 0]             EX_MEM_pc      ; 
  wire     [`WORD - 1 : 0]             EX_MEM_r_data2 ; // Read data 2 from register
  wire     [`WORD - 1 : 0]             EX_MEM_ALUOut  ; 
  wire     [`WORD - 1 : 0]             EX_MEM_ALU_res ; 
  wire     [ID_EX_CON_SIZE - 1 : 0]    EX_MEM_Control ; 

  wire     [2:0]                       EX_MEM_BranchOp;
  wire                                 EX_MEM_MemRead ;
  wire                                 EX_MEM_MemWrite;
  wire                                 EX_MEM_N       ;
  wire                                 EX_MEM_Z       ;
  wire                                 EX_MEM_V       ;
  wire                                 EX_MEM_C       ;

  wire     [`WORD - 1 : 0]             EX_ALUOut ; 
  wire     [`WORD - 1 : 0]             EX_ALU_res; 

  wire                                 EX_N      ;
  wire                                 EX_Z      ;
  wire                                 EX_V      ;
  wire                                 EX_C      ;

  // Internal signals from MEM to WB
  wire     [MEM_WB_CON_SIZE - 1 : 0]   MEM_WB_Control_tmp;

  wire     [`INST_SIZE - 1 : 0]        MEM_WB_inst    ; 
  wire     [`WORD - 1 : 0]             MEM_WB_pc      ; 
  wire     [`WORD - 1 : 0]             MEM_WB_r_data  ; // Read data from memory
  wire     [`WORD - 1 : 0]             MEM_WB_r_data2 ; // Read data 2 from register
  wire     [`WORD - 1 : 0]             MEM_WB_ALUOut  ; 
  wire     [MEM_WB_CON_SIZE - 1 : 0]   MEM_WB_Control ; 

  wire     [`WORD - 1 : 0]             MEM_WB_w_data  ; 
  wire                                 MEM_WB_RegWrite;
  wire                                 MEM_WB_WRegLoc ;
  wire     [1:0]                       MEM_WB_MemtoReg;

  wire     [1:0]                       MEM_PCSrc      ;
  wire     [`WORD - 1 : 0]             MEM_r_data     ;

  //
  // Instruction fetch
  IF IF( 
  .clk    ( clk              ) ,             
  .rst_n  ( rst_n            ) , 
  .ALU_res( EX_MEM_ALU_res   ) ,    // Result of ADD ALU in EX, i.e. address of branch     
  .ALUOut ( EX_MEM_ALUOut    ) ,    // Result of ALU in EX
  .PCSrc  ( MEM_PCSrc        ) ,    // Control signal of PCSrc 
  .pc     ( pc               ) ,    // Current PC
  .pc_incr( IF_pc_incr       )      // Current PC + 4
  );

  // IF ID
  assign IF_ID_tmp = {pc, inst};

  dff #( 
  .SIZE ( IF_ID_REG_SIZE  )  ) dff_IF_ID_reg(
  .clk  ( clk         )  ,              
  .rst_n( rst_n       )  ,    
  .D    ( IF_ID_tmp   )  ,           
  .Q    ( IF_ID_reg   )             
  );

  assign IF_ID_inst = IF_ID_reg[31:00];
  assign IF_ID_pc   = IF_ID_reg[95:32];

  assign o_opcode   = IF_ID_inst[31:21];

  //
  // Instruction decode

  ID ID( 
  .clk     ( clk             ) ,            
  .rst_n   ( rst_n           ) ,        
  .inst    ( IF_ID_inst      ) ,       // Input instruction to be decoded
  .RegWrite( MEM_WB_RegWrite ) ,       // Flag of writing to register file 
  .Reg2Loc ( Reg2Loc         ) ,       // Flag of judging register file 2nd source register
  .WRegLoc ( MEM_WB_WRegLoc  ) ,       // Flag of judging register file write register
  .w_reg   ( ID_w_reg        ) ,       // Register to be written
  .w_data  ( MEM_WB_w_data   ) ,       // Data to be written
  .r_data1 ( ID_r_data1      ) ,       // Read data 1 from register file
  .r_data2 ( ID_r_data2      ) ,       // Read data 2 from register file
  .ex_data ( ID_ex_data      )         // Extend data
  );

  // ID EX
  assign ID_EX_Control_tmp = {ALUSrc, ALUOp, SregUp, BranchOp, MemRead, MemWrite, RegWrite, WRegLoc, MemtoReg};
  assign ID_EX_tmp = {ID_EX_Control_tmp, ID_r_data1, ID_r_data2, ID_ex_data, IF_ID_pc, IF_ID_inst};

  dff #( 
  .SIZE ( ID_EX_REG_SIZE  )  ) dff_ID_EX_reg(
  .clk  ( clk         )  ,              
  .rst_n( rst_n       )  ,    
  .D    ( ID_EX_tmp   )  ,           
  .Q    ( ID_EX_reg   )             
  );

  assign ID_EX_inst      = ID_EX_reg[000+:32];
  assign ID_EX_pc        = ID_EX_reg[032+:64];
  assign ID_EX_ex_data   = ID_EX_reg[096+:64];
  assign ID_EX_r_data2   = ID_EX_reg[160+:64];
  assign ID_EX_r_data1   = ID_EX_reg[224+:64];
  assign ID_EX_Control   = ID_EX_reg[288+:ID_EX_CON_SIZE];

  assign ID_EX_ALUSrc = ID_EX_Control[(ID_EX_CON_SIZE-1)];
  assign ID_EX_ALUOp  = ID_EX_Control[(ID_EX_CON_SIZE-2)-:2];
  assign ID_EX_SregUp = ID_EX_Control[(ID_EX_CON_SIZE-4)-:1];
  
  // 
  // Excute

  EX EX(
  .clk      ( clk       )    ,           
  .rst_n    ( rst_n     )    ,       
  .r_data1  ( ID_EX_r_data1   )    ,      // Read data 1 from register file      
  .r_data2  ( ID_EX_r_data2   )    ,      // Read data 2 from register file
  .ex_data  ( ID_EX_ex_data   )    ,      // Extend data from sign extend
  .inst     ( ID_EX_inst      )    ,      // Instruction for ALU control signal
  .ALUOp    ( ID_EX_ALUOp     )    ,      // Output from control unit for ALU control signal
  .ALUSrc   ( ID_EX_ALUSrc    )    ,      // Output from control unit for ALU source data 
  .SregUp   ( ID_EX_SregUp    )    ,      // Output from control unit for status register
  .pc       ( ID_EX_pc        )    ,      // Program counter for branch address
  .ALUOut   ( EX_ALUOut       )    ,      // Output result from ALU
  .ALU_res  ( EX_ALU_res      )    ,      // Address for branch from ADD ALU
  .N        ( EX_N            )    ,      // Negative
  .Z        ( EX_Z            )    ,      // Zero
  .C        ( EX_C            )    ,      // Carry
  .V        ( EX_V            )           // oVerflow
  );

  // EX MEM
  // Pipeline rest control signals
  assign EX_MEM_Control_tmp = ID_EX_Control[EX_MEM_CON_SIZE - 1 : 0];
  assign EX_MEM_tmp = {EX_MEM_Control_tmp, EX_ALU_res, EX_ALUOut, ID_EX_r_data2, ID_EX_pc, ID_EX_inst};

  dff #( 
  .SIZE ( EX_MEM_REG_SIZE  )  ) dff_EX_MEM_reg(
  .clk  ( clk         )  ,              
  .rst_n( rst_n       )  ,    
  .D    ( EX_MEM_tmp  )  ,           
  .Q    ( EX_MEM_reg  )             
  );

  assign EX_MEM_inst      = EX_MEM_reg[000+:32];
  assign EX_MEM_pc        = EX_MEM_reg[032+:64];
  assign EX_MEM_r_data2   = EX_MEM_reg[096+:64]; 
  assign EX_MEM_ALUOut    = EX_MEM_reg[160+:64];
  assign EX_MEM_ALU_res   = EX_MEM_reg[224+:64];
  assign EX_MEM_Control   = EX_MEM_reg[288+:EX_MEM_CON_SIZE];

  assign EX_MEM_BranchOp  = EX_MEM_Control[(EX_MEM_CON_SIZE - 1) -: 3];
  assign EX_MEM_MemRead   = EX_MEM_Control[(EX_MEM_CON_SIZE - 4)];
  assign EX_MEM_MemWrite  = EX_MEM_Control[(EX_MEM_CON_SIZE - 5)];

  assign o_MemRead        = EX_MEM_MemRead ;
  assign o_MemWrite       = EX_MEM_MemWrite;

  // N Z V C is status register output, so we dont need to pipeline them
  assign EX_MEM_N = EX_N;
  assign EX_MEM_Z = EX_Z;
  assign EX_MEM_V = EX_V;
  assign EX_MEM_C = EX_C;

  //
  // Memory

  // Data to be written into memory
  assign MemData = EX_MEM_r_data2;
  // Data address to be written into memory
  assign ALUOut  = EX_MEM_ALUOut;
  // Data read from memory in MEM stage
  assign MEM_r_data = r_data;

  br_control MEM(
  .BranchOp   ( EX_MEM_BranchOp  )  ,    // 3 bits branch operation code from control unit
  .ConBr_type ( EX_MEM_inst[4:0] )  ,    // 5 bits conditional branch type of insturction( i.e. rt register of B.cond ) 
  .Zero       ( EX_MEM_Z         )  ,    // Zero flag from ALU
  .Negative   ( EX_MEM_N         )  ,    // Negative flag from ALU
  .Overflow   ( EX_MEM_V         )  ,    // Overflow flag from ALU
  .Co         ( EX_MEM_C         )  ,    // Carry out flag from ALU
  .PCSrc      ( MEM_PCSrc        )       // 2 bits output flag for PC source
  );

  // MEM WB
  assign MEM_WB_Control_tmp = EX_MEM_Control[MEM_WB_CON_SIZE - 1 : 0];
  assign MEM_WB_tmp = {MEM_WB_Control_tmp, EX_MEM_ALUOut, EX_MEM_r_data2, MEM_r_data, EX_MEM_pc, EX_MEM_inst};

  dff #( 
  .SIZE ( MEM_WB_REG_SIZE  )  ) dff_MEM_WB_reg(
  .clk  ( clk         )  ,              
  .rst_n( rst_n       )  ,    
  .D    ( MEM_WB_tmp  )  ,           
  .Q    ( MEM_WB_reg  )             
  );

  assign MEM_WB_inst      = MEM_WB_reg[000+:32];
  assign MEM_WB_pc        = MEM_WB_reg[032+:64] + 'd4; 
  assign MEM_WB_r_data    = MEM_WB_reg[096+:64]; // Data read from memory
  assign MEM_WB_r_data2   = MEM_WB_reg[160+:64]; // Data read from register file, for MOVK
  assign MEM_WB_ALUOut    = MEM_WB_reg[224+:64];
  assign MEM_WB_Control   = MEM_WB_reg[288+:MEM_WB_CON_SIZE];

  assign MEM_WB_RegWrite  = MEM_WB_Control[(MEM_WB_CON_SIZE - 1)];
  assign MEM_WB_WRegLoc   = MEM_WB_Control[(MEM_WB_CON_SIZE - 2)];
  assign MEM_WB_MemtoReg  = MEM_WB_Control[(MEM_WB_CON_SIZE - 3) -: 2];

  //
  // Write back

  write_back WB(
  .ALUOut  ( MEM_WB_ALUOut   ) ,       // ALU output result in EX       
  .r_data  ( MEM_WB_r_data   ) ,       // Data read from MEM  
  .pc_incr ( MEM_WB_pc       ) ,       // PC + 4
  .r_data2 ( MEM_WB_r_data2  ) ,       // Data read from register file, for MOVK
  .MemtoReg( MEM_WB_MemtoReg ) ,       // Memory to register signal from control unit
  .inst    ( MEM_WB_inst     ) ,       // Instruction to obtain opcode
  .w_data  ( MEM_WB_w_data   )         // Write data to be written back
  );

  assign ID_w_reg = MEM_WB_inst[4:0];

endmodule
  
