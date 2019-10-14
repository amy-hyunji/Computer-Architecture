module RISCV_TOP (
	//General Signals
	input wire CLK, //every 5 sec
	input wire RSTn, // every 101 sec

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

	// 여기서 I_MEM_CSN, D_MEM_CSN 처리 필요하지 않을까? - control은 그 뒤에 나오니까
	
	wire [31:0] PC, PCOUT, IMM, isJALR_OUT, ALUI_OUT, ALUR_OUT, LOADER_OUT, ALUPC_OUT, ALUIMUX_OUT, BRANCH_OUT;
	wire ALUIMUX, ISBRANCH, BRANCH, ISJALR;
	wire [1:0] REMUX;
	wire [2:0] LFUNCT;
	wire [3:0] ALUI, ALUR;
	wire [11:0] w_I_MEM_ADDR, TEMP;
	assign D_MEM_ADDR = ALUI_OUT[11:0];
	initial I_MEM_ADDR = 0;

	PC pc (
			.CLK(CLK), 
			.RSTn(RSTn),
			._PC(PC),
			._OUT_I_MEM_ADDR(w_I_MEM_ADDR),
			.PC_OUT(PCOUT));
	
	always@ (*) begin
		I_MEM_ADDR = TEMP;
	end

	CONTROL control (
			._Instruction(PC),
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

	ALU aluI (
			.OP(ALUI),
			.A(ALUIMUX_OUT),
			.B(IMM), 
			.Out(ALUI_OUT));

	isJALR isjalr (
			.ISJALR(ISJALR),
			.ALUI_OUTPUT(ALUI_OUT),
			.OUTPUT(isJALR_OUT));
	
	TRANSLATE i_translate (
			.E_ADDR(w_I_MEM_ADDR),
			.WHICH(1'b0),
			.T_ADDR(TEMP));

	TRANSLATE d_translate (
			.E_ADDR(D_MEM_ADDR),
			.WHICH(1'b1),
			.T_ADDR(D_MEM_ADDR));

	ONEBITMUX muxaluI(
			.SIGNAL(ALUIMUX),
			.INPUT1(PCOUT),
			.INPUT2(RF_RD1),
			.OUTPUT(ALUIMUX_OUT));

	ALU aluPC(
		.OP(4'b0000),
		.A(PCOUT),
		.B(32'b00000000000000000000000000000100),
		.Out(ALUPC_OUT));

	ONEBITMUX muxbranch (
		.SIGNAL(ISBRANCH),
		.INPUT1(ALUPC_OUT),
		.INPUT2(isJALR_OUT),
		.OUTPUT(BRANCH_OUT));

	ONEBITMUX muxjump (
		.SIGNAL(ISJUMP),
		.INPUT1(BRANCH_OUT),
		.INPUT2(isJALR_OUT),
		.OUTPUT(PC));

	ALU alur (
		.OP(ALUR),
		.A(RF_RD1),
		.B(RF_RD2),
		.Out(ALUR_OUT));

	LOADER loader (
		.LFUNCT(LFUNCT),
		._D_MEM_DOUT(D_MEM_DOUT),
		.LOADER_OUT(LOADER_OUT));

	TWOBITMUX twobitmux (
		.SIGNAL(REMUX),
		.INPUT1(ALUPC_OUT),
		.INPUT2(ALUI_OUT),
		.INPUT3(LOADER_OUT),
		.INPUT4(ALUR_OUT),
		.OUTPUT(RF_WD));

	isBRANCH isbranch (
		._ALUR_OUT(ALUR_OUT),
		._BRANCH(BRANCH),
		._ISBRANCH(ISBRANCH));

	OUTPUT _output (
		._D_MEM_WEN(D_MEM_WEN),
		._ISBRANCH(ISBRANCH),
		._BRANCH(BRANCH),
		._ALUIOUT(ALUI_OUT),
		._RFWD(RF_WD),
		._OUT_RFWD(RF_WD));	

endmodule //
