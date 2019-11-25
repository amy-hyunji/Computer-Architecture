module RISCV_TOP (
	//General Signals
	input wire CLK,
	input wire RSTn,

	//I-Memory Signals
	output wire I_MEM_CSN,
	input wire [31:0] I_MEM_DI,//input from IM
	output reg [11:0] I_MEM_ADDR,//in byte address

	//D-Memory Signals
	output wire D_MEM_CSN,
	input wire [31:0] D_MEM_DI,
	output wire [31:0] D_MEM_DOUT,
	output wire [11:0] D_MEM_ADDR,//in word address
	output wire D_MEM_WEN,
	output wire [3:0] D_MEM_BE,

	//RegFile Signals
	output wire RF_WE,
	output wire [4:0] RF_RA1,
	output wire [4:0] RF_RA2,
	output wire [4:0] RF_WA1,
	input wire [31:0] RF_RD1,
	input wire [31:0] RF_RD2,
	output wire [31:0] RF_WD,
	output wire HALT,                   // if set, terminate program
	output reg [31:0] NUM_INST,         // number of instruction completed
	output wire [31:0] OUTPUT_PORT      // equal RF_WD this port is used for test
	);

	assign OUTPUT_PORT = RF_WD;

	initial begin
		NUM_INST <= 0;
	end

	// Only allow for NUM_INST
	always @ (negedge CLK) begin
		if (RSTn) NUM_INST <= NUM_INST + 1;
	end

	// TODO: implement

	wire [31:0] PC_IN, PC_OUT, IMM_IN, IMM_OUT, Be_OUT, ALU_D, BMUX_OUT, CUR_INST, CONDALU_OUT, nPC_IN, ALUOUT_D, MDRw_OUT, Aout_IN, Aout_OUT, WD_IN, PCm_OUT, Ae_OUT, AMUX_OUT, PCr_IN, PCr_OUT, CONDMUX_OUT, PCALU_OUT, nPC_OUT, Ae_IN, Be_IN, PCm_IN, PCm_OUT, BM_IN, MDRw_IN, MDRw_OUT;
	wire [11:0] I_TEMP;
	wire [6:0] OPCODE, ALUCONTROL_IN, FUNCT7;
	wire [4:0] PREV_DEST; 
	wire [3:0] ALUCONTROL_OUT;
	wire [2:0] FUNCT3;
	wire [1:0] BMUX;
	wire ISJALR, REWR_MUX, AMUX, CONDMUX, IR_WR, PC_WR, PREV_REWR_MUX, ZERO;
	
	initial begin
		I_MEM_ADDR = 0;
	end

	always@ (I_TEMP) begin
		assign I_MEM_ADDR = I_TEMP;
	end

	CONTROL control (
		.OPCODE(OPCODE),
		.RSTn(RSTn),
		.CLK(CLK),
		.RD1(RF_RA1),
		.RD2(RF_RA2),
		.PREV_DEST(PREV_DEST), //previous instruction WD
		.PREV_REWR_MUX(PREV_REWR_MUX),
		.D_MEM_BE(D_MEM_BE),
		.RF_WE(RF_WE),
		.D_MEM_WEN(D_MEM_WEN),
		.D_MEM_CSN(D_MEM_CSN),
		.I_MEM_CSN(I_MEM_CSN),
		.REWR_MUX(REWR_MUX),
		.AMUX(AMUX),
		.ISJALR(ISJALR),
		.CONDMUX(CONDMUX),
		.ALU_CONTROL(ALUCONTROL_IN),
		.BMUX(BMUX),
		.IR_WR(IR_WR),
		.PC_WR(PC_WR)
	);

	CONTROLREG pc (
		.CLK(CLK),
		.WREN(PC_WR),
		.RSTn(RSTn),
		.IN_VAL(PC_IN),
		.OUT_VAL(PC_OUT)
	);

	ALUCONTROL alucontrol(
		.ALUCONTROL(ALUCONTROL_IN),
		.FUNCT3(FUNCT3),
		.FUNCT7(FUNCT7),
		.CONTROLOUT(ALUCONTROL_OUT)
	);

	isJALR isjalr (
		.ISJALR(ISJALR),
		.ALUI_OUTPUT(CONDALU_OUT),
		.OUTPUT(nPC_IN)
	);

	HALT halt (
		.CUR_INST(CUR_INST),
		.NXT_INST(I_MEM_DI),
		._halt(HALT)
	);

	TRANSLATE i_translate(
		.E_ADDR(PC_OUT),
		.T_ADDR(I_TEMP)
	);
	
	TRANSLATE d_translate(
		.E_ADDR(ALUOUT_D),
		.T_ADDR(D_MEM_ADDR)
	);

	///MUX///////////////////////
	ONEBITMUX MREWR_MUX(
		.SIGNAL(REWR_MUX),
		.INPUT1(MDRw_OUT),
		.INPUT2(Aout_OUT),
		.OUTPUT(WD_IN)
	);

	ONEBITMUX MAMUX(
		.SIGNAL(AMUX),
		.INPUT1(PCm_OUT),
		.INPUT2(Ae_OUT),
		.OUTPUT(AMUX_OUT)
	);

	TWOBITMUX MBMUX(
		.SIGNAL(BMUX),
		.INPUT1(IMM_OUT),
		.INPUT2(32'b00000000000000000000000000000100),
		.INPUT3(32'b00000000000000000000000000000000),
		.INPUT4(Be_OUT),
		.OUTPUT(BMUX_OUT)
	};

	ONEBITMUX MCONDMUX(
		.SIGNAL(CONDMUX),
		.INPUT1(PCr_OUT),
		.INPUT2(RF_RA2),
		.OUTPUT(CONDMUX_OUT)
	);

	ONEBITMUX MPCMUX(
		.SIGNAL(PC_WR),
		.INPUT1(PCALU_OUT),
		.INPUT2(nPC_OUT),
		.OUTPUT(PC_IN)
	);
	/////////////////////////////


	///ALU///////////////////////
	ALU CONDALU(
		.OP(4'b0000),
		.A(CONDMUX_OUT),
		.B(IMM_IN),
		.Out(CONDALU_OUT)
	);

	ALU REGALU(
		.OP(ALUCONTROL_OUT),
		.A(AMUX_OUT),
		.B(BMUX_OUT),
		.Out(ALU_D)
	);

	ALU PCALU(
		.OP(4'b0000),
		.A(PC_OUT),
		.B(32'b00000000000000000000000000000100),
		.Out(PCALU_OUT)
	);

	EQUAL equal(
		.OP(ALUCONTROL_OUT),
		.A(Ae_IN),
		.B(Be_IN),
		.Out(ZERO)
	);
	/////////////////////////////

	//IF/ID pipeline registers//
	REG PCr (
		.CLK(CLK),
		.IN_VAL(PCr_IN),
		.OUT_VAL(PCr_OUT)
	);

	INSTREG instreg (
		.CLK(CLK),
		.INSTRUCTION(I_MEM_DI),
		.IRWRITE(IR_WR),
		.OPCODE(OPCODE),
		.IMMEDIATE(IMM_IN),
		.RS1(RF_RA1),
		.RS2(RF_RA2),
		.FUNCT3(FUNCT3),
		.FUNCT7(FUNCT7),
		.RD(RF_WA1),
		.CUR_INST(CUR_INST)
	);
	/////////////////////////////
	
	//ID/EX pipeline registers//
	REG nPC(
		.CLK(CLK),
		.IN_VAL(nPC_IN),
		.OUT_VAL(nPC_OUT)
	);

	REG imm (
		.CLK(CLK),
		.IN_VAL(IMM_IN),
		.OUT_VAL(IMM_OUT)
	);

	REG PCm(
		.CLK(CLK),
		.IN_VAL(PCm_IN),
		.OUT_VAL(PCm_OUT)
	);

	REG Ae(
		.CLK(CLK),
		.IN_VAL(Ae_IN),
		.OUT_VAL(Ae_OUT)
	);

	REG Be(
		.CLK(CLK),
		.IN_VAL(Be_IN),
		.OUT_VAL(Be_OUT)
	);
	/////////////////////////////
	
	//EX/MEM pipeline registers//
	REG aluout (
		.CLK(CLK),
		.IN_VAL(ALU_D),
		.OUT_VAL(ALUOUT_D)
	);

	REG Bm (
		.CLK(CLK),
		.IN_VAL(BM_IN),
		.OUT_VAL(D_MEM_DOUT)
	);
	/////////////////////////////

	//MEM_WB pipeline registers//
	REG MDRw (
		.CLK(CLK),
		.IN_VAL(MDRw_IN),
		.OUT_VAL(MDRw_OUT)
	);

	REG Aout (
		.CLK(CLK),
		.IN_VAL(Aout_IN),
		.OUT_VAL(Aout_OUT)
	);
	/////////////////////////////


endmodule //
