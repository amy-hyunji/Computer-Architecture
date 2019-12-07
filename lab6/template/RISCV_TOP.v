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


	// TODO: implement

	wire [31:0] PC_IN, PC_OUT, IMM_IN, IMM_OUT, Be_OUT, ALU_D, BMUX_OUT, CUR_INST, CONDALU_OUT, nPC_IN, ALUOUT_D, Aout_IN, Aout_OUT, Ae_OUT, AMUX_OUT, PCr_OUT, CONDMUX_OUT, PCALU_OUT, PCm_OUT, MDRw_OUT, ADDR_OUT, FMUX1OUT, FMUX2OUT;
    wire [31:0] ZERO_EX_MEM, ZERO_MEM_WB, ZERO_WB_OUT, RDFORMUXOUT;
	wire [11:0] I_TEMP;
	wire [6:0] OPCODE, ALUCONTROL_IN, FUNCT7;
	wire [3:0] ALUCONTROL_OUT, ALUCONTROL_EX_OUT; 
	wire [2:0] FUNCT3;
	wire [1:0] BMUX_EX_IN, BMUX_EX_OUT;
	wire ISJALR, AMUX_EX_IN, AMUX_EX_OUT, CONDMUX, IR_WR, PC_WR, PREV_REWR_MUX, ZERO, FLUSH;
    wire RF_WE_ID_EX_IN, RF_WE_EX_MEM_IN, RF_WE_MEM_WB_IN;
    wire RDMUX_ID_EX_IN, RDMUX_EX_MEM_IN, RDFORMUXSIG;
    wire [1:0] MREWR_MUX_ID_EX_IN, MREWR_MUX_EX_MEM_IN, MREWR_MUX_MEM_WB_IN, MREWR_MUX_SIG;
    wire [4:0] RS1EX, RS2EX, RDID, RDEX, RDMEM, RDWB;
    wire [1:0] FORWARDMUX1, FORWARDMUX2;
    wire NUMINSTADD, NUMINSTADD_ID_EX_IN, NUMINSTADD_EX_MEM_IN, NUMINSTADD_MEM_WB_IN, PCMUX, USE_RS1_IN, USE_RS2_IN, USE_RS1_OUT, USE_RS2_OUT;
    wire HALT_ID_EX_IN, HALT_EX_MEM_IN, HALT_MEM_WB_IN;

	 //FOR CACHE//
	 wire [31:0] C_MEM_DI, C_MEM_DOUT;
	 wire C_MEM_WEN, C_MEM_REN, CACHE_STALL;
	 wire [11:0] C_MEM_ADDR;
	 wire C_MEM_REN_ID_EX_IN, C_MEM_REN_EX_MEM_IN;
    wire C_MEM_WEN_ID_EX_IN, C_MEM_WEN_EX_MEM_IN;
	 wire C_MEM_CSN_ID_EX_IN, C_MEM_CSN_EX_MEM_IN, C_MEM_CSN;
 
    reg [31:0] cnt;
    assign RF_WA1 = RDWB;
	 assign OUTPUT_PORT = RF_WD;

	 initial begin
		NUM_INST <= 0;
	 end

	 always@ (posedge CLK) begin
		$display("numinst is %d", NUM_INST);
	 end

	 	// Only allow for NUM_INST
	always @ (negedge CLK) begin
		if (RSTn) NUM_INST = NUM_INST + NUMINSTADD;
	end
	
	initial begin
		I_MEM_ADDR = 0;
		cnt = 0;
	end

	always@ (I_TEMP) begin
		assign I_MEM_ADDR = I_TEMP;
	end


	CONTROL control ( //ok
		.OPCODE(OPCODE),
		.RSTn(RSTn),
		.CLK(CLK),
		.RD1(RF_RA1),
		.RD2(RF_RA2),
		.PREV_DEST(RDEX), //previous instruction WD
		.PREV_REWR_MUX(MREWR_MUX_EX_MEM_IN),
      .ZERO(ZERO),
		.RF_WE(RF_WE_ID_EX_IN),
		.C_MEM_WEN(C_MEM_WEN_ID_EX_IN),
		.C_MEM_REN(C_MEM_REN_ID_EX_IN),
		.I_MEM_CSN(I_MEM_CSN),
		.C_MEM_CSN(C_MEM_CSN_ID_EX_IN),
		.REWR_MUX(MREWR_MUX_ID_EX_IN),
		.AMUX(AMUX_EX_IN),
		.ISJALR(ISJALR),
		.CONDMUX(CONDMUX),
		.ALU_CONTROL(ALUCONTROL_IN),
		.BMUX(BMUX_EX_IN),
		.IR_WR(IR_WR),
		.PC_WR(PC_WR),
      .FLUSH(FLUSH),
      .NUMINSTADD(NUMINSTADD_ID_EX_IN),
      .PCMUX(PCMUX),
      .USE_RS1_IN(USE_RS1_IN),
      .USE_RS2_IN(USE_RS2_IN),
		.RDFORMUXSIG(RDMUX_ID_EX_IN)
	);

	CONTROLREG pc ( //ok
		.CLK(CLK),
		.WREN(PC_WR & (~CACHE_STALL)),
		.RSTn(RSTn),
		.IN_VAL(PC_IN),
		.OUT_VAL(PC_OUT)
	);

	ALUCONTROL alucontrol( //ok
		.OPCODE(ALUCONTROL_IN),
		.FUNCT3(FUNCT3),
		.FUNCT7(FUNCT7),
		.CONTROLOUT(ALUCONTROL_OUT)
	);

	CACHE cache (
		.CLK(CLK),
		.CSN(C_MEM_CSN),
		.C_MEM_DI(C_MEM_DOUT),
		.C_MEM_WEN(C_MEM_WEN),
		.C_MEM_REN(C_MEM_REN),
		.C_MEM_ADDR(C_MEM_ADDR),
		.D_MEM_DI(D_MEM_DI),
		.D_MEM_DOUT(D_MEM_DOUT),
		.C_MEM_DOUT(C_MEM_DI),
		.D_MEM_ADDR(D_MEM_ADDR),
		.D_MEM_WEN(D_MEM_WEN),
		.D_MEM_BE(D_MEM_BE),
		.D_MEM_CSN(D_MEM_CSN),
		.CACHE_STALL(CACHE_STALL)
	);

    // forwarding
    // ------------------------
    FORWARD forward(
	  .rs1ex(RF_RA1),
	  .rs2ex(RF_RA2),
	  .destex(RDEX),
	  .destmem(RDMEM),
	  .destwb(RDWB),
	  .regwriteex(RF_WE_EX_MEM_IN),
	  .regwritemem(RF_WE_MEM_WB_IN),
	  .regwritewb(RF_WE),
	  .users1(USE_RS1_IN),
	  .users2(USE_RS2_IN),
	  .rs1for(FORWARDMUX1),
	  .rs2for(FORWARDMUX2)
    );

    TWOBITMUX fmux1(
	  .SIGNAL(FORWARDMUX1),
	  .INPUT1(RF_RD1),
	  .INPUT2(ALU_D),
	  .INPUT3(RDFORMUXOUT),
	  .INPUT4(RF_WD),
	  .OUTPUT(FMUX1OUT)
    );

	TWOBITMUX fmux2(
		  .SIGNAL(FORWARDMUX2),
		  .INPUT1(RF_RD2),
		  .INPUT2(ALU_D),
		  .INPUT3(RDFORMUXOUT),
		  .INPUT4(RF_WD),
		  .OUTPUT(FMUX2OUT)
    );

    ONEBITMUX rdformux(
		.SIGNAL(RDFORMUXSIG),
		.INPUT1(C_MEM_DI),
		.INPUT2(ALUOUT_D),
		.OUTPUT(RDFORMUXOUT)
);


    // ------------------------

    EXREG exreg( //ok
        .ALUCONTROLOUT_IN(ALUCONTROL_OUT),
        .AMUX_IN(AMUX_EX_IN),
        .BMUX_IN(BMUX_EX_IN),
        .CLK(CLK),
		  .ENABLE(~CACHE_STALL),
        .ALUCONTROLOUT_OUT(ALUCONTROL_EX_OUT),
        .AMUX_OUT(AMUX_EX_OUT),
        .BMUX_OUT(BMUX_EX_OUT)
    );

    MEMREG id_ex_memreg ( //OK
        .C_MEM_WEN_IN(C_MEM_WEN_ID_EX_IN),
		  .C_MEM_REN_IN(C_MEM_REN_ID_EX_IN),
		  .C_MEM_CSN_IN(C_MEM_CSN_ID_EX_IN),
        .CLK(CLK),
		  .ENABLE(~CACHE_STALL),
		  .C_MEM_CSN_OUT(C_MEM_CSN_EX_MEM_IN),
        .C_MEM_WEN_OUT(C_MEM_WEN_EX_MEM_IN),
		  .C_MEM_REN_OUT(C_MEM_REN_EX_MEM_IN),
    );

    MEMREG ex_mem_memreg ( //ok
        .C_MEM_WEN_IN(C_MEM_WEN_EX_MEM_IN),
		  .C_MEM_REN_IN(C_MEM_REN_EX_MEM_IN),
		  .C_MEM_CSN_IN(C_MEM_CSN_EX_MEM_IN),
        .CLK(CLK),
		  .ENABLE(~CACHE_STALL),
        .C_MEM_WEN_OUT(C_MEM_WEN),
		  .C_MEM_CSN_OUT(C_MEM_CSN),
		  .C_MEM_REN_OUT(C_MEM_REN),
    );

    WBREG id_ex_wbreg( //OK
        .RF_WE_IN(RF_WE_ID_EX_IN),
        .MREWR_MUX_IN(MREWR_MUX_ID_EX_IN),
        .NUMINSTADD_IN(NUMINSTADD_ID_EX_IN),
		  .RD_FOR_MUX_IN(RDMUX_ID_EX_IN),
        .CLK(CLK),
		  .ENABLE(~CACHE_STALL),
        .RF_WE_OUT(RF_WE_EX_MEM_IN),
        .MREWR_MUX_OUT(MREWR_MUX_EX_MEM_IN),
        .NUMINSTADD_OUT(NUMINSTADD_EX_MEM_IN),
		  .RD_FOR_MUX_OUT(RDMUX_EX_MEM_IN)
    );

    WBREG ex_mem_wbreg( //OK
        .RF_WE_IN(RF_WE_EX_MEM_IN), // to 0
        .MREWR_MUX_IN(MREWR_MUX_EX_MEM_IN), //2'b10
        .NUMINSTADD_IN(NUMINSTADD_EX_MEM_IN), //0
		  .RD_FOR_MUX_IN(RDMUX_EX_MEM_IN), // no need 
        .CLK(CLK),
		  .ENABLE(~CACHE_STALL),
		  .RD_FOR_MUX_OUT(RDFORMUXSIG),
        .RF_WE_OUT(RF_WE_MEM_WB_IN),
        .MREWR_MUX_OUT(MREWR_MUX_MEM_WB_IN),
        .NUMINSTADD_OUT(NUMINSTADD_MEM_WB_IN)
    );

    LASTWBREG mem_wb_wbreg( //OK
        .RF_WE_IN(RF_WE_MEM_WB_IN), // to 0
        .MREWR_MUX_IN(MREWR_MUX_MEM_WB_IN), //2'b10
        .NUMINSTADD_IN(NUMINSTADD_MEM_WB_IN), //0
        .CLK(CLK),
		  .ENABLE(~CACHE_STALL),
        .RF_WE_OUT(RF_WE),
        .MREWR_MUX_OUT(MREWR_MUX_SIG),
        .NUMINSTADD_OUT(NUMINSTADD)
    );

	isJALR isjalr ( //OK
		.ISJALR(ISJALR),
		.ALUI_OUTPUT(CONDALU_OUT),
		.OUTPUT(nPC_IN)
	);

	HALT temphalt ( //OK
		.CUR_INST(CUR_INST),
		.NXT_INST(I_MEM_DI),
		._halt(HALT_ID_EX_IN)
	);

	TRANSLATE i_translate( //OK
		.E_ADDR(PC_OUT),
		.T_ADDR(I_TEMP)
	);
	
	TRANSLATE d_translate( //OK
		.E_ADDR(ALUOUT_D),
		.T_ADDR(C_MEM_ADDR)
	);

	///MUX///////////////////////
	TWOBITMUX MREWR_MUX( //OK
		.SIGNAL(MREWR_MUX_SIG),
		.INPUT1(ADDR_OUT),
		.INPUT2(MDRw_OUT),
        .INPUT3(Aout_OUT),
        .INPUT4(ZERO_WB_OUT),
		.OUTPUT(RF_WD)
	);

	ONEBITMUX MAMUX( //OK
		.SIGNAL(AMUX_EX_OUT),
		.INPUT1(PCm_OUT),
		.INPUT2(Ae_OUT),
		.OUTPUT(AMUX_OUT)
	);

	TWOBITMUX MBMUX( //OK
		.SIGNAL(BMUX_EX_OUT),
		.INPUT1(IMM_OUT),
		.INPUT2(32'b00000000000000000000000000000100),
		.INPUT3(32'b00000000000000000000000000000000),
		.INPUT4(Be_OUT),
		.OUTPUT(BMUX_OUT)
	);

	ONEBITMUX MCONDMUX( //OK
		.SIGNAL(CONDMUX),
		.INPUT1(PCr_OUT),
		.INPUT2(RF_RD1),
		.OUTPUT(CONDMUX_OUT)
	);

	ONEBITMUX MPCMUX( //ok
		.SIGNAL(PCMUX),
		.INPUT1(PCALU_OUT),
		.INPUT2(nPC_IN),
		.OUTPUT(PC_IN)
	);
	/////////////////////////////


	///ALU///////////////////////
	ALU CONDALU( //ok
		.OP(4'b0000),
		.A(CONDMUX_OUT),
		.B(IMM_IN),
		.Out(CONDALU_OUT)
	);

	ALU REGALU( //ok
		.OP(ALUCONTROL_EX_OUT),
		.A(AMUX_OUT),
		.B(BMUX_OUT),
		.Out(ALU_D)
	);

	ALU PCALU( //ok
		.OP(4'b0000),
		.A(PC_OUT),
		.B(32'b00000000000000000000000000000100),
		.Out(PCALU_OUT)
	);

	EQUAL equal( //OK
		.OP(ALUCONTROL_OUT),
		.A(FMUX1OUT),
		.B(FMUX2OUT),
		.Zero(ZERO) 
	);
	/////////////////////////////

	//IF/ID pipeline registers//
	CONTROLREG PCr ( //ok
		.CLK(CLK),
		.WREN(PC_WR & (~CACHE_STALL)),
		.RSTn(RSTn),
		.IN_VAL(PC_OUT),
		.OUT_VAL(PCr_OUT)
	);

	INSTREG instreg ( //ok
		.CLK(CLK),
		.INSTRUCTION(I_MEM_DI),
		.IRWRITE(IR_WR & (~CACHE_STALL)),
      .DUMMY(FLUSH),
		.OPCODE(OPCODE),
		.IMMEDIATE(IMM_IN),
		.RS1(RF_RA1),
		.RS2(RF_RA2),
		.FUNCT3(FUNCT3),
		.FUNCT7(FUNCT7),
		.RD(RDID),
		.CUR_INST(CUR_INST)
	);
	/////////////////////////////
	

	CONTROLBIT1REG halt1reg(
		.CLK(CLK),
		.WREN(~CACHE_STALL),
		.RSTn(RSTn),
		.IN_VAL(HALT_ID_EX_IN),
		.OUT_VAL(HALT_EX_MEM_IN)
	);

    CONTROLBIT1REG users1reg(
        .CLK(CLK),
		  .WREN(~CACHE_STALL),
		  .RSTn(RSTn),
        .IN_VAL(USE_RS1_IN),
        .OUT_VAL(USE_RS1_OUT)
    );

    CONTROLBIT1REG users2reg(
        .CLK(CLK),
		  .WREN(~CACHE_STALL),
		  .RSTn(RSTn),
        .IN_VAL(USE_RS2_IN),
        .OUT_VAL(USE_RS2_OUT)
    );

	CONTROLREG imm ( //OK
		.CLK(CLK),
		.WREN(~CACHE_STALL),
		.RSTn(RSTn),
		.IN_VAL(IMM_IN),
		.OUT_VAL(IMM_OUT)
	);

	CONTROLREG PCm( //OK
		.CLK(CLK),
		.WREN(~CACHE_STALL),
		.RSTn(RSTn),
		.IN_VAL(PCr_OUT),
		.OUT_VAL(PCm_OUT)
	);

	CONTROLREG Ae( //OK
		.CLK(CLK),
		.WREN(~CACHE_STALL),
		.RSTn(RSTn),
		.IN_VAL(FMUX1OUT),
		.OUT_VAL(Ae_OUT)
	);

	CONTROLREG Be( //OK
		.CLK(CLK),
		.WREN(~CACHE_STALL),
		.RSTn(RSTn),
		.IN_VAL(FMUX2OUT),
		.OUT_VAL(Be_OUT)
	);

    CONTROLREG id_ex_zero( //OK
        .CLK(CLK),
		  .WREN(~CACHE_STALL),
		  .RSTn(RSTn),
        .IN_VAL({31'b0000000000000000000000000000000, FLUSH}),
        .OUT_VAL(ZERO_EX_MEM)
    );

    CONTROLBIT5REG id_ex_rs1(
        .CLK(CLK),
		  .WREN(~CACHE_STALL),
		  .RSTn(RSTn),
        .IN_VAL(RF_RA1),
        .OUT_VAL(RS1EX)
    );

    CONTROLBIT5REG id_ex_rs2(
        .CLK(CLK),
		  .WREN(~CACHE_STALL),
		  .RSTn(RSTn),
        .IN_VAL(RF_RA2),
        .OUT_VAL(RS2EX)
    );

    CONTROLBIT5REG id_ex_rd(
        .CLK(CLK),
		  .WREN(~CACHE_STALL),
		  .RSTn(RSTn),
        .IN_VAL(RDID),
        .OUT_VAL(RDEX)
    );
	/////////////////////////////
	
	//EX/MEM pipeline registers//
	CONTROLREG aluout ( //ok
		.CLK(CLK),
		.WREN(~CACHE_STALL),
		.RSTn(RSTn),
		.IN_VAL(ALU_D),
		.OUT_VAL(ALUOUT_D)
	);

	CONTROLREG Bm ( //ok
		.CLK(CLK),
		.WREN(~CACHE_STALL),
		.RSTn(RSTn),
		.IN_VAL(Be_OUT),
		.OUT_VAL(C_MEM_DOUT)
	);

    CONTROLREG ex_mem_zero( //ok
        .CLK(CLK),
		  .WREN(~CACHE_STALL),
		  .RSTn(RSTn),
        .IN_VAL(ZERO_EX_MEM),
        .OUT_VAL(ZERO_MEM_WB)
    );

    CONTROLBIT5REG ex_mem_rd(
        .CLK(CLK),
		  .WREN(~CACHE_STALL),
		  .RSTn(RSTn),
        .IN_VAL(RDEX),
        .OUT_VAL(RDMEM)
    );

	CONTROLBIT1REG halt2reg(
		.CLK(CLK),
		.WREN(~CACHE_STALL),
		.RSTn(RSTn),
		.IN_VAL(HALT_EX_MEM_IN),
		.OUT_VAL(HALT_MEM_WB_IN)
	);
	/////////////////////////////

	//MEM_WB pipeline registers//
	REG MDRw ( //OK
		.CLK(CLK),
		.IN_VAL(C_MEM_DI),
		.OUT_VAL(MDRw_OUT)
	);

	BIT1REG halt3reg(
		.CLK(CLK),
		.IN_VAL(HALT_MEM_WB_IN),
		.OUT_VAL(HALT)
	);

	REG Aout ( //OK
		.CLK(CLK),
		.IN_VAL(ALUOUT_D),
		.OUT_VAL(Aout_OUT)
	);

    REG ADDR( //OK
        .CLK(CLK),
        .IN_VAL(ALUOUT_D),
        .OUT_VAL(ADDR_OUT)
    );

    REG mem_wr_zero( //ok
        .CLK(CLK),
        .IN_VAL(ZERO_MEM_WB),
        .OUT_VAL(ZERO_WB_OUT)
    );

    BIT5REG mem_wb_rd(
        .CLK(CLK),
        .IN_VAL(RDMEM),
        .OUT_VAL(RDWB)
    );
	/////////////////////////////



endmodule //
