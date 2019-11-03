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
	output wire HALT,
	output reg [31:0] NUM_INST,
	output wire [31:0] OUTPUT_PORT
	);

	// TODO: implement multi-cycle CPU
	assign OUTPUT_PORT = RF_WD;

	wire ZERO, MUX1, MUX4, ALU_WR, PC_WR, PC_WRITE_COND, IR_WR, REWR_MUX;
	wire [31:0] IMMEDIATE, PC_IN, PC_OUT, A_OUT, B_OUT, MUX1_OUT, ALU_D, ALUOUT_D, MUX2_OUT, _NUM_INST;
	wire [11:0] TEMP;
	wire [10:0] ALU_CONTROL;
	wire [6:0] OPCODE, FUNCT7;
	wire [4:0] OP;
	wire [2:0] FUNCT3;
	wire [1:0] MUX2;

	assign D_MEM_DOUT = B_OUT; 

	always@ (posedge CLK) begin
		I_MEM_ADDR <= TEMP;
        NUM_INST <= _NUM_INST;
        if (RSTn) begin
            $display("NUM_INST : %d", NUM_INST);
            $display("REWR_MUX : %d", REWR_MUX);
            $display("MUX1_OUT : %d", MUX1_OUT);
            $display("MUX2_OUT : %d", MUX2_OUT);
            $display("MUX2 control sig : %d", MUX2);

            $display("ALUOUT_D : %d", ALUOUT_D);
            $display("ALU_D : %d", ALU_D);
            $display("--------------------");
        end

	end

	INSTREG instreg (
			.CLK(CLK),
			.INSTRUCTION(I_MEM_DI),
			.OPCODE(OPCODE),
			.IMMEDIATE(IMMEDIATE),
            .IRWRITE(IR_WR),
			.RS1(RF_RA1),
			.RS2(RF_RA2),
			.FUNCT3(FUNCT3),
			.FUNCT7(FUNCT7),
			.RD(RF_WA1));
	

	CONTROL control (
			.OPCODE(OPCODE),
			.RSTn(RSTn),
			.CLK(CLK),
			._MUX1(MUX1),
			._MUX4(MUX4),
			._ALU_WR(ALU_WR),
			._PC_WR(PC_WR),
			._RF_WE(RF_WE),
			._PC_WRITE_COND(PC_WRITE_COND),
			._IR_WR(IR_WR),
			._D_MEM_WEN(D_MEM_WEN),
			._REWR_MUX(REWR_MUX),
			._I_MEM_CSN(I_MEM_CSN),
			._D_MEM_CSN(D_MEM_CSN),
			._D_MEM_BE(D_MEM_BE),
			._MUX2(MUX2),
			._ALU_CONTROL(ALU_CONTROL),
            .NUM_INST(_NUM_INST)
			);

	HALT halt (
		._Instruction(I_MEM_DI),
		._RF_RD1(RF_RD1),
		._halt(HALT));

	CONTROLREG pc (
			.CLK(CLK),
			.WREN((ZERO & PC_WRITE_COND) | PC_WR),
            .RSTn(RSTn),
			.IN_VAL(PC_IN),
			.OUT_VAL(PC_OUT));

	CONTROLREG aluout (
			.CLK(CLK),
			.WREN(ALU_WR),
            .RSTn(RSTn),
			.IN_VAL(ALU_D),
			.OUT_VAL(ALUOUT_D));

	REG A (
			.CLK(CLK),
			.IN_VAL(RF_RD1),
			.OUT_VAL(A_OUT));

	REG B (
			.CLK(CLK),
			.IN_VAL(RF_RD2),
			.OUT_VAL(B_OUT));

	TRANSLATE i_translate (
		.E_ADDR(PC_OUT),
		.T_ADDR(TEMP));

	TRANSLATE d_translate (
		.E_ADDR(ALUOUT_D),
		.T_ADDR(D_MEM_ADDR));

	ONEBITMUX mux1 (
			.SIGNAL(MUX1),
			.INPUT1(PC_OUT),
			.INPUT2(A_OUT),
			.OUTPUT(MUX1_OUT));

	ONEBITMUX mux4 (
			.SIGNAL(MUX4),
			.INPUT1(ALU_D),
			.INPUT2(ALUOUT_D),
			.OUTPUT(PC_IN));

	ONEBITMUX MREWR_MUX (
			.SIGNAL(REWR_MUX),
			.INPUT1(ALUOUT_D),
			.INPUT2(D_MEM_DI),
			.OUTPUT(RF_WD));

	TWOBITMUX mux2(
			.SIGNAL(MUX2),
			.INPUT1(4),
			.INPUT2(B_OUT),
			.INPUT3(IMMEDIATE),
			.INPUT4(0),
			.OUTPUT(MUX2_OUT)
			);

	ALU alu (
		.OP(OP),
		.A(MUX1_OUT),
		.B(MUX2_OUT),
		.Out(ALU_D),
		.Zero(ZERO));

	ALUCONTROL alucontrol (
		.ALU_CONTROL(ALU_CONTROL),
		.FUNCT3(FUNCT3),
		.FUNCT7(FUNCT7),
		.CONTROLOUT(OP));
	
endmodule //
