`timescale 100ps / 100ps
`define LUI 32'b00000000000000000000000000110111 //LUI
`define AUIPC 32'b00000000000000000000000000010111 // AUIPC

module CON_TB;

reg [31:0] instruction;
reg RSTn;

wire ALUIMUX;
wire [2:0] ALUI;
wire [3:0] ALUR;
wire BRANCH;
wire [1:0] REMUX;
wire [2:0] LFUNCT;
wire I_MEM_CSN;
wire D_MEM_CSN;
wire D_MEM_WEN;
wire [3:0] D_MEM_BE;
wire RF_WE;
wire [4:0] RF_RA1;
wire [4:0] RF_RA2;
wire [4:0] RF_WA1;
wire [31:0] IMM;
wire HALT;

controller controller(
    ._Instruction(instruction),
    ._RSTn(RSTn),
    ._ALUIMUX(ALUIMUX),
    ._ALUI(ALUI),
    ._ALUR(ALUR),
    ._BRANCH(BRANCH),
    ._REMUX(REMUX),
    ._LFUNCT(LFUNCT),
    ._I_MEM_CSN(I_MEM_CSN),
    ._D_MEM_CSN(D_MEM_CSN),
    ._D_MEM_WEN(D_MEM_WEN),
    ._D_MEM_BE(D_MEM_BE),
    ._RF_WE(RF_WE),
    ._RF_RA1(RF_RA1),
    ._RF_RA2(RF_RA2),
    ._RF_WA1(RF_WA1),
    ._IMM(IMM),
    ._HALT(HALT));

initial begin
    RSTn = 1;
    $finish;
end

task LUITEST;
    begin
        instruction = LUI; 
        #1;
        $display("ALUIMUX : %0b", ALUIMUX);`
