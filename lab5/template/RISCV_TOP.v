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

	wire [31:0] PC_IN, PC_OUT, IMM_IN, IMM_OUT, Be_OUT, ALU_D, BMUX_OUT, CUR_INST, CONDALU_OUT, nPC_IN, ALUOUT_D, Aout_IN, Aout_OUT, Ae_OUT, AMUX_OUT, PCr_OUT, CONDMUX_OUT, PCALU_OUT, nPC_OUT, PCm_OUT, MDRw_OUT, ADDR_OUT, FMUX1OUT, FMUX2OUT;
    wire [31:0] ZERO_EX_MEM, ZERO_MEM_WB, ZERO_WB_OUT;
	wire [11:0] I_TEMP;
	wire [6:0] OPCODE, ALUCONTROL_IN, FUNCT7;
	wire [3:0] ALUCONTROL_OUT, ALUCONTROL_EX_OUT; 
	wire [2:0] FUNCT3;
	wire [1:0] BMUX_EX_IN, BMUX_EX_OUT;
	wire ISJALR, AMUX_EX_IN, AMUX_EX_OUT, CONDMUX, IR_WR, PC_WR, PREV_REWR_MUX, ZERO, FLUSH;
    wire RF_WE_ID_EX_IN, RF_WE_EX_MEM_IN, RF_WE_MEM_WB_IN;
    wire [1:0] MREWR_MUX_ID_EX_IN, MREWR_MUX_EX_MEM_IN, MREWR_MUX_MEM_WB_IN, MREWR_MUX_SIG;
    wire D_MEM_WEN_ID_EX_IN, D_MEM_WEN_EX_MEM_IN;
    wire [3:0] D_MEM_BE_ID_EX_IN, D_MEM_BE_EX_MEM_IN;
    wire [4:0] RS1EX, RS2EX, RDID, RDEX, RDMEM, RDWB;
    wire [1:0] FORWARDMUX1, FORWARDMUX2;
    wire D_MEM_CSN_ID_EX_IN, D_MEM_CSN_EX_MEM_IN;
    wire NUMINSTADD, NUMINSTADD_ID_EX_IN, NUMINSTADD_EX_MEM_IN, NUMINSTADD_MEM_WB_IN, PCMUX;

    assign RF_WA1 = RDWB;
	assign OUTPUT_PORT = RF_WD;

	initial begin
		NUM_INST <= 0;
	end

	// Only allow for NUM_INST
	always @ (negedge CLK) begin
		if (RSTn) NUM_INST <= NUM_INST + NUMINSTADD;
	end
	
	initial begin
		I_MEM_ADDR = 0;
	end

	always@ (I_TEMP) begin
		assign I_MEM_ADDR = I_TEMP;
	end

	always @ (negedge CLK) begin
        $display("\n");
        $display("--start cycle--");
        $display("IMEMDI: %b", I_MEM_DI);
        /*
        $display("----IF-----");
        $display("IMEMDI: %b", I_MEM_DI);
        $display("-----ID------");
        $display("numinstadd: %b",NUMINSTADD_ID_EX_IN);
        $display("rfra1: %b", RF_RA1);
        $display("rfra2: %b", RF_RA2);
        $display("ALU_D: %b", ALU_D);
        */
        $display("rd: %b", RDID);
        //$display("amux signal: %b",AMUX_EX_OUT);
        //$display("amux out: %b", AMUX_OUT);
        //$display("bmux signal: %b",BMUX_EX_OUT);
        //$display("bmux out: %b", BMUX_OUT);
        //$display("alucontrolout :%b", ALUCONTROL_EX_OUT);
        /*
        $display("regwrite: %b", RF_WE_ID_EX_IN);
        $display("----EX----");
        $display("forwardmux1 : %b",FORWARDMUX1);
        $display("forwardmux2 : %b",FORWARDMUX2);
        $display("fmux1out: %b", FMUX1OUT);
        $display("fmux2out: %b", FMUX2OUT);
        $display("forwardmux1: %b",FORWARDMUX1);
        $display("forwardmux2: %b",FORWARDMUX2);
        */
        $display("destex: %b",RDEX);
        /*
        $display("r1sex: %b",RS1EX);
        $display("r2sex: %b",RS2EX);
        $display("---MEM---");
        */
        $display("destmem: %b",RDMEM);
        $display("----WB----");
        $display("NUMINST: %b",NUM_INST);
        $display("\n");
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
		.D_MEM_BE(D_MEM_BE_ID_EX_IN),
		.RF_WE(RF_WE_ID_EX_IN),
		.D_MEM_WEN(D_MEM_WEN_ID_EX_IN),
		.D_MEM_CSN(D_MEM_CSN_ID_EX_IN),
		.I_MEM_CSN(I_MEM_CSN),
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
        .PCMUX(PCMUX)
	);

	CONTROLREG pc ( //ok
		.CLK(CLK),
		.WREN(PC_WR),
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

    // forwarding
    // ------------------------
    FORWARD forward(
        .rs1ex(RS1EX),
        .rs2ex(RS2EX),
        .destmem(RDMEM),
        .destwb(RDWB),
        .regwritemem(RF_WE_MEM_WB_IN),
        .regwritewb(RF_WE),
        .rs1for(FORWARDMUX1),
        .rs2for(FORWARDMUX2)
    );

    TWOBITMUX fmux1(
        .SIGNAL(FORWARDMUX1),
        .INPUT1(AMUX_OUT),
        .INPUT2(ALUOUT_D),
        .INPUT3(MDRw_OUT),
        .INPUT4(0),
        .OUTPUT(FMUX1OUT)
    );

    TWOBITMUX fmux2(
        .SIGNAL(FORWARDMUX2),
        .INPUT1(BMUX_OUT),
        .INPUT2(ALUOUT_D),
        .INPUT3(MDRw_OUT),
        .INPUT4(0),
        .OUTPUT(FMUX2OUT)
    );


    // ------------------------

    EXREG exreg( //ok
        .ALUCONTROLOUT_IN(ALUCONTROL_OUT),
        .AMUX_IN(AMUX_EX_IN),
        .BMUX_IN(BMUX_EX_IN),
        .CLK(CLK),
        .ALUCONTROLOUT_OUT(ALUCONTROL_EX_OUT),
        .AMUX_OUT(AMUX_EX_OUT),
        .BMUX_OUT(BMUX_EX_OUT)
    );

    MEMREG id_ex_memreg ( //OK
        .D_MEM_WEN_IN(D_MEM_WEN_ID_EX_IN),
        .D_MEM_BE_IN(D_MEM_BE_ID_EX_IN),
        .D_MEM_CSN_IN(D_MEM_CSN_ID_EX_IN),
        .CLK(CLK),
        .D_MEM_WEN_OUT(D_MEM_WEN_EX_MEM_IN),
        .D_MEM_BE_OUT(D_MEM_BE_EX_MEM_IN),
        .D_MEM_CSN_OUT(D_MEM_CSN_EX_MEM_IN)
    );

    MEMREG ex_mem_memreg ( //ok
        .D_MEM_WEN_IN(D_MEM_WEN_EX_MEM_IN),
        .D_MEM_BE_IN(D_MEM_BE_EX_MEM_IN),
        .D_MEM_CSN_IN(D_MEM_CSN_EX_MEM_IN),
        .CLK(CLK),
        .D_MEM_WEN_OUT(D_MEM_WEN),
        .D_MEM_BE_OUT(D_MEM_BE),
        .D_MEM_CSN_OUT(D_MEM_CSN)
    );

    WBREG id_ex_wbreg( //OK
        .RF_WE_IN(RF_WE_ID_EX_IN),
        .MREWR_MUX_IN(MREWR_MUX_ID_EX_IN),
        .NUMINSTADD_IN(NUMINSTADD_ID_EX_IN),
        .CLK(CLK),
        .RF_WE_OUT(RF_WE_EX_MEM_IN),
        .MREWR_MUX_OUT(MREWR_MUX_EX_MEM_IN),
        .NUMINSTADD_OUT(NUMINSTADD_EX_MEM_IN)
    );

    WBREG ex_mem_wbreg( //OK
        .RF_WE_IN(RF_WE_EX_MEM_IN),
        .MREWR_MUX_IN(MREWR_MUX_EX_MEM_IN),
        .NUMINSTADD_IN(NUMINSTADD_EX_MEM_IN),
        .CLK(CLK),
        .RF_WE_OUT(RF_WE_MEM_WB_IN),
        .MREWR_MUX_OUT(MREWR_MUX_MEM_WB_IN),
        .NUMINSTADD_OUT(NUMINSTADD_MEM_WB_IN)
    );

    WBREG mem_wb_wbreg( //OK
        .RF_WE_IN(RF_WE_MEM_WB_IN),
        .MREWR_MUX_IN(MREWR_MUX_MEM_WB_IN),
        .NUMINSTADD_IN(NUMINSTADD_MEM_WB_IN),
        .CLK(CLK),
        .RF_WE_OUT(RF_WE),
        .MREWR_MUX_OUT(MREWR_MUX_SIG),
        .NUMINSTADD_OUT(NUMINSTADD)
    );

	isJALR isjalr ( //OK
		.ISJALR(ISJALR),
		.ALUI_OUTPUT(CONDALU_OUT),
		.OUTPUT(nPC_IN)
	);

	HALT halt ( //OK
		.CUR_INST(CUR_INST),
		.NXT_INST(I_MEM_DI),
		._halt(HALT)
	);

	TRANSLATE i_translate( //OK
		.E_ADDR(PC_OUT),
		.T_ADDR(I_TEMP)
	);
	
	TRANSLATE d_translate( //OK
		.E_ADDR(ALUOUT_D),
		.T_ADDR(D_MEM_ADDR)
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
		.INPUT2(nPC_OUT),
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
		.A(FMUX1OUT),
		.B(FMUX2OUT),
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
		.A(RF_RD1),
		.B(RF_RD2),
		.Zero(ZERO) 
	);
	/////////////////////////////

	//IF/ID pipeline registers//
	REG PCr ( //ok
		.CLK(CLK),
		.IN_VAL(PC_OUT),
		.OUT_VAL(PCr_OUT)
	);

	INSTREG instreg ( //ok
		.CLK(CLK),
		.INSTRUCTION(I_MEM_DI),
		.IRWRITE(IR_WR),
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
	
	//ID/EX pipeline registers//
	REG nPC( //OK
		.CLK(CLK),
		.IN_VAL(nPC_IN),
		.OUT_VAL(nPC_OUT)
	);

	REG imm ( //OK
		.CLK(CLK),
		.IN_VAL(IMM_IN),
		.OUT_VAL(IMM_OUT)
	);

	REG PCm( //OK
		.CLK(CLK),
		.IN_VAL(PCr_OUT),
		.OUT_VAL(PCm_OUT)
	);

	REG Ae( //OK
		.CLK(CLK),
		.IN_VAL(RF_RD1),
		.OUT_VAL(Ae_OUT)
	);

	REG Be( //OK
		.CLK(CLK),
		.IN_VAL(RF_RD2),
		.OUT_VAL(Be_OUT)
	);

    REG id_ex_zero( //OK
        .CLK(CLK),
        .IN_VAL({31'b0000000000000000000000000000000, FLUSH}),
        .OUT_VAL(ZERO_EX_MEM)
    );

    BIT5REG id_ex_rs1(
        .CLK(CLK),
        .IN_VAL(RF_RA1),
        .OUT_VAL(RS1EX)
    );

    BIT5REG id_ex_rs2(
        .CLK(CLK),
        .IN_VAL(RF_RA2),
        .OUT_VAL(RS2EX)
    );

    BIT5REG id_ex_rd(
        .CLK(CLK),
        .IN_VAL(RDID),
        .OUT_VAL(RDEX)
    );
	/////////////////////////////
	
	//EX/MEM pipeline registers//
	REG aluout ( //ok
		.CLK(CLK),
		.IN_VAL(ALU_D),
		.OUT_VAL(ALUOUT_D)
	);

	REG Bm ( //ok
		.CLK(CLK),
		.IN_VAL(Be_OUT),
		.OUT_VAL(D_MEM_DOUT)
	);

    REG ex_mem_zero( //ok
        .CLK(CLK),
        .IN_VAL(ZERO_EX_MEM),
        .OUT_VAL(ZERO_MEM_WB)
    );

    BIT5REG ex_mem_rd(
        .CLK(CLK),
        .IN_VAL(RDEX),
        .OUT_VAL(RDMEM)
    );
	/////////////////////////////

	//MEM_WB pipeline registers//
	REG MDRw ( //OK
		.CLK(CLK),
		.IN_VAL(D_MEM_DI),
		.OUT_VAL(MDRw_OUT)
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
